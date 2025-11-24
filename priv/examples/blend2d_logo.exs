# The logo of blend2d. Shows overlapping radial and linear gradients to recreate the icon colors.
alias Blendend.Style.Gradient
draw 600, 600 do
 
grad = Gradient.radial_from_stops({90, 90, 90, 90, 90},
  [{0.0, rgb(0xFF, 0xFF, 0xFF)},
  {1.0, rgb(0xFF, 0x6F, 0x3F)}])
  
grad2 = Gradient.linear_from_stops({97, 97, 235, 235}, 
  [{0.0, rgb(0xFF, 0xFF, 0xFF)},
   {1.0, rgb(0x3F, 0x9F, 0xFF)}]) 

circle 90, 90, 87, fill: grad
comp_op :difference
round_rect 97, 97, 150, 150, 20, 20, fill: grad2
end
