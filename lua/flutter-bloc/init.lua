local util = require("flutter-bloc.util")

local M = {}

M.opts = {}

local defaults = {
    bloc_type = 'default', -- 'default', 'equatable', 'freezed'
    use_sealed_classes = false,
}

function M.setup(options)
    -- Merge user options with defaults
    M.opts = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

function M.create_bloc()
    local bloc_name = vim.fn.input("Bloc name: ")
    if bloc_name == "" then
        print('The bloc name must not be empty')
        return
    end

    -- Get bloc path from user
    local buf_directory = util.get_current_buffer_path()
    local bloc_path = vim.fn.input("Bloc path: ", buf_directory .. 'bloc/')
    if bloc_path == "" then
        print('The bloc path must not be empty')
        return
    end

    local snake_case_bloc_name = util.camel_to_snake(bloc_name)
    vim.fn.mkdir(bloc_path, "p")

    local bloc_type = M.opts.blocType
    local use_sealed_classes = M.opts.use_sealed_classes
    local templates = {
        require("flutter-bloc.templates.bloc").create_bloc(bloc_name, bloc_type),
        require("flutter-bloc.templates.bloc-state").create_state(bloc_name, bloc_type, use_sealed_classes),
        require("flutter-bloc.templates.bloc-event").create_event(bloc_name, bloc_type, use_sealed_classes),
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

return M
