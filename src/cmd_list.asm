; ============================================================================
; PBasic Z80 - LIST Command Handler
; ============================================================================

LIST:
DO_LIST:
    push af
    push bc
    push de
    push hl

    ld de, MEM_PROG_START

.list_loop:
    ; Read next pointer at (DE)
    push de
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    ld b, a
    pop de

    ; Check if sentinel (next pointer is 0x0000)
    ld a, b
    or c
    jr z, .list_done

    ; Save next pointer in SCR_PTR
    ld h, b
    ld l, c
    ld (SCR_PTR), hl

    ; 1. Print line number at DE + 2 in decimal
    push de
    inc de
    inc de
    ld a, (de)
    ld l, a
    inc de
    ld a, (de)
    ld h, a
    ld de, 0
    call PRINT_NUMBER
    pop de

    ; 2. Print space separator
    ld a, ' '
    call OUTCHAR

    ; 3. Call PRINT_TOKENS with pointer to token body at DE + 4
    push de
    inc de
    inc de
    inc de
    inc de
    ex de, hl             ; HL = token stream start
    call PRINT_TOKENS
    pop de

    ; 4. Print newline
    call PRINT_CRLF

    ; Advance to next line node
    ld hl, (SCR_PTR)
    ex de, hl
    jr .list_loop

.list_done:
    pop hl
    pop de
    pop bc
    pop af
    ld a, (MEM_RUN_FLAG)
    or a
    jp nz, RUN_NEXT
    jp REPL
