# show-type.nvim

A simple Neovim plugin to show the type of the variable under the cursor in a notification.

## Features

- Shows the type of the variable under the cursor using LSP.
- Displays the type in a notification.
- Pluggable notification system, compatible with `vim.notify` and `mini.notify`.

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'sim-maz/show-type.nvim',
  config = function()
    require('show_type').setup()
  end
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

The `setup` function accepts a configuration table. The following options are available:

- `notify_func`: A function that takes a message string and displays it as a notification. Defaults to `vim.notify`.

### Example with `mini.notify`

To use `mini.notify`, you can configure it like this:

```lua
require('show_type').setup({
  notify_func = function(msg)
    require('mini.notify').make(msg, 'info', { title = 'Type' })()
  end
})
```

## Usage

Run the `:ShowType` command to see the type of the variable under the cursor.

You can also create a keymap for it:
```lua
vim.keymap.set('n', '<Leader>st', '<cmd>ShowType<cr>', { desc = 'Show Type' })
```

## How it works

This plugin temporarily overrides the `textDocument/hover` LSP handler to capture the hover information without displaying the floating window. It then parses the hover information to extract the type and displays it using the configured notification function.

This approach is a bit of a hack, but it's a simple and effective way to get the type information without requiring a custom LSP client.
