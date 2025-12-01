# Treble staff with G clef and a key signature built from pitch-to-staff mapping.
# Choose `key` below to render any major key (sharps or flats).
draw 1200, 800 do
  clear(fill: rgb(255, 255, 255))

  face = font_face("priv/fonts/BravuraText.otf")
  music_font = font_create(face, 90.0)
  staff_scale = 24.0
  line_spacing = staff_scale * 0.5
  staff_center_y = 200.0
  staff_left = 80.0
  staff_width = 200.0
  staff_color = hsv(105, 0.1, 0.7)
  accidental_color = hsv(125, 0.1, 0.3)
  # 5 staff lines (middle line at staff_center_y).
  Enum.each(0..4, fn idx ->
    offset = (idx - 2) * line_spacing
    y = staff_center_y + offset
    line staff_left, y, staff_left + staff_width, y,
      stroke: staff_color,
      stroke_width: 2.0
  end)

  # G clef glyph (SMuFL E050).
  g_clef = <<0xE050::utf8>>
  clef_x = staff_left + staff_scale * 0.3
  clef_y = staff_center_y + staff_scale * 1.4
  text music_font, clef_x, clef_y, g_clef, fill: staff_color

  # Glyphs for accidentals.
  sharp = <<0xE262::utf8>>
  flat = <<0xE260::utf8>>
  double_flat =  <<0xE264::utf8>>
  double_sharp = <<0xE263::utf8>>
  # Positions (in half-line steps) relative to the middle line (B). Positive is upward.
  note_step = line_spacing / 2.0
  pitch_y_steps = %{
    b_flat: -6.0,
    b: -6.0,
    b_sharp: -6.0,
    b_double_flat: -6.0,
    c_flat: -5.0,
    c: -5.0,
    c_sharp: -5.0,
    d_flat: -4.0,
    d: -4.0,
    d_sharp: -4.0,
    e_flat: -3.0,
    e: -3.0,
    e_sharp: -3.0,
    f_flat: -9.0,
    f: -2.0,
    f_sharp: -2.0,
    f_double_sharp: -2.0,
    g_flat: -8.0,
    g: -1.0,
    g_sharp: -1.0,
    a_flat: -7.0,
    a: -7.0,
    a_sharp: -7.0
    
  }

  # Key definitions as pitch lists.
  keys = %{
    c_major: [],
    g_major: [:f_sharp],
    d_major: [:f_sharp, :c_sharp],
    a_major: [:f_sharp, :c_sharp, :g_sharp],
    e_major: [:f_sharp, :c_sharp, :g_sharp, :d_sharp],
    b_major: [:f_sharp, :c_sharp, :g_sharp, :d_sharp, :a_sharp],
    f_sharp_major: [:f_sharp, :c_sharp, :g_sharp, :d_sharp, :a_sharp, :e_sharp],
    c_sharp_major: [:f_sharp, :c_sharp, :g_sharp, :d_sharp, :a_sharp, :e_sharp, :b_sharp],
    g_sharp_major: [:c_sharp, :g_sharp, :d_sharp, :a_sharp, :e_sharp, :b_sharp, :f_double_sharp],
    f_major: [:b_flat],
    b_flat_major: [:b_flat, :e_flat],
    e_flat_major: [:b_flat, :e_flat, :a_flat],
    a_flat_major: [:b_flat, :e_flat, :a_flat, :d_flat],
    d_flat_major: [:b_flat, :e_flat, :a_flat, :d_flat, :g_flat],
    g_flat_major: [:b_flat, :e_flat, :a_flat, :d_flat, :g_flat, :c_flat],
    c_flat_major: [:b_flat, :e_flat, :a_flat, :d_flat, :g_flat, :c_flat, :f_flat],
    f_flat_major: [ :e_flat, :a_flat, :d_flat,  :g_flat, :c_flat, :f_flat, :b_double_flat]
  }

  key = :g_sharp_major
  accidentals = Map.fetch!(keys, key)
  accidental_spacing = line_spacing * 1.6
  key_start_x = clef_x + staff_scale * 2.2

  Enum.with_index(accidentals)
  |> Enum.each(fn {pitch, idx} ->
    y_steps = Map.fetch!(pitch_y_steps, pitch)
    pitch_name = Atom.to_string(pitch)
    #glyph = if String.ends_with?(pitch_name, "flat"), do: flat, else: sharp

    glyph = cond do
      String.ends_with?(pitch_name, "double_flat") -> double_flat
        String.ends_with?(pitch_name, "double_sharp") -> double_sharp
        String.ends_with?(pitch_name, "sharp") -> sharp
        true -> flat
    end

    
    text music_font,
      key_start_x + idx * accidental_spacing,
      staff_center_y - y_steps * note_step,
      glyph,
      fill: accidental_color
  end)

  label_font = load_font "priv/fonts/Alegreya-Regular.otf", 20.0
  text label_font,
    staff_left,
    staff_center_y + staff_scale * 4.0,
    "Key: #{Atom.to_string(key)} (treble)",
    fill: staff_color
end
