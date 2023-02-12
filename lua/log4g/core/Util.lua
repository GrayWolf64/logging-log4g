--- The Util Library (Module).
-- @module Util
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Util = Log4g.Util or {}

--- Check if one table has a certain key.
-- @param tbl The table to check
-- @param key The key to find in the table
-- @return bool ifhaskey
-- @return keyfound
Log4g.Util.HasKey = function(tbl, key)
    if table.IsEmpty(tbl) then return false end

    for k, _ in pairs(tbl) do
        if k == key then return true, k end
    end

    return false
end

--- Add all the string keys in a table to network string table.
-- @param tbl The table of network strings to add
Log4g.Util.AddNetworkStrsViaTbl = function(tbl)
    for _, v in pairs(tbl) do
        util.AddNetworkString(v)
    end
end