# AGENTS.md

Instruções para agentes de IA (Claude Code, Codex, Cursor etc.) trabalhando neste repositório.

## Sempre usar a versão mais recente do Perssua

Antes de qualquer tarefa que envolva o binário do Perssua (rodar, depurar, testar, documentar),
**verifique a versão estável mais recente** em:

- https://perssua.com/pt (página principal)
- https://perssua.com/pt/downloads (lista de versões e links diretos)

Regras:

1. Use a versão marcada como **"Mais recente"** (estável). Versões **Canary** só se o usuário pedir.
2. O AppImage Linux x86_64 fica em `https://downloads.perssua.com/Perssua-<versão>-x86_64.AppImage`.
3. Se a versão do site for mais nova que a do repositório, atualize:
   - Baixe o AppImage para `bin/` e rode `chmod +x`.
   - `VERSION` em `bin/perssua` (o caminho do AppImage é derivado dela).
   - `VERSION` no `Makefile`.
   - Referências de versão em `README.md`, `bin/README.md`, `docs/`, `logging/GUIDE.md` e `tests/`.
4. Rode `make version`, `make validate` e `make test` para confirmar.
5. Não faça commit do AppImage (binário de ~240 MB).

Para descobrir a versão atual rapidamente:

```bash
curl -sL https://perssua.com/pt/downloads | grep -oE 'Perssua-[0-9]+\.[0-9]+\.[0-9]+-x86_64\.AppImage' | sort -uV | tail -n 3
```

> Atenção: a listagem inclui a Canary; confira no site qual é a "Mais recente".

## Estrutura

- `bin/perssua` — launcher (extrai o AppImage em `data/squashfs-root`, configura sandbox, áudio e X11).
- `Makefile` — `make up`, `make debug`, `make validate`, `make test`.
- `docs/` — guia, árvore e troubleshooting.
- `data/` — runtime (ignorado pelo git).

## Áudio do sistema (Linux)

A captura do áudio nativo do computador depende do PulseAudio/PipeWire (fonte `monitor` da saída).
Ao depurar problemas de áudio, verifique com `make config` e `pactl list short sources | grep monitor`.
