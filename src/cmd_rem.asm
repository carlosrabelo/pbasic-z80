; ============================================================================
; PBasic Z80 - REM Statement Execution
; ============================================================================

DO_REM:
    ld hl, (MEM_TOKEN_PTR)
.drem_loop:
    ld a, (hl)
    or a
    jr z, .drem_done
    inc hl
    jp .drem_loop

.drem_done:
    ld (MEM_TOKEN_PTR), hl
    ld a, (MEM_RUN_FLAG)
    or a
    jp nz, RUN_NEXT
    jp REPL
