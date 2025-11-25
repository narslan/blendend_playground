# Port of https://openprocessing.org/sketch/855987 to Blendend.
# Exercises blend modes (burn), gradients, and soft blur shadows.
use Blendend.Draw

defmodule BlendendPlayground.Demos.P5BurnGrid do
  def parse_palette() do
    url = "ffcd38-f2816a-71dcdd-2d557f-f7ede2"

    url
    |> String.split("-")
    |> Enum.map(fn hex ->
      <<r::binary-size(2), g::binary-size(2), b::binary-size(2)>> = hex
      rgb(String.to_integer(r, 16), String.to_integer(g, 16), String.to_integer(b, 16))
    end)
  end

  def noise_overlay(w, h) do
    points =
      for _ <- 1..round(w * h * 0.02),
          do: {:rand.uniform() * w, :rand.uniform() * h}

    fn ->
      Enum.each(points, fn {x, y} ->
        line(x, y, x + 1, y + 1)
      end)
    end
  end

  def radial_gradient_fill(x0, y0, r0, x1, y1, r1, colors) do
    [c1 , c2 , c3 | _] = colors


    Blendend.Style.Gradient.radial_from_stops(
      {x0, y0, r0, x1, y1, r1},
      [
        {0.0, c1},
        {0.5, c2},
        {1.0, c3}
      ]
    )
  end

  def shape_choice(d) do
    r = :rand.uniform()

    cond do
      r > 0.5 ->
        if :rand.uniform() > 0.5,
          do: [{-d / 2, -d / 2}, {0, -d / 2}, {d / 2, d / 2}, {0, d / 2}],
          else: [{d / 2, -d / 2}, {0, -d / 2}, {-d / 2, d / 2}, {0, d / 2}]

      true ->
        [{-d / 2, -d / 2}, {d / 2, -d / 2}, {d / 2, d / 2}]
    end
  end

  def to_path(points) do
    {path, started?} =
      Enum.reduce(points, {Blendend.Path.new!(), false}, fn {x, y}, {p, started?} ->
        if started? do
          {Blendend.Path.line_to!(p, x, y), true}
        else
          {Blendend.Path.move_to!(p, x, y), true}
        end
      end)

    if started?, do: Blendend.Path.close!(path), else: path
  end
end

w = 800
h = 800
alias BlendendPlayground.Demos.P5BurnGrid, as: Demo
palette = Demo.parse_palette()
noise = Demo.noise_overlay(w, h)

draw w, h do
  # base background
  clear(fill: rgb(:rand.uniform(360) |> rem(360), 5, 95))

  comp_op(:color_burn)

  canvas = Blendend.Draw.get_canvas()
  Blendend.Canvas.disable_stroke_style!(canvas)

  layers = :rand.uniform(11) + 1

  for _k <- 1..layers do
    offset = w / 18
    # 3..6 cells to keep shape count reasonable
    cells = :rand.uniform(4) + 2
    margin = 0
    d = (w - offset * 2 - margin * (cells - 1)) / cells
    
    grad = Demo.radial_gradient_fill( -d / 2, -d/2, 0,  -d/2, -d/2,   d*2, palette )
    
    Blendend.Canvas.set_fill_style!(canvas, grad)
    for j <- 0..(cells - 1), i <- 0..(cells - 1) do
      x = offset + i * (d + margin)
      y = offset + j * (d + margin)

      translate x + d / 2, y + d / 2 do
        rotate(:rand.uniform(4) * :math.pi() / 2)

        # pick three palette colors (cycle through to avoid dominance)
        idx = rem(i + j * cells, length(palette))
        c1 = Enum.at(palette, idx)
        c2 = Enum.at(palette, rem(idx + 1, length(palette)))
        c3 = Enum.at(palette, rem(idx + 2, length(palette)))

        

        # shadow via blur_path on the polygon outline (skip most for perf)
        case Demo.shape_choice(d) do
          [] ->
            :ok

          pts ->
            if :rand.uniform() > 0.7 do
              path = Demo.to_path(pts)

              blur_path(path, w / 120,
                mode: :fill,
                fill: Enum.random(palette),
                padding: d / 6
              )
            end

            polygon pts
        end
      end
    end
  end

  # back to normal comp, draw noise overlay
  comp_op(:src_over)
  stroke_color = rgb(255, 255, 255, 20)
  Blendend.Canvas.set_stroke_style!(canvas, stroke_color)
  Blendend.Canvas.set_stroke_width!(canvas, 1.0)
  noise.()
end
