# HTTP

Send asynchronous HTTP or HTTPS requests without blocking Lua on network I/O.
HTTP requires **allow unsafe scripts** and a reload. The permission is checked
before request arguments are prepared. Requests can carry the URL, credentials
and body that the script supplies, so only grant the permission to source you
trust.

## http.get

```text
http.get(url: string, callback: function(response: http_response)) -> subscription | (nil, error: string, os_error: integer)
http.get(url: string, options: table, callback: function(response: http_response)) -> subscription | (nil, error: string, os_error: integer)
```

## http.post

```text
http.post(url: string, body: string, callback: function(response: http_response)) -> subscription | (nil, error: string, os_error: integer)
http.post(url: string, body: string, options: table, callback: function(response: http_response)) -> subscription | (nil, error: string, os_error: integer)
```

The body is a binary-safe string. For JSON, encode it with `json.encode` and
supply `Content-Type: application/json` in `options.headers`.

## http.request

```text
http.request(options: table, callback: function(response: http_response)) -> subscription | (nil, error: string, os_error: integer)
```

Use this form for an explicit method, including PUT, PATCH, DELETE or HEAD.
HTTP methods are case-sensitive. Use the server's documented spelling.

| Option | Meaning |
| --- | --- |
| `url` | Required by `http.request`. An HTTP or HTTPS URL, up to 8,192 UTF-8 bytes. Encode spaces and reserved query characters before passing the URL. URL fragments and embedded username/password fields are refused. |
| `method` | Defaults to `"GET"`. Up to 16 HTTP-token bytes. |
| `body` | Defaults to an empty string. Up to 1 MiB, including any NUL bytes. |
| `headers` | Optional table of string names and string values. Up to 64 headers and 64 KiB total. Values must be printable ASCII. |
| `timeout_ms` | Whole milliseconds from 1 through 120,000. Default 10,000. Includes queue time and time waiting for a stream reader. |
| `response_limit` | Positive maximum body size. Defaults to 8 MiB. Buffered responses cannot exceed 8 MiB. Streams may use larger limits, including exact decimal strings for 64-bit sizes. |
| `stream` | Defaults to `false`. Set to `true` to consume body chunks with `http.read`. |

The GET and POST shortcuts accept `headers`, `timeout_ms`, `response_limit` and `stream`.
Their URL, method and body come from their positional arguments. They do not
modify the options table you pass. Unknown options raise an error rather than
silently ignoring a misspelled timeout or header field.

The transport owns Host, Content-Length, Transfer-Encoding and Connection.
These headers cannot be supplied independently of the validated request.
Authentication headers such as Authorization may be supplied explicitly.
Requests send no User-Agent header. Supply one in `headers` when a server
requires it.

```lua
local function received(response)
    if not response.ok then
        console.warn(response.error)
    elseif response.status >= 200 and response.status < 300 then
        local decoded, data = pcall(json.decode, response.body)
        if decoded then
            console.log('JSON response received')
        else
            console.warn(data)
        end
    else
        console.warn('HTTP ' .. tostring(response.status))
    end
end

menu.lua.a:button('fetch example response', function()
    local pending, reason = http.get('https://example.com/', {
        timeout_ms = 5000,
        response_limit = 64 * 1024
    }, received)
    if not pending then console.warn(reason) end
end)
```

The example address does not promise a JSON response. The protected decode makes
that distinction visible. Use your own endpoint for structured data.

## Response

```text
http_response: table
http_response.ok: boolean
http_response.status: integer | nil
http_response.body: string | nil
http_response.streamed: boolean
http_response.received_bytes: string
http_response.headers: table<string, string | string[]>
http_response.error: string | nil
http_response.os_error: integer | nil
```

The callback receives a fresh Lua-owned table. Retaining or modifying it does
not change a request, another script, or a later response.

