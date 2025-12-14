# This is here to experiment a private repo.
# It will fail for now.
alias BlendendPlayground.Palette

draw 800, 800 do
#https://observablehq.com/@d3/colorbrewer-splines
palette = ["#8e0152", "#c51b7d", "#de77ae", "#f1b6da", "#fde0ef", "#f7f7f7", "#e6f5d0", "#b8e186", "#7fbc41", "#4d9221", "#276419"]
palette = Palette.from_hex_list_rgb(palette)

  scale2 =
    Scale.Quantize.new(
      domain: [0, 1],
      range: palette)

  stops2 =
    for i <- 0..10 do
      t = i / 10
      # => {t, {r,g,b}}
      {t, Scale.map(scale2, t)}
    end

  grad2 =
    linear_gradient 40, 40, 760, 100 do
      for {t, {r, g, b}} <- stops2 do
        add_stop(t, rgb(r, g, b))
      end
    end

  #translate(200, 200)
  box(40, 40, 760, 100, fill: grad2)
  
  
end
