# From Mathematical Structures for Computer Graphics Steven J. Janke
# Bracketed DOL-system tree (Example 10.7 style).
alias BlendendPlayground.Demos.LSystem

draw 800, 900 do
  clear(fill: rgb(250, 250, 250))

  axiom = "F"
  rules = %{"F" => "FF[+F]F[+F][-F]F[-F [-F [+F [+F]]]]F"}
  iterations = 3
  word = LSystem.derive(axiom, rules, iterations)

  # Drawing parameters.
  angle = :math.pi() / 6
  segment_len = 3.0
  origin = {400.0, 820.0}
  heading = -:math.pi() / 2

  # Optional: gradient-like effect by re-drawing with slight hue shift per depth
  # is omitted for simplicity; we keep a single stroke color.
  LSystem.draw(word,
    len: segment_len ,
    angle: angle,
    origin: origin,
    heading: heading,
    stroke: hsv(0, 0.2, 0.5),
    stroke_width: 2.8
  )
end
