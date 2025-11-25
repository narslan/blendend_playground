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
      for _ <- 1..round(w * h * 0.1) do
        {:rand.uniform(w), :rand.uniform(h), :rand.uniform() * 3.0}
      end

    fn ->
      canvas = Blendend.Draw.get_canvas()

      Enum.each(points, fn {x, y, weight} ->
        Blendend.Canvas.set_stroke_width!(canvas, weight)
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
  clear(fill: hsv(:rand.uniform(360), 0.05, 0.95))

  comp_op(:color_burn)
  canvas = Blendend.Draw.get_canvas()
  Blendend.Canvas.disable_stroke_style!(canvas)

  layers = 5

  for _k <- 1..layers do
    offset = w / 15
    cells = :rand.uniform(10) + 1
    margin = 0
    d = (w - offset * 2 - margin * (cells - 1)) / cells

    for j <- 0..(cells - 1), i <- 0..(cells - 1) do
      x = offset + i * (d + margin)
      y = offset + j * (d + margin)

      translate x + d / 2, y + d / 2 do
        rotate(:rand.uniform(4) * :math.pi() / 2)

        if :rand.uniform(100) > 33 do
          [c1, c2, c3] = Enum.take_random(palette, 3)
          grad = Demo.radial_gradient_fill(-d / 2, -d / 2, 0, -d / 2, -d / 2, d * 2, [c1, c2, c3])
          Blendend.Canvas.set_fill_style!(canvas, grad)

          shape =
            cond do
              :rand.uniform(100) > 50 and :rand.uniform(100) > 50 ->
                [{-d / 2, -d / 2}, {0, -d / 2}, {d / 2, d / 2}, {0, d / 2}]

              :rand.uniform(100) > 50 ->
                [{d / 2, -d / 2}, {0, -d / 2}, {-d / 2, d / 2}, {0, d / 2}]

              true ->
                [{-d / 2, -d / 2}, {d / 2, -d / 2}, {d / 2, d / 2}]
            end

          path = Demo.to_path(shape)

          shadow_path(path, 0.0, 0.0, w / 40.0, fill: Enum.random(palette))
          polygon shape
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
