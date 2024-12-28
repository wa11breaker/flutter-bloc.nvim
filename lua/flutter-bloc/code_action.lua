local null_ls = require("null-ls")

local M = {}

local bloc_builder_template = {
    "BlocBuilder<MyBloc, MyBlocState>(",
    "  builder: (context, state) {",
    "    return %s;",
    "  },",
    ")"
}
local bloc_listener_template = {
    "BlocListener<MyBloc, MyBlocState>(",
    "  listener: (context, state) {",
    "    %s;",
    "  },",
    ")"
}
local bloc_provider_template = {
    "BlocProvider<MyBloc>(",
    "  create: (context) => MyBloc(),",
    "  child: %s,",
    ")"
}
local bloc_selector_template = {
    "BlocSelector<MyBloc, MyBlocState, MyType>(",
    "  selector: (state) {",
    "    return state;",
    "  },",
    "  builder: (context, state) {",
    "    return %s;",
    "  },",
    ")"
}
local bloc_consumer_template = {
    "BlocConsumer<MyBloc, MyBlocState>(",
    "  listener: (context, state) {",
    "  },",
    "  builder: (context, state) {",
    "    return %s;",
    "  },",
    ")"
}

local function is_valid_node(node)
    if not node then return false end

    return node:type() == "identifier" or node:type() == "type_identifier"
end

local function get_node_text(bufnr, node)
    if not node then return nil end
    local sibling = node:next_sibling()
    if not sibling then return nil end

    local start_row, start_col = node:start()
    local end_row, end_col = sibling:end_()

    return vim.api.nvim_buf_get_text(
        bufnr, start_row,
        start_col, end_row,
        end_col, {}
    )
end

local get_widget_details = function()
    local bufnr = vim.api.nvim_get_current_buf()

    local node = vim.treesitter.get_node()
    if not node then return nil end

    local sibling = node:next_sibling()
    if not sibling then return nil end

    local start_row, start_col = node:start()
    local end_row, end_col = sibling:end_()

    return {
        widget_name = vim.api.nvim_buf_get_text(
            bufnr, start_row,
            start_col, end_row,
            end_col, {}
        ),
        widget_text = get_node_text(bufnr, node),
        range = {
            start_row = start_row,
            start_col = start_col,
            end_row = end_row,
            end_col = end_col
        },
        bufnr = bufnr,
    }
end

local write_widget = function(wrapped_widget, widget)
    vim.api.nvim_buf_set_text(
        widget.bufnr, widget.range.start_row,
        widget.range.start_col, widget.range.end_row,
        widget.range.end_col, wrapped_widget
    )
    vim.cmd("undojoin")
    vim.lsp.buf.format({ async = false, bufnr = widget.bufnr, })
end

local function format_widget_content(widget_text)
    -- Is its a single line widget
    if #widget_text == 1 then
        return widget_text[1]
    end

    -- For multi line widget
    local result = {}
    for i, line in ipairs(widget_text) do
        if i == 1 then
            table.insert(result, line)
        else
            table.insert(result, "    " .. line)
        end
    end

    return table.concat(result, " ")
end

local function apply_template(template, widget_content)
    local result = {}
    for _, line in ipairs(template) do
        if line:find("%%s") then
            table.insert(result, string.format(line, widget_content))
        else
            table.insert(result, line)
        end
    end
    return result
end

local wrap_with_bloc_builder = function()
    local widget = get_widget_details()
    if not widget then return end

    local formatted_content = format_widget_content(widget.widget_text)
    local wrapped_widget = apply_template(bloc_builder_template, formatted_content)
    write_widget(wrapped_widget, widget)
end

local wrap_with_bloc_listener = function()
    local widget = get_widget_details()
    if not widget then return end

    local formatted_content = format_widget_content(widget.widget_text)
    local wrapped_widget = apply_template(bloc_listener_template, formatted_content)
    write_widget(wrapped_widget, widget)
end

local wrap_with_bloc_provider = function()
    local widget = get_widget_details()
    if not widget then return end

    local formatted_content = format_widget_content(widget.widget_text)
    local wrapped_widget = apply_template(bloc_provider_template, formatted_content)
    write_widget(wrapped_widget, widget)
end

local wrap_with_bloc_selector = function()
    local widget = get_widget_details()
    if not widget then return end

    local formatted_content = format_widget_content(widget.widget_text)
    local wrapped_widget = apply_template(bloc_selector_template, formatted_content)
    write_widget(wrapped_widget, widget)
end

local wrap_with_bloc_consumer = function()
    local widget = get_widget_details()
    if not widget then return end

    local formatted_content = format_widget_content(widget.widget_text)
    local wrapped_widget = apply_template(bloc_consumer_template, formatted_content)
    write_widget(wrapped_widget, widget)
end

function M.setup()
    null_ls.register({
        name = "flutter-bloc",
        method = null_ls.methods.CODE_ACTION,
        filetypes = { "dart" },
        generator = {
            fn = function(_)
                local out = {}
                local node = vim.treesitter.get_node()

                if is_valid_node(node) then
                    table.insert(out, {
                        title  = "Wrap with BlocBuilder",
                        action = wrap_with_bloc_builder,
                    })
                    table.insert(out, {
                        title  = "Wrap with BlocListener",
                        action = wrap_with_bloc_listener,
                    })
                    table.insert(out, {
                        title  = "Wrap with BlocProvider",
                        action = wrap_with_bloc_provider,
                    })
                    table.insert(out, {
                        title  = "Wrap with BlocSelector",
                        action = wrap_with_bloc_selector,
                    })
                    table.insert(out, {
                        title  = "Wrap with BlocConsumer",
                        action = wrap_with_bloc_consumer,
                    })
                end

                return out
            end,
        },
    })
end

return M
