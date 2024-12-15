local template = require("flutter-bloc.templates.const")
local util = require("flutter-bloc.util")

local M = {}

function M.create_bloc(bloc_name, type)
    if type == "equatable" then
        return M.get_equatable_bloc_template(bloc_name)
    end
    if type == "freezed" then
        return M.get_freezed_bloc_template(bloc_name)
    end
    return M.get_default_bloc_template(bloc_name)
end

M.get_default_bloc_template = function(bloc_name)
    local snake_case_bloc_name = util.camel_to_snake(bloc_name)
    local pascal_case_bloc_name = bloc_name

    return template.default_bloc_template
        :gsub("${snakeCaseBlocName}", snake_case_bloc_name)
        :gsub("${pascalCaseBlocName}", pascal_case_bloc_name)
        :gsub("${blocEvent}", pascal_case_bloc_name .. "Event")
        :gsub("${blocState}", pascal_case_bloc_name .. "State")
end

M.get_equatable_bloc_template = function(bloc_name)
    local snake_case_bloc_name = util.camel_to_snake(bloc_name)
    local pascal_case_bloc_name = bloc_name

    return template.equatalbe_bloc_template
        :gsub("${snakeCaseBlocName}", snake_case_bloc_name)
        :gsub("${pascalCaseBlocName}", pascal_case_bloc_name)
        :gsub("${blocEvent}", pascal_case_bloc_name .. "Event")
        :gsub("${blocState}", pascal_case_bloc_name .. "State")
end

M.get_freezed_bloc_template = function(bloc_name)
    local snake_case_bloc_name = util.camel_to_snake(bloc_name)
    local pascal_case_bloc_name = bloc_name

    return template.bloc_default_template
        :gsub("${snakeCaseBlocName}", snake_case_bloc_name)
        :gsub("${pascalCaseBlocName}", pascal_case_bloc_name)
        :gsub("${blocEvent}", pascal_case_bloc_name .. "Event")
        :gsub("${blocState}", pascal_case_bloc_name .. "State")
end

return M
