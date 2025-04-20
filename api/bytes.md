# Byte utilities

Base64 carries binary data in text. SHA-256 produces a checksum you can compare
with a known value. These functions accept Lua byte strings in any callback
and during setup.

## base64.encode

```text
base64.encode(bytes: string) -> string
```

Returns standard Base64 with `=` padding and no line breaks. Embedded NUL bytes
are preserved.

## base64.decode

```text
base64.decode(text: string) -> string | (nil, error: string)
```

Decodes the standard alphabet. Spaces, tabs, CR and LF are ignored. Padding
may be omitted. When supplied, it must be complete. Nonzero unused bits are
rejected.

Returns `nil` with `invalid_character`, `invalid_length` or `invalid_padding`
for malformed input. URL-safe Base64 uses a different alphabet and is not
accepted.

```lua
local encoded = base64.encode('hello\0world')
local bytes, reason = base64.decode(encoded)
assert(bytes, reason)
assert(bytes == 'hello\0world')
```

## hash.sha256

```text
hash.sha256(bytes: string) -> string | (nil, error: string)
```

Returns the SHA-256 digest as 64 lowercase hexadecimal characters.

```lua
local bytes = assert(assets.read('presets.json'))
local checksum, reason = hash.sha256(bytes)
assert(checksum, reason)
print(checksum)
```

Failures return `input_too_large`, `provider_open_failed` or `hash_failed`.
The native one-shot hash accepts at most 4,294,967,295 bytes. A checksum does
not prove who supplied a file.

Work accounting scales with input length. Standard scripts can exhaust their
native-work allowance. Unsafe scripts record that work without a policy stop.
