; ============================================================================
; PBasic Z80 - Utility Functions & PRNG
; ============================================================================

RAND16:
    ; seed = (seed * 25173 + 13849) mod 65536
    ; Output: HL = new 16-bit pseudo-random word
    push de
    ld hl, (MEM_RAND_SEED)
    ld de, 25173
    call MUL16
    ld de, 13849
    add hl, de
    ld (MEM_RAND_SEED), hl
    pop de
    ret
