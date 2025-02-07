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

DIV16:
    ; Input: HL = dividend, DE = divisor
    ; Output: HL = quotient (HL / DE), or 0xFFFF if DE == 0
    ld a, d
    or e
    jr nz, .div16_nonzero
    ld hl, 0xFFFF
    ret
.div16_nonzero:
    call DIVMOD16
    ld h, b
    ld l, c
    ret

MOD16:
    ; Input: HL = dividend, DE = divisor
    ; Output: HL = remainder (HL % DE), or original HL if DE == 0
    ld a, d
    or e
    ret z
    call DIVMOD16
    ret

DIVMOD16:
    ; Input: HL = dividend, DE = divisor
    ; Output: BC = quotient, A = B (so A:C = quotient), HL = remainder
    ld b, h
    ld c, l
    ld hl, 0
    ld a, 16

.dm16_loop:
    sla c
    rl b
    adc hl, hl

    or a
    sbc hl, de
    jr nc, .dm16_no_restore
    add hl, de
    jp .dm16_next

.dm16_no_restore:
    inc c

.dm16_next:
    dec a
    jp nz, .dm16_loop

    ld a, b
    ret

