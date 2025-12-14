# This is here to experiment a private repo.
# It will fail for now.
alias BlendendPlayground.Palette

draw 800, 800 do
  palette =
    Palette.palette_by_name("takamo.VanGogh")
    |> Map.get(:colors, [])
    |> Palette.from_hex_list_rgb()

  scale =
    Scale.Ordinal.new(
      domain: ["a", "b", "c", "d", "e"],
      range: palette
    )

  col = Scale.map(scale, "a")
  IO.inspect(col)

  clear(fill: rgb(col))

  scale =
    Scale.Linear.new(
      domain: [0, 1],
      range: [{165, 42, 42}, {70, 130, 180}],
      interpolate: &Scale.Interpolator.rgb/2
    )

  stops =
    for i <- 0..4 do
      t = i / 4
      # => {t, {r,g,b}}
      {t, Scale.map(scale, t)}
    end

  grad =
    linear_gradient 40, 40, 420, 420 do
      for {t, {r, g, b}} <- stops do
        add_stop(t, rgb(r, g, b))
      end
    end

  translate(200, 200)
  round_rect(40, 40, 420, 420, 28, 28, fill: grad)

  font = load_font("priv/fonts/Alegreya-Regular.otf", 48.0)
  text(font, 80, 215, "Hello, blendend!", fill: rgb(40, 40, 40))
end
