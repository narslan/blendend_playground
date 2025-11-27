# https://openprocessing.org/sketch/1215612
# exercise ground with shadows and difference composition operator 
alias BlendendPlayground.Palette
use BlendendPlayground.Calculation.Macros
use BlendendPlayground.Palette.Macros
width = 800
height = 800
draw width, height do

clear(fill: rgb(255, 255, 255))
  
  palette = from_hex_list ["#FFFFFF", "#9da3a4", "#ffdbda", "#000000"]
    cols = 3
    rows = cols
  cell_w = width / cols
  cell_h = height / rows

  for j <- 0 .. (rows - 1) do

    for i <- 0 .. (cols - 1) do

       x = i * cell_w
       y = j * cell_h
       d = rand_between cell_w / 2.3 , cell_w / 1.9
      comp_op :difference
      

      #drawingContext.shadowOffsetX = 10;
      #drawingContext.shadowOffsetY = 10;
      #drawingContext.shadowBlur = 60;
      #drawingContext.shadowColor = "#FFFFFC";

      if :rand.uniform < 0.5 do
        set_fill_style(Enum.random(palette))
        
        cp = Blendend.Path.new!() 
        |> Blendend.Path.add_circle!(x, y, d * 1.3)

      fill_path cp
       shadow_path(cp, 10, 10, 2,
         mode: :fill, 
         fill: rgb(0xFF, 0xFF, 0xFC)) 
      
      else

        set_fill_style(Enum.random(palette))
        
        rr = Blendend.Path.new!() 
        |> Blendend.Path.add_round_rect!(x + cell_w / 2, y + cell_h / 2, d ,d, Enum.random(10..30), Enum.random(10..30))

       fill_path rr
       shadow_path(rr, 10, 10, 3,
         mode: :fill, 
         fill: rgb(0xFF, 0xFF, 0xFC)) 
      
		
      end
      
  end 
  end 
  end
  