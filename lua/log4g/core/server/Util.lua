--- The Util Library (Module).
-- @module Util.lua
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
        if not tbl[k] then return end
        if not isstring(k) then return end
        util.AddNetworkString(k)
    end
end

--- Find all the files in all the folder's subfolders using wildcard.
-- @param dir The folder which contains subfolders
-- @param wildcard The wildcard to use
-- @param path The game path
-- @return tbl filesfound
Log4g.Util.FindFilesInSubFolders = function(dir, wildcard, path)
    local tbl = {}
    local _, subfolders = file.Find(dir .. "*", path)

    if #subfolders ~= 0 then
        for _, v in ipairs(subfolders) do
            local files, _ = file.Find(dir .. v .. "/" .. wildcard, path)

            if #files ~= 0 then
                for _, j in ipairs(files) do
                    table.insert(tbl, dir .. v .. "/" .. j)
                end
            end
        end
    end

    return tbl
end