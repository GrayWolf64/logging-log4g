--- Initialization of Log4g MMC GUI on server and client.
-- It's based on [Derma](https://wiki.facepunch.com/gmod/Derma_Basic_Guide) UI system that comes with the game itself.
-- @script MMC
-- @license Apache License 2.0
-- @copyright GrayWolf64
if SERVER then
    include"server/ClientGUI.lua"
    AddCSLuaFile"client/MMCDerma.lua"
    AddCSLuaFile"client/ClientGUI.lua"
elseif CLIENT then
    include"client/ClientGUI.lua"
end