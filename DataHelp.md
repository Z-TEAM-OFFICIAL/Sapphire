# ***Sapphire*** — Official Language Reference
### The *Official* Sapphire Language — Made By **Z-TEAM**
> Version 2.0 — Z-TEAM Internal Build

---

## **Core Syntax Reference**

| Operation Category | Command/Keyword | Syntax Pattern | Description | Example |
| :--- | :--- | :--- | :--- | :--- |
| **Identity Definition** | Identity Assignment | `variable = VALUE` | Assigns an unquoted string identity to a variable. | `sys_node = ZEGA_NODE_V1` |
| **Identity Definition** | Inverted Integer Buffers | `variable = "NUMBER"` | Quoted numbers become raw integers for math. | `base_val = "500"` |
| **Output** | `sph::print` | `sph::print << ... << sph::end "print" (line)` | Prints all streamed values. `(line)` adds newline; `()` does not. | `sph::print << "Hello" << sph::end "print" (line)` |
| **Math** | `sph::math` | `? sph::math << val << op << val << sph::end "math" (/? )` | Evaluates integer math stream. Prefix with `?`. | `? sph::math << "10" << + << "5" << sph::end "math" (/? )` |
| **System Info** | `sph::get` | `sph::get << "query" << sph::end "get" ()` | Retrieves system data. See sph::get Queries table. | `sph::get << "time" << sph::end "get" ()` |
| **URL** | `sph::url` | `sph::url "https://..."` | Opens a URL in the default browser. | `sph::url "https://example.com"` |
| **Window** | `window` | `window "Title" { ... }` | Opens a Vulkan-backed Win32 window. | `window "My App" { }` |
| **Button** | `btn:` | `btn: ([x,y]; [w,h])` | Creates a button inside the current window. | `btn: ([10,10]; [100,30])` |

---

## **v2 Features — New in Sapphire 2.0**

### `sph::cmp` — Stream Comparison
Compares two values, pushes `"1"` (true) or `"0"` (false) onto the stack.

```sph
sph::cmp << val1 << operator << val2 <<
sph::end "cmp" ()
```

**Comparison Operators:**
| Operator | Meaning |
| :--- | :--- |
| `==` or `eq` | Equal |
| `!=` or `ne` | Not equal |
| `gt` | Greater than |
| `lt` | Less than |
| `gte` | Greater than or equal |
| `lte` | Less than or equal |

---

### `sph::if` — Conditional Block
Pops a comparison result and conditionally executes a block. Supports an optional `else` branch.

```sph
# Without else:
sph::cmp << x << == << "5" <<
sph::end "cmp" ()
sph::if (start)
    sph::print << "x is five!" << sph::end "print" (line)
sph::end "if" (stop)

# With else:
sph::cmp << x << gt << "100" <<
sph::end "cmp" ()
sph::if (start)
    sph::print << "Large!" << sph::end "print" (line)
sph::if (else)
    sph::print << "Small!" << sph::end "print" (line)
sph::end "if" (stop)
```

---

### `sph::loop` — Counted Loop
Repeats a block N times. Push the count via the stream line before `sph::end "loop" (start)`.

```sph
sph::loop << "5" <<
sph::end "loop" (start)
    sph::print << "Hello!" << sph::end "print" (line)
sph::end "loop" (stop)
```

> **Note:** Loop count must be `>= 1`. Uses do-while semantics: the body always runs at least once.

---

### `sph::input` — User Input
Prints all streamed values as a prompt, reads a line from stdin, and pushes the result onto the stack. Use `sph::pop` to store the result.

```sph
sph::input << "Enter your name: " <<
sph::end "input" ()
sph::pop "name"

sph::print << "Hello, " << name << "!" <<
sph::end "print" (line)
```

---

### `sph::pop` — Store Top of Stack
Pops the top stack value and stores it in a named variable.

```sph
sph::pop "variableName"
```

---

### `sph::concat` — String Concatenation
Pops all stack items and concatenates them into a single string, then pushes the result. Use `sph::pop` to store it.

```sph
sph::concat << "Hello" << ", " << "World" << "!" <<
sph::end "concat" ()
sph::pop "greeting"

sph::print << greeting << sph::end "print" (line)
```

---

### `sph::debug` — Debug Dump
Prints the current stack contents and all variable bindings to stdout. Useful during development.

```sph
sph::debug ()
```

---

## **Extended Math Operators (v2)**

In addition to `+`, `-`, `*`, `/`, `^`, `&`:

| Operator | Symbol | Example |
| :--- | :--- | :--- |
| Modulo | `%` | `? sph::math << "17" << % << "5" << sph::end "math" (/? )` → `2` |
| Power | `**` | `? sph::math << "2" << ** << "10" << sph::end "math" (/? )` → `1024` |

---

## **`sph::get` Queries (v2)**

| Query String | Description | Example Output |
| :--- | :--- | :--- |
| `"time"` | Current system time (HH:MM:SS) | `14:32:07` |
| `"date"` | Current date (YYYY-MM-DD) | `2026-02-22` |
| `"day"` | Current day of week | `Sunday` |
| `"year"` | Current year only | `2026` |
| `"month"` | Current month (zero-padded) | `02` |
| `"username"` | **NEW** — Logged-in Windows username | `ZeGA` |
| `"hostname"` | **NEW** — Machine/computer name | `ZTEAM-PC` |
| `"os"` | **NEW** — Operating system name | `Windows` |
| `"random"` | **NEW** — Random integer | `18423` |

---

## **Comments**

| Style | Syntax |
| :--- | :--- |
| Line comment | `# This is a comment` |
| Inline comment | `code here # inline comment` |
| Block comment (toggle) | `&?&` ... `&?&` |
| C-style block | `/* ... */` |

---

## **Technical Notes**

- **Stream Buffer Logic**: `<<` pipes data into a temporary operand stack processed left to right.
- **Deferred Execution**: Operations execute only when the `sph::end "..."` terminator is processed.
- **Inverted Buffering**: Quoted numbers (e.g. `"500"`) are treated as integer types for math; unquoted values are strings/identities.
- **`?` Prefix**: Required for math execution lines. Signals the compiler to prioritize the arithmetic stream.
- **Window Lifecycle**: Windows are Vulkan-backed. After program code finishes, Sapphire enters a message loop to keep open windows alive and responsive until manually closed.
- **Multi-window Support**: Multiple `window { }` blocks can be open simultaneously. Each gets its own Vulkan instance and surface.
- **Button Labels**: The top of the stack at button-creation time is used as the button label.
