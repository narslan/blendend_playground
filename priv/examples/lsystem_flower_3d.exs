# Plant with flowers using full 3D turtle semantics (yaw/pitch/roll, diameter, color index).
alias BlendendPlayground.Demos.LSystem

draw 1000, 1200 do
  clear(fill: rgb(245, 245, 245))

  axiom = "plant"

  rules = %{
    "plant" =>
      "internode + [ plant + flower ] -- [ -- leaf ] internode [ ++ leaf ] - [ plant flower ] ++ plant flower",
    "internode" => [
      "F seg [ / / leaf ] [ / / leaf ] F seg",
      "F seg [ / / leaf ] [ / / flower ] F seg"
    ],
    "seg" => "seg F seg",
    "leaf" => "leaf",
    # tick color index at flower start (')
    "flower" => "'<[ & & & pedicel / wedge / / / / wedge / / / / wedge / / / / wedge / / / / wedge ]>",
    "pedicel" => "F F",
    "wedge" => "[ F ] [ { - F + F | - F + F } ]"
  }

  iterations = 5
  word = LSystem.derive(axiom, rules, iterations)

  angle = :math.pi() * 20.0 / 180.0
  colors = [
    hsv(120, 0.95, 0.5, 240),
    hsv(300, 0.8, 0.3),
    hsv(0, 0.9, 0.4),
    hsv(160, 0.8, 0.6),
  ]

  LSystem.draw_3d(word,
    len: 24.0,
    angle: angle,
    origin: {400.0, 1150.0, 0.0},
    heading: {{0.0, 1.0, 0.0}, {-1.0, 0.0, 0.0}, {0.0, 0.0, 1.0}},
    dia: 3.0,
    dia_step: 0.5,
    colors: colors ++ [hsv(50, 0.6, 0.8), hsv(240, 0.9, 0.7)],
    proj_k: 0.2,
    leaf_len: 20.0,
    leaf_width: 8.0
  )
end
