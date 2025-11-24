# Demonstrates transforming a glyph along its contour by flattening curves to lines.
# Samples the path to place jittered, rainbow "hair" strokes along the outline.

alias Blendend.Text.{Face, Font, GlyphBuffer, GlyphRun}
alias Blendend.{Canvas, Style, Matrix2D, Draw, Path}

defmodule BlendendPlayground.Demos.Hairy do
  # spacing: approx distance between samples along the path
  def draw_hair(path, {canvas_w, canvas_h}, spacing \\ 3.0, opts \\ []) do
    length = Keyword.get(opts, :length, 6.0)
    jitter = Keyword.get(opts, :jitter, 0.5)
    tuft_size = Keyword.get(opts, :tuft_size, 3)   # hairs per sample
    spread_deg = Keyword.get(opts, :spread_deg, 30.0)
    flat_tol = Keyword.get(opts, :flat_tol, 0.5)

    grad2 =
      Blendend.Style.Gradient.linear_from_stops({0.0, canvas_h * 0.5, canvas_w * 1.0, canvas_h * 0.5},
        [
          {0.00, rgb(0xFF, 0x00, 0x00)}, # Red
          {0.14, rgb(0xFF, 0x7F, 0x00)}, # Orange
          {0.29, rgb(0xFF, 0xFF, 0x00)}, # Yellow
          {0.43, rgb(0x80, 0xFF, 0x00)}, # Yellow-Green
          {0.57, rgb(0x00, 0xFF, 0x00)}, # Green
          {0.69, rgb(0x00, 0xFF, 0xFF)}, # Cyan
          {0.80, rgb(0x00, 0x00, 0xFF)}, # Blue
          {1.00, rgb(0xFF, 0x00, 0xFF)}  # Violet
        ])

    angle_spread = spread_deg * :math.pi() / 180.0

    path
    |> Path.flatten!(flat_tol)
    |> Path.segments()
    |> Path.sample(spacing)
    |> Enum.with_index()
    |> Enum.each(fn {{{x, y}, {nx, ny}}, idx} ->
      tx = ny
      ty = -nx

      base_len =
        length *
          (1.0 +
             jitter *
               (:math.sin(idx * 0.42) * 0.6 + (:rand.uniform() - 0.5) * 0.3))

      root_offset = (:rand.uniform() - 0.5) * (spacing * 0.6)
      bx = x + tx * root_offset
      by = y + ty * root_offset

      max_k = max(tuft_size - 1, 1)

      for j <- 0..(tuft_size - 1) do
        k = j - max_k / 2.0
        a = if tuft_size == 1, do: 0.0, else: k * (angle_spread / max_k)

        ca = :math.cos(a)
        sa = :math.sin(a)

        dir_x = nx * ca + tx * sa
        dir_y = ny * ca + ty * sa

        len_i = base_len * (0.8 + :rand.uniform() * 0.4)

        hx = bx + dir_x * len_i
        hy = by + dir_y * len_i

        line bx, by, hx, hy,
          stroke: grad2,
          stroke_width: 0.9,
          stroke_cap: :triangle
      end
    end)

    :ok
  end
end


width = 1000
height = 300
canvas_size = {width, height}

draw width, height do
  clear(fill: rgb(0, 0, 0))
  face = Face.load!("priv/fonts/Alegreya-Regular.otf")
  font = Font.create!(face, 80.0)

  gb =
    GlyphBuffer.new!()
    |> GlyphBuffer.set_utf8_text!("blendend")
    |> Font.shape!(font)

  run = GlyphRun.new!(gb)

  x0 = 60.0
  y0 = 240.0

  # 1) draw the glyph run normally
  # 2) build an outline path in the same coord system
  mtx =
    Matrix2D.identity!()
    |> Matrix2D.translate!(x0, y0)
    |> Matrix2D.scale!(3, 3)


  path =
    Path.new!()
    |> Font.get_glyph_run_outlines!(font, run, mtx)

  fill_path path, fill: rgb(255, 255, 255)

   # overlay hairs
  BlendendPlayground.Demos.Hairy.draw_hair(path,
    canvas_size,
    2,
    length: 3,
    jitter: 3,
    tuft_size: 4,
    spread_deg: 65.0)


end
