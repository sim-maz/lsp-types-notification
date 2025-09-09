# show-type.nvim

A simple Neovim plugin to show the type of the variable under the cursor in a notification.

## Features

- Shows the type of the variable under the cursor using LSP.
- Displays the type in a notification.
- Pluggable notification system, compatible with `vim.notify`, `mini.notify`, and `nvim-notify`.

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'sim-maz/show-type.nvim',
  opts = {} -- Or your configuration table
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'sim-maz/show-type.nvim',
  config = function()
    require('show_type').setup()
  end
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'sim-maz/show-type.nvim'
```
Then, in your `init.lua` or somewhere after the plugin is loaded:
```lua
require('show_type').setup()
```

## Configuration

The `setup` function accepts a configuration table.

### Options

- `notification_provider` (string): The notification provider to use.
  - `'default'`: Uses the built-in `vim.notify`. This is the default.
  - `'mini.notify'`: Uses `mini.notify`. Requires `mini.nvim` to be installed.
  - `'nvim-notify'`: Uses `rcarriga/nvim-notify`. Requires the plugin to be installed.

- `notify_func` (function): For advanced customization, you can provide your own notification function. If this is provided, it will override `notification_provider`.

### Examples

#### Using the default `vim.notify`
No configuration is needed. The plugin works out of the box with `vim.notify`.

#### Using `mini.notify`
To use `mini.notify`, set the `notification_provider` to `'mini.notify'`.

For `lazy.nvim`:
```lua
{
  'sim-maz/show-type.nvim',
  dependencies = { 'echasnovski/mini.nvim' },
  opts = {
    notification_provider = 'mini.notify'
  }
}
```
**Note:** The `dependencies` key is required for `lazy.nvim` to ensure `mini.nvim` is loaded before this plugin.

#### Using `nvim-notify`
To use `nvim-notify`, set the `notification_provider` to `'nvim-notify'`.

For `lazy.nvim`:
```lua
{
  'sim-maz/show-type.nvim',
  dependencies = { 'rcarriga/nvim-notify' },
  opts = {
    notification_provider = 'nvim-notify'
  }
}
```
**Note:** The `dependencies` key is required for `lazy.nvim` to ensure `nvim-notify` is loaded before this plugin.

For other plugin managers:
```lua
require('show_type').setup({
  notification_provider = 'nvim-notify'
})
```

## Usage

Run the `:ShowType` command to see the type of the variable under the cursor.

You can also create a keymap for it:
```lua
vim.keymap.set('n', '<Leader>st', '<cmd>ShowType<cr>', { desc = 'Show Type' })
```

## How it works

This plugin uses `vim.lsp.buf_request_all` to send a `textDocument/hover` request to the LSP server without triggering the default hover UI. It then parses the hover information to extract the type and displays it using the configured notification function.
