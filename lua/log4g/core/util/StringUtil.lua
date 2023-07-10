--- The StringUtil Library.
-- @module StringUtil
-- @license Apache License 2.0
-- @copyright GrayWolf64
local StringUtil = {}
local tableConcat, tableInsert = table.concat, table.insert
local pairs, ipairs = pairs, ipairs
local type = type

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

local function stringToTable(str)
    local result = {}

    for i = 1, #str do
        result[i] = str:sub(i, i)
    end

    return result
end

--- Qualifies the string name of an object and returns if it's a valid name.
-- @param str String name
-- @param dot If dots are allowed, default is allowed if param not set
-- @return bool ifvalid
function StringUtil.checkName(str, dot)
    if type(str) ~= "string" then return false end

    if dot == true or dot == nil then
        if str:sub(1, 1) == "." or str:sub(-1) == "." or str:find("[^%a%.]") then return false end
        local chars = stringToTable(str)

        for k, v in pairs(chars) do
            if v == "." and (chars[k - 1] == "." or chars[k + 1] == ".") then return false end
        end
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
    if type(str) ~= "string" then return end
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
    if type(str) ~= "string" or type(char) ~= "string" or #char ~= 1 then return end
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