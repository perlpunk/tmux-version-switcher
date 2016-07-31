Select several interpreter versions in tmux panes automatically.

* perlbrew
* plenv
* rbenv
* pyenv

# Usage

    $tool local v1 v2 ...

Opens tiled panes and selects the specified versions.
Activates synchronize-panes.

    $tool run '$x = 23' v1 v2 ...

Does what `local` does and runs the specified command in your interpreter.

    $tool exec 'perl myapp.pl' v1 v2 ...

Does what `local` does and runs the specified command.

# Installation

    % git clone https://github.com/perlpunk/tmux-version-switcher.git
    # or
    % git hub clone perlpunk/tmux-version-switcher
    # put this in your .bashrc/.zshrc:
    % source /path/to/tmux-version-switcher/init

# Examples

    % tmux-perlbrew-switcher local perl-5.22.0 perl-5.24.0
    # tmux opens with two tiled panes, with the specified versions

    % tmux-perlbrew-switcher run '$x = 23' perl-5.22.0 perl-5.24.0
    # tmux opens with two tiled panes and runs `perl -wE'$x = 23'`

    % tmux-perlbrew-switcher exec 'perl myapp.pl' perl-5.22.0 perl-5.24.0
    # tmux opens with two tiled panes and runs `perl myapp.pl`
