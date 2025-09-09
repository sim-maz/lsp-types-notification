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

To use `mini.notify`, you can configure it like this. This example includes a check to see if `mini.notify` is available, and falls back to the standard `vim.notify` if it's not. This is recommended to avoid errors if `mini.notify` is not loaded.

```lua
require('show_type').setup({
  notify_func = function(msg)
    -- Use mini.notify if it's available, otherwise fall back to vim.notify
    local success, mini_notify = pcall(require, 'mini.notify')
    if success then
      mini_notify.make(msg, 'info', { title = 'Type' })()
    else
      vim.notify(msg, vim.log.levels.INFO, { title = 'Type' })
    end
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

This plugin uses `vim.lsp.buf_request_all` to send a `textDocument/hover` request to the LSP server. This is done without triggering the default hover UI (floating window). It then parses the hover information to extract the type and displays it using the configured notification function.
