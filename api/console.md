# Console

Write to the game console and the Dylanhook log, queue a game console command,
or add console commands of your own. [`on.console_input`](../events.md#onconsole_input)
sees the lines players type.

## console.log

```text
console.log(text: string | number) -> true | nil
```

Writes one message at the normal log level. The game console adds the product tag
and a newline. The Dylanhook log also records the script filename.

Available while the script loads and in every callback. Only the first argument
is used. Format or join the message before passing it.

```lua
local labels = {"compact", "detailed"}
console.log("available layouts: " .. table.concat(labels, ", "))
```

## console.warn

```text
console.warn(text: string | number) -> true | nil
```

Writes a warning. The game console adds `warning: ` after the product tag. Arguments, availability, and limits match `console.log`.

```lua
console.warn("saved layout is missing, using the default")
```

## console.error

```text
console.error(text: string | number) -> true | nil
```

Writes an error message. The game console adds `error: ` after the product tag. Arguments, availability, and limits match `console.log`.

Logging at this level does not stop the script. Use Lua's `error()` when execution should stop.

```lua
console.error("could not save the layout")
```

## print

```text
print(...: any) -> true | nil
```

Formats up to 64 arguments using `tostring`, joins them with one space between
each argument, and writes one message at the normal log level. Available during
source load and in every callback. A call without arguments produces an empty
message. No arguments are discarded.

```lua
print("loaded", 3, "entries", true)
```

## Message limits

For `print`, the 4096-byte limit includes the spaces between arguments. Conversion
errors, a non-string `tostring` result, too many arguments or an oversized result
raise an error before the message is sent. Custom `__tostring` methods run under
the current script's instruction allowance. Each `print` costs 1 native work unit
plus 1 per argument, as well as the output allowance described below.

Each message can contain up to 4096 bytes. An embedded NUL byte raises an argument error. An empty string is accepted and uses one output allowance, but adds no game console line.

The four logging functions and [`notify.screen`](notify.md#notifyscreen) share
8 calls per callback and a burst allowance of 256 calls, refilling at 64 calls
per second of monotonic time. There is no lifetime output limit. Source-loading
messages use a separate 256-call setup allowance and do not consume the callback
burst. A reload starts a fresh allowance.

Game console messages are queued and appear after the callback returns. They do
not appear in the screen notification feed.

Successful calls return `true`. Output throttling and delivery failures return
`nil` and set [`why.last()`](why.md#whylast) to one of the reasons below.
Ignoring that result does not disable a callback. Argument and conversion
errors, and an enforced native-work limit, still raise Lua errors.

| Reason | Meaning |
| --- | --- |
| `callback_limit` | This callback has used its 8 output calls. |
| `source_limit` | Setup has used its separate 256 output calls. |
| `rate_limit` | The callback burst allowance is temporarily empty. It refills with time. |
| `output_unavailable` | The game console output service is unavailable. |
| `output_queue_full` | Console lines from every script are waiting for the next game frame. Retry later. |

An `output_unavailable` or `output_queue_full` failure still uses one allowance
and may already have written to the Dylanhook log.

## console.exec

```text
console.exec(...: string | number) -> no values
```

Queues a game console command from any callback. Pass at least one argument. The arguments are joined exactly as given, with no added spaces or quoting.

```lua
timer.after(0, function()
    console.exec("echo ", "script ready")
end)
```

The joined command must contain 1-4096 bytes and no NUL bytes. A bad argument or a call during source loading raises an error.

Commands are queued for later execution. The return only means the command was
queued. It does not report whether the game accepted or executed it.

The queue holds 128 pending actions shared by all scripts and [`cvar`](cvar.md) writes. Queue failures raise `console command refused: <reason>` with `runtime_unavailable`, `service_unavailable`, or `queue_full`. They do not update `why.last()`.

## console.register

```text
console.register(name: string, callback: function(...: string), help: string = "") -> subscription
```

Adds a console command. Typing `name` in the game console, running it from a
bind or an alias, or queuing it with `console.exec` calls `callback` with the
command's arguments as strings, without the command name. `mycmd 1 "two words"`
calls it with `"1"` and `"two words"`.

Register commands while the script loads. `name` is 1-63 lowercase letters,
digits or underscores. `help` is at most 255 bytes without control characters
and is what the console shows for the command. A name the game already uses for
a console variable raises an error at this line.

```lua
local presses = 0

console.register('lua_counter', function(amount)
    presses = presses + (tonumber(amount) or 1)
    console.log('counter: ' .. presses)
end, 'adds to a counter; optional amount')
```

The command is added when the script finishes loading, so the subscription's
`active` property reads `false` inside the loading code. It becomes `true`
once the game has the command, and stays `false` if the game refused the name,
for example because the game already has a command with that name. A refusal is
reported in the console.

A reload keeps the same commands without removing them from the game first,
and updates a changed help text. Unloading, `subscription:remove()` and a
callback error remove the command from the game.

The callback runs on the game thread, where the game runs its own console
commands. Live player reads, [`panorama.run`](panorama.md#panoramarun) and
queued actions such as `console.exec` are available. Drawing, input reads and
menu value writes are not. A callback error disables the command and removes
it. A command line of more than 64 words, the command name included, or with a
word longer than 4,096 bytes, is refused before the callback and logged once.

Each script can register 16 commands, and all loaded scripts share 64. Two
loaded scripts cannot register the same name: the second load is refused with
a message naming the command. The same name twice in one script raises an
error at the second call.

A refused registration raises `console command registration refused: <reason>`:
`not_loading` when called after the script finished loading, `command_limit`
for a 17th command, or `duplicate_name` for a name this script already
registered.
