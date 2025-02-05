; ============================================================================
; PBasic Z80 - Bytecode Detokenizer (PRINT_TOKENS)
; ============================================================================

PRINT_TOKENS:
    push af
    push bc
    push de
    push hl

.dtok_loop:
    ld a, (hl)
    inc hl
    or a
    jp z, .dtok_end

    ; 1. Number literal (0xC0 <lo> <hi>)
    cp TOK_NUMBER
    jr nz, .dtok_not_num
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    push hl
    ld h, d
    ld l, e
    ld de, 0
    call PRINT_NUMBER
    pop hl
    jp .dtok_loop

.dtok_not_num:
    ; 2. String literal (0xC1 ... 0xC1)
    cp TOK_STRING
    jr nz, .dtok_not_str
    ld a, '"'
    call OUTCHAR
.dtok_str_loop:
    ld a, (hl)
    inc hl
    or a
    jr z, .dtok_str_done
    cp TOK_STRING
    jr z, .dtok_str_done
    call OUTCHAR
    jr .dtok_str_loop
.dtok_str_done:
    ld a, '"'
    call OUTCHAR
    jp .dtok_loop

.dtok_not_str:
    ; 3. Keywords (0x80 - 0x8D)
    cp TOK_LET
    jr c, .dtok_not_kw
    cp TOK_THEN + 1
    jr nc, .dtok_not_kw
    sub TOK_LET
    push hl
    call PRINT_KW
    pop hl
    jp .dtok_loop

.dtok_not_kw:
    ; 4. Built-in functions (0xA0 - 0xA2)
    cp TOK_FREE
    jr c, .dtok_not_fn
    cp TOK_ABS + 1
    jr nc, .dtok_not_fn
    sub TOK_FREE
    push hl
    call PRINT_FN
    pop hl
    jp .dtok_loop

.dtok_not_fn:
    ; 5. Multi-character relational operators (0xB0 - 0xB2)
    cp TOK_NEQ
    jr c, .dtok_not_rel
    cp TOK_GTE + 1
    jr nc, .dtok_not_rel
    sub TOK_NEQ
    push hl
    call PRINT_REL
    pop hl
    jp .dtok_loop

.dtok_not_rel:
    ; 6. Single-letter variables (0xD0 - 0xE9)
    cp TOK_VAR_BASE
    jr c, .dtok_not_var
    cp TOK_VAR_BASE + 26
    jr nc, .dtok_not_var
    sub TOK_VAR_BASE
    add a, 'A'
    call OUTCHAR
    jp .dtok_loop

.dtok_not_var:
    ; 7. Other bytes emitted directly
    call OUTCHAR
    jp .dtok_loop

.dtok_end:
    pop hl
    pop de
    pop bc
    pop af
    ret

; ============================================================================
; Token Printing Helpers
; ============================================================================

PRINT_KW:
    ld hl, PKW_TABLE
    call INDEX_STRING_TABLE
    jp PRINT_STR

PRINT_FN:
    ld hl, PFN_TABLE
    call INDEX_STRING_TABLE
    jp PRINT_STR

PRINT_REL:
    ld hl, PREL_TABLE
    call INDEX_STRING_TABLE
    jp PRINT_STR

INDEX_STRING_TABLE:
    or a
    ret z
    ld b, a
.ist_loop:
    ld a, (hl)
    inc hl
    or a
    jr nz, .ist_loop
    djnz .ist_loop
    ret

PKW_TABLE:
    defm "LET \0"
    defm "GOTO \0"
    defm "GOSUB \0"
    defm "PRINT \0"
    defm "IF \0"
    defm "INPUT \0"
    defm "RETURN\0"
    defm "END\0"
    defm "LIST\0"
    defm "RUN\0"
    defm "NEW\0"
    defm "EXIT\0"
    defm "REM \0"
    defm "THEN \0"

PFN_TABLE:
    defm "FREE\0"
    defm "RND\0"
    defm "ABS\0"

PREL_TABLE:
    defm "<> \0"
    defm "<= \0"
    defm ">= \0"
