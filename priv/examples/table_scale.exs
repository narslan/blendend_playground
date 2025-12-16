# This is the draft for a table layout. Nothing too much at the moment.
alias BlendendPlayground.Palette
alias BlendendPlayground.Gradients

width = 1500
height = 1000

draw width, height do
  clear(fill: rgb(0xFF, 0xFA, 0xCE))

  s =
    Scale.Band.new(domain: [:a, :b, :c], range: [0, 200], padding_inner: 1.0, padding_outer: 0.2)

  base_x = 40
  base_y = 40

  for i <- Scale.domain(s) do
    h = Scale.map(s, i)
    line(base_x, base_y + h, width - base_x, base_y + h)
  end

  font = load_font("priv/fonts/AlegreyaSans-Regular.otf", 30.0)
  text(font, 22, 34, "Tables and Scales", fill: rgb(0, 0, 36))
end
