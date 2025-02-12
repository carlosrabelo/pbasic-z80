; ============================================================================
; PBasic Z80 - IF/THEN Statement Execution
; ============================================================================

DO_IF:
    call EVAL_COND
    or a
    jr z, .dif_false

    ld hl, (MEM_TOKEN_PTR)
    ld a, (hl)
    cp TOK_THEN
    jp nz, REPL_SYNTAX_ERROR

    inc hl
    ld (MEM_TOKEN_PTR), hl

    ld a, (hl)
    cp TOK_FREE
    jr z, .dif_free

    cp 0x80
    jp c, REPL_SYNTAX_ERROR
    cp 0x8D
    jp nc, REPL_SYNTAX_ERROR

    inc hl
    ld (MEM_TOKEN_PTR), hl

    sub 0x80
    add a, a
    ld e, a
    ld d, 0
    ld hl, CMD_JUMP_TABLE
    add hl, de
    ld e, (hl)
    inc hl
    ld d, (hl)
    ex de, hl
    jp (hl)

.dif_free:
    inc hl
    ld (MEM_TOKEN_PTR), hl
    jp DO_FREE

.dif_false:
    ld a, (MEM_RUN_FLAG)
    or a
    jp nz, RUN_NEXT
    jp REPL
