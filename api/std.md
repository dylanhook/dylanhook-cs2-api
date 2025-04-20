# Standard library

Each script has its own LuaJIT state with Lua 5.1 syntax. The base functions and the `table`, `string`, `math`, `bit`, and `coroutine` libraries are ready when your script starts.

Dylanhook values have their own references: [color](../types/color.md),
[vec2](../types/vec2.md) and [vec3](../types/vec3.md). [Files](resources.md),
[timers](../events.md#timerafter) and [failure reasons](why.md) are documented
separately.

## require

```text
require(name: string) -> any
```

Loads a script-local text module, or returns a built-in library. Local modules
use the asset folder, caching and setup-time rules described below.

Returns an existing built-in library. Accepted names are `"table"`, `"string"`, `"math"`, `"bit"`, and `"coroutine"`. `"ffi"` requires [allow unsafe scripts](memory.md#permission).

```lua
local math = require("math")
local rounded = math.floor(12.75 + 0.5)
console.log(string.format("rounded: %d", rounded))
```

For a built-in, repeated calls return the same library table. Built-ins always
take precedence over local files.

Other names load local text modules. For `example.lua`, `require("labels")`
reads `example.assets/labels.lua`. Names contain 1-64 lowercase ASCII letters,
digits or underscores, and cannot begin with a digit. Do not include a path or
file extension. Windows device names are refused. There is no global module
search path or shared cache.

Require helpers while the main script loads. Helpers can require other helpers
and use the same environment, declarations and execution allowances as the main
file. A cached module can be required from any callback without reading its file
again. First loads in callbacks raise an error.

The first return value is cached for the current loaded script, including `false`.
Returning `nil` or nothing caches `true`. Each script has its own module values.
An ordinary import error clears the in-progress cache entry, but it does not
undo earlier Lua assignments or declarations. Let an essential helper failure
reject the main load rather than continuing with a partially initialized script.

The limits are 32 uncached attempts, 256 KiB per helper and 1 MiB of total helper
source per load. Failed attempts count too.

Each file-read attempt costs 64 native-work units. A successful read costs
another 64 plus 1 per started 4 KiB before compilation. Cache hits and built-ins
have no additional charge. Source must be text, not bytecode.

Saving a loaded main file or changing a helper schedules a reload. A failed
reload keeps the previous version and its cached helpers. Use **reload** manually
if automatic reload is unavailable.

An unknown name or unavailable library raises an error. A denied `require("ffi")` explains which permission to enable and asks you to reload.

## loadstring

```text
loadstring(source: string, chunk_name: string = "=(loadstring)") -> function | (nil, error: string)
```

Compiles Lua source text into a function without executing it. Enable
**allow unsafe scripts**, then load or reload the script before using this
function. A denied call raises an error with that guidance.

Compilation is available during setup and render-side callbacks:
paint, above-menu paint, menu buttons, control changes, timers, HTTP completions,
ESP values, session changes, shot notifications and unload. Command, frame-stage and game-event callbacks
cannot compile code. A compiled function can be called later, but every API
it uses must be allowed in the callback that calls it.

`source` is a string of at most 256 KiB. An empty string is valid. The optional
chunk name is a string of 1-96 bytes without NUL, used in errors and tracebacks.
Omitting it or passing `nil` uses the displayed default. Numbers are not
accepted in place of either string.

```lua
local build_label, error_message = loadstring(
    "return function(value) return 'count: ' .. tostring(value) end",
    "@label-helper"
)
if not build_label then error(error_message) end
local label = build_label()
console.log(label(3))
```

The function belongs to the current script's Lua state and globals. Calling it
does not reset callback limits or output throttling. Bytecode is refused even in
unsafe mode. It does not enable package searchers, filesystem loaders,
`string.dump` or the JIT engine.

A compilation failure returns `nil` and its error string. Permission, callback
and argument failures raise an error.

Each compilation attempt costs 64 native-work units plus 1 per started 4 KiB of
source.
Compile reusable helpers once instead of recompiling them every frame.

## Base functions

These functions are globals. `_G` refers to the script's global table, and `_VERSION` starts as `"Lua 5.1"`.

| Functions | Use |
| --- | --- |
| `assert`, `error` | Check a condition or raise a Lua error. |
| `pcall`, `xpcall` | Call a function while handling ordinary Lua errors. |
| `type`, `tonumber`, `tostring` | Inspect or convert a value. |
| `pairs`, `ipairs`, `next` | Walk a table. |
| `select`, `unpack` | Select arguments or unpack a table range. |
| `rawget`, `rawset`, `rawequal` | Work with values without invoking their matching metamethods. |
| `getmetatable`, `setmetatable` | Inspect or assign an accessible metatable. |
| `getfenv`, `setfenv` | Inspect or assign a Lua function environment. |
| `collectgarbage`, `gcinfo` | Control garbage collection or inspect Lua memory use. |
| `print` | Format arguments into one [console message](console.md#print). |
| `require` | Get a built-in library or script-local module as described above. |

`print` accepts up to 64 arguments and joins their `tostring` results with spaces.

`pcall` returns `true` followed by the function's results, or `false` followed by its error. It does not clear an exhausted script instruction allowance. See [callback errors](../events.md#errors-and-limits).

```lua
local ok, value = pcall(json.decode, '{"scale":1}')
if ok then
    console.log(string.format("scale: %g", value.scale))
else
    console.warn(tostring(value))
end
```

`collectgarbage()` requests a collection. Its modes are `"stop"`, `"restart"`, `"collect"`, `"count"`, `"step"`, `"setpause"`, `"setstepmul"`, and `"isrunning"`. `"count"` returns Lua memory use in KiB; `gcinfo()` returns that count rounded down to a whole KiB. Neither changes the script's [memory limit](../limits.md).

## table

| Functions | Use |
| --- | --- |
| `table.insert`, `table.remove` | Insert or remove a sequence item, shifting nearby items. |
| `table.concat` | Join a range of string or number items. |
| `table.sort` | Sort a sequence in place, optionally with a comparison function. |
| `table.move` | Copy an indexed range, including overlapping ranges. |
| `table.getn` | Return the sequence length, like `#value`. |
| `table.maxn` | Find the largest positive numeric key, or return `0`. |
| `table.foreach`, `table.foreachi` | Call a function for table entries or sequence items. |

Sequence indices start at `1`. Use consecutive indices when relying on `#`, `ipairs`, sorting, or concatenation.

```text
table.move(source: table, first: integer, last: integer,
           destination_start: integer, destination: table = source) -> table
```

Copies the inclusive range and returns the destination table. It does not delete source slots. When source and destination overlap, destination writes can replace source values. Omitting `destination` or passing `nil` copies within `source`.

```lua
local labels = {"small", "medium", "large"}
local copy = table.move(labels, 1, #labels, 1, {})
table.sort(copy)
console.log(table.concat(copy, ", "))
```

## string

| Functions | Use |
| --- | --- |
| `string.len`, `string.byte`, `string.char` | Measure or construct byte strings. |
| `string.sub` | Copy a byte range. |
| `string.find`, `string.match` | Find text or match a Lua pattern. |
| `string.gmatch`, `string.gsub` | Iterate matches or replace them. |
| `string.format` | Format values into a string. |
| `string.rep` | Repeat a string, optionally with a separator. |
| `string.lower`, `string.upper`, `string.reverse` | Transform the string's bytes. |

String indices start at `1`. A negative index counts back from the end. Lengths and ranges count bytes. A UTF-8 character can take more than one byte.

```lua
local label = "compact layout"
local first = label:match("^(%S+)")
console.log(string.format("first word: %s", first))
```

## math

| Functions | Use |
| --- | --- |
| `math.abs`, `math.floor`, `math.ceil` | Absolute value and rounding. |
| `math.min`, `math.max` | The smallest or largest of the supplied numbers. |
| `math.sqrt`, `math.pow`, `math.exp` | Roots, powers, and exponentials. |
| `math.log`, `math.log10` | Logarithms. `math.log(x)` uses the natural logarithm. A second numeric argument selects a base. |
| `math.sin`, `math.cos`, `math.tan` | Trigonometric functions with angles in radians. |
| `math.asin`, `math.acos`, `math.atan`, `math.atan2` | Inverse trigonometric functions, returning radians. |
| `math.sinh`, `math.cosh`, `math.tanh` | Hyperbolic functions. |
| `math.rad`, `math.deg` | Convert degrees to radians or radians to degrees. |
| `math.fmod`, `math.modf`, `math.frexp`, `math.ldexp` | Remainders, fractional parts, and binary exponents. |
| `math.random`, `math.randomseed` | Generate pseudorandom values and set their starting state. |

`math.pi` contains pi. `math.huge` contains positive infinity. Functions such as `json.encode` that require finite numbers refuse it.

```text
math.random() -> number
math.random(upper: integer) -> integer
math.random(lower: integer, upper: integer) -> integer
math.randomseed(seed: number) -> no values
math.randomseed() -> no values
```

Without arguments, `math.random` returns a number from `0` inclusive to `1` exclusive. With one integer bound, it returns an integer from `1` through that bound. With two integer bounds, both ends are included. Supply ordered bounds for a nonempty range.

An explicit seed produces a repeatable sequence. Omitting the seed requests system randomness and can raise an error if that seed is unavailable. Each fresh script starts with the same initial random state until you seed it.

```lua
math.randomseed(42)
local choice = math.random(1, 3)
console.log(string.format("choice: %d", choice))
```

### math.clamp

```text
math.clamp(value: number, minimum: number, maximum: number) -> number
```

Keeps `value` between the inclusive bounds. Equal bounds are valid. Reversed
bounds raise an error.

### math.lerp

```text
math.lerp(from: number, to: number, amount: number) -> number
```

Interpolates between two numbers. `0` returns `from`, `1` returns `to`, and `0.5`
returns their midpoint. The amount is not clamped. Values outside `[0, 1]`
extrapolate beyond the endpoints.

### math.remap

```text
math.remap(value: number, input_minimum: number, input_maximum: number,
           output_minimum: number, output_maximum: number) -> number
```

Maps a value from one interval to another, without clamping. Descending intervals
are valid, but equal input bounds raise an error. An overflowing input difference,
ratio or result also raises an error rather than returning infinity.

### math.round

```text
math.round(value: number, decimals: integer = 0) -> number
```

Rounds to the requested number of decimal places. Exact halfway values round
away from zero. `decimals` must be from `-15` through `15`. Negative values round
to tens, hundreds and so on. Decimal inputs still have ordinary binary
floating-point precision.

### math.normalize_angle

```text
math.normalize_angle(angle: number) -> number
```

Wraps degrees into `[-180, 180)`. For example, both `180` and `540` become `-180`.
It does not clamp pitch or choose a direction for a zero vector.

These five helpers require finite numbers and raise an error for invalid inputs
or unrepresentable results. They are available during loading and in every
callback, with no additional native work charge.

```lua
local opacity = math.clamp(300, 0, 255)
local midpoint = math.lerp(10, 30, 0.5)
local progress = math.remap(25, 0, 100, 0, 1)
print(opacity, midpoint, math.round(progress, 2), math.normalize_angle(270))
```

## bit

| Functions | Use |
| --- | --- |
| `bit.tobit` | Convert a number to a signed 32-bit integer. |
| `bit.band`, `bit.bor`, `bit.bxor`, `bit.bnot` | Bitwise and, or, xor, and complement. |
| `bit.lshift`, `bit.rshift`, `bit.arshift` | Left, logical right, and arithmetic right shifts. |
| `bit.rol`, `bit.ror` | Rotate bits left or right. |
| `bit.bswap` | Reverse the byte order. |
| `bit.tohex` | Format a bit pattern as hexadecimal text. |

Ordinary Lua numbers use signed 32-bit results for the bitwise operations. Shift and rotation counts use their lowest 5 bits. LuaJIT's 64-bit integer cdata uses its corresponding 64-bit operations.

```lua
local flags = bit.bor(1, 4)
local has_four = bit.band(flags, 4) ~= 0
console.log(string.format("flags: %s, four: %s", bit.tohex(flags), tostring(has_four)))
```

`bit.tohex` defaults to 8 digits for Lua numbers or 16 for 64-bit integer cdata. A negative digit count selects uppercase text.

## coroutine

| Function | Use |
| --- | --- |
| `coroutine.create` | Create a coroutine from a function. |
| `coroutine.resume` | Run or resume it. Return a success flag followed by results or an error. |
| `coroutine.yield` | Suspend a resumable coroutine and return values to its caller. |
| `coroutine.wrap` | Wrap a coroutine in a function that resumes it and raises its errors. |
| `coroutine.status` | Return `"running"`, `"suspended"`, `"normal"`, or `"dead"`. |
| `coroutine.running` | Return the running coroutine, or `nil` on the main Lua thread. |
| `coroutine.isyieldable` | Report whether the current call can yield. |

Your script decides when to resume a coroutine. It does not schedule itself with
a rendered frame. Dylanhook API calls made inside it still need the appropriate
[callback context](../events.md).

## JSON

Encode and decode settings or other structured data through the global `json` table.

### json.encode

```text
json.encode(value: nil | boolean | number | string | table | json.null) -> string
```

Encodes one value as compact JSON. The argument is required. Passing `nil` encodes `null`.

| Lua value | JSON result |
| --- | --- |
| `nil` or `json.null` | `null`. |
| A boolean | `true` or `false`. |
| A finite number | A number, with enough precision to round-trip a Lua number. |
| A UTF-8 string | An escaped JSON string. |
| A table with string keys | An object with sorted keys. |
| A table with consecutive integer keys starting at `1` | An array in index order. |
| An empty table | `{}`, unless marked with `json.array`. |

```lua
local settings = {
    compact = true,
    label = "status",
    offsets = json.array({12, 24}),
    selected = json.null
}

local encoded = json.encode(settings)
console.log(encoded)
```

The encoder reads table entries directly. Table metamethods do not supply missing values or custom encodings. Mixed string and numeric keys, gaps, invalid key types, cycles, invalid UTF-8, and non-finite numbers raise an error. Functions, coroutines, and other userdata or cdata also raise an error.

Object keys are ordered by their bytes. Repeating the same table contents gives the same object-key order. Shared child tables are allowed as long as they do not form a cycle.

### json.decode

```text
json.decode(text: string | number) -> boolean | number | string | table | json.null
```

Decodes exactly one JSON value. Whitespace around it is accepted. Malformed syntax, trailing non-whitespace, invalid UTF-8, invalid Unicode escapes, and numbers outside Lua's finite range raise an error.

Objects become tables with string keys. Arrays become tables with consecutive indices starting at `1` and keep their array marker, including empty arrays. Repeated object keys keep the last value. JSON `null` becomes `json.null`, including at the top level.

```lua
local result = json.decode('{"positions":[12,null,24]}')
assert(result.positions[2] == json.null)
assert(#result.positions == 3)
console.log(json.encode(result))
```

Numbers become ordinary Lua numbers. Store large identifiers as JSON strings when every digit must survive conversion.

### json.array

```text
json.array(value: table) -> table
```

Marks a table as a JSON array and returns that same table. An empty marked table encodes as `[]`.

```lua
local items = json.array({})
assert(json.encode(items) == "[]")
```

The marker replaces the table's metatable and protects it from ordinary `setmetatable` calls. It does not copy or validate entries. Encoding still requires consecutive integer keys starting at `1` and refuses string keys.

### json.null

```text
json.null: userdata
```

The sentinel for a stored JSON `null`. It is truthy and compares equal to itself. Use `value == json.null` to detect it.
`tostring(json.null)` returns `"json.null"`. Each script has its own sentinel, and its metatable is locked.

Assigning Lua `nil` removes a table entry. Assign `json.null` to keep a null object field or an array position.

### Availability and limits

`json.encode` and `json.decode` are available during loading, paint, above-menu paint, menu button and change callbacks, timers, HTTP completions, ESP values, session changes, shot notifications, and unload. Each call uses 128 [native work units](../limits.md), including failed calls. The allowance is shared with other work in the same callback or source load.

`json.array` and `json.null` are available in every context and have no additional native work charge.

| Resource | Limit |
| --- | --- |
| JSON input or encoded output | Capped at 1 MiB. |
| Values | Traversal at 4,096 values. |
| Arrays and objects | Nesting at 32 levels. |

The value count includes the root, each container, and each contained value. Object keys do not add to that count. A flat array can therefore contain up to 4095 values. Encoding also caps the combined object-key bytes at 1 MiB.

Bad arguments, invalid data, an unavailable callback context, and exceeded limits raise Lua errors. These functions do not return a failure tuple or update [`why.last()`](why.md#whylast).
