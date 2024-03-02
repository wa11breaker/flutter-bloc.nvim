local util = {}

util.camel_to_snake = function(camelCase)
    return camelCase:gsub("%u", "_%1"):gsub("^_", ""):lower()
end

return util
