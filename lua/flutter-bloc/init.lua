local util = require("flutter-bloc.util")
local bloc_template = require("flutter-bloc.templates")

local M = {}

M.setup = function(opts)
end

M.create_cubit = function()
    local cubit_name = vim.fn.input("Cubit name: ")
    if cubit_name == "" then
        print('The cubit name must not be empty')
        return
    end
    local snake_case_cubit_name = util.camel_to_snake(cubit_name)

    local buf = vim.api.nvim_get_current_buf()
    local file_path = vim.api.nvim_buf_get_name(buf)
    local directory_path = file_path:match("(.*[/\\])")
    directory_path = directory_path .. "cubit/"

    -- Create a directory if it doesn't exist
    vim.fn.mkdir(directory_path, "p")

    local files = {
        snake_case_cubit_name .. "_bloc.dart",
        snake_case_cubit_name .. "_state.dart"
    }

    local templates = {
        bloc_template.create_cubit_template(cubit_name),
        bloc_template.create_state_template(cubit_name),
    }

    -- Write templates to files
    for i, file in ipairs(files) do
        local file_full_path = directory_path .. file
        local f = io.open(file_full_path, "w")
        f:write(templates[i])
        f:close()
        vim.cmd("edit " .. file_full_path)
    end

    vim.cmd("edit " .. directory_path .. files[1])
end

M.create_bloc = function(opts)
    local bloc_name = vim.fn.input("Bloc name: ")
    if bloc_name == "" then
        print('The bloc name must not be empty')
        return
    end
    local snake_case_bloc_name = util.camel_to_snake(bloc_name)

    local buf = vim.api.nvim_get_current_buf()
    local file_path = vim.api.nvim_buf_get_name(buf)
    local directory_path = file_path:match("(.*[/\\])")
    directory_path = directory_path .. "bloc/"

    -- Create a directory if it doesn't exist
    vim.fn.mkdir(directory_path, "p")

    local files = {
        snake_case_bloc_name .. "_bloc.dart",
        snake_case_bloc_name .. "_event.dart",
        snake_case_bloc_name .. "_state.dart"
    }

    local templates = {
        bloc_template.create_bloc_template(bloc_name),
        bloc_template.create_event_template(bloc_name),
        bloc_template.create_state_template(bloc_name),
    }

    -- Write templates to files
    for i, file in ipairs(files) do
        local file_full_path = directory_path .. file
        local f = io.open(file_full_path, "w")
        f:write(templates[i])
        f:close()
        vim.cmd("edit " .. file_full_path)
    end

    vim.cmd("edit " .. directory_path .. files[1])
end

return M
