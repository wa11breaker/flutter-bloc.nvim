local util = require("flutter-bloc.util")
local template = require("flutter-bloc.templates.const")

local M = {}

M.create_event = function(bloc_name, type, use_sealed_classes)
    if type == "equatable" then
        return M.get_equatable_bloc_event_template(bloc_name, use_sealed_classes)
    end
    if type == "freezed" then
        return M.get_freezed_bloc_event_template(bloc_name, use_sealed_classes)
    end
    return M.get_default_bloc_event_template(bloc_name, use_sealed_classes)
end

M.get_default_bloc_event_template = function(bloc_name, use_sealed_classes)
    local snake_case_bloc_name = util.camel_to_snake(bloc_name)
    local pascal_case_bloc_name = bloc_name
    local classPrefix = use_sealed_classes and "sealed" or "abstract"

    return template.default_bloc_event
        :gsub("${snakeCaseBlocName}", snake_case_bloc_name)
        :gsub("${pascalCaseBlocName}", pascal_case_bloc_name)
        :gsub("${classPrefix}", classPrefix)
end

M.get_equatable_bloc_event_template = function(bloc_name, use_sealed_classes)
    local classPrefix = use_sealed_classes and "sealed" or "abstract"
    local snake_case_bloc_name = util.camel_to_snake(bloc_name)
    local pascal_case_bloc_name = bloc_name

    return template.equatable_bloc_event
        :gsub("${snakeCaseBlocName}", snake_case_bloc_name)
        :gsub("${pascalCaseBlocName}", pascal_case_bloc_name)
        :gsub("${classPrefix}", classPrefix)
end

M.get_freezed_bloc_event_template = function(bloc_name, use_sealed_classes)
    local classPrefix = use_sealed_classes and "sealed" or "abstract"
    local snake_case_bloc_name = util.camel_to_snake(bloc_name)
    local pascal_case_bloc_name = bloc_name

    return template.freezed_bloc_event
        :gsub("${snakeCaseBlocName}", snake_case_bloc_name)
        :gsub("${pascalCaseBlocName}", pascal_case_bloc_name)
        :gsub("${classPrefix}", classPrefix)
end

return M
