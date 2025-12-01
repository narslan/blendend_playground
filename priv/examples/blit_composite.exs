# Blit image test. TODO: This demo should be improved.
# Finding a texture on internet shouldn't be difficult.
alias Blendend.Image
alias Blendend.Canvas

canvas_w = 450
canvas_h = 450

draw canvas_w, canvas_h do
  canvas = Blendend.Draw.get_canvas()

  blit1 = Image.from_file!("priv/images/texture.jpg")

  Canvas.blit_image!(canvas, blit1, 0, 0, 300, 300)
  set_comp_op :difference
  rect 150, 150, 150, 150, fill: hsv(0, 0, 1, 200)
  
end
