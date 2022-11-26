log4g = log4g or {}
file.CreateDir("log4g")

if CLIENT then
    file.CreateDir("log4g/client")
else
    file.CreateDir("log4g/server")
    file.CreateDir("log4g/server/loggercontext")
end