# flutter-bloc.nvim

A Neovim plugin for generating bloc and cubit boilerplate code with support for code actions.



https://github.com/user-attachments/assets/f9bbe601-cd1c-4ba9-8e80-d73c4060d878


https://github.com/user-attachments/assets/9101c829-bfb2-49b6-9306-6b2fb8785b8c




#### Features

- [x] Generate bloc boiler plate code
- [x] Generate cubit boiler plate code
- [x] Code actions (wrap with bloc widgets, convert to Multi* widgets)
- [x] Snippets
- [x] Create from file explorers
- [x] [Bloc lint](https://bloclibrary.dev/lint/) diagnostics

#### Installation

- With [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'wa11breaker/flutter-bloc.nvim',
  opts = {
    bloc_type = 'auto', -- Choose from: 'auto', 'default', 'equatable', 'freezed'
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
      bloc_type = 'auto', -- Choose from: 'auto', 'default', 'equatable', 'freezed'
      use_sealed_classes = false,
      enable_code_actions = true,
    })
  end
}
```

## Configuration Options

- `bloc_type`: Specifies the type of BLoC generation

  - `'auto'` (default): Picks `freezed` or `equatable` from the project's `pubspec.yaml` dependencies, otherwise `default`
  - `'default'`: Standard BLoC generation
  - `'equatable'`: Uses Equatable for equality comparisons
  - `'freezed'`: Generates code with Freezed immutable classes

- `use_sealed_classes`: Enables or disables sealed classes generation

- `create_directory`: Creates the files inside a `bloc/` or `cubit/` folder (default `true`)

- `bloc` / `cubit`: Per-kind overrides of the options above, e.g. `cubit = { type = 'equatable', use_sealed_classes = true, create_directory = false }`

- `enable_code_actions`: Adds the bloc actions to Neovim's native code actions (`vim.lsp.buf.code_action()`, `gra` by default). Requires the dart tree-sitter parser.

- `enable_snippets`: Offers bloc snippets as LSP completion items (default `true`)

- `lint.enabled`: Starts the bloc language server for lint diagnostics when the `bloc` CLI is installed (default `true`)

- `lint.cmd`: Command for the bloc language server (default `{ 'bloc', 'language-server' }`)

## Usage

### Built-in Commands

Commands

- `:FlutterCreateBloc [dir]` - Create a new Bloc
- `:FlutterCreateCubit [dir]` - Create a new Cubit

The name can be typed in any case (`counter`, `user_profile` or `UserProfile`); classes are generated in PascalCase and files in snake_case.

Code Actions (place the cursor on a widget constructor, e.g. `Text(...)`)

- Convert to `MultiBlocProvider` / `MultiBlocListener` / `MultiRepositoryProvider` (nested providers or listeners of the same kind are merged into one list)
- Wrap with `BlocBuilder`
- Wrap with `BlocSelector`
- Wrap with `BlocListener`
- Wrap with `BlocConsumer`
- Wrap with `BlocProvider`
- Wrap with `RepositoryProvider`

### Snippets

Snippets are served by the plugin's built-in language server, so they show up in any LSP completion (blink.cmp, nvim-cmp or native completion) without a snippet engine.

| Prefix | Description |
| --- | --- |
| `importbloc`, `importflutterbloc`, `importbloctest` | Imports |
| `bloc`, `cubit` | Bloc / Cubit class |
| `onevent`, `_onevent` | Event handler / handler method |
| `blocstate`, `blocevent` | State / Event class |
| `blocobserver` | BlocObserver class |
| `blocprovider`, `multiblocprovider` | BlocProvider / MultiBlocProvider |
| `repoprovider`, `multirepoprovider` | RepositoryProvider / MultiRepositoryProvider |
| `blocbuilder`, `blocselector`, `bloclistener`, `multibloclistener`, `blocconsumer` | Bloc widgets |
| `blocof`, `repoof`, `read`, `watch`, `select` | Lookups |
| `bloctest`, `mockbloc`, `_mockbloc`, `mockcubit`, `_mockcubit` | bloc_test helpers |
| `mock`, `_mock`, `fake`, `_fake` | mocktail Mock / Fake classes |
| `fstate`, `fevent` | Freezed state / event |

### Lint

The official [bloc linter](https://bloclibrary.dev/lint/) runs as a language server from the `bloc` CLI. Install it and make sure `~/.pub-cache/bin` is on your `PATH`:

```sh
dart pub global activate bloc_tools
```

Then enable rules in `analysis_options.yaml` (see the [configuration docs](https://bloclibrary.dev/lint/configuration/)). The plugin starts the server for Dart files and `analysis_options.yaml` in Flutter projects; nothing runs if the CLI is not installed.

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
