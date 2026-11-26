if vim.g.loaded_flutter_bloc then
    return
end
vim.g.loaded_flutter_bloc = true

vim.api.nvim_create_user_command("FlutterCreateBloc", function()
    require("flutter-bloc").create_bloc()
end, { desc = "Create a new Bloc" })

vim.api.nvim_create_user_command("FlutterCreateCubit", function()
    require("flutter-bloc").create_cubit()
end, { desc = "Create a new Cubit" })
