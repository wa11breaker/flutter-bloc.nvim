local util = require("flutter-bloc.util")
local templates = require("flutter-bloc.templates")

local M = {}

local defaults = {
    bloc_type = "auto", -- "auto" (from pubspec.yaml), "default", "equatable" or "freezed"
    use_sealed_classes = false,
    create_directory = true, -- create files inside a bloc/ or cubit/ folder
    -- Per-kind overrides: { type = ..., use_sealed_classes = ..., create_directory = ... }
    bloc = {},
    cubit = {},
    enable_code_actions = true,
    enable_snippets = true,
    lint = {
        enabled = true, -- only starts when the `bloc` CLI (bloc_tools) is installed
        cmd = { "bloc", "language-server" },
    },
    -- filetype -> function(bufnr) returning the path under the cursor
    explorers = require("flutter-bloc.explorers"),
}

M.opts = vim.deepcopy(defaults)

-- Files generated for each kind; the first one is opened afterwards.
local parts = {
    bloc = { "bloc", "state", "event" },
    cubit = { "cubit", "state" },
}

local function valid_type(type)
    return type == "auto" or templates.bloc[type] ~= nil
end

function M.setup(options)
    M.opts = vim.tbl_deep_extend("force", vim.deepcopy(defaults), options or {})

    for _, opts in ipairs({ M.opts, M.opts.bloc, M.opts.cubit }) do
        local key = opts == M.opts and "bloc_type" or "type"
        if opts[key] ~= nil and not valid_type(opts[key]) then
            util.notify("Unknown " .. key .. " '" .. tostring(opts[key]) .. "', using 'auto'", vim.log.levels.WARN)
            opts[key] = "auto"
        end
    end

    if M.opts.enable_code_actions or M.opts.enable_snippets then
        require("flutter-bloc.lsp").setup(M.opts)
    end
    if M.opts.lint.enabled then
        require("flutter-bloc.lint").setup(M.opts.lint.cmd)
    end
end

--- Settings for "bloc" or "cubit": per-kind overrides, then the shared options.
local function kind_opts(kind)
    local overrides = M.opts[kind] or {}
    local function pick(key, shared_key)
        if overrides[key] ~= nil then
            return overrides[key]
        end
        return M.opts[shared_key or key]
    end
    return {
        type = pick("type", "bloc_type"),
        use_sealed_classes = pick("use_sealed_classes"),
        create_directory = pick("create_directory"),
    }
end

--- Template type from the project's pubspec.yaml dependencies.
local function detect_type(dir)
    local root = vim.fs.root(dir, "pubspec.yaml")
    local file = root and io.open(vim.fs.joinpath(root, "pubspec.yaml"))
    if not file then
        return "default"
    end
    local pubspec = file:read("*a")
    file:close()

    if pubspec:match("\n%s+freezed_annotation:") or pubspec:match("\n%s+freezed:") then
        return "freezed"
    end
    if pubspec:match("\n%s+equatable:") then
        return "equatable"
    end
    return "default"
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
    local opts = kind_opts(kind)
    local type = opts.type == "auto" and detect_type(dir) or opts.type
    local sealed = opts.use_sealed_classes
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
        table.insert(files, { path = path, template = templates[part][type] })
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
    if kind_opts(kind).create_directory then
        dir = vim.fs.joinpath(dir, kind)
    end
    local default_path = vim.fn.fnamemodify(dir, ":~:.") .. "/"

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
