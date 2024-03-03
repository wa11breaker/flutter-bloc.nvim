# flutter-bloc.nvim
A Neovim plugin for generating bloc and cubit boiler plate code.

[![Preview](https://i.imgur.com/4GtjuPW.gif)](https://github.com/wa11breaker/flutter-bloc.nvim/assets/28669642/de135918-93ce-4157-95ab-9ad5971c45b4
)

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
