# ────────────────────────────────────────
# HERDR
# ────────────────────────────────────────

# Atalho principal para o Herdr
alias h="herdr"


# ────────────────────────────────────────
# AGENTS
# ────────────────────────────────────────

# Lista todos os agentes ativos
alias ha=hagents

# Mostra agentes em formato legível
hagents() {
  herdr agent list | jq -r '
    .result.agents[] |
    "\(.name // "-")  \(.agent)  \(.agent_status)  \(.pane_id)  \(.cwd)"
  '
}

# Mostra informações de um agente
alias hag="herdr agent get"

# Foca diretamente em um agente
alias haf="herdr agent focus"

# Renomeia um agente
alias han="herdr agent rename"

# Espera um agente terminar
alias haw="herdr agent wait"

# Lê a saída recente de um agente
haread() {
  herdr agent read "$1" \
    --source recent-unwrapped \
    --lines "${2:-120}"
}

# Envia uma mensagem para um agente
hap() {
  local target="$1"
  shift

  herdr agent prompt "$target" "$*"
}

# Envia mensagem e espera resposta
hapw() {
  local target="$1"
  shift

  herdr agent prompt "$target" "$*" \
    --wait
}


# ────────────────────────────────────────
# CODE REVIEW
# ────────────────────────────────────────

# Pede code review para outro agente
hareview() {
  local target="$1"

  herdr agent prompt "$target" \
    "Review my current changes. Inspect the diff and identify bugs, regressions, incorrect assumptions, integration problems, missing tests, type issues and edge cases. Do not modify my code. Return actionable findings ordered by severity."
}

# Pede review e espera o resultado
harevieww() {
  local target="$1"

  herdr agent prompt "$target" \
    "Review my current changes. Inspect the diff and identify bugs, regressions, incorrect assumptions, integration problems, missing tests, type issues and edge cases. Do not modify my code. Return actionable findings ordered by severity." \
    --wait
}


# ────────────────────────────────────────
# PANES
# ────────────────────────────────────────

# Lista todos os panes
alias hpanes="herdr pane list"

# Mostra informações do pane atual
alias hpcurrent="herdr pane current --current"

# Mostra layout do pane atual
alias hplayout="herdr pane layout --current"

# Mostra processo rodando no pane
alias hpproc="herdr pane process-info --current"


# ────────────────────────────────────────
# WORKSPACES
# ────────────────────────────────────────

# Lista todos os workspaces
alias hws="herdr workspace list"

# Cria um novo workspace
alias hwnew="herdr workspace create"

# Foca em um workspace
alias hwfocus="herdr workspace focus"

# Renomeia um workspace
alias hwname="herdr workspace rename"

# Fecha um workspace
alias hwclose="herdr workspace close"


# ────────────────────────────────────────
# SESSIONS
# ────────────────────────────────────────

# Lista todas as sessões
alias hs="herdr session list"

# Conecta em uma sessão
alias hsattach="herdr session attach"

# Encerra uma sessão
alias hsstop="herdr session stop"

# Remove uma sessão
alias hsdelete="herdr session delete"


# ────────────────────────────────────────
# SERVER
# ────────────────────────────────────────

# Recarrega configuração do Herdr
alias hre="herdr server reload-config"

# Encerra completamente o servidor
alias hstop="herdr server stop"

