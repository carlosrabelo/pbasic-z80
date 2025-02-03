; ============================================================================
; PBasic Z80 - Console Character I/O Primitives
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
