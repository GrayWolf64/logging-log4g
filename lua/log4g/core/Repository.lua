--- Repositories are used to store and retrieve an object.
-- @classmod Repository
-- @license Apache License 2.0
-- @copyright GrayWolf64
local Object = Log4g.Core.Object.getClass()
local Repository = Repository or Object:subclass"Repository"
Repository:include(Log4g.Core.Object.namedMixins)

function Repository:Initialize(name)
    Object.Initialize(self)
    self:SetName(name)
    self.__repo = {}
end

function Repository:Access()
    return self.__repo
end

function Repository:InsertKVPair(k, v)
    if not k or not v then return end
    self.__repo[k] = v
end

local LContextRepo = LContextRepo or Repository"LContextRepo"
local CLevelRepo = CLevelRepo or Repository"CLevelRepo"

Log4g.Core.Repository = {
    getLContextRepo = function() return LContextRepo end,
    getCLevelRepo = function() return CLevelRepo end
}