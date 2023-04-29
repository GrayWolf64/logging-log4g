--- The StringUtil Library.
-- @module StringUtil
-- @license Apache License 2.0
-- @copyright GrayWolf64
local StringUtil = {}
local tableConcat, tableInsert = table.concat, table.insert
local ipairs = ipairs
local isstring = isstring

--- Optimized version of [string.Explode](https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/extensions/string.lua#L87-L104).
-- @lfunction stringExplode
local function stringExplode(separator, str)
    local result, currentPos = {}, 1

    for i = 1, #str do
        local startPos, endPos = str:find(separator, currentPos, true)
        if not startPos then break end
        result[i], currentPos = str:sub(currentPos, startPos - 1), endPos + 1
    end

    result[#result + 1] = str:sub(currentPos)

    return result
end

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
    local result = stringExplode(".", str:sub(1, #str - str:reverse():find("%.")))

    if doconcat ~= false then
        return tableConcat(result, ".")
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
            tableInsert(pos, k)
        end
    end

    return not #pos or pos
end

return StringUtil