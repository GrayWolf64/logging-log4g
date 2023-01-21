--- The Util Library (Module).
-- @module Util.lua
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Util = Log4g.Util or {}

--- Check if one table has a certain key.
-- @param tbl The table to check
-- @param key The key to find in the table
-- @return bool ifhaskey
Log4g.Util.HasKey = function(tbl, key)
    if tbl == nil then return false end

    for k, _ in pairs(tbl) do
        if k == key then return true, k end
    end

    return false
end

--- Send a table after receiving a net message.
-- @param receive The message to receive (from a player)
-- @param start The message for sending the table
-- @param tbl The table to send
Log4g.Util.SendTableAfterRcvNetMsg = function(receive, start, tbl)
    net.Receive(receive, function(len, ply)
        net.Start(start)
        net.WriteTable(tbl)
        net.Send(ply)
    end)
end

--- Add all the string keys in a table to network string table.
-- @param tbl The table of network strings to add
Log4g.Util.AddNetworkStrsViaTbl = function(tbl)
    for k, _ in pairs(tbl) do
        if not isstring(k) or not tbl[k] then return end
        util.AddNetworkString(k)
    end
end

--- Write simple compressed data.
-- Must be used between net start and send.
-- @param content The content to compress
-- @param bits The number of bits for net.WriteUInt() to write the length of compressed binary data
Log4g.Util.WriteDataSimple = function(content, bits)
    local bindata = util.Compress(content)
    local len = #bindata
    net.WriteUInt(len, bits)
    net.WriteData(bindata, len)
end

--- Recursively delete a folder's content and eventually delete the folder itself.
-- @param folder The folder to delete which doesn't end with "/"
-- @param path File search path
Log4g.Util.DeleteFolderRecursive = function(folder, path)
    if not file.Exists(folder, path) then return end
    local files, folders = file.Find(folder .. "/*", path)

    if istable(files) and not table.IsEmpty(files) then
        for k, v in pairs(files) do
            file.Delete(folder .. "/" .. v)
        end
    end

    if istable(folders) and not table.IsEmpty(folders) then
        local DeleteFolderRecursive = Log4g.Util.DeleteFolderRecursive

        for i, j in pairs(folders) do
            DeleteFolderRecursive(folder .. "/" .. j, path)
            file.Delete(folder .. "/" .. j)
        end
    end

    file.Delete(folder)
end