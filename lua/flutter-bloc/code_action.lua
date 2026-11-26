local util = require("flutter-bloc.util")

local M = {}

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

local function is_call(selector)
    local child = selector:named_child(0)
    return child ~= nil and child:type() == "argument_part"
end

--- Range { start_row, start_col, end_row, end_col } of the widget constructor
--- call under `node`, e.g. `Text(...)`, `const Text(...)` or `Foo.named(...)`.
function M.widget_range(bufnr, node)
    if not node or not node:type():match("identifier$") then
        return nil
    end
    if not vim.treesitter.get_node_text(node, bufnr):match("^%u") then
        return nil
    end

    local parent = node:parent()
    if parent and parent:type() == "const_object_expression" then
        return { parent:range() }
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
    return { start_row, start_col, end_row, end_col }
end

local FORMAT_COMMAND = "flutter-bloc.format"

local function format(bufnr)
    if #vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/formatting" }) > 0 then
        pcall(vim.cmd.undojoin)
        vim.lsp.buf.format({ bufnr = bufnr, async = false })
    end
end

--- LSP code actions that wrap the widget at (row, col) with each bloc widget.
function M.code_actions(bufnr, row, col)
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "dart")
    if not ok or not parser then
        return {}
    end
    parser:parse()

    local range = M.widget_range(bufnr, parser:named_node_for_range({ row, col, row, col }))
    if not range then
        return {}
    end

    local sr, sc, er, ec = unpack(range)
    local widget = table.concat(vim.api.nvim_buf_get_text(bufnr, sr, sc, er, ec, {}), "\n")
    local uri = vim.uri_from_bufnr(bufnr)

    local actions = {}
    for _, wrapper in ipairs(wrappers) do
        table.insert(actions, {
            title = wrapper.title,
            kind = "refactor.rewrite",
            edit = {
                changes = {
                    [uri] = {
                        {
                            range = {
                                start = { line = sr, character = sc },
                                ["end"] = { line = er, character = ec },
                            },
                            newText = util.render(wrapper.template, { widget = widget }),
                        },
                    },
                },
            },
            command = { title = "Format", command = FORMAT_COMMAND },
        })
    end
    return actions
end

local handlers = {
    initialize = function()
        -- utf-8 positions match tree-sitter byte columns
        return { capabilities = { codeActionProvider = true, positionEncoding = "utf-8" } }
    end,
    ["textDocument/codeAction"] = function(params)
        local pos = params.range.start
        return M.code_actions(vim.uri_to_bufnr(params.textDocument.uri), pos.line, pos.character)
    end,
}

--- Minimal in-process language server that only provides code actions.
local function server(dispatchers)
    local closing, request_id = false, 0

    local function stop()
        if not closing then
            closing = true
            dispatchers.on_exit(0, 15)
        end
    end

    return {
        request = function(method, params, callback)
            request_id = request_id + 1
            vim.schedule(function()
                local handler = handlers[method]
                local ok, result = pcall(handler or function() end, params)
                callback(not ok and { code = -32603, message = tostring(result) } or nil, ok and result or nil)
            end)
            return true, request_id
        end,
        notify = function(method)
            if method == "exit" then
                stop()
            end
            return true
        end,
        is_closing = function()
            return closing
        end,
        terminate = stop,
    }
end

local function attach(bufnr)
    vim.lsp.start({
        name = "flutter-bloc",
        cmd = server,
        commands = {
            [FORMAT_COMMAND] = function(_, ctx)
                format(ctx.bufnr)
            end,
        },
    }, {
        bufnr = bufnr,
        reuse_client = function(client, config)
            return client.name == config.name
        end,
    })
end

function M.setup()
    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("flutter-bloc", { clear = true }),
        pattern = "dart",
        callback = function(args)
            attach(args.buf)
        end,
    })

    -- Dart buffers opened before setup() ran.
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype == "dart" then
            attach(bufnr)
        end
    end
end

return M
