# Blendend Playground

A web UI for experimenting with [`blendend`](https://github.com/narslan/blendend): 
Safety: the backend evaluates the code you type. Run it only on a trusted machine.

## Features
- **Playground** – live sketchbook for `blendend` snippets. 
- **Swatches** – palette browser rendered as collages. It shows how colors interact on a composition.
- **Font Explorer** – scans bundled fonts plus `~/.fonts` by default and shows families/weights with live previews. To add more search paths, set `config :blendend_playground, :font_paths, ["/path/to/fonts"]` in your own `config/config.exs` before booting the server.

## Requirements
- Elixir (tested on 1.19)
- Erlang/OTP 27+
- `mix` to fetch/build dependencies (`mix deps.get` will pull `blendend`)
- Node.js + pnpm/npm if you rebuild the frontend in `assets/`

## Run (dev)
```sh
mix deps.get
mix run --no-halt
# open http://localhost:4000
# If you want to change js files, rebuild assets
cd assets
pnpm run build 
```

## Using sublime backend

If you're a Sublime Text user, you can edit blendend scripts in the comfort of your editor and send them to the playground for a quick preview.

1. Copy `sublime_plugin/blendend_preview.py` under "~/.config/sublime-text/Packages/User/"
2. Start the server: `BLENDEND_PREVIEW=1 iex -S mix`
3. In Sublime, run the command via the console: `window.run_command("blendend_preview")`, or assign a key binding:
   ```json
   {
     "keys": ["ctrl+shift+e"],
     "command": "blendend_preview"
   }
   ```
4. The plugin POSTs the current file path, waits for render, and opens tmp/preview.png.

## Licenses

- This project is released under the MIT License (see `LICENSE`).
- `blend2d` is licensed under the zlib license.
- The fonts under `priv/fonts/` are distributed under the SIL Open Font License.
- [Chromotome Palettes](https://github.com/kgolid/chromotome) is distributed under MIT License.
- More palettes are taken from takawo's sketches (https://openprocessing.org/user/6533) 
