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

VAR_ADDR:
    ; Input: A = variable token (0xD0..0xE9)
    ; Output: HL = address of variable in MEM_VARS
    ; Preserves BC, DE
    push af
    push de
    sub TOK_VAR_BASE
    add a, a
    add a, a
    ld l, a
    ld h, 0
    ld de, MEM_VARS
    add hl, de
    pop de
    pop af
    ret

VAR_GET:
    ; Input: A = variable token (0xD0..0xE9)
    ; Output: DE:HL = 32-bit value (HL = low word, DE = high word)
    ; Preserves BC
    push bc
    call VAR_ADDR
    ld c, (hl)
    inc hl
    ld b, (hl)
    inc hl
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld h, b
    ld l, c
    pop bc
    ret

VAR_SET:
    ; Input: A = variable token (0xD0..0xE9)
    ;        DE:HL = 32-bit value (HL = low word, DE = high word)
    ; Preserves BC
    push bc
    push de
    push hl
    call VAR_ADDR
    pop bc
    ld (hl), c
    inc hl
    ld (hl), b
    inc hl
    pop bc
    ld (hl), c
    inc hl
    ld (hl), b
    pop bc
    ret

