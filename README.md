# ***Sapphire***
The *Official* Sapphire Language Made By ****Zega****
## **specs**

## **Core Syntax Reference**

| Operation Category | Command/Keyword | Syntax Pattern | Description | Example Usage | Expected Output (Inferred) | Source |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Identity Definition** | Identity Assignment | `variable = VALUE` | Assigns a string or identity to a variable without requiring quotes for specific constants. | `sys_node = ZEGA_NODE_V1` | `ZEGA_NODE_V1` | 1, 2 |
| **Identity Definition** | Inverted Integer Buffers | `variable = "NUMBER"` | Numbers enclosed in double quotes are treated as raw integers for mathematical operations. | `base_val = "500"` | `500` | 1, 2 |
| **Stream Math** | `sph::math` | `? sph::math << val1 << operator << val2 << sph::end "math" (/? )` | Executes mathematical calculations including division and addition using streamed values. Prefix with `?` and end with `(/? )`. | `? sph::math << "500" << / << "10" << + << "2" << sph::end "math" (/? )` | `52` | 03-Jan |
| **Stream Math** | `sph::math (XOR)` | `? sph::math << val1 << ^ << val2 << sph::end "math" (/? )` | Performs a bitwise XOR operation on provided integer buffers. | `? sph::math << "500" << ^ << "10" << sph::end "math" (/? )` | `510` | 03-Jan |
| **Stream Math** | `sph::math (AND)` | `? sph::math << val1 << & << val2 << sph::end "math" (/? )` | Performs a bitwise AND operation on provided integer buffers. | `? sph::math << "500" << & << "10" << sph::end "math" (/? )` | `0` | 1, 3 |
| **System Retrieval** | `sph::get` | `sph::get << "parameter" << sph::end "get" ()` | Retrieves system information such as time, date, or day via a stream. | `sph::get << "time" << sph::end "get" ()` | `Current System Time` | 2, 4 |
| **Output Operations** | `sph::print` | `sph::print << "text" << sph::end "print" (line)` | Outputs text or variable content to the console. The `(line)` parameter indicates a new line after printing. | `sph::print << "NODE: " << sys_node << sph::end "print" ()` | `NODE: ZEGA_NODE_V1` | 1, 2 |

---

## **Technical Implementation Details**

* **Stream Buffer Logic**: Sapphire uses the `<<` operator to pipe data into a temporary stack.
* **Deferred Execution**: The execution only occurs when the corresponding `sph::end` command is processed by the C++ VM.
* **Logical Execution Trigger**: The `?` prefix is used specifically for mathematical evaluations to signal the compiler to prioritize the arithmetic stream.
* **Inverted Buffering**: By treating quoted strings like `"500"` as integers, Sapphire allows for a unique data-handling style that simplifies type-checking during high-speed calculations.