| Field | Meaning |
| --- | --- |
| `ok` | Whether the transport completed. This is **not** a test for a 2xx status. A completed 404 response has `ok == true`. |
| `status` | Numeric HTTP status when headers were received. Otherwise `nil`. |
| `body` | Binary-safe buffered response. Empty on transport/size failure. `nil` for streamed responses. |
| `streamed` | Whether the request used chunked delivery. |
| `received_bytes` | Exact decimal count of accepted body bytes, including bytes received before a failure. |
| `headers` | Lowercase header-name keys. A single value is a string. Repeated headers produce a one-based array of strings. |
| `error` | Named transport failure, or `nil` on completion. |
| `os_error` | Windows error code on failure. Zero when there is no underlying OS error. |

Common failures include `http_timeout`, `http_tls_failed`,
`http_response_too_large`, `http_headers_too_large` and `http_unavailable`.
HTTP statuses such as 401, 404 and 500 remain ordinary completed responses.
Bodies are not automatically decoded as JSON or executed as Lua. Compressed
responses stay compressed unless the server sends an uncompressed body.

## http.progress

```text
http.progress(request: subscription) -> http_progress | (nil, error: string)
http_progress: table
http_progress.phase: string
http_progress.received_bytes: string
http_progress.content_length: string | nil
http_progress.status: integer | nil
```

Reads a pending request's progress. Phases are `queued`, `sending`, `receiving`,
`reading`, `closing` and `complete`. Byte counts are exact decimal strings.
`content_length` is the server's advertised size when available, not a promise
that the request will complete. `status` appears after headers arrive.

The request expires when removed or delivered. Further reads return
`nil, "http_request_expired"`.

## http.read

```text
http.read(request: subscription) -> string | (nil, error: string)
```

Takes the next body chunk from a request created with `stream = true`. Chunks
are binary strings of up to 64 KiB. `nil` without an error means no chunk is
ready yet. A buffered request returns `http_not_streaming`.

Read from a timer or another callback until no chunk is ready. The transport
holds one chunk per request and pauses that request until it is consumed.
Other requests continue. The completion callback reports the final result
after all successful chunks have been consumed.

Chunks can arrive before a later failure. Treat the complete transfer as valid
only when the completion callback reports `ok`. If Lua cannot accept a chunk,
the request is cancelled. Unloading and cancellation discard unread chunks.

```lua
local pending
local total = 0

menu.lua.a:button('stream response', function()
    if pending and pending.active then return end
    total = 0
    pending = assert(http.get('https://example.com/', {
        stream = true,
        timeout_ms = 30000,
        response_limit = 16 * 1024 * 1024
    }, function(response)
        print(response.ok and ('received ' .. total .. ' bytes') or response.error)
    end))
end)

timer.every(0.01, function()
    if not pending or not pending.active then return end
    while true do
        local chunk, reason = http.read(pending)
        if reason then error(reason) end
        if not chunk then break end
        total = total + #chunk
        -- Process or save this chunk here.
    end
end)
```

## Delivery, cancellation and reload

Requests may be created during setup or from any callback except unload, where
the call raises an error. A
request created during setup starts only after the script loads successfully.
If the load fails, the request is discarded.

Completion runs before ordinary paint. It can update controls, use JSON and local
files, or schedule another request. It cannot draw, read input, use a command or
read live entities. It can read the current render snapshot. Save response data and draw it later in `on.paint`.

The returned [subscription](../events.md#subscriptions) supports `.active` and
`:remove()`. Removing it cancels the request and prevents future delivery.
Reloading or unloading the script cancels its pending requests automatically.
The subscription becomes inactive before its completion callback starts.

Each script can hold eight pending requests. Across all scripts, up to 16
requests can be queued or active and four can be in flight. A full queue returns
`nil, "http_queue_full", 0`. Retry later with a timer instead of busy-waiting.
Cancellation may take a short time to release an in-flight slot.

Submitting a request costs eight native-work units. Network wait time does not
count as Lua instruction time. Copying the response uses Lua memory. A timeout
starts cancellation but does not guarantee delivery at the exact millisecond.

## Network behavior

Normal certificate verification remains enabled. Windows proxy settings are
respected. Ambient cookies and automatic authentication are disabled. Redirects
are returned as 3xx responses instead of being followed automatically. Read the
`Location` header and decide whether to make another request.
