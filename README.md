  # Blendend Playground

  A web UI for experimenting with [`blendend`](https://github.com/narslan/blendend): edit Elixir drawing code in the browser, send it to the backend, and see the rendered image live.

  ⚠️  Safety: the backend evaluates the code you type. Run it only on a trusted machine.

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
  ```

## Licenses

- This project is released under the MIT License (see `LICENSE`).
- `blend2d` is licensed under the zlib license.
- `priv/fonts/Alegreya-Regular.otf` is distributed under the SIL Open Font License.
- [Chromotome Palettes](https://github.com/kgolid/chromotome)  is distributed under MIT License


