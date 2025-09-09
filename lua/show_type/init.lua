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

local function get_type_from_hover(hover_results)
  if not hover_results or vim.tbl_isempty(hover_results) then
    return nil
  end

  local message = ""
  -- The result from buf_request_all is a map of client_id -> result
  for _, client_result in pairs(hover_results) do
    if client_result.result and client_result.result.contents then
      local contents = client_result.result.contents
      if type(contents) == "table" then
        for _, line in ipairs(contents) do
          if type(line) == 'string' then
            message = message .. line .. "\n"
          end
        end
      else
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
    type_info = message
  end

  return type_info:gsub("^\n*", ""):gsub("\n*$", "")
end


function M.show()
  local bufnr = vim.api.nvim_get_current_buf()
  local params = vim.lsp.util.make_position_params()

  local handler = function(_, result, _, _)
    if not result or vim.tbl_isempty(result) then
      config.notify_func("No type information found.")
      return
    end

    local type_info = get_type_from_hover(result)

    if type_info and type_info ~= "" then
      config.notify_func(type_info)
    else
      config.notify_func("No type information found.")
    end
  end

  vim.lsp.buf_request_all(bufnr, 'textDocument/hover', params, handler)
end

return M
