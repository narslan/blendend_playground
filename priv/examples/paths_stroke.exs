# Paths.Stroke Example from https://fiddle.blend2d.com/.
# Shows filling a complex path then stroking it with a different comp op for layered outlines.

draw 600, 600 do
  clear(fill: rgb(0, 0, 0))

  path p do
    move_to(247, 97)
    line_to(247, 172)
    arc_quadrant_to(172, 172, 172, 247)
    line_to(97, 247)
    line_to(97, 115)
    arc_quadrant_to(97, 97, 115, 97)
    close()
    add_circle(90, 90, 87)
  end

  fill_rule(:even_odd)
  fill_path(p, fill: rgb(255, 255, 255))
  stroke_path(p, stroke: rgb(255, 80, 0, 255), stroke_width: 3.0)
end
