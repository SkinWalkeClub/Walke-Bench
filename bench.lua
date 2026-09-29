local B = {}
B._VERSION = "1.0.0"
B._AUTHOR = "Weegee_MLG / Skin Walke Team"

local env = (getgenv and getgenv()) or _G
local clk = os.clock
local fmt = string.format
local floor = math.floor

local function res(p)
	for _, r in ipairs({ env, _G }) do
		local c = r
		for s in p:gmatch("[^.]+") do if type(c) ~= "table" then c = nil break end c = c[s] end
		if c ~= nil then return c end
	end
	return nil
end
local function isfn(p) return type(res(p)) == "function" end

local FUNCS = {
	Filesystem = { "readfile", "writefile", "appendfile", "isfile", "isfolder", "makefolder", "delfile", "delfolder", "listfiles", "loadstring", "getcustomasset" },
	Reflection = { "getgc", "getreg", "getgenv", "getrenv", "getloadedmodules", "getrunningscripts", "getscripts", "getnilinstances", "getinstances", "getcallbackvalue" },
	Metatable = { "getrawmetatable", "setrawmetatable", "setreadonly", "isreadonly", "hookmetamethod", "getnamecallmethod" },
	Closures = { "hookfunction", "newcclosure", "iscclosure", "islclosure", "checkcaller", "clonefunction", "getfunctionhash", "getscriptclosure" },
	Signals = { "getconnections", "firesignal", "replicatesignal" },
	Instances = { "cloneref", "compareinstances", "fireclickdetector", "firetouchinterest", "fireproximityprompt", "getproperties", "gethiddenproperty", "sethiddenproperty", "setscriptable" },
	Crypt = { "crypt.encrypt", "crypt.decrypt", "crypt.hash", "crypt.base64encode", "crypt.base64decode", "crypt.generatekey" },
	Debug = { "debug.getupvalues", "debug.setupvalue", "debug.getconstants", "debug.getprotos", "debug.getstack", "debug.getinfo" },
	Misc = { "identifyexecutor", "request", "setclipboard", "queue_on_teleport", "messagebox", "setfpscap", "getscriptbytecode", "decompile", "saveinstance", "getthreadidentity", "setthreadidentity" },
}

function B.scan()
	local cats, tp, tt = {}, 0, 0
	for cat, list in pairs(FUNCS) do
		local pr, miss = 0, {}
		for _, n in ipairs(list) do
			if isfn(n) then pr = pr + 1 else miss[#miss + 1] = n end
		end
		cats[cat] = { present = pr, total = #list, missing = miss }
		tp = tp + pr
		tt = tt + #list
	end
	return { cats = cats, present = tp, total = tt, pct = floor(tp / tt * 100 + 0.5) }
end

function B.verify()
	local out = {}
	local be = res("crypt.base64encode")
	if be then out.base64 = (select(1, pcall(be, "Man")) and be("Man") == "TWFu") or false end
	local wf, rf, df = res("writefile"), res("readfile"), res("delfile")
	if wf and rf then
		local ok = pcall(function()
			wf("walke_bench_probe.txt", "walke")
			local r = rf("walke_bench_probe.txt")
			if df then pcall(df, "walke_bench_probe.txt") end
			return r
		end)
		out.filesystem = ok and true or false
	end
	local gg = res("getgenv")
	if gg then out.getgenv = (select(1, pcall(gg)) and type(gg()) == "table") or false end
	local hf = res("hookfunction")
	if hf then
		local ok, r = pcall(function()
			local function a() return 1 end
			local function b() return 2 end
			local old = hf(a, b)
			local swapped = a() == 2
			if type(old) == "function" then pcall(hf, a, old) end
			return swapped
		end)
		out.hookfunction = ok and r == true
	end
	return out
end

local function timeit(fn, budget)
	budget = budget or 0.04
	if not pcall(fn) then return nil end
	local n = 64
	while true do
		local t0 = clk()
		for _ = 1, n do fn() end
		local dt = clk() - t0
		if dt >= budget then return floor(n / dt) end
		if dt <= 0 then n = n * 8 else n = floor(n * (budget / dt) * 1.3) + 1 end
		if n > 8e7 then
			local t1 = clk()
			for _ = 1, n do fn() end
			return floor(n / math.max(clk() - t1, 1e-6))
		end
	end
end

function B.speed()
	local r = {}
	r.lua_loop = timeit(function() local s = 0 for i = 1, 1000 do s = s + i * 2 end return s end)
	r.table_ops = timeit(function() local t = {} for i = 1, 100 do t[i] = i end end)
	r.string_concat = timeit(function() local s = "" for i = 1, 50 do s = s .. i end return s end)
	if Instance and Instance.new then r.instance_new = timeit(function() Instance.new("Part") end) end
	if game and game.GetService then r.get_service = timeit(function() game:GetService("Lighting") end) end
	local wf, rf = res("writefile"), res("readfile")
	if wf and rf then
		r.file_io = timeit(function() wf("walke_bench_io.txt", "x") rf("walke_bench_io.txt") end, 0.06)
		local df = res("delfile") if df then pcall(df, "walke_bench_io.txt") end
	end
	local h = res("crypt.hash")
	if h then r.crypt_hash = timeit(function() pcall(h, "walkebench", "sha256") end) end
	return r
end

local function grade(p)
	if p >= 90 then return "A" elseif p >= 78 then return "B" elseif p >= 65 then return "C" elseif p >= 50 then return "D" else return "F" end
end

function B.run()
	local name, ver = "Unknown", ""
	local ie = res("identifyexecutor")
	if ie then pcall(function() name, ver = ie() end) end
	local sc = B.scan()
	return { executor = name, version = ver, scan = sc, verify = B.verify(), speed = B.speed(), grade = grade(sc.pct) }
end

local function commas(n)
	local s = tostring(n)
	local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	return (out:gsub("^,", ""))
end

function B.report()
	local d = B.run()
	local L = {}
	local function line(s) L[#L + 1] = s end
	line("== Walke Bench ==")
	line("Executor: " .. tostring(d.executor) .. (d.version ~= "" and (" " .. tostring(d.version)) or ""))
	line(fmt("Support:  %d/%d  (%d%%)  grade %s", d.scan.present, d.scan.total, d.scan.pct, d.grade))
	line("")
	local order = { "Filesystem", "Reflection", "Metatable", "Closures", "Signals", "Instances", "Crypt", "Debug", "Misc" }
	for _, cat in ipairs(order) do
		local c = d.scan.cats[cat]
		if c then line(fmt("  %-11s %d/%d", cat, c.present, c.total)) end
	end
	line("")
	line("Verify:")
	local vk = {}
	for k in pairs(d.verify) do vk[#vk + 1] = k end
	table.sort(vk)
	if #vk == 0 then line("  (nothing to verify)") end
	for _, k in ipairs(vk) do line("  " .. (d.verify[k] and "ok  " or "BAD ") .. k) end
	line("")
	line("Speed (ops/sec, higher = faster):")
	local sk = { "lua_loop", "table_ops", "string_concat", "instance_new", "get_service", "file_io", "crypt_hash" }
	for _, k in ipairs(sk) do
		if d.speed[k] then line(fmt("  %-14s %s", k, commas(d.speed[k]))) end
	end
	local s = table.concat(L, "\n")
	print(s)
	return s, d
end

return B
