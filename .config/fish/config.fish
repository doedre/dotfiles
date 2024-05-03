if status is-interactive
    set -U fish_greeting
end

# opam configuration
source /home/anton/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true

set -gx EDITOR nvim
set -gx PAGER less

#if type -q theme.sh
#    if test -e ~/.theme_history
#        set -l last_theme (theme.sh -l | tail -n1)
#        if test "$last_theme" = "gruvbox"
#            switch_theme --light
#        else
#            switch_theme --dark
#        end
#    end
#end

