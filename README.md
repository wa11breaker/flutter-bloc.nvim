# flutter-bloc.nvim

A Neovim plugin for generating bloc and cubit boilerplate code with support for code actions.



https://github.com/user-attachments/assets/f9bbe601-cd1c-4ba9-8e80-d73c4060d878


https://github.com/user-attachments/assets/9101c829-bfb2-49b6-9306-6b2fb8785b8c




#### Features

- [x] Generate bloc boiler plate code
- [x] Generate cubit boiler plate code
- [x] Code actions

#### Installation

- With [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'wa11breaker/flutter-bloc.nvim',
  opts = {
    bloc_type = 'default', -- Choose from: 'default', 'equatable', 'freezed'
    use_sealed_classes = false,
    enable_code_actions = true,
  }
}
```

- With [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'wa11breaker/flutter-bloc.nvim',
  config = function()
    require('flutter-bloc').setup({
      bloc_type = 'default', -- Choose from: 'default', 'equatable', 'freezed'
      use_sealed_classes = false,
      enable_code_actions = true,
    })
  end
}
```

## Configuration Options

- `bloc_type`: Specifies the type of BLoC generation

  - `'default'`: Standard BLoC generation
  - `'equatable'`: Uses Equatable for equality comparisons
  - `'freezed'`: Generates code with Freezed immutable classes

- `use_sealed_classes`: Enables or disables sealed classes generation

- `enable_code_actions`: Adds the "Wrap with ..." actions to Neovim's native code actions (`vim.lsp.buf.code_action()`, `gra` by default). Requires the dart tree-sitter parser.

## Usage

### Built-in Commands

Commands

- `:FlutterCreateBloc [dir]` - Create a new Bloc
- `:FlutterCreateCubit [dir]` - Create a new Cubit

The name can be typed in any case (`counter`, `user_profile` or `UserProfile`); classes are generated in PascalCase and files in snake_case.

Code Actions (place the cursor on a widget constructor, e.g. `Text(...)`)

- Wrap with `BlocBuilder`
- Wrap with `BlocSelector`
- Wrap with `BlocListener`
- Wrap with `BlocConsumer`
- Wrap with `BlocProvider`
- Wrap with `RepositoryProvider`

### File Explorers

Run the commands from a file explorer to create the bloc inside the folder under the cursor.
netrw, [oil.nvim](https://github.com/stevearc/oil.nvim), [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua), [neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim) and [mini.files](https://github.com/echasnovski/mini.files) work out of the box.

For other explorers, map their filetype to a function returning the path under the cursor:

```lua
require('flutter-bloc').setup({
  explorers = {
    ['my-explorer'] = function(bufnr)
      return require('my-explorer').get_path_under_cursor()
    end,
  },
})
```

Or pass the folder directly, e.g. from an explorer keymap:

```lua
require('flutter-bloc').create_bloc({ dir = '/path/to/feature' })
```

### Custom Key Mappings

You can add custom key mappings to streamline your workflow:

```lua
-- Create BLoC quickly
vim.keymap.set("n", "<Leader>cfb", "<cmd>lua require('flutter-bloc').create_bloc()<cr>", {
  desc = '[C]reate [F]lutter [B]loc'
})

-- Create Cubit quickly
vim.keymap.set("n", "<Leader>cfc", "<cmd>lua require('flutter-bloc').create_cubit()<cr>", {
  desc = '[C]reate [F]lutter [C]ubit'
})
```

## Documentation

For detailed documentation and advanced usage, refer to the help file:

- `:help flutter-bloc.nvim`
