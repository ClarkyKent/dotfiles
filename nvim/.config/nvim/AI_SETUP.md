# AI Assistant Reference (CodeCompanion + Copilot)

Configuration lives in `lua/plugins/ai.lua`. This is the single source of
truth for keybindings/models below -- if they ever disagree, trust the code.

## Adapters (`<leader>aA` to switch)

| Adapter | Access | Setup |
|---|---|---|
| **GitHub Copilot** (default) | All models below via one subscription | `:Copilot auth` |
| **Gemini CLI** | Direct Google access via ACP | Install the `gemini` CLI, `export GEMINI_API_KEY=...` |
| **Claude Code** | Direct Anthropic access via ACP | Install the `claude` CLI, `export ANTHROPIC_API_KEY=...` |

Copilot is the only adapter required for day-to-day use; the other two are
optional direct-API escape hatches, wired through codecompanion's built-in
`gemini_cli` / `claude_code` ACP adapters.

## Model selection (`<leader>am`)

The full, current choice list lives in `ai.lua`'s `adapters.copilot` schema
(currently: Claude Opus/Sonnet/Haiku 4.5, Claude 3.7 (+ Thinking), Claude
3.5 (deprecated), GPT-5/5.1 (+ Codex variants), GPT-4.1 (default), GPT-4o,
o1/o3 reasoning models, Gemini 3/2.5/2.0, Grok Code Fast 1, Raptor mini).
Default model: `claude-4.5-sonnet`.

## Keybindings

### Core
| Key | Mode | Action |
|---|---|---|
| `<leader>aa` | n, v | Toggle AI chat |
| `<leader>an` | n, v | New chat |
| `<leader>ah` | v | Add selection to chat |
| `<leader>ai` | n, v | Inline prompt |
| `<leader>a<cr>` | n, v | Actions palette |
| `ga` | v | Add to AI chat (quick) |

### Agent & context
| Key | Action |
|---|---|
| `<leader>ag` | Agent mode (multi-step tasks) |
| `<leader>aw` | Workspace context |
| `<leader>ab` | Ask about buffer |
| `<leader>al` | With LSP context |

### Quick prompts (visual mode)
`<leader>ae` explain · `<leader>af` fix · `<leader>at` tests · `<leader>ad` docs ·
`<leader>ar` refactor · `<leader>ao` optimize · `<leader>av` review

### Settings
| Key | Action |
|---|---|
| `<leader>aA` | Select adapter |
| `<leader>am` | Select model |
| `<leader>as` | Toggle Copilot inline suggestions |
| `<leader>ap` | Copilot panel |
| `<leader>a:` | AI command mode |

### Copilot inline suggestions (insert mode)
`<M-l>` accept · `<M-k>` accept word · `<M-j>` accept line · `<M-]>`/`<M-[>` next/prev ·
`<C-]>` dismiss · `<M-CR>` open panel

## Chat commands

- `@agent` -- multi-step agent mode
- `@workspace` -- include workspace context
- `#buffer` -- reference current buffer
- `#file` / `#symbols` -- attach a file or symbol, picked via **fzf-lua**
  (there is no Telescope in this config)
- `/help` -- list all commands

## Abbreviations

`:cc` -> `:CodeCompanion` · `:ccc` -> `:CodeCompanionChat` · `:cca` -> `:CodeCompanionActions`

## Troubleshooting

- `:Copilot status` / `:Copilot auth` -- authentication
- `:CodeCompanion log` -- view logs
- `<leader>am` -- change model if one is rate-limited or unavailable
- API keys for the optional CLI adapters: `echo $GEMINI_API_KEY`, `echo $ANTHROPIC_API_KEY`
