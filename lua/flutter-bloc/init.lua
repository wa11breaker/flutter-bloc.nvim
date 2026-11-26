local util = require("flutter-bloc.util")
local templates = require("flutter-bloc.templates")

local M = {}

local defaults = {
    bloc_type = "default", -- "default", "equatable" or "freezed"
    use_sealed_classes = false,
    enable_code_actions = true,
    -- filetype -> function(bufnr) returning the path under the cursor
    explorers = require("flutter-bloc.explorers"),
}

M.opts = vim.deepcopy(defaults)

-- Files generated for each kind; the first one is opened afterwards.
local parts = {
    bloc = { "bloc", "state", "event" },
    cubit = { "cubit", "state" },
}

function M.setup(options)
    M.opts = vim.tbl_deep_extend("force", vim.deepcopy(defaults), options or {})

    if not templates.bloc[M.opts.bloc_type] then
        util.notify("Unknown bloc_type '" .. tostring(M.opts.bloc_type) .. "', using 'default'", vim.log.levels.WARN)
        M.opts.bloc_type = "default"
    end

    if M.opts.enable_code_actions then
        require("flutter-bloc.code_action").setup()
    end
end

local function explorer_path(bufnr)
    local resolve = M.opts.explorers[vim.bo[bufnr].filetype]
    if not resolve then
        return nil
    end
    local ok, path = pcall(resolve, bufnr)
    return ok and type(path) == "string" and path ~= "" and path or nil
end

--- Directory to create the bloc in: the explorer item or file in the
--- current buffer, falling back to `lib/`.
local function base_dir()
    local bufnr = vim.api.nvim_get_current_buf()
    local path = explorer_path(bufnr)
    if not path and vim.bo[bufnr].buftype == "" and vim.api.nvim_buf_get_name(bufnr) ~= "" then
        path = vim.api.nvim_buf_get_name(bufnr)
    end
    if not path then
        return vim.fs.joinpath(vim.fn.getcwd(), "lib")
    end
    return vim.fn.isdirectory(path) == 1 and path or vim.fs.dirname(path)
end

local function is_editor_window(win)
    return vim.api.nvim_win_is_valid(win)
        and vim.api.nvim_win_get_config(win).relative == ""
        and vim.bo[vim.api.nvim_win_get_buf(win)].buftype == ""
end

--- Open files in the editing window rather than an explorer sidebar or float.
local function focus_editor_window()
    if is_editor_window(vim.api.nvim_get_current_win()) then
        return
    end
    local previous = vim.fn.win_getid(vim.fn.winnr("#"))
    if previous ~= 0 and is_editor_window(previous) then
        vim.api.nvim_set_current_win(previous)
    end
end

--- Writes the bloc/cubit files for `name` into `dir` and opens the main file.
function M.generate(kind, name, dir)
    local sealed = M.opts.use_sealed_classes
    local vars = {
        name = name,
        file = util.to_snake(name),
        kind = kind,
        class_modifier = sealed and "sealed" or "abstract",
        subclass_modifier = sealed and "final " or "",
    }

    local files, existing = {}, {}
    for _, part in ipairs(parts[kind]) do
        local path = vim.fs.joinpath(dir, vars.file .. "_" .. part .. ".dart")
        table.insert(files, { path = path, template = templates[part][M.opts.bloc_type] })
        if vim.uv.fs_stat(path) then
            table.insert(existing, vim.fs.basename(path))
        end
    end

    if #existing > 0 then
        local msg = "Overwrite " .. table.concat(existing, ", ") .. "?"
        if vim.fn.confirm(msg, "&Yes\n&No", 2) ~= 1 then
            return
        end
    end

    vim.fn.mkdir(dir, "p")
    for _, file in ipairs(files) do
        local ok, err = util.write_file(file.path, util.render(file.template, vars))
        if not ok then
            util.notify("Failed to write " .. file.path .. ": " .. err, vim.log.levels.ERROR)
            return
        end
    end

    focus_editor_window()
    vim.cmd.edit(vim.fn.fnameescape(files[1].path))
end

local function create(kind, opts)
    local label = kind:sub(1, 1):upper() .. kind:sub(2)
    local dir = opts and opts.dir and vim.fs.normalize(vim.fn.expand(opts.dir)) or base_dir()
    local default_path = vim.fn.fnamemodify(vim.fs.joinpath(dir, kind), ":~:.") .. "/"

    vim.ui.input({ prompt = label .. " name: " }, function(input)
        if input == nil then
            return
        end
        local name = util.to_pascal(vim.trim(input))
        if not name:match("^%u%w*$") then
            util.notify("Invalid " .. kind .. " name: '" .. input .. "'", vim.log.levels.ERROR)
            return
        end

        vim.ui.input({ prompt = label .. " path: ", default = default_path, completion = "dir" }, function(path)
            path = path and vim.trim(path) or ""
            if path == "" then
                return
            end
            M.generate(kind, name, vim.fs.normalize(vim.fn.expand(path)))
        end)
    end)
end

--- opts.dir: parent directory for the new bloc (defaults to the explorer
--- item or current file's directory)
function M.create_bloc(opts)
    create("bloc", opts)
end

function M.create_cubit(opts)
    create("cubit", opts)
end

return M
