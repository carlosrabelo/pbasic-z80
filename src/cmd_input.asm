; ============================================================================
; PBasic Z80 - INPUT Statement Execution
; ============================================================================

DO_INPUT:
    ld hl, (MEM_TOKEN_PTR)
    ld a, (hl)
    cp TOK_STRING
    jr nz, .di_check_var

    ; 1. Print prompt string
    inc hl
.di_prompt_loop:
    ld a, (hl)
    cp TOK_STRING
    jr z, .di_prompt_end
    or a
    jp z, REPL_SYNTAX_ERROR
    push hl
    call OUTCHAR
    pop hl
    inc hl
    jp .di_prompt_loop

.di_prompt_end:
    inc hl
    ld a, (hl)
    cp ';'
    jp nz, REPL_SYNTAX_ERROR
    inc hl
    ld (MEM_TOKEN_PTR), hl

.di_check_var:
    ; 2. Verify variable token 0xD0..0xE9
    ld hl, (MEM_TOKEN_PTR)
    ld a, (hl)
    cp TOK_VAR_BASE
    jp c, REPL_SYNTAX_ERROR
    cp TOK_VAR_BASE + 26
    jp nc, REPL_SYNTAX_ERROR

    ; 3. Save variable token and advance pointer
    ld c, a
    inc hl
    ld (MEM_TOKEN_PTR), hl
    push bc              ; stack: [var_token]

    ; 4. Read user input line into MEM_INPUT_BUF
    call READ_LINE

    ; 5. Parse MEM_INPUT_BUF as signed decimal integer
    ld hl, MEM_INPUT_BUF

.di_skip_spaces:
    ld a, (hl)
    cp ' '
    jr nz, .di_check_sign
    inc hl
    jp .di_skip_spaces

.di_check_sign:
    ld b, 0              ; B = sign flag (0 = positive, 1 = negative)
    cp '-'
    jr nz, .di_parse_init
    ld b, 1
    inc hl

.di_parse_init:
    push bc              ; stack: [var_token, sign_flag]
    ld de, 0
    ld (SCR_ACC_LO), de
    ld (SCR_ACC_HI), de

.di_digit_loop:
    ld a, (hl)
    cp '0'
    jr c, .di_digits_done
    cp '9' + 1
    jr nc, .di_digits_done

    sub '0'
    ld c, a
    ld b, 0

    inc hl
    push hl

    ; Acc * 2:
    ld de, (SCR_ACC_LO)
    ld hl, (SCR_ACC_HI)
    sla e
    rl d
    rl l
    rl h
    push de
    push hl

    ; Acc * 8:
    sla e
    rl d
    rl l
    rl h
    sla e
    rl d
    rl l
    rl h

    ; Acc * 10:
    pop bc
    ex (sp), hl
    add hl, de
    ex de, hl
    pop hl
    adc hl, bc
    ex de, hl

    ; Add digit:
    add hl, bc
    jr nc, .di_no_carry
    inc de
.di_no_carry:
    ld (SCR_ACC_LO), hl
    ld (SCR_ACC_HI), de

    pop hl
    jp .di_digit_loop

.di_digits_done:
    pop bc               ; B = sign flag
    ld hl, (SCR_ACC_LO)
    ld de, (SCR_ACC_HI)
    ld a, b
    or a
    jr z, .di_store_val
    call NEG32

.di_store_val:
    pop bc               ; C = variable token
    ld a, c
    call VAR_SET

    ; 6. Resume execution
    ld a, (MEM_RUN_FLAG)
    or a
    jp nz, RUN_NEXT
    jp REPL
