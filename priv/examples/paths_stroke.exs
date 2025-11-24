# Paths.Stroke Example from https://fiddle.blend2d.com/.
# Shows filling a complex path then stroking it with a different comp op for layered outlines.

alias Blendend.Path
draw 600, 600 do
 p = Path.new!() 
   |> Path.move_to!(247, 97)
   |> Path.line_to!(247, 172)
   |> Path.arc_quadrant_to!(172, 172, 172, 247)
   |> Path.line_to!(97, 247)
   |> Path.line_to!( 97, 115)
   |> Path.arc_quadrant_to!(97, 97, 115, 97)
   |> Path.close!()
   |> Path.add_circle!(90, 90, 87)

 fill_rule :even_odd
 fill_path p, fill: rgb(255, 255, 255)
 comp_op :xor
 stroke_path p, stroke: rgb(255, 80, 0, 255), stroke_width: 3.0
end
