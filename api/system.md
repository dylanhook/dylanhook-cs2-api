# System clock

Use the system clock for a watermark, calendar date or timestamp in a saved note.
It can jump when the computer's clock changes. Use [globals.real_time](globals.md)
for animation durations and the appropriate game clock for game timers.

## system.time

```text
system.time() -> integer
```

Returns whole seconds since January 1, 1970, UTC, rounded down. Available while
loading and in every callback. There is no additional native work charge.

## system.date

```text
system.date(format: string = "%H:%M:%S", timestamp: integer? = nil,
            timezone: string = "local") -> string | table | nil
```

Formats a timestamp. Omit `timestamp` to read the clock now, including its
millisecond component. An explicit timestamp uses whole Unix seconds.
`timezone` is `"local"` or `"utc"`. The local option uses Windows timezone rules.
Omitting an optional argument or passing `nil` uses its default.

```lua
local timestamp = system.time()
local date = system.date("%F %T", timestamp, "utc")
if date then print("saved at", date) end
```

| Token | Output |
| --- | --- |
| `%Y`, `%m`, `%d` | Four-digit year, two-digit month and two-digit day. |
| `%H`, `%M`, `%S` | Two-digit hour, minute and second. Hours use the 24-hour clock. |
| `%F` | Date as `YYYY-MM-DD`. |
| `%T` | Time as `HH:MM:SS`. |
| `%%` | A literal percent sign. |

Other bytes are copied as written. Other percent tokens, an incomplete token,
an embedded NUL or a format longer than 128 bytes raise an error. The output is
limited to 512 bytes. An empty format returns an empty string.

The exact format `"*t"` returns a new table instead:

```lua
local clock = system.date("*t")
if clock then print(clock.hour, clock.min, clock.sec, clock.ms) end
```

| Field | Meaning |
| --- | --- |
| `year`, `month`, `day` | Calendar year, month from 1 through 12, and day of the month. |
| `hour`, `min`, `sec` | Hour from 0 through 23, minute and second. |
| `ms` | Millisecond from 0 through 999. Zero for an explicit whole-second timestamp. |
| `wday` | Day of the week, from Sunday as 1 through Saturday as 7. |

Available while loading and in every callback. Each call costs 16 native work
units, including refused calls. Explicit timestamps must be integers from
`-9223372036` through `9223372036`, the supported whole-second range.
Invalid arguments and exhausted budgets raise errors. A Windows conversion
failure returns `nil` and records its cause in [why.last](why.md).
