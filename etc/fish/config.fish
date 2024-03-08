if status is-interactive
    set -g fish_greeting

    set -gx EDITOR "$(which nvim)"
    set -gx VISUAL "$EDITOR"

    alias ls='ls --color=auto --group-directories-first -FX'

    fish_config prompt choose scales
    fish_config theme choose Dracula
end
