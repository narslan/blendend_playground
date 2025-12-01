# Recursive tree with stochastic productions (Example 10.8 style).
alias BlendendPlayground.Demos.LSystem

draw 900, 900 do
  clear(fill: rgb(248, 248, 248))

  axiom = "F1"
  rules = %{
    "F1" => [
      "F0[++F1]-F1",
      "F0[+F1]-F1",
      "F0[+F1]-F1",      # duplicate to weight this option
      "F0[++F1]-F1"
    ],
    "F0" => "F0"
  }

  iterations = 6
  word = LSystem.derive(axiom, rules, iterations)

  base_len = 8.0
  angle = :math.pi() / 6

  LSystem.draw(word,
    len: base_len,
    angle: angle,
    origin: {450.0, 880.0},
    heading: -:math.pi() / 2,
    stroke: rgb(50, 60, 40),
    stroke_width: 1.2,
    forward: ["F0", "F1"]
  )
end
