# Observabilidade & Logging - Guia Completo

**Status:** Implementação Profissional | **Versão:** 1.0  
**Responsável:** OBSERVABILIDADE

Perssua implementa um sistema de logging estruturado que aproveita os recursos nativos do Linux para observabilidade em produção.

---

## 1. Quick Start - Observabilidade

### Comando Básico
```bash
perssua                    # INFO level (padrão)
```

### Com Debug Completo
```bash
PERSSUA_LOG_LEVEL=DEBUG perssua    # Mostrar tudo
```

### Formato Estruturado (JSON)
```bash
PERSSUA_LOG_FORMAT=json perssua 2>&1 | jq    # Parse estruturado
```

### Ver Logs Históricos
```bash
tail -f data/logs/perssua.log      # Arquivo de log
```

---

## 2. Níveis de Log

| Nível | Env Var | Uso | Exemplo |
|-------|---------|-----|---------|
| **ERROR** | `PERSSUA_LOG_LEVEL=ERROR` | Falhas críticas | "AppImage extraction failed" |
| **WARN** | `PERSSUA_LOG_LEVEL=WARN` | Avisos, operações degradadas | "Sandbox config requires sudo" |
| **INFO** | `PERSSUA_LOG_LEVEL=INFO` (padrão) | Eventos normais | "Starting Perssua...", "AppImage extracted" |
| **DEBUG** | `PERSSUA_LOG_LEVEL=DEBUG` | Detalhes internos | "Validating prerequisites...", "Data directory ready" |

### Hierarquia
DEBUG é mais verbose que INFO, que é mais que WARN, que é mais que ERROR.

```bash
# Apenas erros
PERSSUA_LOG_LEVEL=ERROR perssua

# Erros + avisos
PERSSUA_LOG_LEVEL=WARN perssua

# Erros + avisos + eventos normais (padrão)
PERSSUA_LOG_LEVEL=INFO perssua
# or just:
perssua

# Tudo (DEBUG)
PERSSUA_LOG_LEVEL=DEBUG perssua
```

---

## 3. Formatos de Output

### Formato: Human (Padrão)
Legível para humanos, cores, prefixos intuitivos.

```bash
perssua
```

**Saída:**
```
i Starting Perssua launcher (v0.23.3)
[DEBUG] Project root: /home/user/perssua-app
✓ Prerequisites OK
i Extracting AppImage...
✓ AppImage extracted (5.2s)
i Starting Perssua...
```

### Formato: JSON (Machine-Readable)
Estruturado para parsing, agregação, alerting.

```bash
PERSSUA_LOG_FORMAT=json perssua 2>&1 | jq
```

**Saída:**
```json
{
  "timestamp": "2026-07-06T15:42:30.123Z",
  "level": "INFO",
  "module": "launcher",
  "message": "Starting Perssua launcher",
  "version": "0.23.3"
}
{
  "timestamp": "2026-07-06T15:42:30.234Z",
  "level": "DEBUG",
  "module": "validation",
  "message": "Prerequisites validation",
  "status": "OK"
}
```

### Trocar Formato
```bash
PERSSUA_LOG_FORMAT=json perssua          # JSON
PERSSUA_LOG_FORMAT=human perssua         # Human (padrão)
```

---

## 4. Arquivos de Log

### Localização Padrão
```
data/logs/
├── perssua.log           # Log principal
└── perssua.log.1         # Rotações antigas (comprimidas)
```

### Ver Logs em Tempo Real
```bash
# Último 100 linhas
tail -100 data/logs/perssua.log

# Monitorar continuamente
tail -f data/logs/perssua.log

# Com timestamp e grep
grep "ERROR" data/logs/perssua.log
```

### Análise de Logs JSON
```bash
# Parse e filtrar
jq 'select(.level=="ERROR")' data/logs/perssua.log

# Contar por nível
jq -s 'group_by(.level) | map({level: .[0].level, count: length})' data/logs/perssua.log

# Timeline
jq -s 'sort_by(.timestamp) | .[] | "\(.timestamp) [\(.level)] \(.message)"' data/logs/perssua.log
```

---

## 5. Rotação de Logs

### Configuração Automática
Log rotation é configurado via `/etc/logrotate.d/perssua`:

```bash
/path/to/data/logs/perssua.log {
    size 10M
    rotate 5
    compress
    delaycompress
    missingok
    notifempty
}
```

### O que faz:
- **size 10M** — Rotaciona quando atingir 10 MB
- **rotate 5** — Mantém 5 gerações (perssua.log.1.gz, .2.gz, ..., .5.gz)
- **compress** — Compacta logs antigos com gzip
- **delaycompress** — Só compacta na próxima rotação
- **missingok** — Não reclama se arquivo não existe
- **notifempty** — Não rotaciona se arquivo vazio

### Verificar Rotação Manual
```bash
# Executar logrotate (requer sudo)
sudo logrotate -f /etc/logrotate.d/perssua

# Ver histórico
ls -lh data/logs/
```

---

## 6. Integração com Linux nativo

### 6.1 Systemd Journal (journalctl)

Se rodar Perssua como systemd service:

```bash
# Ver logs em tempo real
journalctl -u perssua -f

# Últimas 100 linhas
journalctl -u perssua -n 100

# Filtrar por nível
journalctl -u perssua PRIORITY=3  # Erros

# Com timestamp
journalctl -u perssua --no-pager -o short-iso
```

**Arquivo de exemplo:** [systemd-example.service](systemd-example.service)

### 6.2 Syslog

Logs automaticamente aparecem em syslog (via `/var/log/syslog` em Debian/Ubuntu):

```bash
grep perssua /var/log/syslog
tail -f /var/log/syslog | grep perssua
```

