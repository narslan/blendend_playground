# circle of fifths
alias BlendendPlayground.Palette

width = 1500
height = 1500
draw width, height do
  clear(fill: rgb(250, 250, 250, 250))

  #set_comp_op :pin_light                        
  music_font = load_font("priv/fonts/BravuraText.otf", 60)
  label_font = load_font("priv/fonts/Alegreya-Regular.otf",52.0)
  
  staff_scale = 23.0
  line_spacing = staff_scale * 0.5
  note_step = line_spacing / 2.0
  
  staff_color = hsv(125, 0.4, 0.8)
  accidental_color = hsv(125, 0.1, 0.3)
  clef_color = hsv(100, 1.0, 0.1, 250) 
  major_label_color = hsv(200, 0.9, 0.9, 200) 
  minor_label_color = hsv(0, 0.9, 0.6, 200)
    
  
  center_x = width/2
  center_y = height/2
  base_radius = 400.0
  
  # Glyphs for accidentals.
  sharp = <<0xE262::utf8>>
  flat = <<0xE260::utf8>>
  double_flat = <<0xE264::utf8>>
  double_sharp = <<0xE263::utf8>>
  # Accent ring to frame the key signatures.
  ring_outer = base_radius * 1.5
  ring_inner = base_radius * 0.9
  ring_grad =
    radial_gradient center_x, center_y, ring_outer,
                    center_x, center_y, ring_inner do
      add_stop 0.0, hsv(225, 0.1, 0.92, 200)
      add_stop 0.6, hsv(225, 0.2, 0.85, 180)
      add_stop 1.0, hsv(225, 0.25, 0.75, 140)
    end

  circle center_x, center_y, ring_outer, fill: ring_grad
  circle center_x, center_y, 0, fill: rgb(255, 255, 255)

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

  # Order to render, rotated so C major sits at the top
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

  accidental_spacing = line_spacing 
  clef_x_offset = staff_scale - 10
  key_start_offset = staff_scale * 2
  base_staff_width = 100.0

  Enum.with_index(key_order)
  |> Enum.each(fn {key, idx} ->
    accidentals = Map.fetch!(keys, key)
    # Width scales with accidental count.
    staff_width = base_staff_width + accidental_spacing * max(length(accidentals) - 1, 0)
    half_w = staff_width / 2.0
    acc_count = length(accidentals)

    angle = idx * (:math.pi() * 2) / length(key_order) - :math.pi() / 2
    ring_radius = base_radius * 1.2 + acc_count
    staff_center_x = center_x + ring_radius * :math.cos(angle)
    staff_center_y = center_y + ring_radius * :math.sin(angle)
    # Rotate the entire key group about its own center.
    m =
      matrix do
        translate(staff_center_x, staff_center_y)
        rotate(angle + :math.pi() / 2)
      end

    with_transform m do

      staff_left = -half_w
      staff_right = half_w

      Enum.each(0..4, fn line_idx ->
        offset = (line_idx - 2) * line_spacing
        y = offset
        line staff_left, y, staff_right, y,
          stroke: staff_color,
          stroke_width: 2.0
      end)

      # G clef.
      clef_x = staff_left + clef_x_offset
      clef_y = staff_scale * 1.4

      text music_font, clef_x, clef_y, <<0xE050::utf8>>, fill: clef_color

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
          -(y_steps * note_step),
          glyph,
          fill: accidental_color
      end)

      # Labels anchored to the rotated group so they share orientation.
      major_label =
        Atom.to_string(key)
        |> String.capitalize()
        |> String.replace("_", " ")
        |> String.replace("major", " ")

      minor_label = Enum.at(minor_key_order, idx)
      label_y = line_spacing * 4.5

      
      text label_font, -half_w + 24, label_y - line_spacing * 9.6, major_label, fill: major_label_color
      text label_font, -half_w + 34, label_y + line_spacing * 4.6, minor_label, fill: minor_label_color
    end
  end)
end
