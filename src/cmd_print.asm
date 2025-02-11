; ============================================================================
; PBasic Z80 - PRINT Statement Execution
; ============================================================================

DO_PRINT:
    ld c, 0              ; Newline suppression flag (1 = suppress, 0 = emit)

.dp_loop:
    ld hl, (MEM_TOKEN_PTR)
    ld a, (hl)
    or a
    jp z, .dp_done

    ; Semicolon ';'
    cp ';'
    jr z, .dp_semicolon

    ; Comma ','
    cp ','
    jr z, .dp_comma

    ; Item being printed: clear suppress flag
    ld c, 0

    ; String literal 0xC1
    cp TOK_STRING
    jr z, .dp_string

    ; Arithmetic / variable expression
    push bc
    call EVAL_EXPR
    call PRINT_NUMBER
    pop bc
    jp .dp_loop

.dp_semicolon:
    inc hl
    ld (MEM_TOKEN_PTR), hl
    ld c, 1
    jp .dp_loop

.dp_comma:
    inc hl
    ld (MEM_TOKEN_PTR), hl
    push bc
    ld b, 8
.dp_spaces:
    ld a, ' '
    call OUTCHAR
    djnz .dp_spaces
    pop bc
    ld c, 1
    jp .dp_loop

.dp_string:
    inc hl
.dp_str_loop:
    ld a, (hl)
    cp TOK_STRING
    jr z, .dp_str_end
    or a
    jr z, .dp_str_done
    push bc
    push hl
    call OUTCHAR
    pop hl
    pop bc
    inc hl
    jp .dp_str_loop

.dp_str_end:
    inc hl
.dp_str_done:
    ld (MEM_TOKEN_PTR), hl
    jp .dp_loop

.dp_done:
    ld a, c
    or a
    jr nz, .dp_exit
    call PRINT_CRLF

.dp_exit:
    ld a, (MEM_RUN_FLAG)
    or a
    jp nz, RUN_NEXT
    jp REPL
