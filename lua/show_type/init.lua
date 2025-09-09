local M = {}

-- Default notification function using vim.notify
local function default_notify(msg)
  vim.notify(msg, vim.log.levels.INFO, { title = "Type" })
end

-- Notification function for mini.notify, with a fallback to the default.
local function mini_notify_func(msg)
  if _G.MiniNotify and _G.MiniNotify.make_notify then
    local notify = _G.MiniNotify.make_notify()
    notify(msg, vim.log.levels.INFO, { title = 'Type', timeout = 5000 })
  else
    default_notify(msg)
  end
end

-- Notification function for nvim-notify
local function nvim_notify_func(msg)
  local success, notify = pcall(require, 'notify')
  if success and notify then
    notify(msg, 'info', { title = 'Type' })
  else
    default_notify(msg)
  end
end

local config = {
  -- This will be the function called to show notifications.
  -- It is set during the setup function.
  notify = default_notify,
}

function M.setup(user_config)
  user_config = user_config or {}

  -- The user can provide a custom notification function.
  if user_config.notify_func then
    config.notify = user_config.notify_func
  -- Or they can specify a provider by name for convenience.
  elseif user_config.notification_provider == 'mini.notify' then
    config.notify = mini_notify_func
  elseif user_config.notification_provider == 'nvim-notify' then
    config.notify = nvim_notify_func
  end
end

local function get_type_from_hover(results_map)
  if not results_map or vim.tbl_isempty(results_map) then
    return nil
  end

  local message = ""
  for _, client_response in pairs(results_map) do
    if client_response.result and client_response.result.contents then
      local contents = client_response.result.contents
      if type(contents) == "table" then
        if contents.value then
          message = message .. contents.value .. "\n"
        end
      elseif type(contents) == "string" then
        message = message .. contents .. "\n"
      end
    end
  end

  if message == "" then
    return nil
  end

  local type_info = message:match("```[a-zA-Z_]*\n(.-)```")
  if not type_info then
    local lines = vim.split(message, "\n")
    type_info = lines[1]
  end

  if not type_info then
    return nil
  end

  return type_info:gsub("^%s*", ""):gsub("%s*$", "")
end

function M.show()
  local bufnr = vim.api.nvim_get_current_buf()

  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local encoding = 'utf-16'
  if clients and #clients > 0 and clients[1].offset_encoding then
    encoding = clients[1].offset_encoding
  end

  local params = vim.lsp.util.make_position_params(0, encoding)

  local handler = function(results_map)
    if not results_map or vim.tbl_isempty(results_map) then
      config.notify("No type information found.")
      return
    end

    local type_info = get_type_from_hover(results_map)

    if type_info and type_info ~= "" then
      config.notify(type_info)
    else
      config.notify("No type information found.")
    end
  end

  vim.lsp.buf_request_all(bufnr, 'textDocument/hover', params, handler)
end

return M
