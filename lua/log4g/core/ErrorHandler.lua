--- Our own implementation of ErrorHandler.
-- @module ErrorHandler
-- @license Apache License 2.0
-- @copyright GrayWolf64
local mathModF = math.modf
local stringRep = string.rep
local stringToTable = include"util/StringUtil.lua".stringToTable
local tableInsert = table.insert
local tableConcat = table.concat
local debugGetLocal = debug.getlocal
local print = print

--- List of available error titles to choose from.
-- @table _errorTitles
local _errorTitles = {
    "type mismatch",
    "name conflict"
}

--- Uses debug lib to get a function's param names.
-- @param func Lua function
-- @return table params
local function getFuncParams(func)
    local k, params = 2, {}
    local param = debugGetLocal(func, 1)
    while param ~= nil do
        tableInsert(params, param)
        param = debugGetLocal(func, k)
        k = k + 1
    end
    return params
end

--- Gets the digit count of a number.
-- @param n Lua number
-- @return number digits
local function getDigit(n)
    local digit = 0
    while n > 0 do
        n = mathModF(n / 10)
        digit = digit + 1
    end
    return digit
end

--- Prints the values of a table.
-- @param t Lua number
local function printTabContent(t)
    for _, v in ipairs(t) do print(v) end
end

--- Removes the '\n' at the end of a string.
-- @param str Lua string
-- @return string withoutNewLine
local function removeNewLine(str)
    if str:find("\n", #str - 1) then str = str:sub(1, #str - 1) end
    return str
end

--- Reads the lines of a file.
local function readLines(fileName, startLine, endLine)
    local result = {}
    local srcFile = file.Open(fileName, "r", "GAME")
    for i = 1, endLine do
        local line = srcFile:ReadLine()
        if i >= startLine then
            tableInsert(result, removeNewLine(line))
        end
    end
    srcFile:Close()
    return result
end

--- A more friendly but advanced assert function to be used by devs.
-- If an assert fails, it will show users the source code about how things should work.
-- Underlines and emphases are allowed.
-- @param exp The expression to assert
-- @param argIndex If given, the arg of that index of the defined function will be underlined
-- @param paramWarn If given, the param's underline will be followed with a message
-- @param titleNum A title from here @{\\_errorTitles}
-- @param maxSrcLines If given, limits the lines of src output
-- @param note If given, the note will be put below the src
-- @param markData If given, add some custom marks under a certain line
-- @usage local markData = {{line = 1, startPos = 2, endPos = 5, sign = "*", msg = "message following the signs(marks)"}}
local function Assert(exp, argIndex, paramWarn, titleNum, maxSrcLines, note, markData)
    if exp then return end

    local info = debug.getinfo(2, "flnSL")
    argIndex = argIndex or -1
    maxSrcLines = maxSrcLines or info.lastlinedefined - info.linedefined + 1

    local snippet = readLines(info.source:sub(2), info.linedefined, info.lastlinedefined)

    local maxRowNum = info.lastlinedefined

    local function putRowNum(tab)
        local pastRows = 0

        for i, line in ipairs(tab) do
            if i > maxSrcLines then break end

            local rowNum = info.linedefined + pastRows
            if info.activelines[rowNum] then
                tab[i] = stringRep(" ", getDigit(maxRowNum) - getDigit(rowNum)) .. rowNum .. " | " .. line
            else
                tab[i] = stringRep(" ", getDigit(maxRowNum)) .. " | " .. line
            end

            pastRows = pastRows + 1
        end
    end

    local function putMarks(tab, lineNum, startPos, endPos, sign, msg)
        if not sign then sign = "~" end
        if not msg then msg = "" end

        local header = stringRep(" ", getDigit(maxRowNum)) .. " | "
        local chars = stringToTable(header .. tab[lineNum]:gsub("[^%~%^%s]", " "))

        if lineNum ~= 1 then
            startPos, endPos = startPos + #header, endPos + #header
        end

        for i in ipairs(chars) do
            if i > endPos then break end
            if i >= startPos then
                chars[i] = sign
            end
            if i == endPos then
                chars[i + 1], chars[i + 2] = " ", msg
            end
        end

        tableInsert(tab, lineNum + 1, tableConcat(chars))
    end

    putRowNum(snippet)

    if argIndex > 0 then
        local paramStartPos, paramEndPos = snippet[1]:find(getFuncParams(info.func)[argIndex])
        putMarks(snippet, 1, paramStartPos, paramEndPos, "^", paramWarn)
    end

    if markData then
        for k, v in pairs(markData) do
            putMarks(snippet, v.line, v.startPos, v.endPos, v.sign, v.msg)
        end
    end

    tableInsert(snippet, 1, "error[E" .. titleNum .. "]: " .. _errorTitles[titleNum])
    tableInsert(snippet, 2, " -src-> " .. debug.getinfo(3, "S").short_src)
    tableInsert(snippet, 3, " -def-> " .. info.short_src .. ":")

    if note then
        tableInsert(snippet, stringRep(" ", getDigit(info.lastlinedefined)) .. " = note: " .. note)
    end

    printTabContent(snippet)

    Error"log4g ErrorHandler.Assert failure, see Console for details\n"
end

return {
    Assert = Assert
}