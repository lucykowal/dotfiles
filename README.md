# lucy's dotfiles

set up an environment in one go[^1] with:

[^1]: assuming you are on mac with at least `brew` and optionally `java` and
    `go` installed.

```shell
ansible-playbook bootstrap.yml
```

or, use stow directly: the following commands assume you've put this repository
in your home directory, `~/dotfiles`. if that's not the case, specify home as
the target with `-t ~`, for example, `stow -t ~ nvim`.

Thanks to [frdmn](https://github.com/frdmn/dotfiles) for inspiration.

### neovim

```shell
stow nvim
```

a distant relative of [kickstart](https://github.com/nvim-lua/kickstart.nvim)
with many mutations.

some external tools needed. in general `:checkhealth` helps identify any missing
programs.

based on a split-heavy post-IDE workflow. perma-zen mode & fuzzy finders. i'm
very particular about my tools. i need a level of consistency, so that's what
i've tried to set up here. expect consistent ui and ux where ever possible.
copilot integration for chat and completions, supercollider support, etc.

**to-do**:

- improve handling of supercollider help buffers
- fork Copilot Chat to make some UI tweaks

### zsh

```shell
stow zsh
```

i use `zsh` because it is default. so far i've set up a `.zsh_profile` that can
be sourced from `.zshrc` to get allow for some environment isolation.

i use completions via `compsys`.

### ghostty

```shell
stow ghostty
```

trying this over alacritty now, mostly for the quick terminal. still tmux-bound,
though.

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
