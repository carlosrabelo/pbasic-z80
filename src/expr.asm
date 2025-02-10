; ============================================================================
; PBasic Z80 - Expression Evaluator
; ============================================================================

EVAL_FACTOR:
    ld hl, (MEM_TOKEN_PTR)
    ld a, (hl)

    ; 1. Number literal (0xC0)
    cp TOK_NUMBER
    jp z, .ef_number

    ; 2. Variable (0xD0..0xE9)
    cp TOK_VAR_BASE
    jr c, .ef_not_var
    cp TOK_VAR_BASE + 26
    jr nc, .ef_not_var
    inc hl
    ld (MEM_TOKEN_PTR), hl
    jp VAR_GET

.ef_not_var:
    ; 3. TOK_FREE (0xA0)
    cp TOK_FREE
    jp z, .ef_free

    ; 4. TOK_RND (0xA1)
    cp TOK_RND
    jp z, .ef_rnd

    ; 5. TOK_ABS (0xA2)
    cp TOK_ABS
    jp z, .ef_abs

    ; 6. Parenthesized expression '(' (0x28)
    cp 0x28
    jp z, .ef_paren

    ; 7. Unary minus '-' (0x2D)
    cp 0x2D
    jp z, .ef_unary_minus

    ; 8. Unary plus '+' (0x2B)
    cp 0x2B
    jp z, .ef_unary_plus

    ; Unexpected token -> return DE:HL = 0
    ld hl, 0
    ld de, 0
    ret

.ef_number:
    inc hl
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ld (MEM_TOKEN_PTR), hl
    ex de, hl
    ld de, 0
    ret

.ef_free:
    inc hl
    ld (MEM_TOKEN_PTR), hl
    ld hl, (MEM_PROG_LIMIT)
    ld de, (MEM_PROG_END)
    or a
    sbc hl, de
    ld de, 0
    ret

.ef_rnd:
    inc hl
    ld (MEM_TOKEN_PTR), hl
    ld a, (hl)
    cp 0x28
    jr nz, .ef_rnd_noparen
    inc hl
    ld (MEM_TOKEN_PTR), hl
.ef_rnd_noparen:
    call EVAL_EXPR
    push hl
    ld hl, (MEM_TOKEN_PTR)
    ld a, (hl)
    cp 0x29
    jr nz, .ef_rnd_close_done
    inc hl
    ld (MEM_TOKEN_PTR), hl
.ef_rnd_close_done:
    pop de
    ld a, d
    or e
    jr nz, .ef_rnd_nonzero
    call RAND16
    ld de, 0
    ret
.ef_rnd_nonzero:
    call RAND16
    call MOD16
    inc hl
    ld de, 0
    ret

.ef_abs:
    inc hl
    ld (MEM_TOKEN_PTR), hl
    ld a, (hl)
    cp 0x28
    jr nz, .ef_abs_noparen
    inc hl
    ld (MEM_TOKEN_PTR), hl
.ef_abs_noparen:
    call EVAL_EXPR
    push de
    push hl
    ld hl, (MEM_TOKEN_PTR)
    ld a, (hl)
    cp 0x29
    jr nz, .ef_abs_close_done
    inc hl
    ld (MEM_TOKEN_PTR), hl
.ef_abs_close_done:
    pop hl
    pop de
    bit 7, d
    ret z
    jp NEG32

.ef_paren:
    inc hl
    ld (MEM_TOKEN_PTR), hl
    call EVAL_EXPR
    push de
    push hl
    ld hl, (MEM_TOKEN_PTR)
    ld a, (hl)
    cp 0x29
    jr nz, .ef_paren_done
    inc hl
    ld (MEM_TOKEN_PTR), hl
.ef_paren_done:
    pop hl
    pop de
    ret

.ef_unary_minus:
    inc hl
    ld (MEM_TOKEN_PTR), hl
    call EVAL_FACTOR
    jp NEG32

.ef_unary_plus:
    inc hl
    ld (MEM_TOKEN_PTR), hl
    jp EVAL_FACTOR

EVAL_TERM:
    call EVAL_FACTOR
.et_loop:
    push hl
    ld hl, (MEM_TOKEN_PTR)
    ld a, (hl)
    pop hl
    cp '*'
    jp z, .et_mul
    cp '/'
    jp z, .et_div
    ret

.et_mul:
    push hl
    ld hl, (MEM_TOKEN_PTR)
    inc hl
    ld (MEM_TOKEN_PTR), hl
    call EVAL_FACTOR
    ld d, h
    ld e, l
    pop hl
    call MUL16
    ld de, 0
    jp .et_loop

.et_div:
    push hl
    ld hl, (MEM_TOKEN_PTR)
    inc hl
    ld (MEM_TOKEN_PTR), hl
    call EVAL_FACTOR
    ld d, h
    ld e, l
    pop hl
    call DIV16
    ld de, 0
    jp .et_loop

