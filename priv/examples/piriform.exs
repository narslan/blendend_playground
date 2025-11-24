# Inspired by https://mathworld.wolfram.com/PiriformCurve.html and the Elixir logo.
# Samples the piriform curve, maps it to canvas space, and fills it with layered gradients.
alias Blendend.Cartesian

draw 600, 600 do
  w = 192
  h = 192
  a = 1.0
  b = 0.5

  # 1) Calculate the points in math space.
  pts_math =
    Cartesian.sample_parametric(
      fn t ->
        x = a * (1.0 + :math.sin(t))
        y = b * :math.cos(t) * (1.0 + :math.sin(t))
        {-y, -x}
      end,
      0.0,
      2.0 * :math.pi(),
      800)
  # create a frame 
  {:ok, frame} = Cartesian.from_points(pts_math, w, h)

  points = 
    for {x, y} <- pts_math do
      Cartesian.to_canvas!(frame, x, y)
    end

  # move canvas' origin
  translate 150, 150
  
  grad =
        Blendend.Style.Gradient.radial_from_stops({100, 40, 100, 100, 120 }, [
        {0.00, rgb(245, 210, 255)},  # light pinkish highlight
        {1.00, rgb(60, 20, 120)}     # deep violet shadow
        ])
  
  polygon points, fill: grad
 
  grad2 =
        Blendend.Style.Gradient.linear_from_stops({220.0, 220.0, 120.0, 120.0}, [
          {1.0,   rgb(0xFF, 0xFF, 0xFF)},
          {0.0,   rgb(0x3F, 0x9F, 0xFF)}
        ])
  
  round_rect 120, 120, 100, 100, 20, 20, fill: grad2, comp_op: :difference

end
