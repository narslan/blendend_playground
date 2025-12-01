# Barnsley-style fern L-system (stochastic-free variant from the Wikipedia example).
alias BlendendPlayground.Demos.LSystem

draw 1000, 1100 do
  clear(fill: rgb(250, 250, 250))

  axiom = "-X"
  rules = %{
    "X" => "F+[[X]-X]-F[-FX]+X",
    "F" => "FF"
  }

  iterations = 6
  word = LSystem.derive(axiom, rules, iterations)

  angle = :math.pi() * 15.0 / 180.0
  seg_len = 3.8

  LSystem.draw(word,
    len: seg_len,
    angle: angle,
    origin: {500.0, 860.0},
    heading: -:math.pi() / 2,
    stroke: rgb(40, 90, 50),
    stroke_width: 1.0,
    stroke_join: :round,
    forward: ["F"] # X is a control symbol; only F draws.
  )
end
