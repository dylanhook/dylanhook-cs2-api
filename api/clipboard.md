# Clipboard

Read or replace Windows clipboard text. Requires **allow unsafe scripts** and
an active render-side callback, such as a menu action or timer. Setup, command,
frame-stage and game-event callbacks cannot access the clipboard.

Text is UTF-8 and limited to 1 MiB per operation. Clipboard access can briefly
block while another application holds it. Use it for explicit copy/paste actions.

## clipboard.read

```text
clipboard.read() -> string | nil
```

Returns the clipboard's text, including `""` for empty text. Returns `nil` when
text is unavailable, too large, malformed, or the clipboard cannot be opened.
Use `why.last()` for the reason.

## clipboard.write

```text
clipboard.write(text: string) -> true | nil
```

Replaces the clipboard text. Returns `true` on success or `nil` on an operational
failure. Oversized text and embedded NUL bytes raise an argument error.
Invalid UTF-8 returns `nil`. An empty string clears the text.

```lua
menu.lua.a:button("copy preset", function()
    if clipboard.write("my preset") == nil then
        console.warn(why.last() or "copy unavailable")
    end
end)
```
