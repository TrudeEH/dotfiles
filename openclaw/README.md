# Openclaw

Development shell for [Openclaw](https://github.com/openclaw/openclaw) with Ollama.

## Usage

```bash
nix develop
```

Auto-starts:
- **ollama** on http://localhost:11434
- **openclaw-gateway** (uses config from `~/.openclaw`)

## Commands

```bash
ollama list              # List models
ollama run llama3.2:3b   # Chat with model

# Stop services
pkill ollama
pkill openclaw-gateway
```
