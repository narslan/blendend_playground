# Paths.HitTest Example from https://fiddle.blend2d.com/.
# Constructs a grid of probe points through a complex path to visualize even-odd hit results.

alias Blendend.Path
draw 500, 500 do
p = Path.new!()
    |> Path.move_to!(10.0, 10.0)
    |> Path.quad_to!(150, 650, 460, 33)
    |> Path.cubic_to!(100, 100, 20, 250, 400, 405)
    |> Path.line_to!(420, 10)
    |> Path.arc_quadrant_to!(110, 510, 220, 110)

fill_rule :evenodd
fill_path p, fill: rgb(0x4f, 0x4f, 0x4f)

for xi <- Stream.iterate(0, &(&1 + 8)) |> Enum.take_while(& &1 < 500),
    yi <- Stream.iterate(0, &(&1 + 8)) |> Enum.take_while(& &1 < 500) do
  
  res = Blendend.Path.hit_test(p, xi , yi, :even_odd)
  if res == :in  do
    # draw the little probe circle
    circle xi * 1.0, yi * 1.0, 1.8,  fill: rgb(255, 255, 255, 255)
  end
end
end
