# Plots two Lissajous curves from parametric samples and fits them into a canvas frame.
# Demonstrating Cartesian sampling and multi-series styling.
alias Blendend.Cartesian

w = 1200
h = 1200
draw w, h do
  color1 = rgb(0x00, 0x7e, 0xfe) 
  color2 = rgb(0xff, 0x7e, 0x6f) 
  lissajous1 = fn t -> { :math.sin(3 * t), :math.sin(4 * t) } end
  lissajous2 = fn t -> { :math.sin(5 * t), :math.sin(2 * t) } end
  pts1 = sample_parametric(lissajous1, 0.0, 2.0 * :math.pi(), 1800)
  pts2 = sample_parametric(lissajous2, 0.0, 2.0 * :math.pi(), 1800)
  all_pts = pts1 ++ pts2
  frame = frame_from_points(all_pts, w, h)
  plot_curve(frame, pts1, stroke: color1, stroke_width: 3.0)
  plot_curve(frame, pts2, stroke: color2, stroke_width: 1.0)
end
