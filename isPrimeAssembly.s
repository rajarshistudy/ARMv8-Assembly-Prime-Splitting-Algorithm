.globl isPrimeAssembly

isPrimeAssembly:
    nop

    ; Prologue: save registers and link register (LR) on stack
    SUB SP, SP, #48
    STP X19, X20, [SP, #0]
    STP X21, X22, [SP, #16]
    STP X29, X30, [SP, #32]
    MOV X29, SP

    ; Initialize pointers and counters
    MOV X19, X0         ; X19 = base address of arrayA
    MOV X20, X1         ; X20 = base address of arrayPrime
    MOV X21, X2         ; X21 = base address of arrayComposite
    MOV X22, X3         ; X22 = length (number of elements)
    MOV X4, XZR         ; X4 (i) = 0 (index for arrayA)
    MOV X5, XZR         ; X5 (j) = 0 (index for prime array)
    MOV X6, XZR         ; X6 (k) = 0 (index for composite array)

loop_start:
    CMP X4, X22             ; compare i (X4) with length (X22)
    B.EQ loop_end           ; if i == len, exit loop

    ; Load a[i] into X0 (argument for isPrime)
    LSL X7, X4, #3          ; X7 = i * 8
    ADD X7, X19, X7         ; X7 = address of a[i]
    LDR X0, [X7]            ; X0 = a[i]
    BL isPrime              ; call isPrime(X0); result in X0

    CBZ X0, handle_composite ; if X0 == 0, branch to composite

handle_prime:
    LDR X8, [X7]            ; reload a[i] into X8
    LSL X9, X5, #3          ; X9 = j * 8
    ADD X9, X20, X9         ; X9 = address of prime[j]
    STR X8, [X9]            ; prime[j] = value
    ADD X5, X5, #1          ; j++
    B store_done

handle_composite:
    LDR X8, [X7]            ; reload a[i] into X8
    LSL X9, X6, #3          ; X9 = k * 8
    ADD X9, X21, X9         ; X9 = address of composite[k]
    STR X8, [X9]            ; composite[k] = value
    ADD X6, X6, #1          ; k++

store_done:
    ADD X4, X4, #1          ; i++
    B loop_start            ; repeat loop

loop_end:
    ; Epilogue: restore saved registers and return
    LDP X29, X30, [SP, #32]
    LDP X21, X22, [SP, #16]
    LDP X19, X20, [SP, #0]
    ADD SP, SP, #48
    RET


isPrime:
    ; Leaf function: tests primality of X0 (n)
    ; Returns 1 in X0 if prime, 0 if composite
    MOV X1, X0             ; X1 = n
    LSR X1, X1, #1         ; X1 = n / 2
    MOV X2, #2             ; X2 = loop counter i, start from 2

check_divisor:
    CMP X2, X1             ; compare i with n/2
    B.GT is_prime          ; if i > n/2, no divisors found → prime
    UDIV X4, X0, X2        ; X4 = n / i
    MUL X5, X4, X2         ; X5 = (n / i) * i
    CMP X5, X0             ; compare with n
    B.EQ not_prime         ; if equal, i divides n → not prime
    ADD X2, X2, #1         ; i++
    B check_divisor        ; loop back

not_prime:
    MOV X0, XZR            ; return 0 (composite)
    RET

is_prime:
    MOV X0, #1             ; return 1 (prime)
    RET
