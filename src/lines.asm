; ============================================================================
; PBasic Z80 - Program Line Management, Lookup & Storage
; ============================================================================

LINE_FIND:
    push hl
    ld de, MEM_PROG_START

.lf_loop:
    ; Read next pointer at (DE)
    push de
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    ld b, a
    pop de

    ; Check if sentinel (next == 0x0000)
    ld a, b
    or c
    jr z, .lf_sentinel

    ; Read line number at DE + 2
    push de
    inc de
    inc de
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    ld b, a
    pop de

    ; Compare candidate BC with target (TOS = HL)
    pop hl
    push hl
    ld a, b
    cp h
    jr nz, .lf_chk_greater
    ld a, c
    cp l
    jr z, .lf_found

.lf_chk_greater:
    ld a, b
    cp h
    jr c, .lf_less
    jr nz, .lf_greater
    ld a, c
    cp l
    jr c, .lf_less

.lf_greater:
    ; Candidate > Target: insertion point found at DE
    pop hl
    xor a
    ret

.lf_less:
    ; Candidate < Target: advance DE = next pointer
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    ld d, a
    ld e, c
    jr .lf_loop

.lf_found:
    pop hl
    ld a, 1
    ret

.lf_sentinel:
    pop hl
    xor a
    ret

; ============================================================================
; Node and Token Length Calculation
; ============================================================================

TOKEN_LEN:
    push af
    push hl
    ld bc, 0
.tl_loop:
    ld a, (hl)
    inc hl
    inc bc
    or a
    jr z, .tl_done
    cp TOK_NUMBER
    jr nz, .tl_not_num
    inc hl
    inc bc
    inc hl
    inc bc
    jr .tl_loop
.tl_not_num:
    cp TOK_STRING
    jr nz, .tl_loop
.tl_str_loop:
    ld a, (hl)
    inc hl
    inc bc
    or a
    jr z, .tl_done
    cp TOK_STRING
    jr z, .tl_loop
    jr .tl_str_loop
.tl_done:
    pop hl
    pop af
    ret

NODE_LEN:
    ; Input: HL = token stream start
    ; Output: BC = total node size (4-byte header + token length)
    call TOKEN_LEN
    inc bc
    inc bc
    inc bc
    inc bc
    ret

; ============================================================================
; Line Storage Engine
; ============================================================================

LINE_STORE:
    ; Extract 16-bit line number from MEM_TOKEN_BUF + 1
    ld hl, (MEM_TOKEN_BUF + 1)
    ld (SCR_NUM), hl

    ; Check if token stream at offset 3 is empty (0x00)
    ld a, (MEM_TOKEN_BUF + 3)
    or a
    jr nz, .ls_insert

    ; Empty line -> delete existing line
    ld hl, (SCR_NUM)
    call LINE_FIND
    or a
    ret z                 ; Line not found, nothing to delete
    call DELETE_NODE_AT_DE
    ret

.ls_insert:
    ; If line already exists, delete old line first
    ld hl, (SCR_NUM)
    call LINE_FIND
    or a
    jr z, .ls_find_ins
    call DELETE_NODE_AT_DE

.ls_find_ins:
    ; Recalculate insertion point
    ld hl, (SCR_NUM)
    call LINE_FIND
    ; DE is now the insertion point
    ld (SCR_INS), de

    ; Calculate node length
    ld hl, MEM_TOKEN_BUF + 3
    call NODE_LEN
    ld (SCR_NLEN), bc

    ; Check capacity: MEM_PROG_END + node_len > MEM_PROG_LIMIT
    ld hl, (MEM_PROG_END)
    add hl, bc
    ex de, hl
    ld hl, (MEM_PROG_LIMIT)
    ld a, d
    cp h
    jr c, .ls_cap_ok
    jr nz, .ls_oom
    ld a, e
    cp l
    jr c, .ls_cap_ok
    jr z, .ls_cap_ok
.ls_oom:
    ld hl, MSG_OUT_OF_MEM
    call PRINT_STR
    ret

.ls_cap_ok:
    ; Adjust successor pointers
    ld hl, (SCR_INS)
    ld bc, (SCR_NLEN)
    call FIX_NEXT_ADD

    ; Open hole at SCR_INS
    ld hl, (SCR_INS)
    ld bc, (SCR_NLEN)
    call MEM_OPEN_HOLE

    ; Write node at (SCR_INS):
    ; 1. Next pointer = SCR_INS + SCR_NLEN
    ld hl, (SCR_INS)
    ld bc, (SCR_NLEN)
    add hl, bc
    ex de, hl             ; DE = next pointer
    ld hl, (SCR_INS)
    ld a, e
    ld (hl), a
    inc hl
    ld a, d
    ld (hl), a
    inc hl

    ; 2. Line number (16-bit LE)
    ld a, (SCR_NUM)
    ld (hl), a
    inc hl
    ld a, (SCR_NUM + 1)
    ld (hl), a
    inc hl

    ; 3. Token stream bytes terminated by 0x00
    ld de, MEM_TOKEN_BUF + 3
.ls_copy_tok:
    ld a, (de)
    ld (hl), a
    inc de
    inc hl
    or a
    jr nz, .ls_copy_tok
    ret

DELETE_NODE_AT_DE:
    push de
    ; Compute NODE_LEN for node at DE (tokens start at DE + 4)
    inc de
    inc de
    inc de
    inc de
    ld h, d
    ld l, e
    call NODE_LEN
    ld (SCR_NLEN), bc
    pop de

    ; FIX_NEXT_SUB(HL=DE, BC=SCR_NLEN)
    ld h, d
    ld l, e
    ld bc, (SCR_NLEN)
    call FIX_NEXT_SUB

    ; MEM_CLOSE_HOLE(HL=DE, BC=SCR_NLEN)
    ld h, d
    ld l, e
    ld bc, (SCR_NLEN)
    call MEM_CLOSE_HOLE
    ret
