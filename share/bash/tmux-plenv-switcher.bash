#!bash

# http://stackoverflow.com/questions/7267185/bash-autocompletion-add-description-for-possible-completions

_tmux-plenv-switcher() {

    COMPREPLY=()
    local program=tmux-plenv-switcher
    local cur=${COMP_WORDS[$COMP_CWORD]}
#    echo "COMP_CWORD:$COMP_CWORD cur:$cur" >>/tmp/comp
    declare -a FLAGS
    declare -a OPTIONS
    declare -a MYWORDS

    local INDEX=`expr $COMP_CWORD - 1`
    MYWORDS=("${COMP_WORDS[@]:1:$COMP_CWORD}")

    FLAGS=('--help' 'Show command help' '-h' 'Show command help')
    OPTIONS=()
    __tmux-plenv-switcher_handle_options_flags

    case $INDEX in

    0)
        __comp_current_options || return
        __tmux-plenv-switcher_dynamic_comp 'commands' '_complete'$'\t''Generate self completion'$'\n''exec'$'\t''Initialize panes and exec command'$'\n''help'$'\t''Show command help'$'\n''run'$'\t''Initialize panes and run code'$'\n''shell'$'\t''Just initialize panes with given versions'

    ;;
    *)
    # subcmds
    case ${MYWORDS[0]} in
      _complete)
        FLAGS+=('--zsh' 'for zsh' '--bash' 'for bash')
        OPTIONS+=('--name' 'name of the program')
        __tmux-plenv-switcher_handle_options_flags
          case $INDEX in
          *)
            __comp_current_options true || return # after parameters
            case ${MYWORDS[$INDEX-1]} in
              --name)
              ;;

            esac
            ;;
        esac
      ;;
      exec)
        FLAGS+=()
        OPTIONS+=()
        __tmux-plenv-switcher_handle_options_flags
          case $INDEX in
          1)
              __comp_current_options || return
          ;;
          2)
              __comp_current_options || return
                _tmux-plenv-switcher_exec_param_versions_completion
          ;;
          *)
            __comp_current_options true || return # after parameters
            case ${MYWORDS[$INDEX-1]} in

            esac
            ;;
        esac
      ;;
      help)
        FLAGS+=('--all' '')
        OPTIONS+=()
        __tmux-plenv-switcher_handle_options_flags
        case $INDEX in

        1)
            __comp_current_options || return
            __tmux-plenv-switcher_dynamic_comp 'commands' '_complete'$'\n''exec'$'\n''run'$'\n''shell'

        ;;
        *)
        # subcmds
        case ${MYWORDS[1]} in
          _complete)
            FLAGS+=()
            OPTIONS+=()
            __tmux-plenv-switcher_handle_options_flags
            __comp_current_options true || return # no subcmds, no params/opts
          ;;
          exec)
            FLAGS+=()
            OPTIONS+=()
            __tmux-plenv-switcher_handle_options_flags
            __comp_current_options true || return # no subcmds, no params/opts
          ;;
          run)
            FLAGS+=()
            OPTIONS+=()
            __tmux-plenv-switcher_handle_options_flags
            __comp_current_options true || return # no subcmds, no params/opts
          ;;
          shell)
            FLAGS+=()
            OPTIONS+=()
            __tmux-plenv-switcher_handle_options_flags
            __comp_current_options true || return # no subcmds, no params/opts
          ;;
        esac

        ;;
        esac
      ;;
      run)
        FLAGS+=()
        OPTIONS+=()
        __tmux-plenv-switcher_handle_options_flags
          case $INDEX in
          1)
              __comp_current_options || return
          ;;
          2)
              __comp_current_options || return
                _tmux-plenv-switcher_run_param_versions_completion
          ;;
          *)
            __comp_current_options true || return # after parameters
            case ${MYWORDS[$INDEX-1]} in

            esac
            ;;
        esac
      ;;
      shell)
        FLAGS+=()
        OPTIONS+=()
        __tmux-plenv-switcher_handle_options_flags
          case $INDEX in
          1)
              __comp_current_options || return
                _tmux-plenv-switcher_shell_param_versions_completion
          ;;
          *)
            __comp_current_options true || return # after parameters
            case ${MYWORDS[$INDEX-1]} in

            esac
            ;;
        esac
      ;;
    esac

    ;;
    esac

}

