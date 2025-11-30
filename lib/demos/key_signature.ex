defmodule BlendendPlayground.Demos.KeySignature do
  @moduledoc """
  Helpers to lay out key signatures (sequence of accidentals) for a 5-line staff.

  This works with Bravura/BravuraText (SMuFL) accidentals:
    * sharp:   "\\uE262"
    * flat:    "\\uE260"
    * natural: "\\uE261"

  We do not use precomposed key-signature glyphs; instead we place the individual
  accidentals at the conventional vertical positions for treble and bass clefs.

  Usage:
      alias BlendendPlayground.Demos.KeySignature
      ks = KeySignature.key_signature(:treble, :c_flat_major)
      # ks => [%{glyph: "\\uE260", x: 0,   y: 2}, ... seven flats]
      # Render by iterating and drawing each glyph (music font) at x+offset/y+offset.
  """
  alias Blendend.Text.{Font, GlyphBuffer}

  @type clef :: :treble | :bass
  @type key ::
          :c_flat_major
          | :g_flat_major
          | :d_flat_major
          | :a_flat_major
          | :e_flat_major
          | :b_flat_major
          | :f_major
          | :c_major
          | :g_major
          | :d_major
          | :a_major
          | :e_major
          | :b_major
          | :f_sharp_major
          | :c_sharp_major

  @sharp "\uE262"
  @flat "\uE260"
  @g_clef "\uE050"
  @staff_lines "\uE01A"

  @sharp_order_treble [4, 1, 5, 2, 6, 3, 7]
  @flat_order_treble [3, 6, 2, 5, 1, 4, 7]

  @staff_step 1.0
  @spacing 1.6

  @doc """
  Returns a list of %{glyph, x, y} for the given clef and key.
  y is in staff steps relative to the middle line; you can scale/translate as needed.
  """
  @spec key_signature(key) :: [%{glyph: String.t(), x: float(), y: float()}]
  def key_signature(key) do
    case key do
      :c_major -> []
      :f_major -> flats(1)
      :b_flat_major -> flats(2)
      :e_flat_major -> flats(3)
      :a_flat_major -> flats(4)
      :d_flat_major -> flats(5)
      :g_flat_major -> flats(6)
      :c_flat_major -> flats(7)
      :g_major -> sharps(1)
      :d_major -> sharps(2)
      :a_major -> sharps(3)
      :e_major -> sharps(4)
      :b_major -> sharps(5)
      :f_sharp_major -> sharps(6)
      :c_sharp_major -> sharps(7)
    end
  end

  defp sharps(n) when n >= 1 and n <= 7 do
    order = @sharp_order_treble

    Enum.take(order, n)
    |> Enum.with_index()
    |> Enum.map(fn {pos, idx} ->
      %{glyph: @sharp, x: idx * @spacing, y: pos_to_y(pos)}
    end)
  end

  defp flats(n) when n >= 1 and n <= 7 do
    order = @flat_order_treble

    Enum.take(order, n)
    |> Enum.with_index()
    |> Enum.map(fn {pos, idx} ->
      %{glyph: @flat, x: idx * @spacing, y: pos_to_y(pos)}
    end)
  end

  # Positions are numbered from bottom line = 1 upward; convert to y offset
  defp pos_to_y(pos), do: (pos - 3) * (@staff_step / 2)

  def glyph_bounds(font) do
    glyphs = %{sharp: @sharp, flat: @flat, g_clef: @g_clef, staff_lines: @staff_lines}

    Enum.reduce(glyphs, %{}, fn {k, g}, acc ->
      gb =
        GlyphBuffer.new!()
        |> GlyphBuffer.set_utf8_text!(g)
        |> Font.shape!(font)

      tm = Font.get_text_metrics!(font, gb)
      Map.put(acc, k, tm)
    end)
  end
end
