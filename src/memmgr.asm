; ============================================================================
; PBasic Z80 - Program Memory Initialization
; ============================================================================

PROG_INIT:
    push hl
    ; Write 0x0000 sentinel at MEM_PROG_START
    ld hl, 0x0000
    ld (MEM_PROG_START), hl
    ; Set MEM_PROG_END = MEM_PROG_START + 2
    ld hl, MEM_PROG_START + 2
    ld (MEM_PROG_END), hl
    ; Set MEM_PROG_LIMIT = MEM_PROG_START + 16384
    ld hl, MEM_PROG_START + PROG_CAPACITY
    ld (MEM_PROG_LIMIT), hl
    pop hl
    ret
