defmodule BlendendPlayground.Swatches do
  @moduledoc """
  Render color swatches + labels using Blendend.
  """
  use Blendend.Draw

  @cols_per_row 6
  @box 90
  @pad 12

  def render(colors) when is_list(colors) do
    try do
      {width, height} = dims(colors)

      {:ok, b64} =
        draw width, height do
          clear(fill: rgb(245, 245, 245))

          Enum.with_index(colors, fn color, idx ->
            row = div(idx, @cols_per_row)
            col = rem(idx, @cols_per_row)
            x = @pad + col * @box
            y = @pad + row * @box
            [r, g, b, a] = normalize_rgba(color)
            label = Map.get(color, "label", Map.get(color, :label, ""))

            rect(x, y, @box - @pad, @box - @pad, fill: rgb(r, g, b, a))

            if font = default_font() do
              text(font, x + 6, y + @box - 20, to_string(label), fill: rgb(0, 0, 0))
            end
          end)
        end

      {:ok, b64}
    rescue
      e -> {:error, e}
    end
  end

  defp normalize_rgba(%{"rgb" => [r, g, b, a]}), do: [r, g, b, a]
  defp normalize_rgba(%{"rgb" => [r, g, b]}), do: [r, g, b, 255]
  defp normalize_rgba(%{rgb: [r, g, b, a]}), do: [r, g, b, a]
  defp normalize_rgba(%{rgb: [r, g, b]}), do: [r, g, b, 255]
  defp normalize_rgba(%{"hex" => hex}), do: hex_to_rgba(hex)
  defp normalize_rgba(%{hex: hex}), do: hex_to_rgba(hex)
  defp normalize_rgba(_), do: [0, 0, 0, 255]

  defp hex_to_rgba(<<"#", h::binary-size(6)>>) do
    <<r::binary-size(2), g::binary-size(2), b::binary-size(2)>> = h
    [String.to_integer(r, 16), String.to_integer(g, 16), String.to_integer(b, 16), 255]
  end

  defp dims(colors) do
    count = max(length(colors), 1)
    rows = div(count + @cols_per_row - 1, @cols_per_row)
    width = @cols_per_row * @box + @pad * 2
    height = rows * @box + @pad * 2
    {width, height}
  end

  defp default_font do
    case :persistent_term.get({__MODULE__, :font}, :undefined) do
      :undefined ->
        case fallback_font_path() do
          nil ->
            :persistent_term.put({__MODULE__, :font}, nil)
            nil

          path ->
            face = Blendend.Text.Face.load!(path)
            font = Blendend.Text.Font.create!(face, 16)
            :persistent_term.put({__MODULE__, :font}, font)
            font
        end

      font ->
        font
    end
  end

  defp fallback_font_path do
    candidates =
      [
        "static/fonts/alegreya/Alegreya-Regular.otf",
        "static/fonts/Alegreya/Alegreya-Bold.ttf",
        "static/fonts/alegreya_sans/Alegreya-Sans.ttf"
      ]
      |> Enum.map(fn fpath -> Path.join(:code.priv_dir(:blendend_playground), fpath) end)

    Enum.find(candidates, &File.exists?/1)
  end
end
