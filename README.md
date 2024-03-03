# flutter-bloc.nvim
A Neovim plugin for generating bloc and cubit boiler plate code.

#### Features
- Generate bloc boiler plate code
- Generate cubit boiler plate code

#### Installation
- With [lazy.nvim](https://github.com/folke/lazy.nvim)
```sh
{
  'wa11breaker/flutter-bloc.nvim'
}
```

- With [packer.nvim](https://github.com/wbthomason/packer.nvim)
```sh
use {
  'wa11breaker/flutter-bloc.nvim'
}
```

#### Usage
This plugin offers two commands out of the box to generate boilerplate code:

- `FlutterCreateBloc`
- `FlutterCreateCubit`

Alternatively, you can create your custom commands.

Example custom key mappings in Lua:

```lua
vim.keymap.set("n", "<Leader>cfb", "<cmd>lua require('flutter-bloc').create_bloc()<cr>", { desc = '[C]reate [F]lutter [B]loc' })
vim.keymap.set("n", "<Leader>cfc", "<cmd>lua require('flutter-bloc').create_cubit()<cr>", { desc = '[C]reate [F]lutter [C]ubit' })
```

#### Documentation
See [`:help flutter-bloc.nvim`](https://github.com/wa11breaker/flutter-bloc.nvim/doc/flutter-bloc.txt)
