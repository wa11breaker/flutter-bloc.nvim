# flutter-bloc.nvim
A Neovim plugin for generating bloc and cubit boilerplate code with support for code actions.


[![Preview](https://i.imgur.com/4GtjuPW.gif)](https://github.com/wa11breaker/flutter-bloc.nvim/assets/28669642/de135918-93ce-4157-95ab-9ad5971c45b4
)

#### Features
- [x] Generate bloc boiler plate code
- [x] Generate cubit boiler plate code
- [x] Code actions

#### Installation
- With [lazy.nvim](https://github.com/folke/lazy.nvim)


```lua
{
  'wa11breaker/flutter-bloc.nvim',
  dependencies = {
      "nvimtools/none-ls.nvim", -- Required for code actions
  },
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
  requires = {
    'nvimtools/none-ls.nvim',
  },
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

## Usage

### Built-in Commands

Commands

- `:FlutterCreateBloc` - Create a new Bloc
- `:FlutterCreateCubit` - Create a new Cubit

Code Actions
- Wrap with `BlocBuilder`
- Wrap with `BlocSelector`
- Wrap with `BlocListener`
- Wrap with `BlocConsumer`
- Wrap with `BlocProvider`
- Wrap with `RepositoryProvider`


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
