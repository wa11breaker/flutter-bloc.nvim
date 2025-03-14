local util = require("flutter-bloc.util")
local code_action = require("flutter-bloc.code_action")

local M = {}

M.opts = {}

local defaults = {
    bloc_type = 'default', -- 'default', 'equatable', 'freezed'
    use_sealed_classes = false,
    enable_code_actions = true,
}

function M.setup(options)
    -- Merge user options with defaults
    M.opts = vim.tbl_deep_extend("force", {}, defaults, options or {})
    if M.opts.enable_code_actions then
        code_action.setup()
    end
end

function M.create_bloc()
    local bloc_name = vim.fn.input("Bloc name: ")
    if bloc_name == "" then
        print('The bloc name must not be empty')
        return
    end

    -- Get block path from user
    -- Get buffer directory; if no buffer is open, get the curren
    local current_directory = util.get_current_buffer_path()
    if current_directory == nil then
        current_directory = vim.fn.getcwd() .. '/lib/'
    end

    local bloc_path = vim.fn.input("Bloc path: ", current_directory .. 'bloc/')
    if bloc_path == "" then
        print('The bloc path must not be empty')
        return
    end

    local snake_case_bloc_name = util.camel_to_snake(bloc_name)
    vim.fn.mkdir(bloc_path, "p")

    local bloc_type = M.opts.bloc_type
    local use_sealed_classes = M.opts.use_sealed_classes
    local templates = {
        require("flutter-bloc.templates.bloc").create_bloc(bloc_name, bloc_type),
        require("flutter-bloc.templates.bloc_state").create_state(bloc_name, bloc_type, use_sealed_classes),
        require("flutter-bloc.templates.bloc_event").create_event(bloc_name, bloc_type, use_sealed_classes),
    }

    local files = {
        snake_case_bloc_name .. "_bloc.dart",
        snake_case_bloc_name .. "_state.dart",
        snake_case_bloc_name .. "_event.dart",
    }

    for i, file in ipairs(files) do
        local file_full_path = bloc_path .. file
        local f = io.open(file_full_path, "w")
        if not f then
            print("Error creating file: " .. file_full_path)
            return
        end

        f:write(templates[i])
        f:close()
    end

    -- Open bloc file after creating it
    vim.cmd("edit " .. bloc_path .. files[1])
end

function M.create_cubit()
    local cubit_name = vim.fn.input("Cubit name: ")
    if cubit_name == "" then
        print('The cubit name must not be empty')
        return
    end

    -- Get block path from user
    -- Get buffer directory; if no buffer is open, get the curren
    local current_directory = util.get_current_buffer_path()
    if current_directory == nil then
        current_directory = vim.fn.getcwd() .. '/lib/'
    end

    local cubit_pat = vim.fn.input("Cubit path: ", current_directory .. 'cubit/')
    if cubit_pat == "" then
        print('The cubit path must not be empty')
        return
    end

    local snake_case_cubit_name = util.camel_to_snake(cubit_name)
    vim.fn.mkdir(cubit_pat, "p")

    local bloc_type = M.opts.bloc_type
    local use_sealed_classes = M.opts.use_sealed_classes
    local templates = {
        require("flutter-bloc.templates.cubit").create_cubit(cubit_name, bloc_type),
        require("flutter-bloc.templates.cubit_state").create_state(cubit_name, bloc_type, use_sealed_classes),
    }

    local files = {
        snake_case_cubit_name .. "_cubit.dart",
        snake_case_cubit_name .. "_state.dart",
    }

    for i, file in ipairs(files) do
        local file_full_path = cubit_pat .. file
        local f = io.open(file_full_path, "w")
        if not f then
            print("Error creating file: " .. file_full_path)
            return
        end

        f:write(templates[i])
        f:close()
    end

    -- Open bloc file after creating it
    vim.cmd("edit " .. cubit_pat .. files[1])
end

return M
