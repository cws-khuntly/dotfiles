# Automatically start/attach to tmux in interactive shells
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [ -z "$TMUX" ] && [ "$TERM_PROGRAM" != "vscode" ]; then
    exec tmux new-session -A -s main
fi
