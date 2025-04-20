# Development

## Edit and reload

Load the script once, edit the file and save it. Dylanhook reloads loaded scripts
after file changes settle. A failed reload keeps the previous version running and
reports the new error in the console.

Use [local modules](api/std.md#require) when a script grows past one file. Changes
to a loaded helper also reload the main script.

## Unsafe scripts

Enable **allow unsafe scripts** and reload to use FFI, `loadstring`, HTTP and
[clipboard access](api/clipboard.md).
The setting is applied when the script loads.

Unsafe mode removes the script VM, Lua memory and native-work enforcement used by
standard mode. API-specific limits still apply, including HTTP queue and body
sizes, textures, callbacks, files and other owned resources.

Use [`script.budget()`](api/script.md#scriptbudget) to see the active execution
mode and [`script.stats()`](api/script.md#scriptstats) for callback timing and
memory use.

Unsafe code can crash or block the game. Only enable it for source you trust.

## Editor completion

[Editor completion](editor/README.md) provides a LuaLS definition file with
module signatures, userdata members and menu destinations.

## Testing

Test the callbacks your script actually uses. Check reloads, missing game data,
map changes and any asynchronous work such as timers or HTTP requests.

If the script is meant to work without **allow unsafe scripts**, test it with the
setting disabled before sharing it.
