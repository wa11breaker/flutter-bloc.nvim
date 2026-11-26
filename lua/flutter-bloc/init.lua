local util = require("flutter-bloc.util")
local templates = require("flutter-bloc.templates")

local M = {}

local defaults = {
    bloc_type = "default", -- "default", "equatable" or "freezed"
    use_sealed_classes = false,
    enable_code_actions = true,
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

local function default_dir(kind)
    local buf_name = vim.api.nvim_buf_get_name(0)
    local base = (buf_name ~= "" and vim.bo.buftype == "") and vim.fs.dirname(buf_name)
        or vim.fs.joinpath(vim.fn.getcwd(), "lib")
    return vim.fn.fnamemodify(vim.fs.joinpath(base, kind), ":~:.") .. "/"
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

    vim.cmd.edit(vim.fn.fnameescape(files[1].path))
end

local function create(kind)
    local label = kind:sub(1, 1):upper() .. kind:sub(2)

    vim.ui.input({ prompt = label .. " name: " }, function(input)
        if input == nil then
            return
        end
        local name = util.to_pascal(vim.trim(input))
        if not name:match("^%u%w*$") then
            util.notify("Invalid " .. kind .. " name: '" .. input .. "'", vim.log.levels.ERROR)
            return
        end

        vim.ui.input({ prompt = label .. " path: ", default = default_dir(kind), completion = "dir" }, function(dir)
            dir = dir and vim.trim(dir) or ""
            if dir == "" then
                return
            end
            M.generate(kind, name, vim.fs.normalize(vim.fn.expand(dir)))
        end)
    end)
end

function M.create_bloc()
    create("bloc")
end

function M.create_cubit()
    create("cubit")
end

return M
