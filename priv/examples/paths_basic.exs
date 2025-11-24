# Paths.Basics Example from https://fiddle.blend2d.com/.
# Builds a classic blend2d path and demonstrates how fill rules affect overlapping segments.
alias Blendend.Path
draw 512, 512 do
p = Path.new!()
  |> Path.move_to!(247, 97)
  |> Path.line_to!(247, 172)
  |> Path.arc_quadrant_to!(172, 172, 172, 247)
  |> Path.line_to!(97, 247)
  |> Path.line_to!(97, 115)
  |> Path.arc_quadrant_to!(97, 97, 115, 97)
  |> Path.add_circle!(90, 90, 87)

# set fill_rule to :non_zero to see the change
fill_rule :even_odd
fill_path p, fill: rgb(255, 255, 255) 
end
