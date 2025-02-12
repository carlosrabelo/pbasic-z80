; ============================================================================
; PBasic Z80 - GOSUB Statement Execution
; ============================================================================

DO_GOSUB:
    ld a, (MEM_GOSUB_SP)
    cp 16
    jp nc, REPL_SYNTAX_ERROR

    add a, a
    ld e, a
    ld d, 0
    ld hl, MEM_GOSUB_STK
    add hl, de

    ld de, (MEM_LINE_PTR)
    ld (hl), e
    inc hl
    ld (hl), d

    ld hl, MEM_GOSUB_SP
    inc (hl)

    call EVAL_EXPR
    call LINE_FIND
    or a
    jp z, REPL_SYNTAX_ERROR

    ld a, 1
    ld (MEM_RUN_FLAG), a
    ld (MEM_LINE_PTR), de
    ex de, hl
    ld de, 4
    add hl, de
    ld (MEM_TOKEN_PTR), hl
    jp REPL_DISPATCH