### 6.3 Stderr/Stdout Redirecionamento

Para capturar tudo em arquivo:

```bash
perssua > data/logs/stdout.log 2> data/logs/stderr.log
# ou
perssua >> data/logs/perssua.log 2>&1
```

---

## 7. Casos de Uso Práticos

### Caso 1: Debug de Falha na Primeira Execução
```bash
PERSSUA_LOG_LEVEL=DEBUG PERSSUA_LOG_FORMAT=json perssua 2>&1 | tee data/logs/debug.json | jq
# Salva e exibe ao mesmo tempo
```

### Caso 2: Monitorar Saúde em Produção
```bash
# Terminal 1: Run app
perssua

# Terminal 2: Monitor
watch -n 5 'tail -1 data/logs/perssua.log'
```

### Caso 3: Análise Histórica
```bash
# Erros da última hora
grep "ERROR" data/logs/perssua.log | tail -20

# Tempos de execução
grep "extraction\|Perssua started" data/logs/perssua.log

# Com jq
jq 'select(.level=="WARN" or .level=="ERROR")' data/logs/perssua.log
```

### Caso 4: Alertas Automáticos
```bash
# Criar script que checa logs a cada 5s
while true; do
  if grep -q "ERROR" data/logs/perssua.log; then
    echo "ALERT: Error detected!" | mail -s "Perssua Error" admin@example.com
  fi
  sleep 5
done
```

---

## 8. Variáveis de Ambiente

### Log Control
```bash
# Nível de verbosidade
PERSSUA_LOG_LEVEL=DEBUG|INFO|WARN|ERROR

# Formato de output
PERSSUA_LOG_FORMAT=human|json

# Diretório de dados (logs ficam em data/logs/)
PERSSUA_DATA_DIR=/custom/path

# Legacy: ativa DEBUG (mapeia para LOG_LEVEL=DEBUG)
PERSSUA_DEBUG=1
```

### Exemplos Combinados
```bash
# Debug completo em JSON
PERSSUA_LOG_LEVEL=DEBUG PERSSUA_LOG_FORMAT=json perssua 2>&1 | jq

# Dados customizados + logs estruturados
PERSSUA_DATA_DIR=/tmp/test PERSSUA_LOG_FORMAT=json perssua

# Info + human readable
PERSSUA_LOG_LEVEL=INFO perssua
```

---

## 9. Backward Compatibility

**Versão Anterior:** `PERSSUA_DEBUG=1 perssua`  
**Novo Equivalente:** `PERSSUA_LOG_LEVEL=DEBUG perssua`

Ambos funcionam:
```bash
# Antigo (ainda suportado)
PERSSUA_DEBUG=1 perssua

# Novo (recomendado)
PERSSUA_LOG_LEVEL=DEBUG perssua
```

O launcher detecta `PERSSUA_DEBUG=1` e mapeia para `LOG_LEVEL=DEBUG` automaticamente.

---

## 10. Troubleshooting

### Logs não aparecem
```bash
# Verificar se arquivo de log foi criado
ls -la data/logs/

# Verificar permissões
ls -l data/logs/perssua.log

# Se ausente, criar manualmente
mkdir -p data/logs
touch data/logs/perssua.log
```

### Logs muito grandes
```bash
# Força rotação manual
sudo logrotate -f /etc/logrotate.d/perssua

# Ou limpa manualmente
rm data/logs/perssua.log*
```

### JSON não parseia
```bash
# Verificar formato
cat data/logs/perssua.log | head -1 | jq .

# Se falhar, verificar encoding
file data/logs/perssua.log

# Ou usar grep para logs legítimos
grep '^{' data/logs/perssua.log | jq
```

---

## 11. Integração com Make

### Comandos de Logging
```bash
make up                           # Executa com INFO (padrão)
make debug                        # Executa com DEBUG
PERSSUA_LOG_LEVEL=WARN make up   # Custom level
```

### Novo: Validar Logs
```bash
make test                        # Executa suite de testes
make tail-logs                   # Monitora logs em tempo real
```

---

## 12. Produção & Operação

### Checklist de Setup
- [ ] Diretório `data/logs/` existe e tem permissões de escrita
- [ ] logrotate configurado em `/etc/logrotate.d/perssua`
- [ ] Se usar systemd: arquivo `.service` instalado
- [ ] Monitorar espaço em disk (`data/logs/` pode crescer)
- [ ] Setup alertas para `ERROR` em logs
- [ ] Documentar runbooks para erros comuns

### Exemplo Runbook (ERROR)
```
Se vir "AppImage extraction failed":
1. Verificar espaço em disk: df -h data/
2. Verificar FUSE: which fuse
3. Limpar cache: make clean
4. Retry: perssua
```

---

## 13. Referência Rápida

```bash
# Ver logs
tail -f data/logs/perssua.log

# Debug
PERSSUA_LOG_LEVEL=DEBUG perssua

# JSON + parse
PERSSUA_LOG_FORMAT=json perssua 2>&1 | jq '.level, .message'

# Monitorar erros
grep "ERROR\|WARN" data/logs/perssua.log

# Systemd (se instalado)
journalctl -u perssua -f
```

---

**Próximos Passos:**
1. Ler [systemd-example.service](systemd-example.service) para setup em produção
2. Configurar alerts para ERROR level
3. Integrar com ferramentas de log aggregation (se necessário)

**Documentação Relacionada:**
- [README.md](../README.md) — Quick start
- [docs/GUIDE.md](../docs/GUIDE.md) — Setup completo
- [docs/TROUBLESHOOT.md](../docs/TROUBLESHOOT.md) — Troubleshooting
