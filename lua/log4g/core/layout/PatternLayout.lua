local function PatternLayout(input)
    string.gsub(input, "%%d{DEFAULT}", os.date("%Y-%m-%d %H-%M-%S"))

    return input
end

return PatternLayout