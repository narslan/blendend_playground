# Repository Guidelines

## Project Structure & Module Organization
- `lib/` holds the OTP app (`BlendendPlayground.*`) plus render/palette utilities and demo data modules under `lib/demos/`.
- `priv/examples/` contains runnable drawing samples sent to the backend; `priv/static/assets/` stores built JS/CSS; `priv/images/` and `priv/fonts/` house bundled assets.
- `assets/` is the JS source (entry: `playground.js`) bundled via esbuild into `priv/static/assets/app.js`.
- Tests live in `test/` and mirror module names (e.g., `lib/blendend_playground.ex` -> `test/blendend_playground_test.exs`).

## Build, Test, and Development Commands
```bash
mix deps.get          # install Elixir deps (set BLENDEND_LOCAL=1 to use ../blendend)
mix compile           # compile the app
mix run --no-halt     # start the Playground at http://localhost:4000
mix test              # run ExUnit suite
mix format            # auto-format Elixir sources
(cd assets && pnpm install)   # install frontend deps (pnpm preferred; npm also works)
(cd assets && pnpm run dev)   # watch & rebundle playground JS
(cd assets && pnpm run build) # produce minified JS/CSS into priv/static/assets
```

## Coding Style & Naming Conventions
- Follow `mix format`; default 2-space indentation, snake_case for functions/vars, PascalCase for modules.
- Keep modules small and focused on a single concern (router vs rendering vs demos).
- Name routes and example files descriptively (`priv/examples/text_multiline.exs`, `render.ex`).
- Keep side-effecting code in supervised processes; avoid running untrusted code outside the controlled evaluator.

## Testing Guidelines
- Framework: ExUnit; place tests in `*_test.exs` under `test/`.
- Prefer small, deterministic cases that assert rendered data or message contracts rather than visuals.
- Add doctests when possible (see `BlendendPlayground`); run `mix test` before PRs.

## Commit & Pull Request Guidelines
- Commit format follows history: `[type] short description` where `type` is `feat`, `refactor`, etc. Write in present tense.
- PRs should state scope, testing performed (`mix test`, asset builds), and attach screenshots/gifs for UI-visible changes.
- Link related issues and note any config flags (`BLENDEND_LOCAL`) or asset rebuild steps required for reviewers.

## Security & Configuration Notes
- The backend evaluates user-submitted code; run locally on trusted machines only.
- Keep secrets out of examples and commits; prefer environment variables and `.gitignore`d files for local config.
