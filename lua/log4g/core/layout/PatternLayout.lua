local function PatternLayout(input)
    local ddefault = string.gsub(input, "%%d{DEFAULT}", os.date("%Y-%m-%d %H-%M-%S"))

    return ddefault
end

return PatternLayout