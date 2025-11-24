#archimedes's spirals
alias Blendend.Text.{Face, Font, GlyphBuffer, GlyphRun}
alias Blendend.{Canvas, Style, Matrix2D, Draw, Path}
draw 400, 400 do
      f = font "priv/fonts/Alegreya-Regular.otf", 60

       info = Font.metrics!(f)
  IO.inspect(info, label: "metrics")
  
      gb =
        GlyphBuffer.new!()
        |> GlyphBuffer.set_utf8_text!("hi!")
        |> Font.shape!(f)
  
  text_metrics = Font.get_text_metrics!(f,gb)
  IO.inspect(text_metrics, label: "text_metrics")

  run = GlyphRun.new!(gb)
  run_info = GlyphRun.info!(run)
  run_inspect = GlyphRun.inspect_run!(run)
  IO.inspect(run_info, label: "run_info")
  IO.inspect(run_inspect, label: "run_inspect")
  r1 = GlyphRun.slice!(run, 0, 1)

    m = Matrix2D.identity!()
    p = Path.new!()
    :ok = Font.get_glyph_run_outlines(f, run, m, p)

    count = Path.vertex_count!(p)
    0..(count - 1)
    |> Enum.each(fn i ->
       cmd = Path.vertex_at!(p, i)
      IO.inspect(cmd)
    end)
  
  Draw.get_canvas()
      |> GlyphRun.stroke!(
        f,
        100.0,
        120.0,
        run,
        stroke_color: Style.color(40, 224, 240)
      )
    
  Draw.get_canvas()
      |> GlyphRun.fill!(
        f,
        100.0,
        180.0,
        r1,
        color: Style.color(240, 44, 40)
      )
  
end

