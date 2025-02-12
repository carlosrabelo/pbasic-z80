; ============================================================================
; PBasic Z80 - RETURN Statement Execution
; ============================================================================

DO_RETURN:
    ld a, (MEM_GOSUB_SP)
    or a
    jp z, REPL_SYNTAX_ERROR

    dec a
    ld (MEM_GOSUB_SP), a

    add a, a
    ld e, a
    ld d, 0
    ld hl, MEM_GOSUB_STK
    add hl, de
    ld e, (hl)
    inc hl
    ld d, (hl)

    ld a, d
    or e
    jp z, RUN_END

    ld (MEM_LINE_PTR), de
    jp RUN_NEXT
