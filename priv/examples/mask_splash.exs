# Mask fill demo inspired by the Blend2D Tcl sample; 
# https://abu-irrational.github.io/tclBlend2d-Gallery/cards/sample157.html
# stamps a grayscale splash mask in layered colors.
alias Blendend.{Image}
alias Blendend.Canvas.Mask

canvas_w = 520
canvas_h = 520

draw canvas_w, canvas_h do
  clear(fill: rgb(255, 255, 255))

  # Use red channel as coverage; switch to :luma if your mask encodes luminance differently.
  mask = Image.from_file_a8!("priv/images/splash.png", :red)


  Mask.fill!(Blendend.Draw.get_canvas(), mask, -5, -20,
    fill: rgb(0, 80, 230), # light blue
    alpha: 0.5
  )

  Mask.fill!(Blendend.Draw.get_canvas(), mask, -150.0, 105.0,
    fill: rgb(255, 215, 0), # yellow
    alpha: 0.5
  )

  Mask.fill!(Blendend.Draw.get_canvas(), mask, 50.0, -45.0,
    fill: rgb(255, 0, 0), # red
    alpha: 0.3
  )
end
