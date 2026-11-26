-- Path under the cursor in file explorers, keyed by filetype.
-- Each function returns a file or directory path, or nil.
return {
    netrw = function(bufnr)
        local dir = vim.b[bufnr].netrw_curdir
        if not dir then
            return nil
        end
        local name = vim.api.nvim_get_current_line():gsub("^[|%s]+", "")
        local path = vim.fs.joinpath(dir, name)
        return vim.fn.isdirectory(path) == 1 and path or dir
    end,

    oil = function(bufnr)
        local oil = require("oil")
        local dir = oil.get_current_dir(bufnr)
        local entry = oil.get_cursor_entry()
        if dir and entry and entry.type == "directory" then
            return vim.fs.joinpath(dir, entry.name)
        end
        return dir
    end,

    NvimTree = function()
        local node = require("nvim-tree.api").tree.get_node_under_cursor()
        return node and node.absolute_path
    end,

    ["neo-tree"] = function()
        local state = require("neo-tree.sources.manager").get_state_for_window()
        local node = state and state.tree and state.tree:get_node()
        return node and node.path
    end,

    minifiles = function()
        local entry = require("mini.files").get_fs_entry()
        return entry and entry.path
    end,
}
