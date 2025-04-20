# Panorama

The game draws its HUD, scoreboard and menus with Panorama, a UI framework
scripted in JavaScript. `panorama.run` runs JavaScript in the HUD and hands its
result back to Lua.

## panorama.run

```text
panorama.run(source: string, panel_id: string = "") -> any
```

Runs `source` as the body of a JavaScript function and returns what that
function returns. The function runs in the script context of the HUD panel
whose id is `panel_id`, or of the HUD's top panel when `panel_id` is empty, so
`$.GetContextPanel()` is that panel and the whole panel API is available.

```lua
-- stage 12 runs once per frame, before the frame is drawn.
on.frame_stage(function(stage)
    if stage ~= 12 then return end
    local ok, board = pcall(panorama.run, [[
        var board = $.GetContextPanel().FindChildTraverse('Scoreboard');
        return board ? { visible: board.visible, children: board.GetChildCount() } : null;
    ]])
    if ok and board then console.log('scoreboard children: ' .. board.children) end
end)
```

The result travels as JSON and comes back as the value
[`json.decode`](std.md#jsondecode) would give: strings, numbers, booleans,
arrays and objects. `null`, `undefined` and no `return` give `nil`. A `null`
inside an array or object is `json.null`. Functions and other values JSON
cannot represent are dropped from objects, as `JSON.stringify` drops them. The
JSON limits apply to the result: 1 MiB, 4,096 values and 32 levels.

`source` is 1 byte to 1 MiB with no NUL byte. `panel_id` is at most 127
printable ASCII bytes with no spaces (`0x21..0x7E`) and matches a panel id exactly, as
`FindChildTraverse` does. A new function is compiled for every call.

Available only from `on.frame_stage`, `on.game_event` and
[`console.register`](console.md#consoleregister) commands, which run on the
thread Panorama runs on. Calling it anywhere else raises an error. It requires
**allow unsafe scripts**: JavaScript here has the whole panel API, including the
game's own console, and nothing limits what it does there. Each call costs 128
native work units.

An exception the JavaScript throws raises a Lua error,
`panorama script threw: <message>`. A run that cannot start raises
`panorama.run refused: <reason>`:

| Reason | Meaning |
| --- | --- |
| `hud_unavailable` | No map is loaded, so there is no HUD. |
| `context_not_found` | No HUD panel has id `panel_id`. |
| `incomplete` | The source did not compile, or the panel has no script context. The game console shows the compiler's message. |
| `not_ready`, `engine_unavailable` | Panorama is not available. |
| `symbols_unavailable`, `attribute_unavailable`, `result_unreadable` | The result could not be passed back. |

Because `nil` is a valid result, refusals raise instead of returning `nil`.
Use `pcall` where a run is allowed to fail, such as before a map has loaded.

Panels a script creates belong to the game. The game rebuilds much of its HUD
on its own schedule, such as the scoreboard's rows each round, and destroys
what was added to a rebuilt panel. Find your panels again by id on each run
rather than keeping them.
