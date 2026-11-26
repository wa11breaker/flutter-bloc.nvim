local M = {}

--- "counter", "user_profile" or "UserProfile" -> "Counter", "UserProfile"
function M.to_pascal(str)
    return (str:gsub("[%w]+", function(word)
        return word:sub(1, 1):upper() .. word:sub(2)
    end):gsub("[^%w]", ""))
end

--- "UserProfile" -> "user_profile", "HTTPClient" -> "http_client"
function M.to_snake(str)
    return (str:gsub("(%u+)(%u%l)", "%1_%2"):gsub("([%l%d])(%u)", "%1_%2"):lower())
end

--- Replaces {{key}} placeholders with values from vars.
function M.render(template, vars)
    return (template:gsub("{{([%w_]+)}}", function(key)
        return vars[key] or error("flutter-bloc: missing template variable '" .. key .. "'")
    end))
end

function M.write_file(path, content)
    local file, err = io.open(path, "w")
    if not file then
        return false, err
    end
    file:write(content)
    file:close()
    return true
end

function M.notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = "flutter-bloc" })
end

return M
