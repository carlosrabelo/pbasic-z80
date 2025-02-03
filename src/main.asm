; ============================================================================
; PBasic Z80 - Main Entry Point and Bootstrap
; ============================================================================

org 0x0000

main:
    ; 1. Set Stack Pointer to top of RAM
    ld sp, 0xFFFE

    ; 2. Initialize memory limits (16 KB program space)
    ld hl, MEM_PROG_START + PROG_CAPACITY
    ld (MEM_PROG_LIMIT), hl

    ; 3. Initial execution mode (REPL mode = 0)
    xor a
    ld (MEM_RUN_FLAG), a

    ; 4. Default PRNG seed (12345)
    ld hl, 12345
    ld (MEM_RAND_SEED), hl

    ; Halt until next stages are hooked
    halt
