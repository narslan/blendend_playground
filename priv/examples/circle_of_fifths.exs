# circle of fifths
draw 1500, 1500 do
  clear(fill: rgb(255, 255, 255))

  face = font_face("priv/fonts/BravuraText.otf")
  music_font = font_create(face, 90.0)
  staff_scale = 24.0
  line_spacing = staff_scale * 0.5
  note_step = line_spacing / 2.0
  staff_color = hsv(125, 0.4, 0.8)
  accidental_color = hsv(125, 0.1, 0.3)
  center_x = 760.0
  center_y = 700.0
  base_radius = 470.0

  # Glyphs for accidentals.
  sharp = <<0xE262::utf8>>
  flat = <<0xE260::utf8>>
  double_flat = <<0xE264::utf8>>
  double_sharp = <<0xE263::utf8>>

  # Positions (in half-line steps) relative to the middle line (B). Positive is upward.
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
    f_flat_major: [:e_flat, :a_flat, :d_flat, :g_flat, :c_flat, :f_flat, :b_double_flat]
  }

  # Order to render, rotated so C major sits at the top (poles hold fewer accidentals,
  # equator lands on keys with more accidentals).
  key_order = [
    :c_major,
    :g_major,
    :d_major,
    :a_major,
    :e_major,
    :b_major,
    :f_sharp_major,
    :c_sharp_major,
    :g_sharp_major,
    :f_flat_major,
    :c_flat_major,
    :g_flat_major,
    :d_flat_major,
    :a_flat_major,
    :e_flat_major,
    :b_flat_major,
    :f_major
  ]

  minor_key_order = [
    "a",
    "e",
    "b",
    "f#",
    "c#",
    "g#",
    "d#",
    "a#",
    "e#",
    "d flat",
    "a flat",
    "e flat",
    "b flat",
    "f",
    "c",
    "g",
    "d "
  ]

  accidental_spacing = line_spacing * 1.6
  clef_x_offset = staff_scale * 0.3
  key_start_offset = staff_scale * 2.2
  base_staff_width = 100.0

  Enum.with_index(key_order)
  |> Enum.each(fn {key, idx} ->
    accidentals = Map.fetch!(keys, key)
    # Width scales with accidental count.
    staff_width = base_staff_width + accidental_spacing * max(length(accidentals) - 1, 0)
    half_w = staff_width / 2.0
    acc_count = length(accidentals)

    angle = idx * (:math.pi() * 2) / length(key_order) - :math.pi() / 2
    ring_radius = base_radius + acc_count * 28.0
    staff_center_x = center_x + ring_radius * :math.cos(angle)
    staff_center_y = center_y + ring_radius * :math.sin(angle)

    staff_left = staff_center_x - half_w
    staff_right = staff_center_x + half_w

    # Staff lines.
    Enum.each(0..4, fn line_idx ->
      offset = (line_idx - 2) * line_spacing
      y = staff_center_y + offset
      line staff_left, y, staff_right, y,
        stroke: staff_color,
        stroke_width: 2.0
    end)

    # G clef.
    clef_x = staff_left + clef_x_offset
    clef_y = staff_center_y + staff_scale * 1.4
    text music_font, clef_x, clef_y, <<0xE050::utf8>>, fill: rgb(:random)

    # Accidentals for this key.
    Enum.with_index(accidentals)
    |> Enum.each(fn {pitch, a_idx} ->
      y_steps = Map.fetch!(pitch_y_steps, pitch)
      pitch_name = Atom.to_string(pitch)

      glyph =
        cond do
          String.ends_with?(pitch_name, "double_flat") -> double_flat
          String.ends_with?(pitch_name, "double_sharp") -> double_sharp
          String.ends_with?(pitch_name, "sharp") -> sharp
          true -> flat
        end

      text music_font,
        clef_x + key_start_offset + a_idx * accidental_spacing,
        staff_center_y - y_steps * note_step,
        glyph,
        fill: accidental_color
    end)

    # Label to the right of the staff.
    label_font = load_font "priv/fonts/Alegreya-Regular.otf", 38.0
    # Major label.
    text label_font,
      staff_left ,
      staff_center_y + 95.0,
      Atom.to_string(key)|> String.capitalize |> String.replace("_", " ") |> String.replace("major", " "),
      fill: accidental_color
    # Minor partner.
    text label_font,
      staff_left ,
      staff_center_y + 128.0,
      Enum.at(minor_key_order, idx),
      fill: accidental_color
  end)
end
