Select several interpreter versions in tmux panes automatically.

* perlbrew
* plenv

Usage:

    $tool use v1 v2 ...

Opens tiled panes and selects the specified versions.
Activates synchronize-panes.

    $tool run '$x = 23' v1 v2 ...

Does what `use` does and runs the specified command in your interpreter.
