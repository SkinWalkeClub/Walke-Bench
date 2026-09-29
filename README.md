# Walke Bench

An executor report card. It scores any executor on how many of the standard UNC/sUNC functions it *actually* has (not just claims), checks that the important ones really work, benchmarks its speed, and prints a shareable report.

Stop arguing about "which executor is best" — run this and post the numbers.

## Load it

```lua
local Bench = loadstring(game:HttpGet("https://raw.githubusercontent.com/SkinWalkeClub/Walke-Bench/main/bench.lua"))()
Bench.report()
```

That prints something like:

```
== Walke Bench ==
Executor: Solara 3.1
Support:  61/70  (87%)  grade B

  Filesystem  11/11
  Reflection  9/10
  Metatable   6/6
  Closures    7/8
  Signals     2/3
  Instances   9/9
  Crypt       6/6
  Debug       6/6
  Misc        5/11

Verify:
  ok  base64
  ok  filesystem
  ok  getgenv
  ok  hookfunction

Speed (ops/sec, higher = faster):
  lua_loop       1,240,000
  table_ops      3,900,000
  instance_new     280,000
  file_io            9,400
  crypt_hash       120,000
```

## What each part means

- **Support** — how many catalogued functions exist, grouped by category, with a percent and letter grade. This is presence only (`type(fn) == "function"`).
- **Verify** — actually *calls* a few key functions to confirm they work, not just exist: `base64` (checks it encodes `"Man"` → `"TWFu"`), a `writefile`/`readfile` round trip, `getgenv` returns a table, and `hookfunction` really swaps a function. Lying executors get caught here.
- **Speed** — benchmarks with an auto-scaling timer (runs each op until it fills a time budget, so the numbers are stable). Pure-Lua ops give you a baseline; `instance_new`, `file_io`, `crypt_hash` etc. show where the executor is slow.

## API

```lua
Bench.report()   -- prints the full report, returns (string, data)
Bench.run()      -- returns the raw data table (executor, scan, verify, speed, grade)
Bench.scan()     -- just the function-presence scan { cats, present, total, pct }
Bench.verify()   -- just the "does it actually work" checks
Bench.speed()    -- just the benchmarks { name = opsPerSec, ... }
```

`Bench.run()` returns everything so you can build your own UI or post the JSON.

## Notes

- Presence is checked by name (dotted names like `crypt.hash` and `debug.getupvalues` resolve too). If your executor names something differently it'll read as missing — add the alias to `FUNCS` in the file.
- The speed numbers are relative; compare executors on the *same* machine, same game. Absolute ops/sec vary by CPU.
- The file-io and crypt benchmarks are skipped automatically if the executor doesn't have those functions.

## License

MIT — Weegee_MLG / The Skin Walke Team.
