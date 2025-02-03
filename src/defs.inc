; ============================================================================
; PBasic Z80 - Core Definitions and Memory Map
; ============================================================================

; Console I/O Ports (Mojave Virtual TTY)
PORT_DATA:       equ 0x0000
PORT_STATUS:     equ 0x0001
STATUS_RX_READY: equ 0
STATUS_TX_READY: equ 1
STATUS_BREAK:    equ 2

; Fixed Memory Workspace
; Address space layout in 64 KiB RAM
; 0x0000 .. code
; 0x8000 .. workspace and buffers
MEM_INPUT_BUF:   equ 0x8000   ; 128 bytes (Raw line input buffer)
MEM_TOKEN_BUF:   equ 0x8080   ; 160 bytes (Tokenized bytecode representation)
MEM_VARS:        equ 0x8120   ; 104 bytes (26 variables A..Z, 4 bytes each)
MEM_GOSUB_STK:   equ 0x8188   ; 32 bytes (16 frames of 2 bytes)
MEM_GOSUB_SP:    equ 0x81A8   ; 1 byte (Call stack pointer index: depth 0..16)
MEM_RAND_SEED:   equ 0x81A9   ; 2 bytes (PRNG seed, initial 12345)
MEM_TOKEN_PTR:   equ 0x81AB   ; 2 bytes (Pointer to current token)
MEM_LINE_PTR:    equ 0x81AD   ; 2 bytes (Pointer to current line node)
MEM_RUN_FLAG:    equ 0x81AF   ; 1 byte (0 = REPL, 1 = running program)
MEM_PROG_END:    equ 0x81B0   ; 2 bytes (Pointer to current end of program)
MEM_PROG_LIMIT:  equ 0x81B2   ; 2 bytes (Pointer to upper limit: MEM_PROG_START + 16384)

; Scratchpad registers (16-bit words)
SCR_PTR:         equ 0x81B4   ; Generic memory pointer
SCR_PTR2:        equ 0x81B6   ; Generic memory pointer 2
SCR_LEN:         equ 0x81B8   ; Block length
SCR_TLEN:        equ 0x81BA   ; Token count
SCR_NLEN:        equ 0x81BC   ; Node length
SCR_NUM:         equ 0x81BE   ; 16-bit line number / parsed constant
SCR_TMP:         equ 0x81C0   ; Temporary calculation storage
SCR_ACC_LO:      equ 0x81C2   ; 32-bit accumulator low word
SCR_ACC_HI:      equ 0x81C4   ; 32-bit accumulator high word
SCR_OP_LO:       equ 0x81C6   ; 32-bit operand low word
SCR_OP_HI:       equ 0x81C8   ; 32-bit operand high word
SCR_BODY:        equ 0x81CA   ; Program line body pointer
SCR_INS:         equ 0x81CC   ; Program line insertion pointer

; Program storage area (16 KiB linked list of lines)
MEM_PROG_START:  equ 0x8200   ; 16 KiB program store
PROG_CAPACITY:   equ 16384    ; 16 KiB limit

; Bytecode Token Definitions
; Keywords (0x80 - 0x8D)
TOK_LET:         equ 0x80
TOK_GOTO:        equ 0x81
TOK_GOSUB:       equ 0x82
TOK_PRINT:       equ 0x83
TOK_IF:          equ 0x84
TOK_INPUT:       equ 0x85
TOK_RETURN:      equ 0x86
TOK_END:         equ 0x87
TOK_LIST:        equ 0x88
TOK_RUN:         equ 0x89
TOK_NEW:         equ 0x8A
TOK_EXIT:        equ 0x8B
TOK_REM:         equ 0x8C
TOK_THEN:        equ 0x8D

; Built-in functions (0xA0 - 0xA2)
TOK_FREE:        equ 0xA0
TOK_RND:         equ 0xA1
TOK_ABS:         equ 0xA2

; Multi-character operators (0xB0 - 0xB2)
TOK_NEQ:         equ 0xB0     ; <>
TOK_LTE:         equ 0xB1     ; <=
TOK_GTE:         equ 0xB2     ; >=

; Literals & variables
TOK_NUMBER:      equ 0xC0     ; Followed by 2 bytes: <lo> <hi>
TOK_STRING:      equ 0xC1     ; Enclosed between 0xC1 and 0xC1
TOK_VAR_BASE:    equ 0xD0     ; Variables A..Z (0xD0 - 0xE9)
TOK_EOL:         equ 0x00     ; End of statement stream
