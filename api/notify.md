# Notify

Put a short message in the screen notification feed.

## notify.screen

```text
notify.screen(text: string | number) -> true | nil
```

Adds a message at the top left of the screen. Available in every callback. A call during source loading raises an error. A zero-delay timer can announce a completed load.

```lua
timer.after(0, function()
    notify.screen("layout loaded")
end)
```

`text` must contain 1-160 bytes. Numbers are converted to text. Bytes 0-31 and 127, including newlines, tabs, and NUL, raise an argument error. Extra arguments are ignored.

The feed holds 6 messages shared with other scripts and Dylanhook notifications.
Adding another removes the oldest. A message lasts 5 seconds and fades over its
final 0.5 seconds. Leaving a level clears the feed. This call does not write to
the game console or Dylanhook log.

Notifications and [`console` messages](console.md#message-limits) share 8 output
calls per callback and a 256-call burst, refilling at 64 calls per second.
Reloading the script starts a fresh burst.

Success returns `true`. Output throttling and delivery failures return `nil` and set [`why.last()`](why.md#whylast) to one of these reasons:

| Reason | Meaning |
| --- | --- |
| `callback_limit` | This callback has used its 8 output calls. |
| `rate_limit` | The shared burst is temporarily empty. It refills with time. |
| `output_unavailable` | The notification feed could not accept the message. |

An unavailable feed still uses one allowance. These failures do not disable
the callback. Invalid arguments and unavailable callback contexts still raise
errors.
