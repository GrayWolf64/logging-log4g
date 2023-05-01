--- The StringUtil Library.
-- @module StringUtil
-- @license Apache License 2.0
-- @copyright GrayWolf64
local StringUtil = {}
local tableConcat = table.concat
local type = type

--- Removes the dot extension of a string.
-- @param str String
-- @param doconcat Whether `table.concat` the result
-- @return string result
function StringUtil.StripDotExtension(str, doconcat)
    if type(str) ~= "string" then return end

    --- Optimized version of [string.Explode](https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/extensions/string.lua#L87-L104).
    local function stringExplode(separator, string)
        local result, currentPos = {}, 1

        for i = 1, #string do
            local startPos, endPos = string:find(separator, currentPos, true)
            if not startPos then break end
            result[i], currentPos = string:sub(currentPos, startPos - 1), endPos + 1
        end

        result[#result + 1] = string:sub(currentPos)

        return result
    end

    local result = stringExplode(".", str:sub(1, #str - str:reverse():find("%.")))

    if doconcat ~= false then
        return tableConcat(result, ".")
    else
        return result
    end
end

return StringUtil