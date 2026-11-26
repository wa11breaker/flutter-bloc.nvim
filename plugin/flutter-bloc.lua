if vim.g.loaded_flutter_bloc then
    return
end
vim.g.loaded_flutter_bloc = true

vim.api.nvim_create_user_command("FlutterCreateBloc", function(args)
    require("flutter-bloc").create_bloc({ dir = args.args ~= "" and args.args or nil })
end, { nargs = "?", complete = "dir", desc = "Create a new Bloc" })

vim.api.nvim_create_user_command("FlutterCreateCubit", function(args)
    require("flutter-bloc").create_cubit({ dir = args.args ~= "" and args.args or nil })
end, { nargs = "?", complete = "dir", desc = "Create a new Cubit" })
