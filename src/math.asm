; ============================================================================
; PBasic Z80 - Mathematical Engine (16-bit Arithmetic)
; ============================================================================

MUL16:
    ; Input: HL = multiplicand, DE = multiplier
    ; Output: HL = 16-bit unsigned product (HL * DE) & 0xFFFF
    ; Preserves BC
    push bc
    push de
    ld b, h
    ld c, l              ; BC = multiplicand
    ld hl, 0             ; HL = accumulator
    ld a, 16

.mul16_loop:
    srl d
    rr e                 ; Shift multiplier right into carry
    jr nc, .mul16_no_add
    add hl, bc           ; Add multiplicand to product
.mul16_no_add:
    sla c
    rl b                 ; Shift multiplicand left
    dec a
    jp nz, .mul16_loop

    pop de
    pop bc
    ret
