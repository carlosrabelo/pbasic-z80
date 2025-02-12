; ============================================================================
; PBasic Z80 - Program Memory Management & Allocation
; ============================================================================

PROG_INIT:
    push hl
    ; 1. Initialize sentinel: write 0x0000 at MEM_PROG_START
    ld hl, 0x0000
    ld (MEM_PROG_START), hl

    ; 2. Set MEM_PROG_END = MEM_PROG_START + 2 (empty list size is 2 bytes sentinel)
    ld hl, MEM_PROG_START + 2
    ld (MEM_PROG_END), hl

    ; 3. Set MEM_PROG_LIMIT = MEM_PROG_START + 16384 (16 KiB ceiling)
    ld hl, MEM_PROG_START + PROG_CAPACITY
    ld (MEM_PROG_LIMIT), hl

    pop hl
    ret

; ============================================================================
; Dynamic Memory Block Shifting
; ============================================================================

MEM_OPEN_HOLE:
    push bc
    push de
    push hl

    ; Save target in SCR_INS, hole size in SCR_LEN
    ld (SCR_INS), hl
    ld (SCR_LEN), bc

    ; Check if MEM_PROG_END + BC > MEM_PROG_LIMIT
    ld hl, (MEM_PROG_END)
    add hl, bc
    ex de, hl             ; DE = MEM_PROG_END + BC
    ld hl, (MEM_PROG_LIMIT)
    ; Compare DE with HL (unsigned)
    ld a, d
    cp h
    jr c, .moh_ok
    jr nz, .moh_overflow
    ld a, e
    cp l
    jr c, .moh_ok
    jr z, .moh_ok

.moh_overflow:
    pop hl
    pop de
    pop bc
    xor a
    ret

.moh_ok:
    ; Bytes to shift = MEM_PROG_END - target
    ld hl, (MEM_PROG_END)
    ld bc, (SCR_INS)
    ld a, l
    sub c
    ld l, a
    ld a, h
    sbc a, b
    ld h, a
    ; If bytes to shift == 0, skip LDDR
    ld a, h
    or l
    jr z, .moh_update_end

    ; Shift right using LDDR
    ld b, h
    ld c, l
    ; Source HL = MEM_PROG_END - 1
    ld hl, (MEM_PROG_END)
    dec hl
    ; Dest DE = new MEM_PROG_END - 1 = MEM_PROG_END + hole_size - 1
    ld de, (MEM_PROG_END)
    ld a, (SCR_LEN)
    add a, e
    ld e, a
    ld a, (SCR_LEN+1)
    adc a, d
    ld d, a
    dec de
    lddr

.moh_update_end:
    ld hl, (MEM_PROG_END)
    ld bc, (SCR_LEN)
    add hl, bc
    ld (MEM_PROG_END), hl

    pop hl
    pop de
    pop bc
    ld a, 1
    ret

MEM_CLOSE_HOLE:
    push bc
    push de
    push hl

    ; HL = target address, BC = hole size to remove
    ld (SCR_INS), hl
    ld (SCR_LEN), bc

    ; Source = target + hole_size
    add hl, bc
    push hl               ; Save source address

    ; Count = MEM_PROG_END - source
    ld hl, (MEM_PROG_END)
    pop bc                ; BC = source address
    push bc               ; Keep source address
    ld a, l
    sub c
    ld l, a
    ld a, h
    sbc a, b
    ld h, a
    pop de                ; DE = source address
    ; If count == 0, no data to shift left
    ld a, h
    or l
    jr z, .mch_update_end

    ; Shift left using LDIR
    ld b, h
    ld c, l
    ex de, hl             ; HL = source, DE = scratch
    ld de, (SCR_INS)      ; DE = target (destination)
    ldir

.mch_update_end:
    ld hl, (MEM_PROG_END)
    ld bc, (SCR_LEN)
    ld a, l
    sub c
    ld l, a
    ld a, h
    sbc a, b
    ld h, a
    ld (MEM_PROG_END), hl

    pop hl
    pop de
    pop bc
    ret

; ============================================================================
; Pointer Fixups
; ============================================================================

FIX_NEXT_ADD:
    push af
    push bc
    push de
    push hl
    ld (SCR_TMP), hl       ; Threshold in SCR_TMP
    ld (SCR_LEN), bc       ; Delta in SCR_LEN
    ld de, MEM_PROG_START

.fna_loop:
    ; Read next pointer at (DE)
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    ld b, a
    dec de
    ; Check sentinel
    ld a, b
    or c
    jr z, .fna_done

    ; Compare next pointer BC with threshold (SCR_TMP)
    ld hl, (SCR_TMP)
    ld a, b
    cp h
    jr c, .fna_skip
    jr nz, .fna_do_add
    ld a, c
    cp l
    jr c, .fna_skip
    jr z, .fna_skip

.fna_do_add:
    ld hl, (SCR_LEN)
    add hl, bc             ; HL = next + delta
    ld a, l
    ld (de), a
    inc de
    ld a, h
    ld (de), a
    dec de

.fna_skip:
    ; Advance DE to next node
    ld d, b
    ld e, c
    jr .fna_loop

.fna_done:
    pop hl
    pop de
    pop bc
    pop af
    ret

FIX_NEXT_SUB:
    push af
    push bc
    push de
    push hl
    ld (SCR_TMP), hl
    ld (SCR_LEN), bc
    ld de, MEM_PROG_START

.fns_loop:
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    ld b, a
    dec de
    ld a, b
    or c
    jr z, .fns_done

    ; If BC > HL -> subtract delta
    ld hl, (SCR_TMP)
    ld a, b
    cp h
    jr c, .fns_skip
    jr nz, .fns_do_sub
    ld a, c
    cp l
    jr c, .fns_skip
    jr z, .fns_skip

.fns_do_sub:
    ld a, (SCR_LEN)
    ld l, a
    ld a, (SCR_LEN+1)
    ld h, a
    ld a, c
    sub l
    ld l, a
    ld a, b
    sbc a, h
    ld h, a
    ld a, l
    ld (de), a
    inc de
    ld a, h
    ld (de), a
    dec de

.fns_skip:
    ld d, b
    ld e, c
    jr .fns_loop

.fns_done:
    pop hl
    pop de
    pop bc
    pop af
    ret
