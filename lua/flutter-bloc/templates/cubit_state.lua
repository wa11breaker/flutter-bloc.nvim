local util = require("flutter-bloc.util")
local template = require("flutter-bloc.templates.const")

local M = {}

M.create_state = function(cubit_name, type, use_sealed_classes)
    if type == "equatable" then
        return M.get_equatable_cubit_state(cubit_name, use_sealed_classes)
    end
    if type == "freezed" then
        return M.get_freezed_cubit_state(cubit_name)
    end
    return M.get_default_cubit_state(cubit_name, use_sealed_classes)
end

M.get_default_cubit_state = function(cubit_name, use_sealed_classes)
    local classPrefix = use_sealed_classes and "sealed" or "abstract"
    local snake_case_cubit_name = util.camel_to_snake(cubit_name)
    local pascal_case_cubit_name = cubit_name
    local subclassPrefix = use_sealed_classes and "sealed" or ""

    return template.default_cubit_state
        :gsub("${snakeCaseCubitName}", snake_case_cubit_name)
        :gsub("${pascalCaseCubitName}", pascal_case_cubit_name)
        :gsub("${classPrefix}", classPrefix)
        :gsub("${subclassPrefix}", subclassPrefix)
end

M.get_equatable_cubit_state = function(cubit_name, use_sealed_classes)
    local classPrefix = use_sealed_classes and "sealed" or "abstract"
    local snake_case_cubit_name = util.camel_to_snake(cubit_name)
    local pascal_case_cubit_name = cubit_name
    local subclassPrefix = use_sealed_classes and "sealed" or ""

    return template.equatalbe_cubit_state
        :gsub("${snakeCaseCubitName}", snake_case_cubit_name)
        :gsub("${pascalCaseCubitName}", pascal_case_cubit_name)
        :gsub("${classPrefix}", classPrefix)
        :gsub("${subclassPrefix}", subclassPrefix)
end

M.get_freezed_cubit_state = function(cubit_name)
    local snake_case_cubit_name = util.camel_to_snake(cubit_name)
    local pascal_case_cubit_name = cubit_name

    return template.freezed_cubit_state
        :gsub("${snakeCaseCubitName}", snake_case_cubit_name)
        :gsub("${pascalCaseCubitName}", pascal_case_cubit_name)
end

return M