_tmux-plenv-switcher_compreply() {
    IFS=$'\n' COMPREPLY=($(compgen -W "$1" -- ${COMP_WORDS[COMP_CWORD]}))
    if [[ ${#COMPREPLY[*]} -eq 1 ]]; then # Only one completion
        COMPREPLY=( ${COMPREPLY[0]%% -- *} ) # Remove ' -- ' and everything after
        COMPREPLY="$(echo -e "$COMPREPLY" | sed -e 's/[[:space:]]*$//')"
    fi
}

_tmux-plenv-switcher_exec_param_versions_completion() {
    local param_versions=`plenv versions | sed -e 's/^[ *]*//'`
    _tmux-plenv-switcher_compreply "$param_versions"
}
_tmux-plenv-switcher_run_param_versions_completion() {
    local param_versions=`plenv versions | sed -e 's/^[ *]*//'`
    _tmux-plenv-switcher_compreply "$param_versions"
}
_tmux-plenv-switcher_shell_param_versions_completion() {
    local param_versions=`plenv versions | sed -e 's/^[ *]*//'`
    _tmux-plenv-switcher_compreply "$param_versions"
}

__tmux-plenv-switcher_dynamic_comp() {
    local argname="$1"
    local arg="$2"
    local comp name desc cols desclength formatted
    local max=0

    while read -r line; do
        name="$line"
        desc="$line"
        name="${name%$'\t'*}"
        if [[ "${#name}" -gt "$max" ]]; then
            max="${#name}"
        fi
    done <<< "$arg"

    while read -r line; do
        name="$line"
        desc="$line"
        name="${name%$'\t'*}"
        desc="${desc/*$'\t'}"
        if [[ -n "$desc" && "$desc" != "$name" ]]; then
            # TODO portable?
            cols=`tput cols`
            [[ -z $cols ]] && cols=80
            desclength=`expr $cols - 4 - $max`
            formatted=`printf "'%-*s -- %-*s'" "$max" "$name" "$desclength" "$desc"`
            comp="$comp$formatted"$'\n'
        else
            comp="$comp'$name'"$'\n'
        fi
    done <<< "$arg"
    _tmux-plenv-switcher_compreply "$comp"
}

function __tmux-plenv-switcher_handle_options() {
    local i j
    declare -a copy
    local last="${MYWORDS[$INDEX]}"
    local max=`expr ${#MYWORDS[@]} - 1`
    for ((i=0; i<$max; i++))
    do
        local word="${MYWORDS[$i]}"
        local found=
        for ((j=0; j<${#OPTIONS[@]}; j+=2))
        do
            local option="${OPTIONS[$j]}"
            if [[ "$word" == "$option" ]]; then
                found=1
                i=`expr $i + 1`
                break
            fi
        done
        if [[ -n $found && $i -lt $max ]]; then
            INDEX=`expr $INDEX - 2`
        else
            copy+=("$word")
        fi
    done
    MYWORDS=("${copy[@]}" "$last")
}

function __tmux-plenv-switcher_handle_flags() {
    local i j
    declare -a copy
    local last="${MYWORDS[$INDEX]}"
    local max=`expr ${#MYWORDS[@]} - 1`
    for ((i=0; i<$max; i++))
    do
        local word="${MYWORDS[$i]}"
        local found=
        for ((j=0; j<${#FLAGS[@]}; j+=2))
        do
            local flag="${FLAGS[$j]}"
            if [[ "$word" == "$flag" ]]; then
                found=1
                break
            fi
        done
        if [[ -n $found ]]; then
            INDEX=`expr $INDEX - 1`
        else
            copy+=("$word")
        fi
    done
    MYWORDS=("${copy[@]}" "$last")
}

__tmux-plenv-switcher_handle_options_flags() {
    __tmux-plenv-switcher_handle_options
    __tmux-plenv-switcher_handle_flags
}

__comp_current_options() {
    local always="$1"
    if [[ -n $always || ${MYWORDS[$INDEX]} =~ ^- ]]; then

      local options_spec=''
      local j=

      for ((j=0; j<${#FLAGS[@]}; j+=2))
      do
          local name="${FLAGS[$j]}"
          local desc="${FLAGS[$j+1]}"
          options_spec+="$name"$'\t'"$desc"$'\n'
      done

      for ((j=0; j<${#OPTIONS[@]}; j+=2))
      do
          local name="${OPTIONS[$j]}"
          local desc="${OPTIONS[$j+1]}"
          options_spec+="$name"$'\t'"$desc"$'\n'
      done
      __tmux-plenv-switcher_dynamic_comp 'options' "$options_spec"

      return 1
    else
      return 0
    fi
}


complete -o default -F _tmux-plenv-switcher tmux-plenv-switcher

