--- A type(class) checking library to extend `MiddleClass`'s functionality.
-- @module TypeUtil
-- @license Apache License 2.0
-- @copyright GrayWolf64
local TypeUtil = {}
local type = type

function TypeUtil.checkClass(o, cls)
    if not o or type(o) ~= "table" or type(cls) ~= "string" then return false end
    local classTable = o.class
    if not classTable then return false end
    local className = classTable.name
    if className == cls then return true end
    local superClassTable = classTable.super

    while superClassTable do
        if superClassTable.name == cls then return true end
        superClassTable = superClassTable.super
    end

    return false
end

return TypeUtil