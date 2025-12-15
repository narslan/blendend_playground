# This is here to experiment a private repo.
# It will fail for now.
alias BlendendPlayground.Palette

draw 800, 800 do
#https://observablehq.com/@d3/colorbrewer-splines
palette = ["#8e0152", "#c51b7d", "#de77ae", "#f1b6da", "#fde0ef", "#f7f7f7", "#e6f5d0", "#b8e186", "#7fbc41", "#4d9221", "#276419"]
palette = Palette.from_hex_list_rgb(palette)

# box dimensions
x0 = 40
y0 = 40
x1  = 720
y1  = 100
#box height, we use it to lay boxes 
h = y1 - y0   
  
scale1 =
   Scale.Quantize.new(
     domain: [0, 1],
     range: palette)

  grad1 =
    linear_gradient x0, y0, x1, y1 do
      for t <- 0..10 do
        add_stop(t/10, rgb(Scale.map(scale1, t/10)))
      end
    end

  scale_oklab =
  Scale.Linear.new(
    domain: [0, 1],
    range: [{255, 0, 0}, {0, 0, 255}],
    interpolate: &Scale.Interpolator.oklab/2)

  grad_oklab =
    linear_gradient x0, y0 + h, x1, y1 + h do
      for t <- 0..10 do
        add_stop(t/10, rgb(Scale.map(scale_oklab, t/10)))
      end
    end

 scale_rgb = Scale.Linear.set_interpolate(scale_oklab, &Scale.Interpolator.rgb/2)
 grad_rgb =
    linear_gradient x0, y0 + 2 * h, x1, y1 + 2 * h do
      for t <- 0..10 do
        add_stop(t/10, rgb(Scale.map(scale_rgb, t/10)))
      end
    end

  scale_oklch = Scale.Linear.set_interpolate(scale_oklab, &Scale.Interpolator.oklch/2)
 grad_rgb =
    linear_gradient x0, y0 + 3 * h, x1, y1 + 3 * h do
      for t <- 0..10 do
        add_stop(t/10, rgb(Scale.map(scale_oklch, t/10)))
      end
    end
  
  #translate(200, 200)
  box(x0, y0, x1, y1, fill: grad1)
  box(x0, y0 + h, x1, y1 + h, fill: grad_oklab)
  box(x0, y0 + 2 * h, x1, y1 + 2 * h, fill: grad_rgb)
  box(x0, y0 + 3 * h, x1, y1 + 3 * h, fill: grad_oklch)
  
end
