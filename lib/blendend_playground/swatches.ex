defmodule BlendendPlayground.Swatches do
  @moduledoc """
  Render color swatches + labels using Blendend.
  """
  use Blendend.Draw

  @cols_per_row 6
  @box 180
  @pad 60

  @doc """
  Render swatches from a palette. Expects a map with `"colors"` or `"values"`,
  or a list of color maps like `%{"hex" => "#rrggbb", "label" => "name"}`.
  """
  # def render(%{"colors" => colors} = params) when is_list(colors), do: do_render(colors, params)
  # def render(%{"values" => colors} = params) when is_list(colors), do: do_render(colors, params)
  # def render(%{colors: colors} = params) when is_list(colors), do: do_render(colors, params)
  # def render(%{values: colors} = params) when is_list(colors), do: do_render(colors, params)
  def render(%BlendendPlayground.Palette.Scheme{} = scheme), do: do_render(scheme, [])
  # def render(colors) when is_list(colors), do: do_render(colors, %{})

  defp do_render(scheme, _params) do
    try do
      {width, height} = dims(scheme.colors)

      draw_result =
        draw width, height do
          if scheme.background do
            {r, g, b} = hex_to_rgb(scheme.background)
            clear(fill: rgb(r, g, b))
          else
            clear(fill: rgb(245, 245, 245))
          end

          font_path = priv_font_path("Alegreya-Regular.otf")
          monospace = load_font(font_path, 12)
          sans_bold = load_font(font_path, 20)

          label = scheme.name |> String.replace("_", " ") |> String.capitalize()

          text(sans_bold, width * 0.5, height * 0.1, "#{width} x #{height}", fill: rgb(0, 0, 0))
          text(sans_bold, width * 0.05, height * 0.1, label, fill: rgb(0, 0, 0))

          stroke_color =
            if scheme.stroke do
              IO.inspect(scheme.stroke)
              {r, g, b} = hex_to_rgb(scheme.stroke)
              rgb(r, g, b)
            else
              rgb(0, 0, 0)
            end

          Enum.with_index(scheme.colors, fn color, idx ->
            row = div(idx, @cols_per_row)
            col = rem(idx, @cols_per_row)
            x = @pad + col * @box
            y = @pad + row * @box
            {r, g, b} = hex_to_rgb(color)
            {h, s, v} = BlendendPlayground.Palette.hex_to_hsv(color)
            h_disp = round(h)
            s_disp = :erlang.float_to_binary(s, decimals: 2)
            v_disp = :erlang.float_to_binary(v, decimals: 2)
            rect(x, y, @box - @pad, @box - @pad, fill: rgb(r, g, b))

            text(monospace, x + 6, y + @box, "hsv: #{h_disp}, #{s_disp}, #{v_disp}",
              fill: stroke_color
            )

            text(monospace, x + 6, y + @box + 20, "rgb: #{r}, #{g}, #{b}", fill: stroke_color)
          end)
        end

      case draw_result do
        {:ok, b64} ->
          {:ok, b64}

        {:error, reason} ->
          IO.inspect(reason, label: "swatch_draw_error")
          {:error, reason}
      end
    rescue
      e ->
        IO.inspect(e, label: "swatch_render_exception")
        {:error, e}
    end
  end

  def hex_to_rgb(<<"#", h::binary-size(6)>>) do
    <<r::binary-size(2), g::binary-size(2), b::binary-size(2)>> = h
    {String.to_integer(r, 16), String.to_integer(g, 16), String.to_integer(b, 16)}
  end

  defp priv_font_path(file) do
    otp_path =
      case :code.priv_dir(:blendend_playground) do
        {:error, _} -> nil
        path -> Path.join(path, "fonts/#{file}")
      end

    project_path = Path.expand("priv/fonts/#{file}", File.cwd!())

    cond do
      otp_path && File.exists?(otp_path) -> otp_path
      File.exists?(project_path) -> project_path
      true -> raise "font file not found: #{file}"
    end
  end

  defp dims(scheme) do
    count = length(scheme)
    rows = div(count + @cols_per_row - 1, @cols_per_row)
    width = @cols_per_row * @box + @pad * 2
    height = rows * @box + @pad * 4
    {width, height}
  end
end
