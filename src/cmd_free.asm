; ============================================================================
; PBasic Z80 - FREE Statement Execution
; ============================================================================

DO_FREE:
    ld hl, (MEM_PROG_LIMIT)
    ld de, (MEM_PROG_END)
    or a
    sbc hl, de
    ld de, 0
    call PRINT_NUMBER
    call PRINT_CRLF
    ld a, (MEM_RUN_FLAG)
    or a
    jp nz, RUN_NEXT
    jp REPL
