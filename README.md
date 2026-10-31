# Perssua para Linux

Launcher e automação para rodar o [Perssua](https://perssua.com/pt) no Linux. O Perssua é um assistente de IA em tempo real que capta o áudio das suas reuniões e sugere respostas e argumentos.

Este repositório não contém o aplicativo. Ele empacota o AppImage oficial com:

- um comando global `perssua`;
- extração automática do AppImage e configuração do sandbox do Chromium;
- ajustes para captar o áudio do sistema (PulseAudio/PipeWire) e forçar o modo X11;
- logs estruturados (texto ou JSON);
- testes de validação do launcher.

**Versão do Perssua:** 0.27.5 · **Licença:** AGPL-3.0

---

## Requisitos

- Linux x86_64 (Ubuntu/Debian, Fedora/RHEL, openSUSE ou Arch)
- **FUSE3**, para executar o AppImage
- **PulseAudio** ou **PipeWire** (com `pipewire-pulse`), para captar o áudio do sistema
- `sudo`, usado uma única vez para configurar o sandbox do Chromium
- `curl`, para baixar o AppImage

---

## Instalação

```bash
git clone git@github.com:luizotavioautomacao/perssua-app.git
cd perssua-app

# 1. Baixe o AppImage. Ele não é versionado no git (~240 MB).
curl -fL -o bin/Perssua-0.27.5-x86_64.AppImage \
  https://downloads.perssua.com/Perssua-0.27.5-x86_64.AppImage
chmod +x bin/Perssua-0.27.5-x86_64.AppImage

# 2. Instale o FUSE3 e o comando `perssua` em ~/.local/bin
make install

# 3. Abra o aplicativo
perssua
```

Na primeira execução, o launcher extrai o AppImage para `data/squashfs-root` e pede `sudo` para configurar o `chrome-sandbox`. As execuções seguintes começam direto.

> Se o comando `perssua` não for encontrado, confira se `~/.local/bin` está no seu `PATH` e abra um novo terminal.

---

## Comandos

### Make

| Comando | Descrição |
|---|---|
| `make install` | Instala as dependências (FUSE3) e o comando para o usuário atual |
| `make install-deps` | Instala o FUSE3, detectando o gerenciador de pacotes |
| `make install-user` | Cria o link `~/.local/bin/perssua` |
| `make install-system` | Cria o link `/usr/local/bin/perssua` (requer sudo) |
| `make uninstall` | Remove o comando `perssua` |
| `make configure-sandbox` | Reconfigura as permissões do `chrome-sandbox` (root:4755) |
| `make up` | Abre o aplicativo |
| `make debug` | Abre com logs em nível DEBUG |
| `make debug-json` | Abre com logs DEBUG em formato JSON |
| `make config` | Mostra o estado da instalação, do áudio e dos logs |
| `make version` | Mostra a versão |
| `make validate` | Verifica os pré-requisitos |
| `make test` | Roda os smoke tests |
| `make test-full` | Roda a suíte completa de validação |
| `make lint` | Analisa os scripts com `shellcheck` |
| `make tail-logs` | Acompanha os logs em tempo real |
| `make clean` | Remove o AppImage extraído (preserva os dados) |
| `make help` | Lista todos os comandos |

### Launcher

```bash
perssua              # abre o aplicativo
perssua --version    # mostra a versão
perssua --config     # mostra a configuração e o diagnóstico
perssua --help       # ajuda
```

### Variáveis de ambiente

| Variável | Valores | Padrão | Descrição |
|---|---|---|---|
| `PERSSUA_LOG_LEVEL` | `DEBUG`, `INFO`, `WARN`, `ERROR` | `INFO` | Nível de log |
| `PERSSUA_LOG_FORMAT` | `human`, `json` | `human` | Formato do log |
| `PERSSUA_DEBUG` | `0`, `1` | `0` | Atalho para `PERSSUA_LOG_LEVEL=DEBUG` |
| `PERSSUA_DATA_DIR` | caminho | `data/` | Pasta de dados do usuário do aplicativo |

Os logs ficam em `data/logs/perssua.log`.

---

## Áudio do sistema

O Perssua capta o áudio do computador (o lado da reunião que você ouve) pela fonte **monitor** do dispositivo de saída padrão do PulseAudio/PipeWire. Para funcionar:

1. O som precisa estar tocando no dispositivo de saída **padrão**:
   ```bash
   pactl get-default-sink
   pactl list short sources | grep monitor
   ```
2. O launcher exporta `PULSE_SERVER`, `PULSE_COOKIE` e `PIPEWIRE_RUNTIME_DIR`, e mantém a captura via PipeWire habilitada.
3. O aplicativo roda em modo X11 (`--ozone-platform=x11`) para manter a captura de tela e áudio estável, inclusive em sessões Wayland.

Para diagnosticar, use `make config` e `make debug`. Veja também [docs/TROUBLESHOOT.md](docs/TROUBLESHOOT.md).

---

## Atualizar a versão do Perssua

1. Confira a versão estável mais recente (marcada como **"Mais recente"**, não Canary) em <https://perssua.com/pt/downloads>.
2. Baixe o novo AppImage para `bin/`.
3. Atualize `VERSION` em `bin/perssua` e no `Makefile`, e as referências na documentação e nos testes.
4. Rode `make validate` e `make test`.

Na próxima execução, o launcher detecta o AppImage novo e extrai de novo automaticamente. O passo a passo para agentes de IA está em [AGENTS.md](AGENTS.md).

---

## Estrutura

```
.
├── bin/
│   ├── perssua              # launcher principal
│   ├── setup.sh             # instalação/remoção do comando
│   └── Perssua-*.AppImage   # binário do aplicativo (baixado, fora do git)
├── data/                    # dados de execução (fora do git)
│   ├── squashfs-root/       # AppImage extraído
│   └── logs/                # logs do launcher
├── docs/
│   ├── GUIDE.md             # guia completo e arquitetura
│   ├── TREE.md              # estrutura do projeto
│   └── TROUBLESHOOT.md      # solução de problemas
├── logging/                 # guia de logs e exemplos (systemd, logrotate)
├── tests/
│   ├── smoke-test.sh        # testes rápidos
│   └── validate.sh          # validação completa
├── AGENTS.md                # instruções para agentes de IA
├── Makefile
└── LICENSE
```

---

## Solução de problemas

| Problema | Solução |
|---|---|
| `perssua: command not found` | Adicione `~/.local/bin` ao `PATH` ou rode `make install-user` |
| `FUSE3 not installed` | `make install-deps` |
| Erro de sandbox do Chromium | `make configure-sandbox` |
| O áudio do sistema não é captado | Confira o dispositivo de saída padrão e a fonte `.monitor` (veja [Áudio do sistema](#áudio-do-sistema)) |
| Comportamento estranho depois de atualizar | `make clean` e abra de novo |

Mais detalhes em [docs/TROUBLESHOOT.md](docs/TROUBLESHOOT.md) e [logging/GUIDE.md](logging/GUIDE.md).

---

## Licença

Distribuído sob a [GNU AGPL v3](LICENSE). O aplicativo Perssua é de seus respectivos autores. Este repositório contém apenas o launcher e a automação.
