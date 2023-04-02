--- The StringUtil Library.
-- @module StringUtil
-- @license Apache License 2.0
-- @copyright GrayWolf64
local StringUtil = {}
local ssub, sfind, sexplode, sreverse = string.sub, string.find, string.Explode, string.reverse
local table_concat = table.concat
local isstring = isstring

--- Qualifies the string name of an object and returns if it's a valid name.
-- @param str String name
-- @return bool ifvalid
function StringUtil.QualifyName(str)
    if not isstring(str) or ssub(str, 1, 1) == "." or ssub(str, -1) == "." or sfind(str, "[^%a%.]") then return false end

    return true
end

--- Removes the dot extension of a string.
-- @param str String
-- @param doconcat Whether `table.concat` the result
-- @return string result
function StringUtil.StripDotExtension(str, doconcat)
    if not isstring(str) then return end
    local result = sexplode(".", ssub(str, 1, #str - sfind(sreverse(str), "%.")))

    if doconcat ~= false then
        return table_concat(result, ".")
    else
        return result
    end
end

return StringUtil