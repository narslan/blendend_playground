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
  cx = (xmin + xmax) / 2
  cy = (ymin + ymax) / 2
  dx = max(xmax - xmin, 1.0e-6)
  dy = max(ymax - ymin, 1.0e-6)

  # Fit into canvas with a margin and a slight horizontal squeeze for a slender look.
  margin = 0.12
  avail_w = canvas_w * (1.0 - 2.0 * margin)
  avail_h = canvas_h * (1.0 - 2.0 * margin)
  base_scale = min(avail_w / dx, avail_h / dy)
  scale_x = base_scale * 0.9
  scale_y = base_scale
  offset_x = canvas_w / 2.0
  offset_y = canvas_h / 2.0 - 40.0

  points =
    Enum.map(pts_math, fn {x, y} ->
      {
        offset_x + (x - cx) * scale_x,
        offset_y - (y - cy) * scale_y
      }
    end)

  grad = radial_gradient canvas_w * 0.45, canvas_h * 0.32, 300,  
                         canvas_w * 0.45, canvas_h * 0.32, 0 do
    add_stop 0.00, rgb(255, 225, 255, 250)
    add_stop 0.30, rgb(225, 210, 255)
    add_stop 1.00, rgb(60, 20, 120)
  end
 
  translate 0, -40 do
      polygon(points, fill: grad)
   end
  grad2 = linear_gradient canvas_w * 0.75, canvas_h * 0.75, canvas_w * 0.59, canvas_h * 0.6 do
    add_stop 1.0, rgb(0xFF, 0xFF, 0xFF)
    add_stop 0.0, rgb(0x3F, 0x9F, 0xFF)
  end

  # Position the rounded rect offset from the piriform, similar to the Blend2D logo layout.
  round_rect(canvas_w * 0.5, canvas_h * 0.5, canvas_w * 0.4, canvas_w * 0.4, 64, 64,
    fill: grad2,
    comp_op: :difference
  )
end
