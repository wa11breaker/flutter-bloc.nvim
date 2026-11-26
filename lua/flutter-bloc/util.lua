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

--- Snippet body as plain text, with placeholders filled in with their defaults.
function M.snippet_preview(body)
    -- Set escaped characters aside so they aren't read as tabstops.
    local escaped = {}
    body = body:gsub("\\([\\$}])", function(char)
        table.insert(escaped, char)
        return "\0" .. #escaped .. "\0"
    end)

    local defaults = {}
    body = body:gsub("%${(%d+):([^}]*)}", function(n, default)
        defaults[n] = default
        return default
    end)
    body = body:gsub("%${(%d+)}", function(n)
        return defaults[n] or ""
    end)
    body = body:gsub("%$%d+", "")

    return (body:gsub("%z(%d+)%z", function(i)
        return escaped[tonumber(i)]
    end))
end

--- Escapes text so a snippet inserts it literally.
function M.snippet_escape(text)
    return (text:gsub("[\\$}]", "\\%0"))
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
