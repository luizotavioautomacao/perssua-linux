# Observabilidade & Logging

Arquivos e guias para implementar observabilidade profissional no Perssua.

## Conteúdo

| Arquivo | Descrição |
|---------|-----------|
| **[GUIDE.md](GUIDE.md)** | Guia completo de logging, níveis de verbosidade, formatos, integração com Linux |
| **[systemd-example.service](systemd-example.service)** | Exemplo de systemd service para rodar Perssua com journalctl |
| **[examples/logrotate.conf](examples/logrotate.conf)** | Configuração de rotação automática de logs (exemplo) |

## Quick Start

### Ver Logs em Tempo Real
```bash
tail -f data/logs/perssua.log
```

### Debug Completo
```bash
PERSSUA_LOG_LEVEL=DEBUG perssua
```

### Formato JSON para Parsing
```bash
PERSSUA_LOG_FORMAT=json perssua 2>&1 | jq
```

### Integração com Make
```bash
make tail-logs    # Monitora logs em tempo real
make test         # Valida suite de observabilidade
```

## Integração com Linux

### Systemd Journal
```bash
# Se instalado como systemd service
journalctl -u perssua -f
```

### Logrotate
```bash
# Ver exemplo de configuração
cat logging/examples/logrotate.conf

# Instalar configuração (requer sudo)
sudo cp logging/examples/logrotate.conf /etc/logrotate.d/perssua

# Testar
sudo logrotate -d /etc/logrotate.d/perssua
```

## Níveis de Log

- **DEBUG**: Tudo (tempo de desenvolvimento)
- **INFO**: Eventos normais (padrão)
- **WARN**: Avisos e operações degradadas
- **ERROR**: Apenas falhas críticas

```bash
PERSSUA_LOG_LEVEL=DEBUG perssua   # Mais verboso
PERSSUA_LOG_LEVEL=ERROR perssua   # Menos verboso
```

## Formatos

### Human-Readable (Padrão)
```
i Starting Perssua...
✓ Prerequisites OK
[DEBUG] Extracting AppImage...
```

### JSON (Estruturado)
```json
{"timestamp":"2026-07-06T15:42:30Z","level":"INFO","module":"launcher","message":"Starting Perssua..."}
```

```bash
PERSSUA_LOG_FORMAT=json perssua 2>&1 | jq
```

## Próximas Leituras

- **[GUIDE.md](GUIDE.md)** — Guia completo com todos os detalhes
- **[../docs/TROUBLESHOOT.md](../docs/TROUBLESHOOT.md)** — Resolução de problemas
- **[../README.md](../README.md)** — Visão geral do projeto
