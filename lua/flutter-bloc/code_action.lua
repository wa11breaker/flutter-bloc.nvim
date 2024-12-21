local null_ls = require("null-ls")

local M = {}

function M.setup()
    null_ls.register({
        name = "flutter-bloc",
        method = null_ls.methods.CODE_ACTION,
        filetypes = { "dart" },
        generator = {
            fn = function(_)
                local out = {}
                local node = vim.treesitter.get_node()

                if M.get_fun_predicate(node) then
                    table.insert(out, {
                        title  = "Wrap with BlocBuilder",
                        action = M.wrap_with_bloc_builder,
                    })
                end

                return out
            end,
        },
    })
end

M.get_fun_predicate = function(node)
    if not node then return false end

    if node:type() == "identifier" then return true end
    if node:type() == "type_identifier" then return true end

    return false
end


local get_widget_details = function()
    local bufnr = vim.api.nvim_get_current_buf()

    local node = vim.treesitter.get_node()
    if not node then
        return nil
    end

    local sibling = node:next_sibling()
    if not sibling then
        return nil
    end

    local node_start, start_col = node:start()
    local node_end, node_end_col = node:end_()

    local widget_end, end_col = sibling:end_()

    local widget = vim.api.nvim_buf_get_text(bufnr, node_start, start_col, widget_end, end_col, {})
    local widget_name = vim.api.nvim_buf_get_text(bufnr, node_start, start_col, node_end, node_end_col, {})

    return {
        widget_name = widget_name,
        widget = widget,
        start_row = node_start,
        start_col = start_col,
        end_row = widget_end,
        end_col = end_col,
        bufnr = bufnr,
    }
end

local write_widget = function(widget, template)
    vim.api.nvim_buf_set_text(widget.bufnr, widget.start_row, widget.start_col, widget.end_row, widget.end_col, template)
    vim.cmd("undojoin")
    vim.lsp.buf.format({ async = false, bufnr = widget.bufnr, })
end


M.wrap_with_bloc_builder = function()
    local widget = get_widget_details()
    if not widget then
        vim.notify("Could not find widget to wrap with BlocBuilder")
        return
    end

    local snippet = {
        "BlocBuilder<MyBloc, MyBlocState>(",
        "  builder: (context, state) {",
    }
    for i = 1, #widget.widget do
        if #widget.widget == 1 then
            table.insert(snippet, "    return " .. widget.widget[i] .. ";")
        elseif i == 1 then
            table.insert(snippet, "    return " .. widget.widget[i])
        elseif i == #widget.widget then
            table.insert(snippet, "    " .. widget.widget[i] .. ";")
        else
            table.insert(snippet, "    " .. widget.widget[i])
        end
    end
    table.insert(snippet, "  },")
    table.insert(snippet, ")")

    write_widget(widget, snippet)
end

return M
