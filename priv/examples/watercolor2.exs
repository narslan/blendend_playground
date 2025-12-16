# Port of https://generated.space/sketch/watercolor-2/
# https://github.com/kgolid/p5ycho/blob/master/horizon3/sketch.js
# by kgolid

defmodule BlendendPlayground.Demos.Watercolor2 do
  @default_opts [
    initial_size: 5,
    initial_deviation: 300.0,
    deviation: 90.0,
    interpolate_passes: 6,
    update_passes: 5
  ]

  def default_opts, do: @default_opts

  def init_points(width, ypos, opts \\ []) do
    opts = Keyword.merge(@default_opts, opts)
    initial_size = Keyword.fetch!(opts, :initial_size)
    initial_deviation = Keyword.fetch!(opts, :initial_deviation)
    interpolate_passes = Keyword.fetch!(opts, :interpolate_passes)

    points =
      0..(initial_size - 1)
      |> Enum.map(fn i ->
        x = i / (initial_size - 1) * width
        {x * 1.0, ypos * 1.0, rand_between(-1.0, 1.0)}
      end)

    Enum.reduce(1..interpolate_passes, points, fn _, acc ->
      interpolate(acc, initial_deviation)
    end)
  end

  def update(points, opts \\ []) do
    opts = Keyword.merge(@default_opts, opts)
    update_passes = Keyword.fetch!(opts, :update_passes)
    deviation = Keyword.fetch!(opts, :deviation)

    Enum.reduce(1..update_passes, points, fn _, acc ->
      Enum.map(acc, &move_nearby(&1, deviation))
    end)
  end

  def polygon_points(points) do
    points
    |> Enum.map(fn {x, y, _z} -> {x, y} end)
  end

  defp interpolate(points, sd) when is_list(points) and length(points) >= 2 do
    [first | rest] = points

    {rev, _last} =
      Enum.reduce(rest, {[first], first}, fn p2, {acc, p1} ->
        mid = generate_midpoint(p1, p2, sd)
        {[p2, mid | acc], p2}
      end)

    rev
  end

  defp generate_midpoint({x1, y1, z1}, {x2, y2, z2}, sd) do
    x = (x1 + x2) / 2.0
    y = (y1 + y2) / 2.0
    z = (z1 + z2) / 2.0 * 0.45 * rand_between(0.1, 3.5)
    move_nearby({x, y, z}, sd)
  end

  defp move_nearby({_, _, _} = pnt, sd) when sd == 0 or sd == 0.0, do: pnt

  defp move_nearby({x, y, z}, sd) do
    stdev = abs(z * sd)
    {rand_gaussian(x, stdev), rand_gaussian(y, stdev), z}
  end

  defp rand_between(min, max), do: min + :rand.uniform() * (max - min)

  defp rand_gaussian(mean, stdev) do
    mean + :rand.normal() * stdev
  end
end

alias BlendendPlayground.Demos.Watercolor2

width = 1500
height = 1000

draw width, height do
  clear(fill: rgb(0xFF, 0xFA, 0xCE))

  Stream.iterate(-100, &(&1 + 250))
  |> Stream.take_while(&(&1 < height))
  |> Enum.each(fn ypos ->
    points = Watercolor2.init_points(width, ypos)

    hue = :rand.uniform() * 360.0
    fill_color = hsv(hue, 1, 0.8)

    Enum.each(1..42, fn _ ->
      current = Watercolor2.update(points)

      polygon(Watercolor2.polygon_points(current),
        fill: fill_color,
        alpha: 0.01,
        comp_op: :darken
      )
    end)
  end)
end
