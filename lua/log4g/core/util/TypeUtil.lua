local TypeUtil = {}
local pcall, isstring, istable = pcall, isstring, istable

--- Checks the type of an object.
-- Necessary objects should have a function named 'Is...' that returns true.
-- @param o Object
-- @param type String type
-- @return bool isoftype
function TypeUtil.IsOfType(o, type)
    if not istable(o) or not isstring(type) then return end
    if pcall(o["Is" .. type]()) then return true end

    return false
end

return TypeUtil