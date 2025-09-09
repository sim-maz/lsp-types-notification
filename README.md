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

To use `mini.notify`, you can provide a custom `notify_func` in the `setup` call. The following example shows the correct way to do this, including the necessary checks to ensure `mini.notify` is ready to be used.

```lua
require('show_type').setup({
  notify_func = function(msg)
    if _G.MiniNotify and _G.MiniNotify.make_notify then
      local notify = _G.MiniNotify.make_notify()
      notify(msg, vim.log.levels.INFO, { title = 'Type', timeout = 5000 })
    else
      vim.notify(msg, vim.log.levels.INFO, { title = 'Type' })
    end
  end
})
```

**Important Note for `lazy.nvim` users:**
If you use `lazy.nvim` and want to use `mini.notify` with this plugin, you must explicitly declare the dependency to ensure `mini.nvim` is loaded first. It is also recommended to set `lazy = false` for `mini.nvim` to ensure it is configured at startup.

Here is a complete example for your `lazy.nvim` configuration:

```lua
{
  'sim-maz/show-type.nvim',
  dependencies = { 'echasnovski/mini.nvim' },
  config = function()
    require('show_type').setup({
      notify_func = function(msg)
        if _G.MiniNotify and _G.MiniNotify.make_notify then
          local notify = _G.MiniNotify.make_notify()
          notify(msg, vim.log.levels.INFO, { title = 'Type', timeout = 5000 })
        else
          vim.notify(msg, vim.log.levels.INFO, { title = 'Type' })
        end
      end
    })
  end,
}
```

## Usage

Run the `:ShowType` command to see the type of the variable under the cursor.

You can also create a keymap for it:
```lua
vim.keymap.set('n', '<Leader>st', '<cmd>ShowType<cr>', { desc = 'Show Type' })
```

## How it works

This plugin uses `vim.lsp.buf_request_all` to send a `textDocument/hover` request to the LSP server. This is done without triggering the default hover UI (floating window). It then parses the hover information to extract the type and displays it using the configured notification function.
