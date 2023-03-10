--- The Util Library (Module).
-- @module Util
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Util = Log4g.Util or {}
local Util = Log4g.Util
local STRL, STRR = string.Left, string.Right
local isstring = isstring

--- Add all the string keys in a table to network string table.
-- @param tbl The table of network strings to add
function Util.AddNetworkStrsViaTbl(tbl)
    local AddNetworkString = util.AddNetworkString

    for _, v in pairs(tbl) do
        AddNetworkString(v)
    end
end

--- Qualifies the string name of an object and returns if it's a valid name.
-- @param str String name
-- @return bool ifvalid
function Util.QualifyName(str)
    if not isstring(str) or STRL(str, 1) == "." or STRR(str, 1) == "." or string.find(str, "[^%a%.]") then return false end

    return true
end