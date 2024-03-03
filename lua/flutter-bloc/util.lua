local util = {}

util.camel_to_snake = function(camelCase)
    return camelCase:gsub("%u", "_%1"):gsub("^_", ""):lower()
end

util.get_current_buffer_path = function()
    local buf_path = vim.fn.expand("%")
    local buf_directory = buf_path:match("(.*[/\\])")
    return buf_directory
end

return util
