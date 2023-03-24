local NetUtils = {}
local AddNetworkString = util.AddNetworkString

--- Add all the string values in a table to network string table.
-- @param tbl The table of network strings to add
function NetUtils.AddNetworkStrsViaTbl(tbl)
    for _, v in pairs(tbl) do
        AddNetworkString(v)
    end
end

return NetUtils