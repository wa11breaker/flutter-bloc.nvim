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

    local buf_directory = util.get_current_buffer_path()
    buf_directory = buf_directory .. "cubit/" .. snake_case_cubit_name .. "_cubit/"

    -- Get bloc path from user
    local cubit_path = vim.fn.input("Cubit path: ", buf_directory)
    if cubit_path == "" then
        print('The Cubit path must not be empty')
        return
    end

    -- Create a directory if it doesn't exist
    vim.fn.mkdir(cubit_path, "p")

    local files = {
        snake_case_cubit_name .. "_cubit.dart",
        snake_case_cubit_name .. "_state.dart"
    }

    local templates = {
        bloc_template.create_cubit_template(cubit_name),
        bloc_template.create_cubit_state_template(cubit_name),
    }

    -- Write templates to files
    for i, file in ipairs(files) do
        local file_full_path = cubit_path .. file
        local f = io.open(file_full_path, "w")
        f:write(templates[i])
        f:close()
        vim.cmd("edit " .. file_full_path)
    end

    vim.cmd("edit " .. cubit_path .. files[1])
end

M.create_bloc = function()
    local bloc_name = vim.fn.input("Bloc name: ")
    if bloc_name == "" then
        print('The bloc name must not be empty')
        return
    end
    local snake_case_bloc_name = util.camel_to_snake(bloc_name)

    -- Get the current buffer's path
    local buf_directory = util.get_current_buffer_path()
    buf_directory = buf_directory .. "bloc/" .. snake_case_bloc_name .. "_bloc/"

    -- Get bloc path from user
    local bloc_path = vim.fn.input("Bloc path: ", buf_directory)
    if bloc_path == "" then
        print('The bloc path must not be empty')
        return
    end

    -- Create a directory if it doesn't exist
    vim.fn.mkdir(bloc_path, "p")

    local files = {
        snake_case_bloc_name .. "_bloc.dart",
        snake_case_bloc_name .. "_event.dart",
        snake_case_bloc_name .. "_state.dart"
    }

    local templates = {
        bloc_template.create_bloc_template(bloc_name),
        bloc_template.create_event_template(bloc_name),
        bloc_template.create_bloc_state_template(bloc_name),
    }

    -- Write templates to files
    for i, file in ipairs(files) do
        local file_full_path = bloc_path .. file
        local f = io.open(file_full_path, "w")
        f:write(templates[i])
        f:close()
    end
    vim.cmd("edit " .. bloc_path .. files[1])
end

M.create_cubit_template = function(cubit_name)
    local snake_case_cubit_name = util.camel_to_snake(cubit_name)

    local template = {
        cubit = bloc_template.create_cubit_template(cubit_name),
        state = bloc_template.create_cubit_state_template(cubit_name),
        cubit_name = snake_case_cubit_name .. "_cubit.dart",
        state_name = snake_case_cubit_name .. "_state.dart"
    }

    return template
end

M.create_bloc_template = function(bloc_name)
    local snake_case_bloc_name = util.camel_to_snake(bloc_name)

    local template = {
        bloc = bloc_template.create_bloc_template(bloc_name),
        state = bloc_template.create_bloc_state_template(bloc_name),
        event = bloc_template.create_event_template(bloc_name),
        bloc_name = snake_case_bloc_name .. "_bloc.dart",
        state_name = snake_case_bloc_name .. "_state.dart",
        event_name = snake_case_bloc_name .. "_event.dart"
    }

    return template
end

return M
