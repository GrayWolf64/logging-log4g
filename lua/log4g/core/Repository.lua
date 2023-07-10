--- Repositories are used to store and retrieve an object.
-- @classmod Repository
-- @license Apache License 2.0
-- @copyright GrayWolf64
local Object = Log4g.Core.Object.getClass()
local Repository = Repository or Object:subclass"Repository"

function Repository:Initialize(name)
    Object.Initialize(self)
    self:SetName(name)
    self:SetPrivateField(0x03E8, {})
end

function Repository:Access()
    return self:GetPrivateField(0x03E8)
end

function Repository:InsertKVPair(k, v)
    if not k or not v then return end
    self:Access()[k] = v
end

local LContextRepo = LContextRepo or Repository"LContextRepo"
local CLevelRepo = CLevelRepo or Repository"CLevelRepo"

Log4g.Core.Repository = {
    getLContextRepo = function() return LContextRepo end,
    getCLevelRepo = function() return CLevelRepo end
}