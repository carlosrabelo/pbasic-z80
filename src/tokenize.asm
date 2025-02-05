; ============================================================================
; PBasic Z80 - Bytecode Tokenizer Engine
; ============================================================================

TOKENIZE:
    push af
    push bc
    push de
    push hl

    ld hl, MEM_INPUT_BUF
    ld (SCR_PTR), hl
    ld hl, MEM_TOKEN_BUF
    ld (SCR_PTR2), hl

.tok_loop:
    ld hl, (SCR_PTR)
    ld a, (hl)

    ; 1. End of line check
    or a
    jp z, .tok_end

    ; 2. Skip whitespace
    cp ' '
    jr nz, .tok_check_keyword
    inc hl
    ld (SCR_PTR), hl
    jp .tok_loop

.tok_check_keyword:
    call TRY_MATCH_KEYWORD
    or a
    jr z, .tok_check_string

    ; Keyword matched! Token in A
    ld b, a
    ld de, (SCR_PTR2)
    ld (de), a
    inc de
    ld (SCR_PTR2), de

    ; Check if REM (0x8C)
    ld a, b
    cp TOK_REM
    jp nz, .tok_loop

    ; REM: copy all remaining characters until 0x00
    ld hl, (SCR_PTR)
    ld de, (SCR_PTR2)
.tok_rem_copy:
    ld a, (hl)
    or a
    jr z, .tok_rem_done
    ld (de), a
    inc hl
    inc de
    jr .tok_rem_copy
.tok_rem_done:
    ld (SCR_PTR), hl
    ld (SCR_PTR2), de
    jp .tok_end

.tok_check_string:
    ; 3. String literal check: '"'
    ld hl, (SCR_PTR)
    ld a, (hl)
    cp '"'
    jr nz, .tok_check_digit

    ; Advance past opening quote
    inc hl
    ld de, (SCR_PTR2)
    ld a, TOK_STRING      ; 0xC1
    ld (de), a
    inc de

.tok_str_loop:
    ld a, (hl)
    or a
    jr z, .tok_str_close
    cp '"'
    jr z, .tok_str_quote
    ld (de), a
    inc hl
    inc de
    jr .tok_str_loop

.tok_str_quote:
    inc hl                ; Advance past closing quote
.tok_str_close:
    ld a, TOK_STRING      ; 0xC1
    ld (de), a
    inc de
    ld (SCR_PTR), hl
    ld (SCR_PTR2), de
    jp .tok_loop

.tok_check_digit:
    ; 4. Numeric literal check: '0'..'9'
    ld hl, (SCR_PTR)
    ld a, (hl)
    cp '0'
    jr c, .tok_check_relop
    cp '9' + 1
    jr nc, .tok_check_relop
    call PARSE_NUMBER
    jp .tok_loop

.tok_check_relop:
    ; 5. Multi-character relational operators: '<>', '<=', '>='
    ld hl, (SCR_PTR)
    ld a, (hl)
    cp '<'
    jr z, .tok_relop_lt
    cp '>'
    jr z, .tok_relop_gt
    jr .tok_check_variable

.tok_relop_lt:
    inc hl
    ld a, (hl)
    cp '>'
    jr z, .tok_relop_neq
    cp '='
    jr z, .tok_relop_lte
    ; Standalone '<'
    dec hl
    jr .tok_fallback

.tok_relop_neq:
    inc hl
    ld (SCR_PTR), hl
    ld de, (SCR_PTR2)
    ld a, TOK_NEQ         ; 0xB0
    ld (de), a
    inc de
    ld (SCR_PTR2), de
    jp .tok_loop

.tok_relop_lte:
    inc hl
    ld (SCR_PTR), hl
    ld de, (SCR_PTR2)
    ld a, TOK_LTE         ; 0xB1
    ld (de), a
    inc de
    ld (SCR_PTR2), de
    jp .tok_loop

.tok_relop_gt:
    inc hl
    ld a, (hl)
    cp '='
    jr z, .tok_relop_gte
    ; Standalone '>'
    dec hl
    jr .tok_fallback

.tok_relop_gte:
    inc hl
    ld (SCR_PTR), hl
    ld de, (SCR_PTR2)
    ld a, TOK_GTE         ; 0xB2
    ld (de), a
    inc de
    ld (SCR_PTR2), de
    jp .tok_loop

.tok_check_variable:
    ; 6. Variable check: 'A'..'Z'
    ld hl, (SCR_PTR)
    ld a, (hl)
    cp 'A'
    jr c, .tok_fallback
    cp 'Z' + 1
    jr nc, .tok_fallback

    ; Single-letter variable: 0xD0 + (A - 'A')
    sub 'A'
    add a, TOK_VAR_BASE
    ld de, (SCR_PTR2)
    ld (de), a
    inc de
    ld (SCR_PTR2), de
    inc hl
    ld (SCR_PTR), hl
    jp .tok_loop

