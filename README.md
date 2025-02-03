# PBasic Z80

Integer BASIC interpreter for the Z80 microprocessor.

## Highlights

- Full integer BASIC dialect designed for the Zilog Z80 processor
- Compact memory footprint fitting entirely within 64 KiB of address space
- Interactive REPL with prompt, line editing, and syntax error reporting
- Comprehensive command set including LET, PRINT, IF, GOTO, GOSUB, RETURN, INPUT, LIST, RUN, NEW, FREE, REM, END, and EXIT
- 32-bit signed integer arithmetic for expressions and variable storage
- Built-in mathematical and utility functions including ABS and pseudo-random numbers via RND
- Efficient linked-list program memory manager with dynamic line insertion and deletion
- Headless execution and verification support via the Mojave Z80 emulator

## Prerequisites

- **z80asm** — required to assemble the source files; install via `apt install z80asm` or your package manager
- **mojave** — optional emulator required to run and test; install from [Mojave](https://github.com/carlos/mojave)

## Installation

### Build from Source

From a checkout of this repository:

```bash
make build
```

## Usage

### Interactive REPL

Start the interactive BASIC environment in the Mojave emulator:

```bash
make run
```

Or invoke the Mojave CLI directly:

```bash
mojave --machine z80 --load-bin bin/pbasic.bin
```

### Running Programs

Execute BASIC source programs via standard input:

```bash
mojave --machine z80 --load-bin bin/pbasic.bin < demos/01_banner.bas
mojave --machine z80 --load-bin bin/pbasic.bin < demos/02_math.bas
mojave --machine z80 --load-bin bin/pbasic.bin < demos/03_guess.bas
```

Stop the interpreter session with `EXIT` or Ctrl+C.

## Project Layout

```
demos/               # Example BASIC programs
src/                 # Z80 assembly source files
bin/                 # Assembled binary outputs
.make/               # Build and test automation scripts
Makefile             # Build automation orchestrator
```

## Development

```bash
make build           # Assemble PBasic binary to bin/pbasic.bin
make run             # Run PBasic in the Mojave simulator
make test            # Run verification and test suite
make clean           # Remove build artifacts
```

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
