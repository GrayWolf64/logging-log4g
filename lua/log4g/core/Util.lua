--- The Util Library (Module).
-- @module Util
-- @license Apache License 2.0
-- @copyright GrayWolf64
Log4g.Util = Log4g.Util or {}
local sql = sql
--- Check if one table has a certain key.
-- @param tbl The table to check
-- @param key The key to find in the table
-- @return bool ifhaskey
-- @return keyfound
Log4g.Util.HasKey = function(tbl, key)
	if tbl == nil then
		return false
	end

	for k, _ in pairs(tbl) do
		if k == key then
			return true, k
		end
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

Log4g.Util.SQLQueryNamedRow = function(tbl, name)
	return sql.QueryRow("SELECT * FROM " .. tbl .. " WHERE Name = '" .. name .. "';")
end

Log4g.Util.SQLQueryValue = function(tbl, name)
	return sql.QueryValue("SELECT Content FROM " .. tbl .. " WHERE Name = '" .. name .. "';")
end

Log4g.Util.SQLUpdateValue = function(tbl, name, str)
	sql.Query("UPDATE " .. tbl .. " SET Content = " .. sql.SQLStr(str) .. " WHERE Name = '" .. name .. "';")
end
