alias BlendendPlayground.Palette

width = 800
height = 800
draw width, height do
  
  
[c1, c2, c3, c4, c5] =
  Palette.palette_by_name("takamo.Hokusai Blue")
  |> Map.get(:colors, [])
  |> Palette.from_hex_list_rgb()
  |> Enum.map(fn {r, g, b} -> rgb(r, g, b) end)
  
  
  clear(fill: c1)

  #declare the corners the paralleogram
  x0 = 200
  x1 = 400
  x2 = 600
  y0 = 200
  y1 = 300
  y2 = 400
  
  p = path do
    add_polyline([
      {x0, y1},
      {x1, y0},
      {x2, y1},
      {x1, y2}])
    #close()
  end

  y_shift = 40
  baseline = 0
  stroke_path(p, stroke: c2, stroke_width: 10.0,  stroke_miter_limit: 14.0, stroke_alpha: 0.2)
    
  m2 = matrix do
    translate(0, baseline + y_shift)  
  end

  with_transform m2 do
    stroke_path(p, stroke: c5, stroke_width: 10.0, stroke_join: :miter_bevel, comp_op: :difference)
  end

  m3 = matrix do
    translate(0, baseline + 2 * y_shift)  
  end
  with_transform m3 do
    stroke_path(p, stroke: c4, stroke_width: 10.0, stroke_join: :bevel)
  end

  m4 = matrix do
    translate(0, baseline + 3 * y_shift)  
  end
  
  with_transform m4 do
    stroke_path(p, stroke: c3, stroke_width: 10.0, stroke_join: :round, stroke_cap: :round)
  end

  m5 = matrix do
    translate(0, baseline + 4 * y_shift)  
  end
  
  with_transform m5 do
    stroke_path(p, stroke: c2, stroke_width: 10.0, stroke_cap: :triangle  )
  end
  
  m6 = matrix do
    translate(0, baseline + 5 * y_shift)  
  end
  
  with_transform m6 do
    stroke_path(p, stroke: c4, stroke_width: 10.0, stroke_cap: :triangle_rev  )
  end

  label_font_size = 20.0
  label_font = load_font("priv/fonts/AlegreyaSans-Regular.otf", label_font_size)

  
end
  