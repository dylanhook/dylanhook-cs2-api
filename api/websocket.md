# WebSocket

Keep a connection open for text or binary messages. Enable **allow unsafe
scripts**, then reload before using this API. Permission is checked before
connection options are read. Poll the returned object for state and messages;
this API does not register a message callback or reconnect automatically.

## websocket.connect

```text
websocket.connect(options: websocket_options) -> websocket | (nil, error: string, os_error: integer)

websocket_options: table
websocket_options.url: string
websocket_options.headers: table<string, string> | nil
websocket_options.timeout_ms: integer | nil
```

Queues a connection and returns its handle. A handle means admission succeeded;
wait for `socket:status().phase == "open"` before sending. Available during
setup and active callbacks except unload. Costs eight native work units.

`url` must use `ws://` or `wss://` and contain at most 8,192 UTF-8 bytes. Embedded
credentials, fragments, spaces, control characters and backslashes are refused.
`wss://` uses the normal TLS certificate checks.

`headers` is an optional map of header names to string values. It accepts up to
64 headers totaling 64 KiB, including each name, value and four framing bytes.
Names must be valid HTTP tokens; values must contain printable ASCII. The API
owns `Host`, `Connection`, `Content-Length`, `Transfer-Encoding`, `Upgrade`,
`Sec-WebSocket-Key`, `Sec-WebSocket-Version` and `Sec-WebSocket-Accept`; supplying
them is refused.

`timeout_ms` defaults to `10000` and must be an integer from `1` to `120000`.
It bounds queued connection setup, an active send and closure. It does not set
an idle receive deadline or a total lifetime for an open socket.

Wrong argument types, unknown options and out-of-range numeric options raise.
Admission and transport-validation failures return `nil, error, os_error` and
set `why.last()`. The OS code is zero when no underlying OS failure is available.

Connections declared during setup remain staged until the script activates.
A failed script load sends no staged request. Each script can retain eight
handles. HTTP and WebSocket share 16 transport slots; at most four connection or
HTTP operations run at once. An open socket releases its connection allowance
but keeps its transport slot.

## socket:status

```text
socket:status() -> websocket_status | (nil, error: string, os_error: integer)

websocket_status: table
websocket_status.phase: string
websocket_status.http_status: integer
websocket_status.queued_send_bytes: integer
websocket_status.queued_send_messages: integer
websocket_status.received_bytes: integer
websocket_status.message_ready: boolean
websocket_status.close_observed: boolean
websocket_status.close_code: integer | nil
websocket_status.close_reason: string | nil
websocket_status.error: string | nil
websocket_status.os_error: integer | nil
```

Returns copied state during setup or callbacks, including unload. No native-work
units are charged. Phases are `"queued"`, `"connecting"`, `"open"`, `"closing"`,
`"closed"` and `"failed"`.

`http_status` is zero before an HTTP response is available. A successful upgrade
uses `101`; another HTTP status produces `websocket_upgrade_failed`.
`queued_send_bytes` and `queued_send_messages` describe pending output, including
the active send. `received_bytes` describes the current assembled or assembling
message, not the lifetime sum. `message_ready` distinguishes a complete message
from a partial one.

`close_code` and `close_reason` are present only after a peer close was observed.
They do not repeat an unconfirmed local close request. A transport failure keeps
its reason in `error` and its OS code in `os_error`. Reading that failed status
still returns a table; an expired or unavailable handle returns the error tuple.

## socket:send

```text
socket:send(data: string, kind: string = "text") -> true | (nil, error: string, os_error: integer)
```

Queues one complete message on an open socket. `kind` is `"text"` or `"binary"`.
Text must be valid UTF-8. Binary data preserves every byte, including NUL; empty
messages are valid. The return value confirms queue admission, not delivery.

Available during setup and active callbacks except unload, although a staged
socket is not open and cannot send. Costs `1 + floor(data_bytes / 4096)` units.
Each message may contain at most 1 MiB. The socket's entire send queue is bounded
to 16 messages and 1 MiB. A full queue returns `websocket_send_full`; sending
before open or after closure starts returns `websocket_not_open`.

## socket:receive

```text
socket:receive() -> (data: string, kind: string) | nil | (nil, error: string, os_error: integer)
```

Takes one complete message, returning its bytes and `"text"` or `"binary"`.
`nil` alone means there is no complete message yet. Check for `nil` rather than
an empty string: an empty message is still a message.

Available during setup and callbacks, including unload. A delivered message
costs `1 + floor(data_bytes / 4096)` units. A pending receive has no charge.
Messages are assembled up to 8 MiB, including fragmented input. Invalid UTF-8
text fails the connection without a partial message. Validation during assembly
returns `websocket_invalid_text`; failures detected by the transport retain
their OS code. Oversized messages return `websocket_message_too_large`.

Only one complete message is retained per socket. Further reads pause until Lua
consumes it. A Lua allocation failure leaves that message available for retry;
a concurrent reentrant receive returns `websocket_receive_busy`. An unread
complete message remains available after closure or failure. Once it is drained,
receiving from a closed socket returns `websocket_closed`, or the saved failure
for a failed socket.

## socket:close

```text
socket:close(code: integer = 1000, reason: string = "") -> boolean | (nil, error: string, os_error: integer)
```

Requests closure. Returns `true` for the first request and `false` when closure
has already started or finished. Available during setup and every callback,
including unload; no native-work units are charged. A staged connection closes
without starting its network request.

Accepted codes are `1000` through `1014`, excluding `1004`, `1005` and `1006`,
or `3000` through `4999`. The reason must be valid UTF-8 and at most 123 bytes.
Invalid values return `websocket_invalid_close`; wrong Lua types raise.

An open socket attempts to drain already queued sends before completing its
close exchange. Observe `phase`, `close_observed` and any failure afterward.
Closing preserves an already complete unread message; later input is discarded
while waiting for the peer close.

Closed and failed handles retain their script and transport slots. Drop all Lua
references when finished; garbage collection discards the socket and releases
its native resources after pending work drains. Unload and replacement discard
all sockets belonging to that script. Calling `close` alone does not free a slot
or promise that the peer acknowledged closure.

## Example

Supply an endpoint you control. Each connection, send and close needs a button
click; the timer only polls an existing connection.

```lua
local endpoint = menu.lua.a:text('websocket endpoint', '', 2048)
local socket
local message = 'enter an endpoint and connect'

menu.lua.a:button('connect websocket', function()
    if socket or endpoint.value == '' then return end
    local reason
    socket, reason = websocket.connect({url = endpoint.value})
    message = socket and 'connection queued' or tostring(reason)
end)

menu.lua.a:button('send greeting', function()
    if not socket then return end
    local accepted, reason = socket:send('hello', 'text')
    message = accepted and 'message queued' or tostring(reason)
end)

timer.every(0.1, function()
    if not socket then return end
    local state, reason = socket:status()
    if not state then message = tostring(reason); return end
    if state.message_ready then
        local data, kind = socket:receive()
        if data ~= nil then message = kind .. ' message: ' .. #data .. ' bytes' end
    elseif state.error then
        message = state.error
    end
end)

menu.lua.a:button('close websocket', function()
    if not socket then return end
    local accepted, reason = socket:close(1000, 'finished')
    message = accepted == nil and tostring(reason) or 'closure requested'
end)

on.paint(function() render.text(24, 24, message, color.white) end)
```
