# ARMv8-Assembly-Prime-Splitting-Algorithm

# ARMv8 Assembly — Prime-Splitting Algorithm

A complete implementation of a prime-splitting algorithm in ARMv8 Assembly, 
written and debugged as part of ECE 331 Systems Programming at UMass Amherst. 
The program takes an input array of 64-bit integers and distributes each value 
into either a prime or composite array using hand-written assembly with full 
ABI compliance.

---

## What It Does

Given an input array `a[]` of unsigned 64-bit integers, the program:
- Tests each element for primality
- Distributes prime values into `prime[]`
- Distributes composite values into `composite[]`
- Maintains separate index counters for each output array

---

## Implementation

### `isPrimeAssembly` — Non-Leaf Function

The main function that iterates through the input array and routes each value. 
Key implementation details:

**Stack Frame Management**
- Allocates 48 bytes of stack space manually (`SUB SP, SP, #48`)
- Saves callee-saved registers X19–X22 following ABI conventions
- Saves frame pointer (X29) and link register (X30) to support the subroutine call

**Why X30 must be saved:** `isPrimeAssembly` is a non-leaf function — it calls 
`isPrime` using `BL`, which overwrites X30 with the return address to `isPrimeAssembly`. 
Without saving X30 first, the original return address back to `main` would be lost.

**Pointer Arithmetic**
- Base addresses of `a[]`, `prime[]`, and `composite[]` are received in X0–X2
- Moved into callee-saved registers X19–X21 to survive across `BL isPrime` calls
- Array indexing uses `LSL #3` (multiply index by 8) for correct 8-byte offset 
  calculation on 64-bit values
- Separate index counters maintained: `i` (X4) for input, `j` (X5) for prime, 
  `k` (X6) for composite

**Control Flow**
loop_start:
if i == length → loop_end
load a[i] → X0
call isPrime
if result == 0 → handle_composite
else → handle_prime
i++
repeat


---

### `isPrime` — Leaf Function

A helper function that tests whether a single 64-bit integer is prime.

**Algorithm:** Trial division from 2 to n/2
- For each candidate divisor `i`: compute `UDIV` then `MUL` back to check 
  divisibility
- If `i * (n/i) == n`, then `i` divides `n` → not prime → return 0
- If no divisor found → return 1

**Why no stack frame:** `isPrime` is a leaf function — it makes no further 
function calls, so X30 is never overwritten. It returns directly via `RET` 
to the address set by the `BL` in `isPrimeAssembly`.

---

## Registers Used

| Register | Role |
|---|---|
| X0 | Function argument / return value |
| X1–X3 | Function arguments (input) |
| X4 | Loop index i (input array) |
| X5 | Loop index j (prime array) |
| X6 | Loop index k (composite array) |
| X7 | Address of current element a[i] |
| X8 | Reloaded value of a[i] for storage |
| X9 | Computed target address in prime[] or composite[] |
| X19 | Saved base address of a[] |
| X20 | Saved base address of prime[] |
| X21 | Saved base address of composite[] |
| X22 | Saved array length |
| X29 | Frame pointer |
| X30 | Link register (return address) |

---

## Debugging with GDB

Correctness was validated using GDB at two strategic breakpoints:

**Breakpoint 1 — Before `isPrimeAssembly` executes**
Set at `main.c:53`, immediately before the function call. Captured register 
state confirms all three arrays are loaded with their initial values and 
base addresses are correctly set in X0–X3.

<img width="828" height="543" alt="Screenshot 2026-09-16 at 10 37 04 PM" src="https://github.com/user-attachments/assets/03a1f322-133d-40f2-9d0d-1290d37f80ba" />

**Breakpoint 2 — After `isPrimeAssembly` returns**
Set at the first `printf` instruction after the function call in `main.c:63`. 
Captured register state confirms:
- `arrayPrime` contains only prime values from the input
- `arrayComposite` contains only composite values from the input
- All callee-saved registers correctly restored to their pre-call values

<img width="817" height="532" alt="image" src="https://github.com/user-attachments/assets/51530b51-668b-4826-bffa-358627310916" />



---

## Key Concepts Demonstrated

- **ABI-compliant calling conventions** — correct use of callee-saved vs 
  caller-saved registers, stack alignment, and frame pointer management
- **Non-leaf vs leaf function design** — understanding when X30 must be 
  preserved and when it can be used freely
- **Manual memory management** — byte-offset pointer arithmetic using LSL 
  for 8-byte aligned 64-bit array access
- **GDB debugging workflow** — strategic breakpoint placement, register 
  inspection, and memory validation before and after function execution
- **Subroutine linkage** — BL/RET mechanics and how return addresses flow 
  through nested function calls

---

## Technologies

- ARMv8 / AArch64 Assembly
- C (main.c driver)
- GDB Debugger
- Linux (Ubuntu)

---

## Course

ECE 331 — Systems Programming | UMass Amherst
