# Schema

Read a field directly with [`entity:get_schema`](entity.md#entityget_schema),
or declare a reusable field during setup with `schema.field`.

`entity:get_schema` resolves the entity's concrete class automatically.
`schema.field` is useful when the class and path are already known.

## schema.field

```text
schema.field(module: string, class: string, path: string) -> schema_field
```

All three arguments are required and case-sensitive, with no embedded NUL.
`module` must be `"client.dll"`. `module` and `class` contain `1..95` bytes.
`class` is the entity's concrete schema class. Inherited fields are included.

`path` is an exact field name or a dot-separated path of up to eight fields,
with at most 1,024 bytes in total. Each field name contains `1..95` bytes.
Intermediate embedded objects, class pointers and typed entity handles can be
followed. The final field must have one of the supported value types below.
The path does not accept addresses, offsets or array subscripts.

`schema.field` is available only during source load. Calling it from a callback
raises an error. Invalid names, missing or ambiguous fields, unsupported types
and unavailable schema data raise an error during declaration. They do not
return `nil`. A successful field handle can be kept for the script's lifetime.

## Nested paths

Use a dot to follow an object's declared fields:

```lua
local position = schema.field("client.dll", "C_CSPlayerPawn",
    "m_pGameSceneNode.m_vecAbsOrigin")
local reserve_ammo = schema.field("client.dll", "C_CSPlayerPawn",
    "m_pWeaponServices.m_iAmmo")
```

A pointer's declared base class might not contain a field that belongs to its
subclass. Name that subclass before the field with `Class::field`:

```lua
local kit = schema.field("client.dll", "C_CSPlayerPawn",
    "m_pItemServices.CCSPlayer_ItemServices::m_bHasDefuser")
```

This is a checked type selection, not a raw cast. The named subclass must derive
from the pointer's declared class, and the object must have that type when read.
Otherwise the read returns `nil`.

A qualifier is allowed only after a pointer or entity-handle step, not on the
root or an embedded object. Ambiguous and virtual base conversions are not
supported.

Keep a terminal entity handle when a separate entity identity is useful. Continue
the path through the handle when only one of its declared fields is needed.
A recycled entity slot is not treated as the old entity.

## Subclass data

Weapons, grenades and other entities carry their authored data (damage, magazine
size, bullets per shot) in a separate record the game calls subclass data. The
game no longer lists the pointer to it as a field, so it is spelled by its engine
name, `m_pSubclassVData`, on any entity class. The record is not a schema class
itself, so the next step must name the record's concrete class:

```lua
on.paint(function()
    local me = entity.local_player()
    local weapon = me and me:get_schema("m_pWeaponServices.m_hActiveWeapon")
    if weapon == nil then return end
    local pellets = weapon:get_schema("m_pSubclassVData.CCSWeaponBaseVData::m_nNumBullets")
    local magazine = weapon:get_schema("m_pSubclassVData.CCSWeaponBaseVData::m_iMaxClip1")
    if pellets and magazine then render.text(24, 24, pellets .. " pellets, " .. magazine .. " rounds", color.white) end
end)
```

`schema.fields("client.dll", "CCSWeaponBaseVData")` lists what the weapon record
holds, inherited fields included; the usual type rules decide which of them read
as values. The path can also start further out, through an entity handle:
`"m_pWeaponServices.m_hActiveWeapon.m_pSubclassVData.CCSWeaponBaseVData::m_nNumBullets"`.

`m_pSubclassVData` must be followed by a `Class::field` step and cannot be the
last step, since a pointer is not a readable value. It is accepted only where the
path stands on an entity. A record of another class returns `nil` when read, like
any other qualifier.

## Concrete class names

Pass the object's concrete schema class, even when the field is declared by a
base class. A pawn's `m_iHealth` declaration uses `C_CSPlayerPawn`.
`entity.schema_class` returns the concrete schema class; `entity.designer_name`
returns its separate designer name.

The handle remembers the concrete class and checks it again on each read. An
expired entity, wrong class, unavailable entity system or invalid stored value
returns `nil` and sets [`why.last()`](why.md#whylast). A stored entity handle with
an invalid identity also returns `nil`, without supplying a new reason.

## schema_field:get

```text
schema_field:get(value: entity) -> boolean | number | string | vec2 | vec3 | color | entity | table | nil
```

Reads a copied value from an entity with the declaration's exact concrete
class. `value` must be entity userdata. Call it from `on.paint`, an ESP value
callback, `on.setup_command`, `on.command_finished`, `on.frame_stage` or
`on.game_event`. Other contexts and
invalid arguments raise an error. Unavailable values return one `nil` with
the reason behavior described above. `false` and zero are valid values.

Paint reads a copied value from the current render frame. The first paint read
can return `nil` until the field is available on the next frame. No command
callback or living local player is required.

An absent pointer, expired intermediate handle, wrong pointed-to type, invalid
number, unreadable string or refused collection returns `nil` with a reason.
An empty string or empty array is a valid value and is not replaced with `nil`.

```lua
local health = schema.field("client.dll", "C_CSPlayerPawn", "m_iHealth")

on.paint(function()
    local me = entity.local_player()
    if me == nil then return end
    local value = health:get(me)
    if value == nil then return end
    render.text(24, 80, string.format("health: %d", value), color.white)
end)
```

Saved values keep the sample they were read from. Call `get` again for a new
value. Strings and array tables are copied into Lua, so retaining one does not
retain a game pointer or pin a native render frame. Editing a returned table
changes only that Lua table, never the game or a later read.

## schema_field:set

```text
schema_field:set(value: entity, new_value: boolean | number | vec2 | vec3 | color) -> true | nil
```

Writes this field on an entity. Requires **allow unsafe scripts** and an active
game-main `on.frame_stage` or `on.game_event` callback, and accepts the same
value kinds as [`entity:set_schema`](entity.md#entityset_schema). Returns `true`,
or `nil` with `why.last()` set when the entity is unavailable or the write is refused.

## schema_field.kind

```text
schema_field.kind: string
```

Returns the field's value kind. These are the exact strings and return types:

| Kind | Width | Returned value |
| --- | --- | --- |
| `bool` | `1` | boolean. |
| `signed_integer` | `1`, `2`, `4`, `8` | Integer number for 8-, 16- and 32-bit fields. Decimal string for 64-bit fields. |
| `unsigned_integer` | `1`, `2`, `4`, `8` | Integer number for 8-, 16- and 32-bit fields. Decimal string for 64-bit fields. |
| `float32` | `4` | Finite number. |
| `float64` | `8` | Finite number. |
| `vector2` | `8` | `vec2` userdata. |
| `vector3` | `12` | `vec3` userdata. |
| `angle` | `12` | `vec3` userdata, with pitch, yaw and roll in degrees. |
| `color` | `4` | `color` userdata. |
| `entity_handle` | `4` | Entity userdata, or `nil` for an invalid identity. |
| `string` | `8` | Copied string from `CUtlString` or `CUtlSymbolLarge`. |
| `array` | Native field size | A table with `.count` and one-based numeric entries. |

64-bit integers always use decimal strings, even for small values. Supported
vector, angle and color schema types are `Vector2D`, `Vector`, `QAngle` and
`Color`. Entity fields must be `CHandle<T>`. Raw pointer values, class objects,
arbitrary containers and unsupported wrappers are not returned as values.

Returned values can be saved and do not update with the entity. A returned
entity identity is not checked for current liveness and can already be expired.
Use `entity.valid` in a supported callback to check it.

## Strings and arrays

`CUtlString` and `CUtlSymbolLarge` are copied through their terminating NUL.
Their native null representation becomes an empty string. Invalid non-null
storage is unavailable, not an empty-string fallback. String bytes are preserved;
the API does not repair their encoding.

Fixed arrays and supported `CUtlVector` / `CNetworkUtlVectorBase` collections
return tables. Their elements may be supported scalar values, strings, entity
handles or further supported arrays. An empty collection returns `{count = 0}`.
Nested arrays each have their own `.count`.

Use `.count` as the array length. An invalid entity handle produces a
`nil` entry at its original position, without shifting later entries. Lua's `#`
and `ipairs` do not reliably represent arrays with those holes:

```lua
local inventory = schema.field("client.dll", "C_CSPlayerPawn",
    "m_pWeaponServices.m_hMyWeapons")

on.paint(function()
    local me = entity.local_player()
    if not me then return end
    local weapons = inventory:get(me)
    if not weapons then return end
    for index = 1, weapons.count do
        local item = weapons[index]
        if item and item.valid then
            render.text(24, 100 + index * 18,
                "inventory entry " .. tostring(item.index), color.white)
        end
    end
end)
```

One result supports up to four array nesting levels, 256 total array entries
across all levels, and 4,096 total string bytes. A nested array itself occupies
an entry in its parent. A fixed character array remains an array of character
values. It is not implicitly converted to text. Over-limit or malformed results
are refused as a whole, never returned as a shortened prefix.

## schema_field.width

```text
schema_field.width: integer
```

Returns the terminal field's native storage size in bytes. Use it with `kind`
to distinguish integer widths. For strings this is the native string object's
size, not the text length. For a vector it includes the native container storage,
not the sum of its elements. Use the returned string's `#value` or an array's
`.count` for the copied value's length.

`kind` and `width` are readable in every context. Both are read-only. Assigning
a property raises an error. An unknown property returns `nil`.

## Read allowances

Each read costs one native work unit per path field. An array result adds
16 units. A string result, or an array whose terminal elements are strings,
adds 64. These are conservative costs even for an empty result. For example,
a direct integer costs one, a two-field path to an integer costs two, and a
two-field path to a numeric array costs 18.

Reads use the current callback's [native-work allowance](../limits.md#native-calls).
Standard mode enforces 256 units per callback and 4,096 during setup. Resolving a
declaration costs 32 units during setup. Exhausting an enforced
allowance raises an error. Unsafe mode keeps the same counters as advisory
measurements.

Across all scripts, paint can capture 1,024 distinct declarations, 16,384 field
values, 32,768 array entries, 1 MiB of string data and 16,384 native-work units
per frame. Failed reads count too.

If a value cannot fit within those limits, the complete value is unavailable and
`why.last()` records the reason. Partial arrays or strings are not returned as
successful results.


## Weapon inventory

Inventory already uses the same captured handle-array reader as other schema
collections. Read it once and keep the returned identities for the callback:

```lua
on.paint(function()
    local pawn = entity.local_player()
    if not pawn then return end
    local carried = pawn:get_schema("m_pWeaponServices.m_hMyWeapons")
    local active = pawn:get_schema("m_pWeaponServices.m_hActiveWeapon")
    if not carried then return end
    for index = 1, carried.count do
        local weapon = carried[index]
        if weapon and weapon == active then
            -- This carried weapon was active in the captured sample.
        end
    end
end)
```

Both declared paths share the current render capture. First requests may wait
for the next capture. Invalid handles remain missing array entries; use `count`
to preserve their positions. The returned array owns no live game storage.


## schema.fields

```text
schema.fields(module: string, class: string, cursor: integer = 0) -> table | nil
```

Inspects registered field metadata, including inherited declarations. `module`
currently accepts `"client.dll"`. This does not read a live entity and is
available during setup or callbacks.

Returns `fields`, `total` and an optional `next_cursor`. Each page contains up
to 64 fields with `name`, `declaring_class` and `native_type`. Pass `next_cursor`
to continue. Cursor zero starts a query. A cursor at `total` returns an empty
page. A class with no fields returns `fields = {}` and `total = 0`.

The native type name describes the schema declaration. It does not promise
that the value reader supports that terminal type. A missing class, malformed
metadata or cursor beyond `total` returns `nil` and sets `why.last()`. Cursors
must be nonnegative whole 32-bit indices. Invalid arguments raise an error.
No addresses or field offsets are returned; unsafe scripts can take an entity's
address with [`entity:address`](entity.md#entityaddress).
