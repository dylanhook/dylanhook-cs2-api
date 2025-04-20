# FFI

LuaJIT's FFI library provides C types, owned data buffers, and calls to declared C functions. Load it with `local ffi = require("ffi")`.

## Permission

Unsafe script APIs start disabled. Enable **allow unsafe scripts** in the Lua
manager, then load or reload the script. This enables FFI,
[`loadstring`](std.md#loadstring), [HTTP](http.md),
[clipboard access](clipboard.md), the [game memory](#game-memory) helpers,
[`panorama.run`](panorama.md#panoramarun) and
[`entity:address`](entity.md#entityaddress). A denied request raises:

```text
unsafe script APIs are disabled; enable 'allow unsafe scripts' in lua actions, then reload the script
```

The setting is applied when the script loads. Changing it does not affect an
already running script until reload or unload. A failed reload keeps the previous
version running.

FFI can call native code and access native memory. Enable it only for scripts you
trust. Invalid pointers, wrong declarations and out-of-bounds accesses can crash
the game.

Unsafe mode does not enforce the standard Lua memory, VM instruction or
native-work limits. API-specific resource limits still apply, but they cannot
contain arbitrary FFI calls or memory allocated outside Lua. `pcall` does not
protect against a native crash.

## Types and values

In the signatures below, `ctype_arg` means a C declaration string, a ctype object, or a cdata value whose type should be used. A ctype describes a C type. Cdata holds a C value.

Arrays use C's index `0` for their first element. Data made by `ffi.new` stays alive while the script keeps a reference to it. Keep that owner alive whenever another value points into it.

```lua
local ffi = require("ffi")
local samples = ffi.new("uint8_t[4]", {10, 20, 30, 40})
local total = 0

for index = 0, 3 do
    total = total + samples[index]
end

console.log(string.format("sample total: %d", total))
```

## ffi.cdef

```text
ffi.cdef(declarations: string, ...: any) -> no values
```

Declares C types, function signatures, and external variables. It parses declarations. It does not compile function bodies or load a library. Extra arguments can fill LuaJIT declaration placeholders.

```lua
local ffi = require("ffi")
ffi.cdef[[
    typedef struct {
        double width;
        double height;
    } layout_size;
]]

local size = ffi.new("layout_size", {240, 120})
console.log(string.format("area: %g", size.width * size.height))
```

## ffi.new

```text
ffi.new(c_type: ctype_arg, ...: any) -> cdata
```

Allocates a value of the requested type. Optional initializer values or a table set its contents. Uninitialized storage is zeroed. For a variable-length array type such as `"uint8_t[?]"`, the next argument supplies the element count before any initializer.

The returned value owns its allocated storage. Calling a ctype object uses the same construction rules unless its metatype defines a custom `__new` constructor.

## ffi.typeof

```text
ffi.typeof(c_type: ctype_arg, ...: any) -> ctype
```

Returns a reusable ctype. Extra arguments can fill placeholders in a declaration string. A cdata argument returns its type.

```lua
local ffi = require("ffi")
local pair = ffi.typeof("struct { double x; double y; }")
local point = pair(16, 24)
console.log(string.format("point: %g, %g", point.x, point.y))
```

## ffi.cast

```text
ffi.cast(c_type: ctype_arg, value: any) -> cdata
```

Converts a value to a numeric, enum, or pointer type using C conversion rules. The result is cdata. A pointer cast does not copy the pointed-to data or keep its owner alive.

## ffi.istype

```text
ffi.istype(c_type: ctype_arg, value: any) -> boolean
```

Checks whether a cdata value or ctype matches the requested C type under LuaJIT's type rules. Ordinary Lua values return `false`. When `c_type` names a struct, a pointer to that same struct also matches. Requesting a pointer type does not make a struct value match.

## ffi.sizeof

```text
ffi.sizeof(c_type: ctype_arg) -> integer | nil
ffi.sizeof(c_type: ctype_arg, element_count: integer) -> integer | nil
```

Returns the size in bytes. A variable-length type needs an element count. A variable-length value created earlier supplies its own allocated size. An incomplete type whose size cannot be determined returns `nil`.

## ffi.alignof

```text
ffi.alignof(c_type: ctype_arg) -> integer
```

Returns the type's alignment in bytes.

## ffi.offsetof

```text
ffi.offsetof(c_type: ctype_arg, field: string) -> integer
ffi.offsetof(c_type: ctype_arg, bitfield: string) -> integer, integer, integer
```

Returns a field's byte offset. A bitfield returns its byte offset, bit position, and bit width. A missing field or a type without the requested field returns no values. Assigning that result gives `nil`.

## ffi.string

```text
ffi.string(data: cdata | string, length: integer | nil = nil) -> string
```

Copies bytes into a Lua string. With an explicit length, the copy includes embedded NUL bytes. Omitting the length or passing `nil` copies through the first NUL without including it. The source must remain readable for the whole requested range.

## ffi.copy

```text
ffi.copy(destination: cdata, source: cdata | string, length: integer) -> no values
ffi.copy(destination: cdata, source: string) -> no values
```

Copies bytes into writable storage. Omitting the length is allowed for a Lua string and copies its trailing NUL too. The destination must have enough room. The source and destination ranges must not overlap.

```lua
local ffi = require("ffi")
local text = "ready"
local buffer = ffi.new("char[?]", #text + 1)
ffi.copy(buffer, text)
assert(ffi.string(buffer) == text)
```

## ffi.fill

```text
ffi.fill(destination: cdata, length: integer, byte: integer = 0) -> no values
```

Fills writable storage with the low byte of `byte`. Omitting it or passing `nil` fills with zeroes. The destination must contain the whole requested range.

## ffi.metatype

```text
ffi.metatype(c_type: ctype_arg, metatable: table) -> ctype
```

Associates Lua behavior with a struct, union, complex, or vector type and returns its ctype. The association applies to that type's values and can be set only once. Keep the metatable and its `__index` table unchanged after registration.

## ffi.gc

```text
ffi.gc(value: cdata, finalizer: function | cdata | nil) -> cdata
```

Attaches a finalizer to an eligible pointer, struct, or array value and returns the same value. The finalizer receives the value when it is collected. Passing `nil` removes the attached finalizer.

Use [`on.unload`](../events.md#onunload) when cleanup needs a Dylanhook callback
context. Garbage collection does not create a new callback context.

## ffi.errno

```text
ffi.errno() -> integer
ffi.errno(value: integer) -> integer
```

Returns the current C `errno` value. With an argument, it also sets `errno` and returns the previous value. A called C function determines whether its result gives `errno` any meaning.

## ffi.abi

```text
ffi.abi(name: string) -> boolean
```

Checks an ABI property, such as `"64bit"`, `"le"`, or `"win"`. Returns `false` for an unknown or inactive property.

## ffi.os and ffi.arch

```text
ffi.os: string
ffi.arch: string
```

Describe the current platform. This build reports `"Windows"` and `"x64"`.

## ffi.C

```text
ffi.C: library
```

The default namespace for declared C functions, variables, and constants. A declaration describes a symbol. That symbol must also be available for a function or variable lookup to succeed. Undeclared or unavailable symbols raise an error.

## ffi.load

```text
ffi.load(name: string, global: boolean = false) -> library
```

Loads a native library and returns its symbol namespace. A name without a slash, backslash, or dot gets a `.dll` suffix. Access its declared exports through the returned namespace. A load or symbol lookup failure raises an error.

Windows ignores `global`. Keep the namespace alive while using function or variable references obtained from it.

## ffi.typeinfo

```text
ffi.typeinfo(type_id: integer) -> table
```

Looks up a numeric LuaJIT type ID. A valid ID returns a table with `info`, the type flags, and any applicable `size`, `sib`, and `name` fields. `size` is a size value, `sib` is a related type ID, and `name` is the type's stored name. An unknown ID returns no values.

## Game memory

Three helpers hand you the game's own addresses as FFI `void*` values, so an
FFI script does not scan memory or walk export tables in Lua, and
[`memory.hook`](#memoryhook) redirects a game function to a Lua callback. They require
**allow unsafe scripts**; a denied script raises the permission error above.
An address is never returned as a Lua number.

Cast the pointer to the type you need, and keep offsets in your own script:
the game can move them in any update.

### memory.find_pattern

```text
memory.find_pattern(module: string, pattern: string) -> cdata | nil
```

Scans the code section of a loaded game module, such as `"client.dll"`, for an
IDA-style byte pattern: hex bytes separated by spaces, with `?` or `??` for any
byte. Returns the address of the match.

A pattern must match exactly once. A pattern that also matches somewhere else
returns `nil` with the reason `not_unique` rather than the first match, because a
signature that has become ambiguous after an update would otherwise point at the
wrong code without telling you. Lengthen the pattern until it is unique. No match
returns `nil` with `not_found`; an unloaded module returns `nil` with
`not_loaded`. A malformed pattern raises an error.

The module name is 1 to 64 printable ASCII characters, with or without `.dll`.
The pattern is at most 1,536 characters. A scan reads the whole code section, so
resolve patterns while the script loads and keep the results.

```lua
local ffi = require('ffi')
local anchor = memory.find_pattern('client.dll', '48 89 5C 24 ? 57 48 83 EC 20')

if anchor then
    local target = ffi.cast('uint8_t*', anchor)
    print(string.format('first byte %02X', target[0]))
else
    print('pattern unavailable: ' .. (why.last() or 'no reason'))
end
```

### memory.interface

```text
memory.interface(module: string, name: string) -> cdata | nil
```

Returns an interface the module registered with the game's interface factory,
such as `memory.interface('engine2.dll', 'Source2EngineToClient001')`. The name
matches the first registered interface whose name starts with it, so a version
suffix can be left off. Unknown names and unloaded modules return `nil` with a
reason in `why.last()`.

### entity:address

See [entity:address](entity.md#entityaddress). It returns a live entity's address
from a game callback.

### memory.hook

```text
memory.hook(target: cdata, returns: string, arguments: string[], callback: function(...: any)) -> function_hook
```

Redirects a game function to `callback`. Every call of the function, from any
thread, runs `callback` with the function's arguments; what the callback
returns is what the caller receives. The original function stays callable as
[`hook.original`](#hookoriginal).

Call it while the script loads. `target` is a pointer to the first instruction
of a function in a loaded module's code, such as a
[`memory.find_pattern`](#memoryfind_pattern) result or a pointer read out of an
interface's function table. `returns` is the C return type, or `"void"`.
`arguments` lists up to 20 C argument types in order; pass `{}` for none.
Each type name is 1 to 64 bytes of letters, digits, underscores, spaces and
`*`, and may name a type declared with [`ffi.cdef`](#fficdef). Integers,
floating-point numbers, booleans and pointers are supported; a structure passed
or returned by value is refused while loading.

```lua
-- replace the pattern and the signature with your function's own.
local entry = memory.find_pattern('client.dll', '40 53 48 83 EC 20 8B D9 E8 ? ? ? ? 84 C0')
local calls = 0
local hook

if entry then
    hook = memory.hook(entry, 'int', {'int'}, function(value)
        calls = calls + 1
        return hook.original(value)
    end)
end
```

The function is redirected when the script finishes loading, so the handle's
`active` property is `false` inside the loading code. Unloading, a reload and
`hook:remove()` put the original entry back; a call already inside the callback
finishes first. A reload redirects the function again for the new version.

If the callback raises an error, or returns a value that does not convert to
`returns`, the hook is removed, the error is reported in the console, and that
call returns what the original function returns. No error reaches the game.

The callback runs on the thread that called the function. Calls are serialized
with the script's other callbacks: a call from another thread waits while the
script is running one, so a slow callback slows the game. Only thread-independent
work is available: copied values, FFI, `console.*` output and queued actions
such as `console.exec`. Drawing, input reads, live player reads and menu value
writes are not. The callback can call the hooked function again. Nested
callbacks share the script's limit of 8 active callbacks; past it, the call runs
the original without the callback. A call that takes longer than 1 ms is
reported once for that hook.

A load stops with `memory.hook refused: <reason>` when the function cannot be
redirected:

| Reason | Meaning |
| --- | --- |
| `target_not_module_code` | `target` is not inside a loaded module's code. |
| `target_misaligned` | `target` is not the start of a function. |
| `target_is_jump` | The function starts with a jump, such as a forwarding stub or another redirection. Hook the jump's destination. |
| `prologue_refused`, `prologue_too_long` | The function's first instructions cannot be moved aside. |
| `table_full` | The session's 128 function slots are used. |
| `hook_limit` | This script already has 32 hooks. |
| `duplicate_target` | This script already hooks this function. |

Other reasons mean the memory for the redirection could not be prepared, or
the function's first bytes changed since it was first hooked. Two loaded scripts cannot
hook the same function: the second load is refused with a message naming the
hook. Each distinct function hooked during a game session keeps one of 128
slots until the game closes, so reloading a script does not use more. Preparing
a hook costs 64 native work units.

Wrong type names, a wrong argument count or a callback that corrupts memory can
crash the game. `pcall` does not protect against a native crash.

### hook.original

```text
hook.original: cdata
```

The original function, as a callable FFI function pointer of the hook's
signature. Calling it runs the game's code without the callback. It stays
callable after `hook:remove()`.

### hook.active

```text
hook.active: boolean
```

`true` while the function is redirected to the callback. `false` while loading,
after removal, after a callback error, or when the function could not be
redirected at the end of the load.

### hook:remove

```text
hook:remove() -> boolean
```

Puts the original entry back. Returns `true` when it removed an active hook,
`false` when the hook was already inactive. Calls already inside the callback
finish normally. A removed hook cannot be activated again without a reload.

## C callbacks

Converting a Lua function to a C function-pointer type creates a callback value.
Keep it alive while any C code can call it, and stop those calls before
releasing it. This does not register a Dylanhook event callback.

`callback:set(function)` replaces the Lua function behind an existing FFI
callback. `callback:free()` releases that callback. The pointer must no longer
be used afterward. Both methods return no values and raise an error when the
value does not identify an active FFI callback.

Argument, declaration and symbol-lookup failures raise Lua errors. They do not
update [`why.last()`](why.md#whylast). Dylanhook API calls made by an FFI
callback still require the appropriate [callback context](../events.md).
