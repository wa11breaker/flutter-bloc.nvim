local M = {}

M.camel_to_snake = function(camelCase)
    return camelCase:gsub("%u", "_%1"):gsub("^_", ""):lower()
end

M.get_current_buffer_path = function()
    local buf_path = vim.fn.expand("%")
    local buf_directory = buf_path:match("(.*[/\\])")
    return buf_directory
end


function M.write_file(filepath, content)
    local file = io.open(filepath, 'w')
    if file then
        file:write(content)
        file:close()
    end
end

return M
