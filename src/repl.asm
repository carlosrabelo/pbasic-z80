; ============================================================================
; PBasic Z80 - Read-Eval-Print Loop (REPL)
; ============================================================================

REPL:
    ; 1. Check MEM_RUN_FLAG
    ld a, (MEM_RUN_FLAG)
    or a
    jr nz, .repl_run_program

    ; 2. Emit interactive prompt '> '
    ld hl, STR_PROMPT
    call PRINT_STR

    ; 3. Read line into MEM_INPUT_BUF
    call READ_LINE

    ; 4. Tokenize input line into MEM_TOKEN_BUF
    call TOKENIZE

    ; 5. Initialize MEM_TOKEN_PTR to MEM_TOKEN_BUF
    ld hl, MEM_TOKEN_BUF
    ld (MEM_TOKEN_PTR), hl

    ; 6. Dispatch command
    jp REPL_DISPATCH

.repl_run_program:
    jp RUN_NEXT
