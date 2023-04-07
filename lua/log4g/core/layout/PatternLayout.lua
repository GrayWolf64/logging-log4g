--- A flexible layout configurable with pattern string.
-- @classmod PatternLayout
Log4g.Core.Layout.PatternLayout = Log4g.Core.Layout.PatternLayout or {}
local Layout = Log4g.Core.Layout.GetClass()
local PatternLayout = Layout:subclass("PatternLayout")
local IsLogEvent = include("log4g/core/util/TypeUtil.lua").IsLogEvent
local ipairs = ipairs
local table_remove, table_insert = table.remove, table.insert
local cvar_cp = "log4g.patternlayout.ConversionPattern"
CreateConVar(cvar_cp, "%-5p [%t]: %m%n", FCVAR_NOTIFY)

function PatternLayout:Initialize(name)
    Layout.Initialize(self, name)
end

local function DoFormat(event)
    local function getcharst(str)
        return {str:byte(1, #str)}
    end

    local function remove2(tbl, i)
        table_remove(tbl, i)
        table_remove(tbl, i)
    end

    local function insertchars(dest, from, idx)
        remove2(dest, idx)

        for i, j in ipairs(from) do
            table_insert(dest, idx + i - 1, j)
        end
    end

    local chars = getcharst(GetConVar(cvar_cp):GetString())

    for k, v in ipairs(chars) do
        if v == 37 then
            local nchar = chars[k + 1]

            if nchar == 109 then
                insertchars(chars, getcharst(event:GetMsg()), k)
            elseif nchar == 110 then
                remove2(chars, k)
                table_insert(chars, k, 10)
            elseif nchar == 116 then
                insertchars(chars, getcharst(debug.getinfo(6, "S").source:GetFileFromFilename()), k)
            end
        end
    end

    return string.char(unpack(chars))
end

function PatternLayout:Format(event)
    if not IsLogEvent(event) then return end

    return DoFormat(event)
end

function Log4g.Core.Layout.PatternLayout.CreateDefaultLayout(name)
    return PatternLayout(name)
end