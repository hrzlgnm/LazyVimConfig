# 💤 LazyVim config

Personal [LazyVim](https://github.com/LazyVim/LazyVim) setup for Svelte / NestJS frontends,
Rust and C++ backends, and embedded Yocto work.

## Setup

The config lives in `~/.config/LazyVim` and runs under its own app name:

```sh
NVIM_APPNAME=LazyVim nvim
```

Plugins, Mason tools and treesitter parsers install on first start.

## Extras

Enabled through `lazyvim.json` (manage with `:LazyExtras`):

| Area | Extras |
|---|---|
| Languages | clangd, cmake, rust, typescript, svelte, python, sql, docker, json, yaml, toml, markdown, git |
| Formatting / linting | prettier, eslint, black |
| Editor | snacks picker + explorer, mini-files, harpoon2, refactoring, inc-rename, navic, illuminate, dial, mini-move, mini-diff |
| Coding | yanky, mini-surround, neogen |
| Debug / test | dap.core, test.core |
| AI | copilot, copilot-chat |
| UI | indent-blankline, treesitter-context, mini-animate, smear-cursor |
| Util | chezmoi, dot, mini-hipatterns, neoconf |

## Custom plugins and overrides (`lua/plugins/`)

| File | Purpose |
|---|---|
| `core.lua` | colorscheme `vague`, LazyVim news off |
| `vague.lua` | [vague.nvim](https://github.com/vague2k/vague.nvim) colorscheme, transparent |
| `bitbake.lua` | BitBake LSP (`language-server-bitbake` from Mason) + treesitter parser |
| `cmake-tools.lua` | Ninja generator, `build/` dir, symlinked `compile_commands.json` |
| `fude.lua` | [fude.nvim](https://github.com/flexphere/fude.nvim) GitHub PR review, keys under `<leader>gr` |
| `nvim-lint.lua` | extra linters: `oelint-adv` (bitbake), `systemdlint` (systemd) |
| `conform.lua` | `shfmt` with 4-space indent |
| `mason.lua` | additional tools (shell, clang-format, gersemi, hadolint, codebook, …) |
| `snacks.lua` | images on, smooth scrolling off |
| `sort.lua` | [sort.nvim](https://github.com/sQVe/sort.nvim) without `:` as delimiter (CMake targets) |
| `suda.lua` | `:SudaWrite` / `:SudaRead` for root-owned files |
| `rainbow_cvs.lua` | column colouring for CSV/TSV |

## Keymaps

Only additions on top of the [LazyVim defaults](https://www.lazyvim.org/keymaps):

| Key | Mode | Action |
|---|---|---|
| `YY` | n | yank the surrounding `{ … }` block |
| `<leader>P` | x | paste over selection without overwriting the register |
| `n` / `N` | n | next/prev match, centered |
| `<C-d>` / `<C-u>` | n | half page down/up, centered |
| `J` | n | join lines, keep cursor position |
| `<M-y>` | n (cmake) | sort all CMake argument lists in the file |
| `<leader>gr…` | n/v | PR review (fude.nvim): `t` toggle, `s` start, `q` stop, `c` comment, `S` suggest, `n`/`p` next/prev file, `f` files, `o` overview, … |

## Other behaviour

- **Project-local config**: built-in `exrc` is enabled. Neovim loads trusted `.nvim.lua`,
  `.nvimrc` or `.exrc` files from the current directory and its parents; run `:trust`
  after reviewing a new or changed file.
- **CMake sorting** (`lua/util/cmake_sort.lua`): `:CMakeSortAll` and
  `:CMakeSelectFirstSortableRange` sort arguments of `target_sources`,
  `target_link_libraries`, `add_executable`, `set`, `list`, … case-insensitively, leaving
  keywords such as `PRIVATE`/`PUBLIC` in place. Available in cmake buffers only.
- **Filetypes** (`lua/config/options.lua`): systemd unit extensions (`*.service`,
  `*.network`, …) anywhere, `.gersemirc*` as YAML, a few board configs as `dosini`.
- **Terminals** start in insert mode without line numbers and close when the process exits
  cleanly.
- **Folding** uses `{{{ }}}` markers and is off by default.
- Per-language indentation lives in `after/ftplugin/`.
