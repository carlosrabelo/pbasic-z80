; ============================================================================
; PBasic Z80 - Program Line Management & Lookup
; ============================================================================

LINE_FIND:
    push hl
    ld de, MEM_PROG_START

.lf_loop:
    ; Read next pointer at (DE)
    push de
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    ld b, a
    pop de

    ; Check if sentinel (next == 0x0000)
    ld a, b
    or c
    jr z, .lf_sentinel

    ; Read line number at DE + 2
    push de
    inc de
    inc de
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    ld b, a
    pop de

    ; Compare candidate BC with target (TOS = HL)
    pop hl
    push hl
    ld a, b
    cp h
    jr nz, .lf_chk_greater
    ld a, c
    cp l
    jr z, .lf_found

.lf_chk_greater:
    ld a, b
    cp h
    jr c, .lf_less
    jr nz, .lf_greater
    ld a, c
    cp l
    jr c, .lf_less

.lf_greater:
    ; Candidate > Target: insertion point found at DE
    pop hl
    xor a
    ret

.lf_less:
    ; Candidate < Target: advance DE = next pointer
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    ld d, a
    ld e, c
    jr .lf_loop

.lf_found:
    pop hl
    ld a, 1
    ret

.lf_sentinel:
    pop hl
    xor a
    ret
