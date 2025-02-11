; ============================================================================
; PBasic Z80 - LET Statement Execution
; ============================================================================

DO_LET:
    ld hl, (MEM_TOKEN_PTR)
    ld a, (hl)

    ; 1. Verify variable token 0xD0..0xE9
    cp TOK_VAR_BASE
    jp c, REPL_SYNTAX_ERROR
    cp TOK_VAR_BASE + 26
    jp nc, REPL_SYNTAX_ERROR

    ; 2. Save variable token and advance pointer
    ld c, a
    inc hl
    ld (MEM_TOKEN_PTR), hl

    ; 3. Expect '='
    ld a, (hl)
    cp '='
    jp nz, REPL_SYNTAX_ERROR
    inc hl
    ld (MEM_TOKEN_PTR), hl

    ; 4. Evaluate expression
    push bc
    call EVAL_EXPR
    pop bc

    ; 5. Store result to variable
    ld a, c
    call VAR_SET

    ; 6. Return to REPL or RUN_NEXT
    ld a, (MEM_RUN_FLAG)
    or a
    jp nz, RUN_NEXT
    jp REPL
