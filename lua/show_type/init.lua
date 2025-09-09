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
  for _, result in ipairs(hover_results) do
    if result.contents then
      if type(result.contents) == "table" then
        for _, line in ipairs(result.contents) do
          message = message .. line .. "\n"
        end
      else
        message = message .. result.contents .. "\n"
      end
    end
  end

  -- This is a heuristic. Different LSPs format hover results differently.
  -- We'll look for lines that look like type definitions.
  -- For example, in typescript, it might be `(property) myVar: string`
  -- or for a function `function myFunc(): number`
  -- We'll try to extract the part after the colon.
  local type_info = message:match(":%s*(.*)")
  if type_info then
    return type_info:gsub("^%s*", ""):gsub("%s*$", "")
  end

  -- Fallback to the first line if no colon is found
  return message:match("^[^\n]*")
end


function M.show()
  local original_hover_handler = vim.lsp.handlers["textDocument/hover"]

  vim.lsp.handlers["textDocument/hover"] = function(_, _, result, _)
    -- Restore the original handler
    vim.lsp.handlers["textDocument/hover"] = original_hover_handler

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

  vim.lsp.buf.hover()
end

return M
