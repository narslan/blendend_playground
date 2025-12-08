# Drawing catmull-Rom spline. Curves.curve_vertices!/3 mirrors curveVertex of p5.js

alias Blendend.Path
alias BlendendPlayground.Palette
alias BlendendPlayground.Curves

draw 400, 400 do
  [bg | palette] =
    Palette.palette_by_name("takamo.VanGogh")
    |> Map.get(:colors, [])
    |> Palette.from_hex_list_rgb()
    |> Enum.map(fn {r, g, b} -> rgb(r, g, b) end)

  clear(fill: bg)

  # The list includes
  # first control point
  # two anchor points
  # second control point
  points = [{32, 91}, {21, 17}, {68, 19}, {84, 91}]

  Path.new!()
  |> Curves.curve_vertices!(points, closed?: false)
  |> Path.translate!(100, 100)
  |> stroke_path(stroke: Enum.random(palette))

  translate(100, 100)

  circle_color = Enum.random(palette)
  
  Stream.each(points, fn {x, y} -> circle(x, y, 3, fill: circle_color ) end)
  |> Stream.run()
  
end
