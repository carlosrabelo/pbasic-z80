# PBasic Z80

Interpretador BASIC de inteiros para o microprocessador Z80.

## Destaques

- Dialeto BASIC de inteiros completo projetado para o processador Zilog Z80
- Uso compacto de memória cabendo inteiramente em 64 KiB de espaço de endereçamento
- REPL interativo com prompt, edição de linha e relatório de erros de sintaxe
- Conjunto abrangente de comandos incluindo LET, PRINT, IF, GOTO, GOSUB, RETURN, INPUT, LIST, RUN, NEW, FREE, REM, END e EXIT
- Aritmética de inteiros com sinal de 32 bits para expressões e armazenamento de variáveis
- Funções matemáticas e utilitárias embutidas incluindo ABS e números pseudoaleatórios via RND
- Gerenciador de memória de programa em lista encadeada eficiente com inserção e exclusão dinâmica de linhas
- Suporte a execução e verificação headless através do emulador Mojave Z80

## Pré-requisitos

- **z80asm** — necessário para montar os arquivos-fonte; instale via `apt install z80asm` ou seu gerenciador de pacotes
- **mojave** — emulador opcional necessário para executar e testar; instale a partir do [Mojave](https://github.com/carlos/mojave)

## Instalação

### Compilar a partir do código

A partir de uma cópia deste repositório:

```bash
make build
```

## Uso

### REPL Interativo

Inicie o ambiente BASIC interativo no emulador Mojave:

```bash
make run
```

Ou invoque o CLI do Mojave diretamente:

```bash
mojave --machine z80 --load-bin bin/pbasic.bin
```

### Execução de Programas

Execute programas BASIC através da entrada padrão:

```bash
mojave --machine z80 --load-bin bin/pbasic.bin < demos/01_banner.bas
mojave --machine z80 --load-bin bin/pbasic.bin < demos/02_math.bas
mojave --machine z80 --load-bin bin/pbasic.bin < demos/03_guess.bas
```

Encerre a sessão do interpretador com `EXIT` ou Ctrl+C.

## Estrutura do Projeto

```
demos/               # Programas BASIC de exemplo
src/                 # Arquivos-fonte em assembly Z80
bin/                 # Binários montados gerados
.make/               # Scripts de automação de build e testes
Makefile             # Orquestrador de automação do build
```

## Desenvolvimento

```bash
make build           # Monta o binário PBasic em bin/pbasic.bin
make run             # Executa o PBasic no simulador Mojave
make test            # Executa a suíte de testes e verificação
make clean           # Remove artefatos de compilação
```

## Licença

Este projeto está licenciado sob a Licença MIT — consulte [LICENSE](LICENSE) para mais detalhes.
