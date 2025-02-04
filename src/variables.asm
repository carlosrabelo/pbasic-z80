; ============================================================================
; PBasic Z80 - Variable Subsystem Initialization
; ============================================================================

VAR_INIT:
    push bc
    push hl
    ld hl, MEM_VARS
    ld b, 104
    xor a
.var_init_loop:
    ld (hl), a
    inc hl
    djnz .var_init_loop
    pop hl
    pop bc
    ret
