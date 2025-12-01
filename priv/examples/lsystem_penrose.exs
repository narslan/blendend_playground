# Penrose rhomb tiling (P3) via L-system emitting thick/thin tiles (A/B).
alias BlendendPlayground.Demos.LSystem

draw 1200, 1200 do
  clear(fill: rgb(250, 250, 250))

  # Thick (A) and thin (B) rhombs; only A/B draw (as polygons).
  axiom = "[A]++[A]++[A]++[A]++[A]"
  rules = %{
    "A" => "B-F-A-F-B",
    "B" => "A+F+B+F+A",
    "F" => "F"
  }

  iterations = 4
  word = LSystem.derive(axiom, rules, iterations)


  angle = :math.pi() / 5     # 36°
  len = 56.0
  thick_angle = :math.pi() * 2 / 5  # 72°
  thin_angle  = :math.pi() / 5      # 36°
  colors = %{thick: hsv(160, 0.6, 0.8), thin: hsv(280, 0.1, 0.4)}
  stroke = rgb(40, 40, 40)


  tokens = Regex.scan(~r/[A-Z]|\+|\-|\[|\]/u, word, capture: :first) |> List.flatten()

  Enum.reduce(tokens, {600.0, 600.0, 0.0, []}, fn
    "A", {x, y, h, stack} -> # thick rhomb
      LSystem.draw_rhomb(:thick, {x, y, h}, len, thick_angle, colors, stroke)
      nx = x + len * :math.cos(h)
      ny = y + len * :math.sin(h)
      {nx, ny, h, stack}

    "B", {x, y, h, stack} -> # thin rhomb
      LSystem.draw_rhomb(:thin, {x, y, h}, len, thin_angle, colors, stroke)
      nx = x + len * :math.cos(h)
      ny = y + len * :math.sin(h)
      {nx, ny, h, stack}

    "+", {x, y, h, st} -> {x, y, h + angle, st}
    "-", {x, y, h, st} -> {x, y, h - angle, st}
    "[", {x, y, h, st} -> {x, y, h, [{x, y, h} | st]}
    "]", {_x, _y, _h, [{px, py, ph} | rest]} -> {px, py, ph, rest}
    _, state -> state
  end)
end
