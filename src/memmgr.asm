; ============================================================================
; PBasic Z80 - Program Memory Management & Allocation
; ============================================================================

PROG_INIT:
    push hl
    ; 1. Initialize sentinel: write 0x0000 at MEM_PROG_START
    ld hl, 0x0000
    ld (MEM_PROG_START), hl

    ; 2. Set MEM_PROG_END = MEM_PROG_START + 2 (empty list size is 2 bytes sentinel)
    ld hl, MEM_PROG_START + 2
    ld (MEM_PROG_END), hl

    ; 3. Set MEM_PROG_LIMIT = MEM_PROG_START + 16384 (16 KiB ceiling)
    ld hl, MEM_PROG_START + PROG_CAPACITY
    ld (MEM_PROG_LIMIT), hl

    pop hl
    ret
