#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use FindBin '$Bin';
use YAML::XS qw/ Load /;

my $yaml = do { local $/; <DATA> };
my $data = Load $yaml;

my ($task) = @ARGV;

{
    appspec => \&appspec,
    completion => \&completion,
}->{$task}->();

sub appspec {
    my $template = "$Bin/../share/tmux-version-switcher.yaml";
    open my $fh, '<', $template or die $!;
    my $orig = do { local $/; <$fh> };
    close $fh;

    for my $key (sort keys %$data) {
        my $conf = $data->{ $key };
        my $target = "$Bin/../share/$conf->{program}.yaml";
        say "Generating $target";
        open my $out, '>', $target or die $!;
        my $content = $orig;
        $content =~ s#\$(\w+)#$conf->{ lc $1 } // "\$$1"#eg;
        print $out $content;
        close $out;
    }
}

sub completion {
    for my $key (sort keys %$data) {
        my $conf = $data->{ $key };
        my $program = $conf->{program};
        say "Generating share/(bash|zsh) for $program";
        my $cmd1 = "appspec completion share/$program.yaml --bash > share/bash/$program.bash";
        my $cmd2 = "appspec completion share/$program.yaml --zsh > share/zsh/_$program && chmod guo+x share/zsh/_$program";
        system $cmd1;
        system $cmd2;
    }
}

__DATA__
perlbrew:
    program: tmux-perlbrew-switcher
    lang: perl
    tool: perlbrew
    list_versions_cmd: |
        perlbrew list | sed -e 's/^[ *]*//'
plenv:
    program: tmux-plenv-switcher
    lang: perl
    tool: plenv
    list_versions_cmd: |
        plenv install --list | sed -e 's/^[ *]*//'

