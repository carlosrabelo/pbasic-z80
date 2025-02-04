; ============================================================================
; PBasic Z80 - Console Character I/O and Formatted Output Primitives
; ============================================================================

INCHAR:
    push bc
.inchar_wait_rx:
    ld bc, PORT_STATUS
    in a, (c)
    bit STATUS_RX_READY, a
    jr z, .inchar_wait_rx
    ld bc, PORT_DATA
    in a, (c)
    pop bc
    ret

OUTCHAR:
    push bc
    push af
.outchar_wait_tx:
    ld bc, PORT_STATUS
    in a, (c)
    bit STATUS_TX_READY, a
    jr z, .outchar_wait_tx
    pop af
    push af
    ld bc, PORT_DATA
    out (c), a
    pop af
    pop bc
    ret

CHECK_BREAK:
    push bc
    ld bc, PORT_STATUS
    in a, (c)
    bit STATUS_BREAK, a
    jr z, .cbrk_no_break
    out (c), a
    ld a, 1
    pop bc
    ret
.cbrk_no_break:
    xor a
    pop bc
    ret

PRINT_STR:
    push hl
    push af
.pstr_loop:
    ld a, (hl)
    or a
    jr z, .pstr_done
    call OUTCHAR
    inc hl
    jr .pstr_loop
.pstr_done:
    pop af
    pop hl
    ret

PRINT_CRLF:
    push af
    ld a, 10
    call OUTCHAR
    pop af
    ret

PRINT_OK:
    push hl
    ld hl, MSG_OK
    call PRINT_STR
    pop hl
    ret

NEG32:
    ld a, l
    cpl
    ld l, a
    ld a, h
    cpl
    ld h, a
    ld a, e
    cpl
    ld e, a
    ld a, d
    cpl
    ld d, a
    inc hl
    ld a, h
    or l
    ret nz
    inc de
    ret

PRINT_NUMBER:
    push af
    push bc
    push de
    push hl
    push ix

    ; Check if negative
    bit 7, d
    jr z, .pnum_not_neg
    ld a, '-'
    call OUTCHAR
    call NEG32

.pnum_not_neg:
    ld ix, POWERS_OF_10
    ld c, 10          ; 10 powers
    xor a
    ld (SCR_TMP), a   ; Leading zero flag in scratchpad

.pnum_power_loop:
    ld b, 0           ; digit = 0

.pnum_sub_loop:
    ld a, d
    cp (ix+3)
    jr c, .pnum_cannot_sub
    jr nz, .pnum_can_sub
    ld a, e
    cp (ix+2)
    jr c, .pnum_cannot_sub
    jr nz, .pnum_can_sub
    ld a, h
    cp (ix+1)
    jr c, .pnum_cannot_sub
    jr nz, .pnum_can_sub
    ld a, l
    cp (ix+0)
    jr c, .pnum_cannot_sub

.pnum_can_sub:
    ld a, l
    sub (ix+0)
    ld l, a
    ld a, h
    sbc a, (ix+1)
    ld h, a
    ld a, e
    sbc a, (ix+2)
    ld e, a
    ld a, d
    sbc a, (ix+3)
    ld d, a
    inc b
    jr .pnum_sub_loop

.pnum_cannot_sub:
    ; Digit is in B
    ld a, b
    or a
    jr nz, .pnum_do_print
    ld a, (SCR_TMP)
    or a
    jr nz, .pnum_do_print
    ld a, c
    cp 1
    jr z, .pnum_do_print
    jr .pnum_next_power

.pnum_do_print:
    ld a, 1
    ld (SCR_TMP), a
    ld a, b
    add a, '0'
    call OUTCHAR

.pnum_next_power:
    inc ix
    inc ix
    inc ix
    inc ix
    dec c
    jr nz, .pnum_power_loop

    pop ix
    pop hl
    pop de
    pop bc
    pop af
    ret

READ_LINE:
    push bc
    push de
    push hl
    ld hl, MEM_INPUT_BUF
    ld c, 0               ; Character count (0..126)

.rl_read_char:
    call INCHAR
    ld b, a               ; Save character in B

    cp 13
    jr z, .rl_end_line
    cp 10
    jr z, .rl_end_line

    cp 8
    jr z, .rl_backspace
    cp 127
    jr z, .rl_backspace

    ld a, c
    cp 126
    jr nc, .rl_read_char  ; Cap input at 126 characters

    ld a, b
    cp 'a'
    jr c, .rl_not_lower
    cp 'z' + 1
    jr nc, .rl_not_lower
    sub 32
.rl_not_lower:
    ld (hl), a
    inc hl
    inc c
    call OUTCHAR
    jr .rl_read_char

.rl_backspace:
    ld a, c
    or a
    jr z, .rl_read_char   ; Nothing to erase
    dec c
    dec hl
    ld a, 8
    call OUTCHAR
    ld a, ' '
    call OUTCHAR
    ld a, 8
    call OUTCHAR
    jr .rl_read_char

.rl_end_line:
    ld (hl), 0            ; Null terminate buffer
    call PRINT_CRLF
    pop hl
    pop de
    pop bc
    ret

POWERS_OF_10:
    defw 0xCA00, 0x3B9A   ; 1,000,000,000
    defw 0xE100, 0x05F5   ; 100,000,000
    defw 0x9680, 0x0098   ; 10,000,000
    defw 0x4240, 0x000F   ; 1,000,000
    defw 0x86A0, 0x0001   ; 100,000
    defw 0x2710, 0x0000   ; 10,000
    defw 0x03E8, 0x0000   ; 1,000
    defw 0x0064, 0x0000   ; 100
    defw 0x000A, 0x0000   ; 10
    defw 0x0001, 0x0000   ; 1
