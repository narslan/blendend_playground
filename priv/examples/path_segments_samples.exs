# Visual primer for `Path.segments/1` and `Path.sample/3`.
# Shows sampled points on a line-based path (rectangle)
# and a curve-based path (circle) that we flatten first.

alias Blendend.{Canvas, Path}

defmodule BlendendPlayground.Demos.SegmentsSamples do
  def draw_normals(path, spacing, opts \\ []) do
    flatten? = Keyword.get(opts, :flatten?, false)
    flat_tol = Keyword.get(opts, :flat_tol, 0.5)
    normal_len = Keyword.get(opts, :normal_len, 18.0)
    color = Keyword.get(opts, :color, rgb(40, 120, 255))
    include_ends? = Keyword.get(opts, :include_ends?, true)

    path
    |> maybe_flatten(flatten?, flat_tol)
    |> Path.segments()
    |> Path.sample(spacing, include_ends?: include_ends?)
    |> Enum.each(fn {{x, y}, {nx, ny}} ->
      line x, y, x + nx * normal_len, y + ny * normal_len,
        stroke: color,
        stroke_width: 1.0,
        stroke_cap: :round

      circle x, y, 2.5, fill: color
    end)
  end

  defp maybe_flatten(path, false, _tol), do: path
  defp maybe_flatten(path, true, tol), do: Path.flatten!(path, tol)
end

draw 640, 360 do
  clear(fill: rgb(20, 20, 24))

  # A purely linear path: rectangle built from moves/lines only.
  rect =
    Path.new!()
    |> Path.move_to!(80, 80)
    |> Path.line_to!(280, 80)
    |> Path.line_to!(280, 220)
    |> Path.line_to!(80, 220)
    |> Path.close!()

  fill_path rect, fill: rgb(235, 235, 240)
  stroke_path rect, stroke: rgb(90, 90, 90), stroke_width: 1.5

  BlendendPlayground.Demos.SegmentsSamples.draw_normals(rect, 28,
    color: rgb(0, 170, 255),
    normal_len: 16.0
  )

  # A curved path: circle needs flattening before sampling.
  circle_path =
    Path.new!()
    |> Path.add_circle!(430, 150, 90.0)

  fill_path circle_path, fill: rgb(245, 240, 230)
  stroke_path circle_path, stroke: rgb(120, 90, 60), stroke_width: 1.5

  BlendendPlayground.Demos.SegmentsSamples.draw_normals(circle_path, 18,
    flatten?: true,
    flat_tol: 0.8,
    include_ends?: false,
    color: rgb(55, 120, 80),
    normal_len: 14.0
  )
end
