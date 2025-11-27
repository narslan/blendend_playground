alias Blendend.Style
alias Blendend.Style.Gradient

canvas_w = 640
canvas_h = 640

draw canvas_w, canvas_h do
  
  sample_parametric = fn fun, t0, t1, steps ->
    dt = (t1 - t0) / steps
    for i <- 0..steps do
      fun.(t0 + dt * i)
    end
  end

  a = 1.0
  b = 0.5

  pts_math =
    sample_parametric.(
      fn t ->
        x = a * (1.0 + :math.sin(t))
        y = b * :math.cos(t) * (1.0 + :math.sin(t))
        {-y, -x}
      end,
      0.0,
      2.0 * :math.pi(),
      1600)

  # Fit the math coordinates into the canvas with generous padding.
  {xs, ys} = Enum.unzip(pts_math)
  {xmin, xmax} = {Enum.min(xs), Enum.max(xs)}
  {ymin, ymax} = {Enum.min(ys), Enum.max(ys)}
  pad = 0.2
  dx = max(xmax - xmin, 1.0e-6)
  dy = max(ymax - ymin, 1.0e-6)
  xmin = xmin - dx * pad
  xmax = xmax + dx * pad
  ymin = ymin - dy * pad
  ymax = ymax + dy * pad

  to_canvas = fn x, y ->
    sx = (x - xmin) / (xmax - xmin)
    sy = (ymax - y) / (ymax - ymin )
    # Extra horizontal margin to keep the bulb slender.
    {sx * (canvas_w * 0.7) + canvas_w * 0.10, sy * (canvas_h - 1)}
  end

  points = Enum.map(pts_math, fn {x, y} -> to_canvas.(x, y) end)

  grad =
    Gradient.radial_from_stops(
      # inner (highlight) circle and outer circle:
      # cx0, cy0,  cx1, cy1, r0, r1
      {canvas_w * 0.45, canvas_h * 0.32, 300,  
       canvas_w * 0.45, canvas_h * 0.32, 0},
      [
        # bright highlight
        {0.00, rgb(255, 225, 255, 250)},
        # soft falloff
        {0.30, rgb(225, 210, 255)},
        # deep shadow
        {1.00, rgb(60, 20, 120)}
      ]
    )
  translate 0, -40 do
      polygon(points, fill: grad)
   end
  
  grad2 =
    Gradient.linear_from_stops(
      {canvas_w * 0.75, canvas_h * 0.75, canvas_w * 0.59, canvas_h * 0.6},
      [
        {1.0, rgb(0xFF, 0xFF, 0xFF)},
        {0.0, rgb(0x3F, 0x9F, 0xFF)}
      ]
    )

  # Position the rounded rect offset from the piriform, similar to the Blend2D logo layout.
  round_rect(canvas_w * 0.5, canvas_h * 0.5, canvas_w * 0.4, canvas_w * 0.4, 64, 64,
    fill: grad2,
    comp_op: :difference
  )
end
