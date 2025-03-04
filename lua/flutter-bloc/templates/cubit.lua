local template = require("flutter-bloc.templates.const")
local util = require("flutter-bloc.util")

local M = {}

function M.create_cubit(cubit_name, type)
    if type == "equatable" then
        return M.get_equatable_cubit_template(cubit_name)
    end
    if type == "freezed" then
        return M.get_freezed_cubit_template(cubit_name)
    end
    return M.get_default_cubit_template(cubit_name)
end

M.get_default_cubit_template = function(cubit_name)
    local snake_case_cubit_name = util.camel_to_snake(cubit_name)
    local pascal_case_cubit_name = cubit_name

    return template.default_cubit_template
        :gsub("${snakeCaseCubitName}", snake_case_cubit_name)
        :gsub("${pascalCaseCubitName}", pascal_case_cubit_name)
        :gsub("${cubitState}", pascal_case_cubit_name .. "State")
end

M.get_equatable_cubit_template = function(cubit_name)
    local snake_case_cubit_name = util.camel_to_snake(cubit_name)
    local pascal_case_cubit_name = cubit_name

    return template.equatalbe_cubit_template
        :gsub("${snakeCaseCubitName}", snake_case_cubit_name)
        :gsub("${pascalCaseCubitName}", pascal_case_cubit_name)
        :gsub("${cubitState}", pascal_case_cubit_name .. "State")
end

M.get_freezed_cubit_template = function(cubit_name)
    local snake_case_cubit_name = util.camel_to_snake(cubit_name)
    local pascal_case_cubit_name = cubit_name

    return template.freezed_cubit_template
        :gsub("${snakeCaseCubitName}", snake_case_cubit_name)
        :gsub("${pascalCaseCubitName}", pascal_case_cubit_name)
        :gsub("${cubitState}", pascal_case_cubit_name .. "State")
end

return M
