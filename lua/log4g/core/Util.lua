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
function Log4g.Util.HasKey(tbl, key)
    if table.IsEmpty(tbl) then return false end

    for k, _ in pairs(tbl) do
        if k == key then return true, k end
    end

    return false
end

--- Add all the string keys in a table to network string table.
-- @param tbl The table of network strings to add
function Log4g.Util.AddNetworkStrsViaTbl(tbl)
    local AddNetworkString = util.AddNetworkString

    for _, v in pairs(tbl) do
        AddNetworkString(v)
    end
end

--- Get the current FQSN according to the function provided.
-- @lfunction Log4g.Util.GetCurrentFQSN
-- @param func The name of the function where GetCurrentFQSN is called
-- @return string fqsn
function Log4g.Util.GetCurrentFQSN(func)
    return string.StripExtension(debug.getinfo(func).source:gsub("%/", "."):gsub("%@", ""))
end