; ============================================================================
; PBasic Z80 - NEW Command Execution
; ============================================================================

DO_NEW:
    call PROG_INIT
    call VAR_INIT
    ld hl, MSG_OK
    call PRINT_STR
    jp REPL
