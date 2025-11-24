# Displays a single glyph as both filled text 
# and extracted outlines, color-coding vertex commands.
# Uses scaling/translation to highlight 
# how the matrix affects the traced path.
alias Blendend.Text.{Face, Font, GlyphBuffer, GlyphRun}
alias Blendend.{Canvas, Style, Matrix2D, Draw, Path}
draw 800, 800 do
  # 1) Background
  clear(fill: rgb(236, 246, 252))

  text_string = "λ"

  # 2) Load font as usual
  face_alegreya = Blendend.Text.Face.load!("priv/fonts/Alegreya-Regular.otf")
  fonta_big = Blendend.Text.Font.create!(face_alegreya, 180.0)
  fonta_small = Blendend.Text.Font.create!(face_alegreya, 18.0)
  
  # 3) Draw normal text for reference
  baseline_x = 200.0
  baseline_y = 600.0

 
  # 4) Shape the text into a GlyphRun
  gb =
    Blendend.Text.GlyphBuffer.new!()
    |> Blendend.Text.GlyphBuffer.set_utf8_text!(text_string)
    |> Blendend.Text.Font.shape!(fonta_big)

  run = Blendend.Text.GlyphRun.new!(gb)

  # 5) Build a transform for the outlines:
  #    - translate so the text sits roughly at (40, baseline_y)
  #    - rotate a little so it’s obvious the matrix is applied
  m =
    Blendend.Matrix2D.identity!()
    |> Blendend.Matrix2D.translate!(baseline_x, baseline_y)
    |> Blendend.Matrix2D.scale!(4, 4)

  # 6) Extract glyph outlines into a Path
  path = Blendend.Path.new!()
  :ok = Blendend.Text.Font.get_glyph_run_outlines(fonta_big, run, m, path)

  # 7) Stroke the outlines in a different color
  outlines_color = rgb(200, 230, 30, 255)

  stroke_path path, fill: outlines_color

  # 8) Inspect the path vertices in the log
  count = Blendend.Path.vertex_count!(path)
  style_close = rgb(0, 255, 0)
  style_move  = rgb(255, 0, 0)
  style_line  = rgb(255, 165, 0)
  style_cubic = rgb(0, 0, 255)
  style_quad  = rgb(90, 90, 255)
  0..(count - 1)
  |> Enum.each(fn i ->
    {cmd, x, y }= Blendend.Path.vertex_at!(path, i)
    case cmd do
      :close ->    circle x, y, 5, fill: style_close
      :move_to ->  circle x, y, 6, stroke: style_move
      :line_to ->  triangle x, y, 6, fill: style_line
      :cubic_to -> circle x, y, 2, fill: style_cubic
      :quad_to ->  circle x, y, 3, fill: style_quad
    end
  end)
text fonta_small, 600, 200, "close" 
text fonta_small, 600, 220, "move_to" 
text fonta_small, 600, 240, "line_to" 
text fonta_small, 600, 260, "cubic_to" 
text fonta_small, 600, 280, "quad_to"   
circle 680, 195, 5, fill: style_close
circle 680, 215, 6, stroke: style_move
triangle 680, 235, 6, fill: style_line
circle 680, 255, 2, fill: style_cubic
circle 680, 275, 3, fill: style_quad 
end
