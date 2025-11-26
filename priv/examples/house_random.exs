
  
  # Welcome to the Blendend playground.
  # Pick an example to load it, tweak
  # and see the preview update.
  # Save as a new file with "Filename" + "New"; 
  # To the edit the current file use "Update".
  alias BlendendPlayground.Palette
  draw 800, 800 do

    [c1, c2 , c3, c4, c5] = Palette.scheme(:vangogh)
    
    grad =
      Blendend.Style.Gradient.linear_from_stops({150, 150, 360, 360}, [
        {0.0, c1},
        {0.25,c2},
        {0.5,c3},
        {0.75,c4},      
        {1.0, c5}
      ])
    translate 200, 200
    round_rect 40, 40, 420, 320, 28, 28, fill: grad

    font = load_font "priv/fonts/Alegreya-Regular.otf", 48.0
    text font, 80, 215, "Hello, blendend!", fill: rgb(40, 40, 40)
  end
  