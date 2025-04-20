# Client identity

## client.username

```text
client.username() -> string | nil
```

Returns the product display username used by the native watermark, or `nil` when
that identity is unavailable. This is not the player's in-game name.

Available during setup and callbacks. Costs one native work unit.

```lua
local username = client.username()
if username then console.log('loaded for ' .. username) end
```
