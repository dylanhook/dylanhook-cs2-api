# Cvar

Look up a convar by name, read its current value, or queue a change. Lookups
and reads work while the script loads and in every callback. Writes require
an active callback.

## cvar.get

```text
cvar.get(name: string) -> cvar_ref | nil
```

Returns a handle for the named console variable. `name` is required and must
contain `1..255` bytes with no embedded NUL. Names can also be opened directly:

```lua
local gravity = cvar.sv_gravity
local named_gravity = cvar["sv_gravity"]
local gravity_again = cvar.get("sv_gravity")
```

Use `cvar.get(name)` for variable names or names that match a module member,
such as `get`. Lookup is available during source load and every callback.
Invalid names, missing convars and unavailable services return `nil` and set
[`why.last()`](why.md#whylast).

A reference keeps its name and type, then resolves the current entry by name
for each read or write. It can be saved between callbacks.

## Properties

```text
ref.name: string
ref.type: string
ref.value: boolean | number | string | color | vec2 | vec3 | table | nil
ref.value = value
```

`name` and `type` are read-only and available in every context. Assigning
another property raises an error. Reading an unknown property returns `nil`.

## ref.value

Reading returns a fresh value using the representation below. An unreadable
entry, changed type or invalid value reads as `nil` and sets `why.last()`.
`false`, zero and an empty string are valid results.

Assigning queues a value matching the reference's discovered type and requires
an active callback. Assigning during source loading raises an error.

The queue holds a copy of the reference and value. Changing a table later does
not change the request. Writes run later in queue order with `console.exec`.
Reading immediately after an assignment can still return the previous value.

The shared queue holds 128 pending console commands and convar writes across
all scripts. Invalid values, unavailable queues and a full queue raise an
error. A later refusal or adjustment is logged with the script and convar names.
Read again in a later callback to see the resulting value.

## ref:get_bool

```text
ref:get_bool() -> boolean | nil
```

Reads a `bool` convar. Other convar types raise an error. Unavailable values
return `nil` with the same reason behavior as reading `ref.value`.

## ref:get_int

```text
ref:get_int() -> number | string | nil
```

Reads `int16`, `uint16`, `int32`, `uint32`, `int64` or `uint64`. The 64-bit
types return decimal strings. The others return exact integer numbers.
Other types raise an error. Unavailable values return `nil`.

## ref:get_float

```text
ref:get_float() -> number | nil
```

Reads `float32` or `float64`. Other convar types raise an error. Unavailable
values return `nil`.

## ref:get_string

```text
ref:get_string() -> string | nil
```

Reads a `string` convar. Other types raise an error. This method does not
convert their values to text. Unavailable values return `nil`.

## Value types

These are the exact strings returned by `ref.type`:

| Type | Lua value |
| --- | --- |
| `bool` | boolean. |
| `int16`, `uint16`, `int32`, `uint32` | Exact integer number. |
| `int64`, `uint64` | Exact decimal string, even for small values. |
| `float32`, `float64` | Finite number. |
| `string` | Copied string. |
| `color` | `color` userdata. |
| `vector2` | `vec2` userdata. |
| `vector3`, `qangle`, `vectorws` | `vec3` userdata. |
| `vector4` | Plain table with `[1]` through `[4]` and `.x`, `.y`, `.z`, `.w`. |

Each callback read costs one native-work unit, including `.value` and the typed
getters. Standard mode raises an error when the callback allowance is exhausted.

Returned strings, vectors, colors and tables are copies. Changing them does
not update the convar. The array and named fields of a `vector4` are separate
copies. Changing `.x` does not change `[1]`. `qangle` values use pitch, yaw
and roll in degrees.

```lua
local gravity = cvar.get("sv_gravity")

on.paint(function()
    if not gravity then return end
    local value = gravity.value
    if value == nil then return end

    render.text(24, 80, "gravity: " .. tostring(value), color.white)
end)
```

The typed setters below queue the same way as assigning `ref.value`, and first
require the convar to have their type. `true` means accepted into the queue.

## ref:set_bool

```text
ref:set_bool(value: boolean) -> true
```

Queues a value for a `bool` convar. The value must be an actual boolean.
Other convar types and non-boolean values raise an error.

## ref:set_int

```text
ref:set_int(value: number | string) -> true
```

Queues a value for any integer convar type. The value must be integral and
within that type's range. Use decimal strings for 64-bit values outside the
exact numeric range below. Other convar types raise an error.

## ref:set_float

```text
ref:set_float(value: number) -> true
```

Queues a value for a `float32` or `float64` convar. The number must be finite
and fit that type. Other convar types raise an error.

## ref:set_string

```text
ref:set_string(value: string) -> true
```

Queues a value for a `string` convar. Empty strings are accepted. The value
must contain at most 4096 bytes and no embedded NUL. Other convar types and
invalid values raise an error.

All typed setters share the `ref.value` assignment's queue and callback rules. The type
in their name selects a convar type. It does not change the convar's type.

## Accepted write values

Values must match the discovered type. Integer limits are inclusive:

| Type | Minimum | Maximum |
| --- | --- | --- |
| `int16` | `-32768` | `32767` |
| `uint16` | `0` | `65535` |
| `int32` | `-2147483648` | `2147483647` |
| `uint32` | `0` | `4294967295` |
| `int64` | `-9223372036854775808` | `9223372036854775807` |
| `uint64` | `0` | `18446744073709551615` |

64-bit setters accept exact decimal strings within those ranges. Numeric input
must be an integer in `-9007199254740991..9007199254740991` for `int64`, or
`0..9007199254740991` for `uint64`. Strings contain only digits, with an optional
leading `-` for signed values. Spaces, `+`, decimal points and exponents are rejected.

Boolean values must be booleans. Floats must be finite and fit their type.
Strings may be empty, are limited to 4096 bytes and must not contain NUL.
Colors, vectors and angles require the corresponding userdata above. Use finite
vector components. `vector4` requires finite numbers at indices `1` through `4`.
named fields do not supply those values.
