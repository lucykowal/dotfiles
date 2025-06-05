# lucy's dotfiles

bootstrap an environment in one go[^1] with:

[^1]: assuming you are on mac with at least `brew` and optionally `java` and
    `go` installed.

```shell
ansible-playbook up.yml
```

use `--tags` or `--skip-tags` to only execute a subset of tasks. for example:

```shell
ansible-playbook --tags stow up.yml
ansible-playbook --skip-tags brew up.yml
```

or, use stow directly: `stow <package>`, assuming you've put this repository in
your home directory, `~/dotfiles`. if that's not the case, specify home as the
target with `-t ~`, for example, `stow -t ~ nvim`.

thanks to [frdmn](https://github.com/frdmn/dotfiles) for ansible inspiration.

### neovim

```shell
stow nvim
```

a distant relative of [kickstart](https://github.com/nvim-lua/kickstart.nvim)
with many mutations.

some external tools needed. in general `:checkhealth` helps identify any missing
programs. most of these can be installed via the brew task in the playbook.

based on a split-heavy post-IDE workflow. perma-zen mode & fuzzy finders. i'm
very particular about my tools. i need a level of consistency, so that's what
i've tried to set up here. expect consistent ui and ux where ever possible.

### alacritty

```shell
stow alacritty
```

back to alacritty! it's a smaller binary and i don't use the fancy features of
ghostty or kitty.

### tmux

```shell
stow tmux
```

i have a slightly modified key mapping set up to emulate something between
`zellij` and `vim`:

```
C-g           - leader
C-g [h|j|k|l] - to left/below/above/right pane
C-g s         - split pane
C-g v         - vsplit pane
```

### git

```shell
stow git
```

sets up some reasonable config defaults.

### zsh

i use `zsh` because it is default. i use completions via `compsys`. it works!

my `.zshrc` is controlled via `ansible` by inserting a managed block. this
allows for per-workstation additions with minimal headache.
