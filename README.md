# lucy's dotfiles

everything is catppuccin latte. i'd explore other themes but i like how
catppuccin has pretty reliable ready-to-go configs for almost everything.

### neovim

```shell
stow -t ~/.config/nvim -S nvim
```

a distant relative of [kickstart](https://github.com/nvim-lua/kickstart.nvim)
with many mutations.

some external tools needed. in general `:checkhealth` helps identify any missing
programs.

based on a split-heavy post-IDE workflow. perma-zen mode & fuzzy finders. i'm
very particular about my tools. i need a level of consistency, so that's what
i've tried to set up here. expect consistent ui and ux where ever possible.
copilot integration for chat and completions, supercollider support,

**to-do**:

- improve handling of supercollider help buffers
- evaluate value of floating terminal v.s. built-in `:term`
- spell/grammar fixes: toggle spell and tie to harper

### zsh

```shell
stow -t ~ -S zsh
```

i use zsh because it is default.

### alacritty

```shell
stow -t ~/.config/alacritty -S alacritty
```

current terminal emulator. kiss.