EVAL_EXPR:
    ld hl, (SCR_ACC_LO)
    push hl
    ld hl, (SCR_ACC_HI)
    push hl

    call EVAL_TERM
    ld (SCR_ACC_LO), hl
    ld (SCR_ACC_HI), de

.ee_loop:
    ld hl, (MEM_TOKEN_PTR)
    ld a, (hl)
    cp '+'
    jp z, .ee_add
    cp '-'
    jp z, .ee_sub
    ld hl, (SCR_ACC_LO)
    ld de, (SCR_ACC_HI)
    pop bc
    ld (SCR_ACC_HI), bc
    pop bc
    ld (SCR_ACC_LO), bc
    ret

.ee_add:
    inc hl
    ld (MEM_TOKEN_PTR), hl
    call EVAL_TERM
    ld (SCR_OP_LO), hl
    ld (SCR_OP_HI), de
    ld bc, (SCR_ACC_LO)
    add hl, bc
    ex de, hl
    ld bc, (SCR_ACC_HI)
    adc hl, bc
    ex de, hl
    ld (SCR_ACC_LO), hl
    ld (SCR_ACC_HI), de
    jp .ee_loop

.ee_sub:
    inc hl
    ld (MEM_TOKEN_PTR), hl
    call EVAL_TERM
    ld (SCR_OP_LO), hl
    ld (SCR_OP_HI), de
    push de
    ld de, (SCR_ACC_LO)
    ex de, hl
    or a
    sbc hl, de
    ex (sp), hl
    ld de, (SCR_ACC_HI)
    ex de, hl
    sbc hl, de
    ld d, h
    ld e, l
    pop hl
    ld (SCR_ACC_LO), hl
    ld (SCR_ACC_HI), de
    jp .ee_loop

EVAL_COND:
    call EVAL_EXPR
    ld (SCR_ACC_LO), hl
    ld (SCR_ACC_HI), de

    ld hl, (MEM_TOKEN_PTR)
    ld a, (hl)

    cp '='
    jp z, .ec_relop
    cp TOK_NEQ
    jp z, .ec_relop
    cp '<'
    jp z, .ec_relop
    cp '>'
    jp z, .ec_relop
    cp TOK_LTE
    jp z, .ec_relop
    cp TOK_GTE
    jp z, .ec_relop

    ; No relational operator: test if accumulator != 0
    ld a, d
    or e
    or h
    or l
    jr z, .ec_false
    ld a, 1
    ret
.ec_false:
    xor a
    ret

.ec_relop:
    push af
    inc hl
    ld (MEM_TOKEN_PTR), hl
    call EVAL_EXPR
    ld (SCR_OP_LO), hl
    ld (SCR_OP_HI), de

    call CMP32

    pop af
    cp '='
    jr z, .ec_op_eq
    cp TOK_NEQ
    jr z, .ec_op_neq
    cp '<'
    jr z, .ec_op_lt
    cp '>'
    jr z, .ec_op_gt
    cp TOK_LTE
    jr z, .ec_op_lte
    cp TOK_GTE
    jr z, .ec_op_gte
    xor a
    ret

.ec_op_eq:
    ld a, b
    or a
    jr z, .ec_ret_true
    jr .ec_ret_false

.ec_op_neq:
    ld a, b
    or a
    jr nz, .ec_ret_true
    jr .ec_ret_false

.ec_op_lt:
    ld a, b
    cp 0xFF
    jr z, .ec_ret_true
    jr .ec_ret_false

.ec_op_gt:
    ld a, b
    cp 0x01
    jr z, .ec_ret_true
    jr .ec_ret_false

.ec_op_lte:
    ld a, b
    cp 0x01
    jr nz, .ec_ret_true
    jr .ec_ret_false

.ec_op_gte:
    ld a, b
    cp 0xFF
    jr nz, .ec_ret_true
    jr .ec_ret_false

.ec_ret_true:
    ld a, 1
    ret
.ec_ret_false:
    xor a
    ret

CMP32:
    ld hl, (SCR_ACC_HI)
    ld de, (SCR_OP_HI)

    bit 7, h
    jr nz, .cmp_left_neg
    bit 7, d
    jr nz, .cmp_left_gt
    jr .cmp_same_sign

.cmp_left_neg:
    bit 7, d
    jr z, .cmp_left_lt

.cmp_same_sign:
    or a
    sbc hl, de
    jr c, .cmp_left_lt
    jr nz, .cmp_left_gt

    ld hl, (SCR_ACC_LO)
    ld de, (SCR_OP_LO)
    or a
    sbc hl, de
    jr c, .cmp_left_lt
    jr nz, .cmp_left_gt

    ld b, 0
    ret

.cmp_left_lt:
    ld b, 0xFF
    ret

.cmp_left_gt:
    ld b, 1
    ret
