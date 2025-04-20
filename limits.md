# Limits

These limits apply to each loaded script unless a row says otherwise. Individual
API pages describe how a limit is reported.

## Files and loaded scripts

| Resource | Limit |
| --- | --- |
| Source file | 16 MiB of text. Compilation also needs room in the Lua heap. |
| Source filename | 98 UTF-8 bytes, including `.lua` |
| Scripts in the manager | 64 across the scripts folder |
| Successful loads and reloads | No cumulative session limit |
| Lua memory | 16 MiB in standard mode. Not enforced in unsafe mode |
| `loadstring` source | 256 KiB of text |
| `loadstring` chunk name | 1-96 bytes without NUL |
| Local module name | 1-64 lowercase identifier bytes, no path or extension |
| Local module source | 256 KiB per file, 1 MiB total per load |
| Uncached module loads | 32 attempts per load, including failures |
| Nested callbacks | 8 active invocations per script. A deeper callback is skipped for that dispatch. |

Reloads are not limited by a session-wide counter.

## Registrations

| Resource | Limit |
| --- | --- |
| `on.*` callbacks, excluding game events | 256 |
| Game-event subscriptions | 64 |
| Active timers | 128 |
| Menu controls | 128, including buttons, labels and attached colors |
| Cached concrete entity classes | 128 |
| Distinct registered schema fields | 1,024 across all scripts, 512 per script. Resolving a field again reuses its registration. |
| Captured entity-field values | 16,384 across all scripts per frame |
| Captured schema array entries | 32,768 across all scripts per frame |
| Captured schema string bytes | 1 MiB across all scripts per frame |
| Schema capture work | 16,384 native work units across all scripts per frame |
| One schema result | Four array levels, 256 total array entries, 4,096 total string bytes |
| Schema path | Eight fields, 1,024 bytes total, 95 bytes per field name |
| Pose sample | 256 bones and 40 hitboxes per pawn |
| Native ESP contributions | 128 flag, text, bar and item registrations across the loaded script set |
| Chams and glow overrides | 8 `esp.chams` and 8 `esp.glow` per script |
| Console commands | 16 per script, 64 across all loaded scripts |
| Function hooks | 32 per script. 128 distinct functions per game session across all scripts; a function keeps its slot until the game closes. |
| ESP text result | 256 bytes, one printable line |
| Native setting claims | 128 per loaded script, 64 scripts per setting |
| Native setting discovery | 64 paths per page, 512 bytes per path or prefix |
| Menu control labels | 128 bytes |
| Console command names | 63 bytes, with 255 bytes of help text |
| Game-event names | 96 bytes |
| Timers | `timer.after` from 0 through 86,400 seconds, `timer.every` from 0.001 through 86,400 seconds |
| Pending trace requests | 32 per script |
| HTTP requests and WebSocket handles | 8 per script in total, in any mix. All scripts share 16 transport slots and 4 connection/request operations in flight. Open sockets release their connection allowance. Closed handles keep their slot until collected or unloaded. |

An `.all` menu control counts once, even when several pages display it. Registration and removal rules are covered under [callbacks](events.md) and [menu](api/menu.md).

## Execution mode

**allow unsafe scripts** is applied when a script loads. Imported profiles cannot
turn it on.

[`script.budget()` and `script.stats()`](api/script.md) report the active mode,
work use and completed callback timings. Text source remains capped at 16 MiB and
precompiled bytecode is not supported.

### Standard execution

| Work | Instruction allowance | Elapsed-time warning |
| --- | ---: | ---: |
| Source setup | 4,194,304 | 50 ms |
| `paint`, `paint_above_menu`, `unload` | 262,144 per callback | 2 ms |
| Other callbacks | 262,144 per callback | 1 ms |

Exceeding the instruction allowance rejects a load or disables the callback. An elapsed-time warning is reported after successful completion and doesn't disable it. `pcall` cannot reset an exhausted instruction allowance. Pattern matching counts its backtracking steps as instructions, so `string.find` and its relatives cannot run past the allowance inside one native call.

