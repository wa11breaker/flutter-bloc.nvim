local util = require("flutter-bloc.util")

local M = {}

M.FORMAT_COMMAND = "flutter-bloc.format"

local wrappers = {
    {
        title = "Wrap with BlocBuilder",
        template = [[
BlocBuilder<MyBloc, MyBlocState>(
  builder: (context, state) {
    return {{widget}};
  },
)]],
    },
    {
        title = "Wrap with BlocSelector",
        template = [[
BlocSelector<MyBloc, MyBlocState, MyType>(
  selector: (state) {
    return state;
  },
  builder: (context, state) {
    return {{widget}};
  },
)]],
    },
    {
        title = "Wrap with BlocListener",
        template = [[
BlocListener<MyBloc, MyBlocState>(
  listener: (context, state) {},
  child: {{widget}},
)]],
    },
    {
        title = "Wrap with BlocConsumer",
        template = [[
BlocConsumer<MyBloc, MyBlocState>(
  listener: (context, state) {},
  builder: (context, state) {
    return {{widget}};
  },
)]],
    },
    {
        title = "Wrap with BlocProvider",
        template = [[
BlocProvider(
  create: (context) => MyBloc(),
  child: {{widget}},
)]],
    },
    {
        title = "Wrap with RepositoryProvider",
        template = [[
RepositoryProvider(
  create: (context) => MyRepository(),
  child: {{widget}},
)]],
    },
}

-- Widgets that can be converted to their Multi* version, and the list argument it takes.
local multi = {
    BlocProvider = { name = "MultiBlocProvider", list = "providers" },
    BlocListener = { name = "MultiBlocListener", list = "listeners" },
    RepositoryProvider = { name = "MultiRepositoryProvider", list = "providers" },
}

local function text(bufnr, sr, sc, er, ec)
    return table.concat(vim.api.nvim_buf_get_text(bufnr, sr, sc, er, ec, {}), "\n")
end

local function node_text(bufnr, node)
    return vim.treesitter.get_node_text(node, bufnr)
end

local function child_of_type(node, type)
    for child in node:iter_children() do
        if child:type() == type then
            return child
        end
    end
end

local function is_call(selector)
    local child = selector:named_child(0)
    return child ~= nil and child:type() == "argument_part"
end

--- Constructor call starting at `node`, e.g. `Text(...)`, `const Text(...)`,
--- `Foo.named(...)` or `Foo<T>(...)`. Returns { name, range, callee, args }:
--- `callee` is where the callee text starts, `args` the `arguments` node.
local function find_call(bufnr, node)
    if not node or not node:type():match("identifier$") then
        return nil
    end
    local name = node_text(bufnr, node)
    if not name:match("^%u") then
        return nil
    end

    local parent = node:parent()
    if parent and parent:type() == "const_object_expression" then
        return {
            name = name,
            range = { parent:range() },
            callee = { node:start() },
            args = child_of_type(parent, "arguments"),
            const = true,
        }
    end

    -- Skip selectors like `.named` until the call's argument list.
    local last = node:next_named_sibling()
    while last and last:type() == "selector" and not is_call(last) do
        last = last:next_named_sibling()
    end
    if not (last and last:type() == "selector") then
        return nil
    end

    local start_row, start_col = node:start()
    local end_row, end_col = last:end_()
    return {
        name = name,
        range = { start_row, start_col, end_row, end_col },
        callee = { start_row, start_col },
        args = child_of_type(last:named_child(0), "arguments"),
    }
end

--- `BlocProvider(a, child: BlocProvider(b, child: X))` ->
--- `MultiBlocProvider(providers: [BlocProvider(a), BlocProvider(b)], child: X)`
local function to_multi(bufnr, call)
    local target = multi[call.name]
    local items, child = {}, nil

    while call do
        local args, child_arg = {}, nil
        for arg in call.args:iter_children() do
            if arg:named() then
                local label = arg:type() == "named_argument" and arg:named_child(0)
                if label and node_text(bufnr, label) == "child:" then
                    child_arg = arg
                else
                    table.insert(args, node_text(bufnr, arg))
                end
            end
        end
        if not child_arg then
            return nil
        end

        local args_row, args_col = call.args:start()
        local callee = text(bufnr, call.callee[1], call.callee[2], args_row, args_col)
        table.insert(items, callee .. "(" .. table.concat(args, ", ") .. ")")

        -- Flatten a directly nested widget of the same kind.
        local value = child_arg:named_child(1)
        local nested = value and find_call(bufnr, value)
        local _, _, child_end_row, child_end_col = child_arg:range()
        if nested and not nested.const and nested.name == call.name
            and nested.range[3] == child_end_row and nested.range[4] == child_end_col then
            call = nested
        else
            local sr, sc = value:start()
            child = text(bufnr, sr, sc, child_end_row, child_end_col)
            call = nil
        end
    end

    return table.concat({
        target.name .. "(",
        "  " .. target.list .. ": [",
        "    " .. table.concat(items, ",\n    ") .. ",",
        "  ],",
        "  child: " .. child .. ",",
        ")",
    }, "\n")
end

local function action(bufnr, title, range, new_text)
    local sr, sc, er, ec = unpack(range)
    return {
        title = title,
        kind = "refactor.rewrite",
        edit = {
            changes = {
                [vim.uri_from_bufnr(bufnr)] = {
                    {
                        range = { start = { line = sr, character = sc }, ["end"] = { line = er, character = ec } },
                        newText = new_text,
                    },
                },
            },
        },
        command = { title = "Format", command = M.FORMAT_COMMAND },
    }
end

--- LSP code actions for the widget at (row, col).
function M.code_actions(bufnr, row, col)
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "dart")
    if not ok or not parser then
        return {}
    end
    parser:parse()

    local call = find_call(bufnr, parser:named_node_for_range({ row, col, row, col }))
    if not call then
        return {}
    end

    local actions = {}
    local widget = text(bufnr, unpack(call.range))
    for _, wrapper in ipairs(wrappers) do
        local wrapped = util.render(wrapper.template, { widget = widget })
        table.insert(actions, action(bufnr, wrapper.title, call.range, wrapped))
    end

    local converted = multi[call.name] and not call.const and call.args and to_multi(bufnr, call)
    if converted then
        table.insert(actions, 1, action(bufnr, "Convert to " .. multi[call.name].name, call.range, converted))
    end
    return actions
end

function M.format(bufnr)
    if #vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/formatting" }) > 0 then
        pcall(vim.cmd.undojoin)
        vim.lsp.buf.format({ bufnr = bufnr, async = false })
    end
end

return M
