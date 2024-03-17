if status is-interactive
    set -U fish_greeting
end

# opam configuration
source /home/anton/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true

set -gx EDITOR nvim
set -gx VISUAL less