Some limits stop one invocation without disabling its callback: an exhausted native-work allowance, and an instruction allowance that a shared pass had already partly spent. The callback runs again on its next event. Command changes staged by a stopped invocation are discarded.

Unsafe mode does not enforce the VM instruction or Lua memory limits above.
Allocation can still fail, and API-specific resource limits still apply.

[ESP value callbacks](api/esp.md) share one native-work and instruction allowance
per script for the ESP frame, and a script's due timers share one per frame.
Ordinary paint has its own allowance.

## Native calls

Standard mode permits **256 units per callback** and **4,096 during setup**.
Unsafe mode keeps the same values for measurement but does not stop the callback
when they are crossed. Not every API call has a native-work charge. Resource and
argument limits still apply in both modes.

| Operation | Units per call |
| --- | ---: |
| Cvar value read during a callback | 1 |
| Schema-field read | 1 per path field, plus 16 for an array and 64 for a string terminal. See [schema](api/schema.md#read-allowances). |
| `entity:get_schema` | Field-read cost + 1, plus 32 for a new concrete-class/path pair |
| `entity.at`, `entity.designer_name` in paint | 1 |
| First resolution of a concrete entity class | 32 |
| Class queries | See [entity query budgets](api/entity.md#entityget_all_by_class) |
| `game.bomb_snapshot`, `entity.planted_c4` in paint | 1 |
| `trace.visible`, `trace.line` | 1 |
| `trace.hull`, `trace.sphere`, `trace.scale_damage`, `render.clip` | 2 |
| `cmd:set_aim_angles` with `keep_camera`, on a server without sub-tick view movement | 2 |
| `render.transform` | 2 + floor(transformed vertices / 256) |
| `render.opacity` | 2 + floor(submitted vertices / 256) |
| `render.layer` | 1 |
| `render.gradient_corners` | 1 + floor(prepared vertices / 256) |
| `trace.bullet`, `trace.surface_probe`, `trace.smoke`, `trace.smoke_density` | 32 |
| `schema.field`, during setup | 32 |
| `game.bomb_snapshot`, `entity.planted_c4` in command callbacks | 64 |
| `sound.play_game`, clipboard operations | 64 |
| File operations | 64, plus 1 per started 64 KiB read or written |
| `json.encode`, `json.decode`, `render.load_image`, `render.prepare_image` | 128 |
| `render.load_font`, `render.load_font_file`, `sound.load_file` | 128 |
| `render.load_rgba` | 1 + 1 per started 64 KiB of input |
| `sound_clip:play` | 64 |
| `render.text`, with a built-in or custom font | 3 + floor(text bytes / 256) |
| `render.measure_text`, with a built-in or custom font | 1 + floor(text bytes / 256) |
| `layout:size()` | 1 + floor(text bytes / 256) |
| `layout:draw()` | 3 + floor(text bytes / 256) |
| `menu.active_binds` | 8 + 1 per started group of 8 returned rows |
| `control:set_options` | 8 per attempt, then `ceil((old + new label bytes) / 256) + ceil(6 * (old + new option counts) / 64)` after argument validation |
| `loadstring` | 64 + 1 per started 4 KiB of source |
| Uncached local `require` | 64 for a read attempt, plus 64 + 1 per started 4 KiB after a successful read |
| `system.date`, `input.key_name` | 16 |
| Config save, load, delete, rename, reset and import | 64, plus 1 per started 256 bytes of import data |
| `config.export` | 64 |
| `script.list` | 32 |
| Path preparation (`render.polygon` and the other path constructors) | 128 + floor(path commands / 16) |
| `game.grenade_path` | 64, plus 1 per started 16 points and contacts |
| `trace.grenade` | 128, plus 1 per started 16 points and contacts |
| `game.grenade_warnings` | 16 |
| `game.catalog` | 64 per page |
| `schema.fields` | 32, plus 1 per returned field and 1 per started 512 fields in the class |
| Control `info()`, `binds()` and `set_binds()` | 16 |
| `base64.encode`, `base64.decode` | 1 + floor(bytes / 4096) |
| `hash.sha256` | 16 + floor(bytes / 4096) |
| `cmd:override_setting`, `cmd:set_target_policy` | 2 |
| Player preference reads | 1. Writes cost 8. |
| `http.read` | 1, even when no chunk is ready |
| `print` | 1 + argument count, with at most 64 arguments |
| Pose read helpers | 1 per call, plus 32 for a fresh live sample |
| `menu.find`, `menu.settings` | 32 per lookup/page |
| Native setting reads, writes and overrides | 1 per call. `ref:info()` costs 16. |
| ESP callback evaluation | 1 plus its own API work, shared across the script's ESP frame |
| HTTP request submission | 8. Network wait time is asynchronous. |
| `memory.interface` | 8 |
| `memory.find_pattern`, `memory.hook` | 64 |
| `panorama.run` | 128 |
| Anti-aim `references:at_target` | 1 |
| Anti-aim `references:freestand` | 54 |
| WebSocket connection | 8. Connection setup is asynchronous. |
| WebSocket send / received message | 1 + floor(message bytes / 4096). Pending receives, status and close have no native-work charge. |

In standard mode, two JSON operations use a callback's full allowance. A JSON
encode followed by a small file write uses 193 units. Standard setup can resolve at
most 128 schema fields if the full setup allowance is spent on those calls.
Shared schema limits still apply in unsafe mode.

Cvar reads during setup do not spend native work units.

Unsafe mode removes native-work enforcement. The values remain available as
measurements. FFI calls are outside these execution limits. See
[permission](api/memory.md#permission).

## Output and stored data

| Resource | Limit |
| --- | --- |
| Console output | 4,096 bytes per call, 8 calls per callback, burst of 256 calls refilling at 64 calls/second |
| Source-loading output | Separate allowance of 256 calls during setup |
| Screen notification | 160 bytes per message, shares the console call allowance |
| Rendered text | 4,096 bytes per call |
| `console.exec` command | 4,096 bytes |
| Lifecycle queue | 128 pending `script.reload`, `script.unload` and config operations across all scripts |
| Game-action queue | 128 pending `console.exec` commands, cvar writes and trace requests across all scripts |
| `why.last()` reason | 511 bytes |
| Date formatting | 128 format bytes, 512 output bytes |
| JSON | 1 MiB input/output, 4,096 values, 32 nesting levels |
| Panorama | 1 MiB source; the result follows the JSON limits |
| Saved data | 8 MiB per file, 64 files and 8 MiB total per script |
| Asset read | 4 MiB per file |
| Image dimensions | 2,048 pixels per dimension, one frame |
| Raw RGBA dimensions | 2,048 pixels per dimension |
| Live textures | 16 textures and 32 MiB of retained CPU pixel-buffer storage |
| Custom fonts | Eight per script. See [font sizes](api/render.md#renderload_font). |
| Bundled font file | 4 MiB, shares the custom-font count |
| Text layout | 4,096 text bytes per layout, shares the renderer's text caches |
| Clipboard text | 1 MiB per operation, unsafe mode required |
| HTTP body | 1 MiB request, up to 8 MiB buffered response. Streaming retains one 64 KiB chunk and uses the requested total limit. |
| HTTP URL | 8,192 bytes, also for WebSocket URLs |
| HTTP and WebSocket timeout | 1 through 120,000 ms |
| HTTP headers | 64 KiB, up to 64 request headers and 256 response headers |
| WebSocket messages | Per socket: 16 queued sends totaling 1 MiB, one received message of up to 8 MiB. Close reason: 123 UTF-8 bytes. |
| Local sound files | 4 MiB each, PCM16 mono/stereo, up to 10 seconds |
| Loaded sound clips | 16 clips and 8 MiB of decoded samples per script |
| Playing local sounds | Four voices shared by all scripts and built-in local audio |

Console messages and screen notifications share the callback output allowance.
Unused time cannot accumulate past the burst capacity. Output throttling returns
`nil` with the reason in `why.last()` instead of disabling the callback.

Name and argument limits are listed with [menu controls](api/menu.md), [game events](events.md), [files](api/resources.md) and [dragging](api/input.md). See [Troubleshooting](troubleshooting.md#the-script-hits-a-limit) when a script reaches a limit.
