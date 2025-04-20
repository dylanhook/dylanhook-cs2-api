# Globals

Read clocks, tick conversions and connection information. These functions
work while the script loads and in every callback. Unavailable reads return
one `nil`. They do not return a second error value.

Returned numbers and booleans do not update after you save them.

## globals.tick_count

```text
globals.tick_count() -> integer | nil
```

Returns the client tick count, or `nil` when unavailable. It can reset on a map change and is not a unique command identifier.

In `on.paint` and ESP value callbacks, this is the tick count for the current frame.

Use [cmd.number](cmd.md#cmdnumber) to track command identity. This clock is not the local player's predicted command tick base.

## globals.curtime

```text
globals.curtime() -> number | nil
```

Returns the client level clock in seconds, or `nil` when unavailable. In `on.paint`
and ESP value callbacks, the value is captured with the current render frame.

Use it with deadlines on the same level clock. Bomb deadlines use a game clock
that accounts for paused ticks. Use `current_time` or `seconds_remaining` from
[`game.bomb_snapshot`](game.md#gamebomb_snapshot) for those.

## globals.real_time

```text
globals.real_time() -> number
```

Returns elapsed time in seconds from Dylanhook's running clock. Use it for fades,
local delays and measuring how old a saved sample is.

The clock is monotonic, starts with the scripting runtime and continues outside a match. Script reloads do not reset it. This is not Unix time.

Returns `0` before that clock is initialized.

```lua
local loaded_at = globals.real_time()

on.paint(function()
    local elapsed = globals.real_time() - loaded_at
    render.text(24, 48, string.format("loaded %.1f seconds", elapsed), color.white)
end)
```

## globals.frame_time

```text
globals.frame_time() -> number
```

Returns the most recent rendered frame's duration in seconds. It is zero
before and during the first measured frame. Check for zero before dividing.

All scripts share this value for the current frame. It measures time between scripting render frames, independently of the game's tick interval.

## globals.frame_count

```text
globals.frame_count() -> number
```

Returns the rendered-frame count. It is a frame counter, not a game tick or command number.

The value is shared by scripts and advances once per ordinary render frame. Ordinary and above-menu paint callbacks see the same count. Script reloads do not reset it.

The value starts at `0` and is integer-valued.

## globals.ticks_to_time

```text
globals.ticks_to_time(ticks: integer) -> number
```

Converts ticks to seconds using the 1/64-second tick interval. The input must be an integer from `-2147483648` through `2147483647`. Negative values are accepted. Invalid arguments raise an error.

## globals.time_to_ticks

```text
globals.time_to_ticks(seconds: number) -> integer
```

Converts seconds to ticks using the same interval, rounded to the nearest integer with halfway values rounded away from zero. Non-finite or out-of-range results raise an error.

The input multiplied by `64` must be between `-2147483647.5` and `2147483646.5`, inclusive.

## globals.in_game

```text
globals.in_game() -> boolean | nil
```

Returns the engine's in-game state. `false` means it is not in game; `nil` means the state is unavailable.

A background map at the game's main menu does not count as being in game.

## globals.max_players

```text
globals.max_players() -> integer
```

Returns the supported player limit, 64. It is not the number of connected players.

## globals.latency

```text
globals.latency() -> integer | nil
```

Returns measured round-trip network latency in milliseconds, rounded to the nearest integer, or `nil` when unavailable. Zero is a valid value for a local connection. Do not display an unavailable read as zero ping.

Valid results are from `0` through `10000` milliseconds. An unreadable channel or invalid measurement returns `nil`.

Failed clock, connection and latency reads record [why.last()](why.md#whylast).

```lua
on.paint(function()
    local frame_time = globals.frame_time()
    if frame_time <= 0 then return end

    local fps = string.format("%.0f fps", 1 / frame_time)
    local latency = globals.latency()
    local ping = latency ~= nil and string.format("%d ms", latency)
        or "latency unavailable"
    render.text(24, 24, fps .. " / " .. ping, color.white)
end)
```

This FPS value describes the last frame. `latency == nil` remains unavailable
in the example. A valid zero latency displays as `0 ms`.
