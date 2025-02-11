; ============================================================================
; PBasic Z80 - GOTO Statement Execution
; ============================================================================

DO_GOTO:
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
