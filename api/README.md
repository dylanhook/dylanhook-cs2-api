# API reference

Use a dot for module functions, such as `render.text(...)`, and a colon for object methods, such as `event:get_int(...)`. Properties are read with a dot: `control.value`.

## Reading a signature

Signature blocks describe a function's arguments and results. The Lua examples below them show calls you can use in a script.

| Notation | Meaning |
| --- | --- |
| `name: number` | An argument or property named `name`, with its type |
| `= value` | The default when that argument is omitted |
| `string \| nil` | Either a string or `nil` |
| `string[]` | An array of strings |
| `-> number, number` | Two return values, in that order |

A `?` on a type also means it may be `nil`. `integer` means a whole number. Ranges and units are listed with each call. Check those details before combining values from different functions.

## Callbacks and controls

| Page | Contents |
| --- | --- |
| [Callbacks](../events.md) | `on`, game events, timers and subscriptions |
| [Menu](menu.md) | Destinations, control constructors, values and saved IDs |
| [Native settings](native_settings.md) | Discover native keys, read effective/base values and own temporary overrides |
| [Input](input.md) | Keys, cursor state and draggable panels |

## Drawing

| Page | Contents |
| --- | --- |
| [Render](render.md) | Shapes, text, fonts, images and projection |
| [Native ESP contributions](esp.md) | Flags, text, bars and measured custom items in the native layout, and player chams and glow |
| [Color](../types/color.md) | Color values and interpolation |
| [vec2](../types/vec2.md) | Vectors with two components |
| [vec3](../types/vec3.md) | Vectors with three components |

## Game data

| Page | Contents |
| --- | --- |
| [Globals](globals.md) | Clocks, tick conversion, connection state and latency |
| [Entities and players](entity.md) | Entity handles, player reads and spectator lists |
| [Bones and hitboxes](pose.md) | Skeletons, named bones, hitboxes and capsule geometry |
| [Weapon](weapon.md) | The local weapon's classification |
| [Game](game.md) | Map name, planted bomb, captures, native feature state and the item catalog |
| [Command](cmd.md) | Command values, buttons, movement and angles |
| [Trace](trace.md) | Visibility, line and shape traces, bullet and surface results |
| [Schema](schema.md) | Typed field reads |
| [Cvar](cvar.md) | Console variable lookup and values |

## Utilities

| Page | Contents |
| --- | --- |
| [Console](console.md) | Messages, queued console commands and commands of your own |
| [Panorama](panorama.md) | JavaScript in the game's HUD, with the result returned to Lua |
| [Script runtime](script.md) | Execution limits, measurements and self reload/unload |
| [Client identity](client.md) | The current public account name |
| [Configs](config.md) | Saved profiles, queued operations and declared script values |
| [HTTP](http.md) | Asynchronous requests, responses and cancellation |
| [WebSocket](websocket.md) | Connections, text/binary messages, polling and closure |
| [System clock](system.md) | Unix timestamps, local dates and calendar fields |
| [Notifications](notify.md) | Messages on screen |
| [Sound](sound.md) | Game sounds and owned local WAV clips |
| [Files and assets](resources.md) | Packaged assets and saved data |
| [Clipboard](clipboard.md) | Copy and paste text with unsafe permission |
| [Lua and JSON](std.md) | Built-in libraries, `require` and JSON |
| [Byte utilities](bytes.md) | Base64 and SHA-256 |
| [FFI](memory.md) | Permission, native value types, game addresses and function hooks |
| [Why](why.md) | Reasons for unavailable results |

A call's available data depends on the callback using it. [Script basics](../concepts.md) explains how to collect values in one callback and use them in another.
