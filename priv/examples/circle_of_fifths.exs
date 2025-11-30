
  
  # Welcome to the Blendend playground.
  # Pick an example to load it, tweak
  # and see the preview update.
  # Save as a new file with "Filename" + "New"; 
  # To the edit the current file use "Update".
alias BlendendPlayground.Palette
alias BlendendPlayground.Demos.KeySignature
draw 800, 800 do
clear(fill: rgb(255, 255, 255))
    #palette = Palette.scheme(:vangogh)
      
  #  text_font = load_font "priv/fonts/Alegreya-Regular.otf", 48.0
  face = font_face("priv/fonts/BravuraText.otf")
  features = Blendend.Text.Face.feature_tags(face)
  ks = KeySignature.key_signature(:c_flat_major)
  IO.inspect(ks)
  music_font = font_create(face, 48.0)
  glyphs = KeySignature.glyph_bounds(music_font)
  #staff line "\uE01A"
 # gClef: \uE050
  # - Flat: "\uE260"
  #- Natural: "\uE261"
  #- Sharp: "\uE262"
  #- Double sharp: "\uE263"
  #- Double flat: "\uE264"

  

    x = 100 
    y = 100
   
  
  sharp = glyphs.sharp
  text music_font, x + sharp["bbox_x1"], y + 0, sharp.glyph, fill: rgb(0,0,0) 
  text music_font, x, y, sharp.glyph, fill: rgb(0,0,0) 


  
     
end
  