.tok_fallback:
    ; 7. Punctuation and standalone operators emitted verbatim
    ld hl, (SCR_PTR)
    ld de, (SCR_PTR2)
    ld a, (hl)
    ld (de), a
    inc de
    ld (SCR_PTR2), de
    inc hl
    ld (SCR_PTR), hl
    jp .tok_loop

.tok_end:
    ; Terminate token stream with 0x00
    ld de, (SCR_PTR2)
    xor a
    ld (de), a
    pop hl
    pop de
    pop bc
    pop af
    ret

; ============================================================================
; Numeric Literal Parsing
; ============================================================================

PARSE_NUMBER:
    push bc
    push de
    push hl
    push ix

    ; 1. Emit TOK_NUMBER (0xC0)
    ld de, (SCR_PTR2)
    ld a, TOK_NUMBER
    ld (de), a
    inc de
    ld (SCR_PTR2), de

    ; 2. Parse decimal digits into 16-bit integer HL
    ld hl, 0
    ld ix, (SCR_PTR)

.pn_loop:
    ld a, (ix+0)
    cp '0'
    jr c, .pn_done
    cp '9' + 1
    jr nc, .pn_done

    sub '0'
    ld c, a               ; C = digit

    ; HL = HL * 10
    add hl, hl            ; * 2
    ld d, h
    ld e, l               ; DE = HL * 2
    add hl, hl            ; * 4
    add hl, hl            ; * 8
    add hl, de            ; * 10

    ; HL = HL + digit
    ld b, 0
    add hl, bc

    inc ix
    jr .pn_loop

.pn_done:
    ld (SCR_PTR), ix      ; Advance SCR_PTR past number

    ; 3. Emit 16-bit word in little-endian order (<lo> <hi>)
    ld de, (SCR_PTR2)
    ld a, l
    ld (de), a
    inc de
    ld a, h
    ld (de), a
    inc de
    ld (SCR_PTR2), de

    pop ix
    pop hl
    pop de
    pop bc
    ret

; ============================================================================
; Keyword Matching Primitives
; ============================================================================

TRY_MATCH_KEYWORD:
    push de
    push bc
    ld de, KEYWORD_TABLE
.tmk_table_loop:
    ld a, (de)
    or a
    jr z, .tmk_no_match
    ld c, a           ; C = token byte
    inc de            ; DE points to keyword string
    ld hl, (SCR_PTR)
    call MATCH_KEYWORD
    or a
    jr nz, .tmk_found
    ; Skip to next keyword in table
.tmk_skip_str:
    ld a, (de)
    inc de
    or a
    jr nz, .tmk_skip_str
    jr .tmk_table_loop

.tmk_found:
    ld (SCR_PTR), hl  ; Update SCR_PTR past matched keyword
    ld a, c           ; Return token in A
    pop bc
    pop de
    ret

.tmk_no_match:
    xor a
    pop bc
    pop de
    ret

MATCH_KEYWORD:
    push de
    push hl
.mk_loop:
    ld a, (de)
    or a
    jr z, .mk_matched_word
    ld b, a
    ld a, (hl)
    cp b
    jr nz, .mk_failed
    inc hl
    inc de
    jr .mk_loop

.mk_matched_word:
    ; Boundary check: next character must NOT be 'A'..'Z'
    ld a, (hl)
    cp 'A'
    jr c, .mk_success
    cp 'Z' + 1
    jr c, .mk_failed

.mk_success:
    pop af            ; Discard original HL
    pop de
    ld a, 1
    ret

.mk_failed:
    pop hl            ; Restore original HL
    pop de
    xor a
    ret

KEYWORD_TABLE:
    defb TOK_LET
    defm "LET\0"
    defb TOK_GOTO
    defm "GOTO\0"
    defb TOK_GOSUB
    defm "GOSUB\0"
    defb TOK_PRINT
    defm "PRINT\0"
    defb TOK_IF
    defm "IF\0"
    defb TOK_INPUT
    defm "INPUT\0"
    defb TOK_RETURN
    defm "RETURN\0"
    defb TOK_END
    defm "END\0"
    defb TOK_LIST
    defm "LIST\0"
    defb TOK_RUN
    defm "RUN\0"
    defb TOK_NEW
    defm "NEW\0"
    defb TOK_EXIT
    defm "EXIT\0"
    defb TOK_REM
    defm "REM\0"
    defb TOK_THEN
    defm "THEN\0"
    defb TOK_FREE
    defm "FREE\0"
    defb TOK_RND
    defm "RND\0"
    defb TOK_ABS
    defm "ABS\0"
    defb 0
