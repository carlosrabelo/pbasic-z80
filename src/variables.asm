; ============================================================================
; PBasic Z80 - Variables Storage & Management
; ============================================================================

VAR_INIT:
    push bc
    push hl
    ; Zero all 104 bytes in MEM_VARS (26 variables A..Z, 4 bytes each)
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
