# Penrose rhomb tiling (P5) via L-system.
# Grammar from classic L-system references; draws only "F" segments.
alias BlendendPlayground.Demos.LSystem

draw 1200, 1200 do
  clear(fill: rgb(250, 250, 250))

  axiom = "[X]++[X]++[X]++[X]++[X]"
  rules = %{
    "W" => "YF++ZF----XF[-YF----WF]++",
    "X" => "+YF--ZF[---WF--XF]+",
    "Y" => "-WF++XF[+++YF++ZF]-",
    "Z" => "--YF++++WF[+ZF++++XF]--XF",
    "F" => "F"
  }

  iterations = 4
  word = LSystem.derive(axiom, rules, iterations)

  angle = :math.pi() / 5   # 36°
  seg_len = 28.0

  LSystem.draw(word,
    len: seg_len,
    angle: angle,
    origin: {500.0, 500.0},
    heading: 0.0,
    stroke: hsv(240, 0.6, 0.4),
    stroke_width: 2.0,
    forward: ["F"] # Only F draws; WXYZ are control symbols.
  )
end
