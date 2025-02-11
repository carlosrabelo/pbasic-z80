; ============================================================================
; PBasic Z80 - RUN Command and Program Execution Loop
; ============================================================================

DO_RUN:
    ld hl, (MEM_PROG_START)
    ld a, h
    or l
    jr nz, .drun_start

    ld hl, MSG_NO_PROGRAM
    call PRINT_STR
    jp REPL

.drun_start:
    xor a
    ld (MEM_GOSUB_SP), a
    inc a
    ld (MEM_RUN_FLAG), a

    ld hl, MEM_PROG_START
    ld (MEM_LINE_PTR), hl

    ld de, 4
    add hl, de
    ld (MEM_TOKEN_PTR), hl

    jp REPL_DISPATCH

RUN_NEXT:
    call CHECK_BREAK
    or a
    jr z, .rn_no_break
    xor a
    ld (MEM_RUN_FLAG), a
    jp REPL

.rn_no_break:
    ld hl, (MEM_LINE_PTR)
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld a, d
    or e
    jp z, RUN_END

    ld (MEM_LINE_PTR), de
    ex de, hl
    ld de, 4
    add hl, de
    ld (MEM_TOKEN_PTR), hl

    jp REPL_DISPATCH

RUN_END:
    xor a
    ld (MEM_RUN_FLAG), a
    jp REPL
