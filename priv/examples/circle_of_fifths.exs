
  
  # Welcome to the Blendend playground.
  # Pick an example to load it, tweak
  # and see the preview update.
  # Save as a new file with "Filename" + "New"; 
  # To the edit the current file use "Update".
alias BlendendPlayground.Palette

draw 800, 800 do
clear(fill: rgb(255, 255, 255))
    #palette = Palette.scheme(:vangogh)
      
    text_font = load_font "priv/fonts/Alegreya-Regular.otf", 48.0
    music_font = load_font "priv/fonts/BravuraText.otf", 48.0
   

  # - Flat: "\uE260"
  #- Natural: "\uE261"
  #- Sharp: "\uE262"
  #- Double sharp: "\uE263"
  #- Double flat: "\uE264"
    x = 100
    y = 100
    x2 = 130
    y2 = 90
    text text_font,  x,  y, "C", fill: rgb(0,0,0)
    text music_font, x2, y2, "\uE262", fill: rgb(0,0,0) 

    text text_font,  x2 + 40,  y, "D", fill: rgb(0,0,0)
    text music_font, x2 + 70, y2, "\uE260", fill: rgb(0,0,0) 

end
  