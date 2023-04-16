--- The StringUtil Library.
-- @module StringUtil
-- @license Apache License 2.0
-- @copyright GrayWolf64
local StringUtil = {}
local string_explode = string.Explode
local concat, insert = table.concat, table.insert
local isstring = isstring

--- Qualifies the string name of an object and returns if it's a valid name.
-- @param str String name
-- @param dot If dots are allowed, default is allowed if param not set
-- @return bool ifvalid
function StringUtil.QualifyName(str, dot)
    if not isstring(str) then return false end

    if dot == true or dot == nil then
        if str:sub(1, 1) == "." or str:sub(-1) == "." or str:find("[^%a%.]") then return false end
    else
        if str:find("[^%a]") then return false end
    end

    return true
end

--- Removes the dot extension of a string.
-- @param str String
-- @param doconcat Whether `table.concat` the result
-- @return string result
function StringUtil.StripDotExtension(str, doconcat)
    if not isstring(str) then return end
    local result = string_explode(".", str:sub(1, #str - str:reverse():find("%.")))

    if doconcat ~= false then
        return concat(result, ".")
    else
        return result
    end
end

--- Get all the positions of a char in a string.
-- @param str String to search in
-- @param char A Single character to search for
-- @return table positions or true if not found
function StringUtil.CharPos(str, char)
    if not isstring(str) or not isstring(char) or not #char == 1 then return end
    local pos = {}
    char = char:byte()

    for k, v in ipairs({str:byte(1, #str)}) do
        if v == char then
            insert(pos, k)
        end
    end

    return not #pos or pos
end

return StringUtil