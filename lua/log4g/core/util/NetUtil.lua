local NetUtil = {}
local AddNetworkString = util.AddNetworkString
local Compress, WriteUInt, WriteData = util.Compress, net.WriteUInt, net.WriteData

--- Add all the string values in a table to network string table.
-- @param tbl The table of network strings to add
function NetUtil.AddNetworkStrsViaTbl(tbl)
    for _, v in pairs(tbl) do
        AddNetworkString(v)
    end
end

--- Write simple compressed data.
-- Must be used between `net.Start()` and `net.Send...`.
-- @param content The content to compress
-- @param bits The number of bits for `net.WriteUInt()` to write the length of compressed binary data
function NetUtil.WriteDataSimple(content, bits)
    local bindata = Compress(content)
    local len = #bindata
    WriteUInt(len, bits)
    WriteData(bindata, len)
end

return NetUtil