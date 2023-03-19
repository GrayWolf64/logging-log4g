--- The Util Library (Module).
-- @module Util
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Util = Log4g.Util or {}
local SSub, SFind, SExplode, SReverse = string.sub, string.find, string.Explode, string.reverse
local TConcat = table.concat
local isstring = isstring

--- Add all the string keys in a table to network string table.
-- @param tbl The table of network strings to add
function Log4g.Util.AddNetworkStrsViaTbl(tbl)
    local AddNetworkString = util.AddNetworkString

    for _, v in pairs(tbl) do
        AddNetworkString(v)
    end
end

--- Qualifies the string name of an object and returns if it's a valid name.
-- @param str String name
-- @return bool ifvalid
function Log4g.Util.QualifyName(str)
    if not isstring(str) or SSub(str, 1, 1) == "." or SSub(str, -1) == "." or SFind(str, "[^%a%.]") then return false end

    return true
end

--- Removes the dot extension of a string.
-- @param str String
-- @param doconcat Whether `table.concat` the result
-- @return string result
function Log4g.Util.StripDotExtension(str, doconcat)
    if not isstring(str) then return end

    if doconcat ~= false then
        return TConcat(SExplode(".", SSub(str, 1, #str - SFind(SReverse(str), "%."))))
    else
        return SExplode(".", SSub(str, 1, #str - SFind(SReverse(str), "%.")))
    end
end