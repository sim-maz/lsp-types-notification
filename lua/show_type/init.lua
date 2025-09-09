local M = {}

local config = {
  notify_func = function(msg)
    vim.notify(msg, vim.log.levels.INFO, { title = "Type" })
  end
}

function M.setup(user_config)
  user_config = user_config or {}
  for k, v in pairs(user_config) do
    config[k] = v
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
        -- Handle MarkupContent
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

  -- This is a heuristic. Different LSPs format hover results differently.
  local type_info = message:match("```[a-zA-Z_]*\n(.-)```")
  if not type_info then
    -- Fallback for non-markdown content
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

  -- Get position_encoding from the active LSP client to avoid a warning.
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local encoding = 'utf-16' -- A safe default if no client is found.
  if clients and #clients > 0 and clients[1].offset_encoding then
    encoding = clients[1].offset_encoding
  end

  local params = vim.lsp.util.make_position_params(0, encoding)

  local handler = function(results_map)
    if not results_map or vim.tbl_isempty(results_map) then
      config.notify_func("No type information found.")
      return
    end

    local type_info = get_type_from_hover(results_map)

    if type_info and type_info ~= "" then
      config.notify_func(type_info)
    else
      config.notify_func("No type information found.")
    end
  end

  vim.lsp.buf_request_all(bufnr, 'textDocument/hover', params, handler)
end

return M
