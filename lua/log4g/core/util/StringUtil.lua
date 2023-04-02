--- The StringUtil Library.
-- @module StringUtil
-- @license Apache License 2.0
-- @copyright GrayWolf64
local StringUtil = {}
local string_sub, string_find, string_explode, string_reverse = string.sub, string.find, string.Explode, string.reverse
local table_concat = table.concat
local isstring = isstring

--- Qualifies the string name of an object and returns if it's a valid name.
-- @param str String name
-- @return bool ifvalid
function StringUtil.QualifyName(str)
    if not isstring(str) or string_sub(str, 1, 1) == "." or string_sub(str, -1) == "." or string_find(str, "[^%a%.]") then return false end

    return true
end

--- Removes the dot extension of a string.
-- @param str String
-- @param doconcat Whether `table.concat` the result
-- @return string result
function StringUtil.StripDotExtension(str, doconcat)
    if not isstring(str) then return end
    local result = string_explode(".", string_sub(str, 1, #str - string_find(string_reverse(str), "%.")))

    if doconcat ~= false then
        return table_concat(result, ".")
    else
        return result
    end
end

return StringUtil