#!/bin/bash
# PreToolUse hook for the Bash and PowerShell tools.
# Based on the git-guardrails-claude-code skill. Reads the command with jq,
# falls back to node, and blocks when neither can parse it, so a missing
# parser shows up at once instead of letting every command through.

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
elif command -v node >/dev/null 2>&1; then
  COMMAND=$(printf '%s' "$INPUT" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{process.stdout.write(String((JSON.parse(s).tool_input||{}).command||""))}catch(e){}})')
else
  echo "BLOCKED: git guardrail needs jq or node to read the command. Install one of them (see README.md)." >&2
  exit 2
fi

DANGEROUS_PATTERNS=(
  "git push"
  "git reset --hard"
  "git clean -fd"
  "git clean -f"
  "git branch -D"
  "git checkout \."
  "git restore \."
  "push --force"
  "reset --hard"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if printf '%s' "$COMMAND" | grep -qE "$pattern"; then
    echo "BLOCKED: '$COMMAND' matches dangerous pattern '$pattern'. The user has prevented you from doing this. Commit on the ticket branch and ask the user to push." >&2
    exit 2
  fi
done

exit 0
