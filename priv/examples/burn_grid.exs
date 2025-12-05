# Port of https://openprocessing.org/sketch/855987 to blendend.
# Exercises blend modes (burn), gradients, and soft blur shadows.
alias BlendendPlayground.Palette

defmodule BlendendPlayground.Demos.BurnGrid do
  def noise_overlay(w, h) do
    points =
      for _ <- 1..round(w * h * 0.1) do
        {:rand.uniform(w), :rand.uniform(h), :rand.uniform() * 3.0}
      end

    fn ->
      Enum.each(points, fn {x, y, weight} ->
        set_stroke_width(weight)
        line(x, y, x + 1, y + 1)
      end)
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
alias BlendendPlayground.Demos.BurnGrid, as: Demo
palette =
  "burn_grid_demo"
  |> Palette.palette_by_name()
  |> Map.get(:colors, [])
  |> Palette.from_hex_list()
noise = Demo.noise_overlay(w, h)

draw w, h do
  # base background
  clear(fill: hsv(:rand.uniform(360), 0.05, 0.95))

  set_comp_op(:color_burn)

  disable_style(:stroke)

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

          grad =
            radial_gradient -d / 2, -d / 2, 0, -d / 2, -d / 2, d * 2 do
              add_stop(0.0, c1)
              add_stop(0.5, c2)
              add_stop(1.0, c3)
            end

          set_fill_style(grad)

          shape =
            cond do
              :rand.uniform(100) > 50 ->
                [{d / 2, -d / 2}, {0, -d / 2}, {-d / 2, d / 2}, {0, d / 2}]

              true ->
                [{-d / 2, -d / 2}, {d / 2, -d / 2}, {d / 2, d / 2}]
            end

          path = Demo.to_path(shape)

          shadow_path(path, 0.0, 0.0, w / 40.0, fill: Enum.random(palette), resolution: 0.4)

          polygon(shape)
        end
      end
    end
  end

  # back to normal comp, draw noise overlay
  set_comp_op(:src_over)

  noise.()
end
