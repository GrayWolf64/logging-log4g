rem Clone https://github.com/lunarmodules/LDoc repo folder into where this .bat lies
rem and rename it to 'ldoc'. You should already have Lua dev environment set up and know something about LDoc.
lua .\ldoc\ldoc.lua -d .\docs -p logging-log4l -f markdown .\lua
@pause