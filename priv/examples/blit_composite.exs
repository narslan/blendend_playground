# Blit image test
alias Blendend.Image
alias Blendend.Canvas

canvas_w = 450
canvas_h = 450

draw canvas_w, canvas_h do
  canvas = Blendend.Draw.get_canvas()

  blit1 = Image.from_file!("priv/images/texture.jpg")
  blit2 = Image.from_file!("priv/images/texture.jpg")

  Canvas.blit_image!(canvas, blit1, 0, 0, 300, 300)
  comp_op :multiply
  Canvas.blit_image!(canvas, blit2, 150, 150, 300, 300)
  
  
end
