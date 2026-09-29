local Bench = loadstring(game:HttpGet("https://raw.githubusercontent.com/SkinWalkeClub/Walke-Bench/main/bench.lua"))()

local report, data = Bench.report()

if data.grade == "A" or data.grade == "B" then
	print("solid executor:", data.executor, data.scan.pct .. "%")
else
	print("weak executor:", data.executor, "missing", #data.scan.cats.Filesystem.missing, "fs funcs")
end

local cb = (getgenv and getgenv().setclipboard) or setclipboard
if cb then cb(report) print("report copied to clipboard") end
