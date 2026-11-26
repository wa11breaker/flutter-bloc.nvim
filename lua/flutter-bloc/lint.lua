-- Starts the official bloc language server (`bloc language-server` from
-- bloc_tools) for Dart files and analysis_options.yaml.
local M = {}

local function is_lint_buffer(bufnr)
    local ft = vim.bo[bufnr].filetype
    return ft == "dart"
        or (ft == "yaml" and vim.fs.basename(vim.api.nvim_buf_get_name(bufnr)) == "analysis_options.yaml")
end

function M.setup(cmd)
    -- Optional: only runs when bloc_tools is installed.
    if vim.fn.executable(cmd[1]) ~= 1 then
        return
    end

    local function attach(bufnr)
        if not is_lint_buffer(bufnr) then
            return
        end
        local root = vim.fs.root(bufnr, "pubspec.yaml")
        if root then
            vim.lsp.start({ name = "bloc", cmd = cmd, root_dir = root }, { bufnr = bufnr })
        end
    end

    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("flutter-bloc-lint", { clear = true }),
        pattern = { "dart", "yaml" },
        callback = function(args)
            attach(args.buf)
        end,
    })

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
            attach(bufnr)
        end
    end
end

return M
