------------------------------------------------------------------------------
-- Aergo Standard NFT Interface (Proposal) - 20210425
------------------------------------------------------------------------------

extensions["searchable"] = true

-- retrieve the first token found that mathes the query
-- the query is a table that can contain these fields:
--   owner    - the owner of the token (address)
--   contains - check if the tokenId contains this string
--   pattern  - check if the tokenId matches this Lua regex pattern
-- the prev_index must be 0 in the first call
-- for the next calls, just inform the returned index from the previous call
-- return value: (2 values) index, tokenId
-- if no token is found with the given query, it returns (nil, nil)
function findToken(query, prev_index)
  _typecheck(query, 'table')
  _typecheck(prev_index, 'uint')

  local contains = query["contains"]
  if contains then
    query["pattern"] = escape(contains)
  end

  local index, tokenId
  local owner = query["owner"]

  if owner then
    -- iterate over the tokens from this user
    local list = _user_tokens[owner] or {}
    local check_tokens = (prev_index == 0)

    for position,index in ipairs(list) do
      if check_tokens then
        tokenId = _ids[tostring(index)]
        if token_matches(tokenId, query) then
          break
        else
          tokenId = nil
        end
      elseif index == prev_index then
        check_tokens = true
      end
    end

  else
    -- iterate over all the tokens
    local last_index = _last_index:get()
    index = prev_index

    if index >= last_index then
      return nil, nil
    end

    do
      index = index + 1
      tokenId = _ids[tostring(index)]
      if not token_matches(tokenId, query) then
        tokenId = nil
      end
    while tokenId == nil and index < last_index
  end

  if tokenId == nil then
    index = nil
  end

  return index, tokenId
end

local function token_matches(tokenId, query)

  if tokenId == nil then
    return false
  end

  local pattern = query["pattern"]

  if pattern then
    if not tokenId:match(pattern) then
      return false
    end
  end

  return true
end

local function escape(str)
  return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", function(c) return "%" .. c end)
end


abi.register(findToken)
