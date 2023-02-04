local function PatternLayout(input)
	if string.find(input, "%%d{DEFAULT}") then
		input = string.gsub(input, "%%d{DEFAULT}", os.date("%Y-%m-%d %H-%M-%S"))
	end

	if string.find(input, "%%d{UNIX}") then
		input = string.gsub(input, "%%d{UNIX}", os.time())
	end

	return input
end

return PatternLayout
