
  - Create a glyph buffer with the text and the accidental separately, shape each with the appropriate font, and use get_text_metrics! to read their bounding boxes/advances. This
    gives you the offsets to align the two draws.

  Example approach:

  alias Blendend.Text.{Face, Font, GlyphBuffer}

  text_face  = Face.load!("YourText.otf")
  music_face = Face.load!("BravuraText.otf")
  text_font  = Font.create!(text_face, 24)
  music_font = Font.create!(music_face, 24)

  # Shape letter
  gb_letter =
    GlyphBuffer.new!()
    |> GlyphBuffer.set_utf8_text!("C")
    |> Font.shape!(text_font)

  letter_metrics = Font.get_text_metrics!(text_font, gb_letter)
  # letter_metrics["bbox_y0"], ["bbox_y1"] give tight bounds.

  # Shape sharp
  gb_acc =
    GlyphBuffer.new!()
    |> GlyphBuffer.set_utf8_text!("\uE262") # sharp
    |> Font.shape!(music_font)

  acc_metrics = Font.get_text_metrics!(music_font, gb_acc)

  # Decide offsets, e.g., baseline-align or center:
  acc_y = y + (letter_metrics["bbox_y0"] - acc_metrics["bbox_y0"]) - 2.0  # tweak to taste
  acc_x = x + letter_metrics["advance_x"] * 0.1                            # tweak

  text text_font,  x,      y, "C", fill: rgb(0,0,0)
  text music_font, acc_x, acc_y, "\uE262", fill: rgb(0,0,0)

  If you want the actual outlines of a single glyph, you can also call Font.get_glyph_outlines/4 once you have a glyph ID from a shaped run. To get a glyph ID, shape the glyph, then
  read it from a GlyphRun:

  {:ok, gr} = GlyphRun.new()
  {:ok, run} = GlyphBuffer.to_glyph_run(gb_acc, gr)   # if you have a helper; otherwise use the run from shaping
  glyph_id = run.glyphs |> hd()  # illustrative; adapt to your glyph run structure

  Given the library doesn’t expose a direct “text to glyph IDs” helper, shaping then using metrics is the simplest reliable way to align two fonts. Since your strings are tiny,
  computing these metrics once per symbol and caching offsets is cheap.


› Indeed I can use  Blendend.Text.GlyphRun.inspect_run!/1 to get all glyph ids from a run of a text "ABCDEFG", and cache them.
  I can do the same for all musical symbols that I want to use.


• Exactly—shape each string once, use Blendend.Text.GlyphRun.inspect_run!/1 to grab the glyph IDs you need, and cache those IDs. Then:

  - For metrics/placement: shape once, cache the run metrics (bbox/advance) alongside the glyph IDs, and reuse those offsets when drawing.
  - For outlines: call Font.get_glyph_outlines/4 with your cached glyph ID and a matrix to position/scale, avoiding repeated shaping.

  This keeps all the font work up front; drawing then just uses cached IDs/metrics and cheap outline calls.