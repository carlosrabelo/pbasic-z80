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

    ; End of line check
    or a
    jr z, .tok_end

    ; Skip spaces
    cp ' '
    jr nz, .tok_non_space
    inc hl
    ld (SCR_PTR), hl
    jr .tok_loop

.tok_non_space:
    ; Default: emit character directly to token buffer
    ld de, (SCR_PTR2)
    ld a, (hl)
    ld (de), a
    inc de
    ld (SCR_PTR2), de
    inc hl
    ld (SCR_PTR), hl
    jr .tok_loop

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
