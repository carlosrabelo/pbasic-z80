; ============================================================================
; PBasic Z80 - Command Dispatcher
; ============================================================================

REPL_SYNTAX_ERROR:
    ld hl, MSG_ERROR
    call PRINT_STR
    xor a
    ld (MEM_RUN_FLAG), a
    jp REPL

REPL_DISPATCH:
    ld hl, (MEM_TOKEN_PTR)
    ld a, (hl)

    ; 0x00: End of statement
    or a
    jr z, .disp_eol

    ; 0xC0: Stored program line (starts with line number token 0xC0)
    cp TOK_NUMBER
    jp z, .disp_line_store

    ; 0xA0: Direct FREE statement
    cp TOK_FREE
    jp z, .disp_free

    ; Command tokens 0x80..0x8C
    cp 0x80
    jr c, REPL_SYNTAX_ERROR
    cp 0x8D
    jr nc, REPL_SYNTAX_ERROR

    ; Advance MEM_TOKEN_PTR past command token
    inc hl
    ld (MEM_TOKEN_PTR), hl

    ; Calculate jump offset: (token - 0x80) * 2
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

.disp_eol:
    ld a, (MEM_RUN_FLAG)
    or a
    jp nz, RUN_NEXT
    jp REPL

.disp_line_store:
    call LINE_STORE
    jp REPL

.disp_free:
    inc hl
    ld (MEM_TOKEN_PTR), hl
    jp DO_FREE

RUN_NEXT:
    ; For now, loops back to REPL
    jp REPL

; Command jump table for tokens 0x80..0x8C
CMD_JUMP_TABLE:
    defw DO_LET      ; 0x80
    defw DO_GOTO     ; 0x81
    defw DO_GOSUB    ; 0x82
    defw DO_PRINT    ; 0x83
    defw DO_IF       ; 0x84
    defw DO_INPUT    ; 0x85
    defw DO_RETURN   ; 0x86
    defw DO_END      ; 0x87
    defw DO_LIST     ; 0x88
    defw DO_RUN      ; 0x89
    defw DO_NEW      ; 0x8A
    defw DO_EXIT     ; 0x8B
    defw DO_REM      ; 0x8C

; Temporary stubs until respective modules are implemented
DO_GOTO:    jp REPL_SYNTAX_ERROR
DO_GOSUB:   jp REPL_SYNTAX_ERROR
DO_IF:      jp REPL_SYNTAX_ERROR
DO_INPUT:   jp REPL_SYNTAX_ERROR
DO_RETURN:  jp REPL_SYNTAX_ERROR
DO_END:     jp REPL_SYNTAX_ERROR
DO_RUN:     jp REPL_SYNTAX_ERROR
DO_EXIT:    jp REPL_SYNTAX_ERROR
