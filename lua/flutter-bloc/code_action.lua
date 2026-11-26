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

function M.wrap(bufnr, range, template)
    local sr, sc, er, ec = unpack(range)
    local widget = table.concat(vim.api.nvim_buf_get_text(bufnr, sr, sc, er, ec, {}), "\n")
    local lines = vim.split(util.render(template, { widget = widget }), "\n")

    vim.api.nvim_buf_set_text(bufnr, sr, sc, er, ec, lines)

    if #vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/formatting" }) > 0 then
        pcall(vim.cmd.undojoin)
        vim.lsp.buf.format({ bufnr = bufnr, async = false })
    end
end

function M.setup()
    local ok, null_ls = pcall(require, "null-ls")
    if not ok then
        util.notify("Code actions require nvimtools/none-ls.nvim", vim.log.levels.WARN)
        return
    end
    if null_ls.is_registered("flutter-bloc") then
        return
    end

    null_ls.register({
        name = "flutter-bloc",
        method = null_ls.methods.CODE_ACTION,
        filetypes = { "dart" },
        generator = {
            fn = function(params)
                local ok_node, node = pcall(vim.treesitter.get_node, {
                    bufnr = params.bufnr,
                    pos = { params.row - 1, params.col },
                })
                local range = ok_node and M.widget_range(params.bufnr, node)
                if not range then
                    return
                end

                local actions = {}
                for _, wrapper in ipairs(wrappers) do
                    table.insert(actions, {
                        title = wrapper.title,
                        action = function()
                            M.wrap(params.bufnr, range, wrapper.template)
                        end,
                    })
                end
                return actions
            end,
        },
    })
end

return M
