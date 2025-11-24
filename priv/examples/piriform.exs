alias Blendend.{Cartesian, Style}
alias Blendend.Style.Gradient

canvas_w = 1200
canvas_h = 1200

draw canvas_w, canvas_h do
  a = 1.0
  b = 0.5

  pts_math =
    sample_parametric(
      fn t ->
        x = a * (1.0 + :math.sin(t))
        y = b * :math.cos(t) * (1.0 + :math.sin(t))
        {-y, -x}
      end,
      0.0,
      2.0 * :math.pi(),
      1600)

  {:ok, frame} = Cartesian.from_points(pts_math, canvas_w, canvas_h, padding: 0.5)

  points =
    for {x, y} <- pts_math do
      Cartesian.to_canvas!(frame, x, y)
    end

  grad =
    Gradient.radial_from_stops({canvas_w * 0.32, canvas_h * 0.36, canvas_w * 0.5, canvas_h * 0.4, canvas_w * 0.4}, [
      {0.00, rgb(245, 210, 255)},  # light pinkish highlight
      {1.00, rgb(60, 20, 120)}   
    ])

  polygon points, fill: grad

  grad2 =
    Gradient.linear_from_stops({canvas_w * 0.75, canvas_h * 0.7, canvas_w * 0.55, canvas_h * 0.6}, [
      {1.0, rgb(0xFF, 0xFF, 0xFF)},
      {0.0, rgb(0x3F, 0x9F, 0xFF)}
    ])

  # Position the rounded rect offset from the piriform, similar to the Blend2D logo layout.
  round_rect canvas_w * 0.54, canvas_h * 0.56, 320, 320, 64, 64,
    fill: grad2,
    comp_op: :difference
end
