# This a draft for table drawing.
defmodule Tabela do
  @moduledoc false

  # alias Tabela.Layout
  alias Blendend.Text.Layout

  @row_data [
    %{id: 457, inserted_at: "2017-03-27 14:42:34.095202Z", key: "CEB0E055ECDF6028", message: ""},
    %{
      id: 326,
      inserted_at: "2017-03-27 14:42:34.097519Z",
      key: "CF67027F7235B88D",
      message: "short message: Hi!"
    },
    %{
      id: 756,
      inserted_at: "2017-03-27 14:42:34.097519Z",
      key: "DE016DFF477BEDDB",
      message: "middle message: Hello!"
    },
    %{
      id: 484,
      inserted_at: "2017-03-27 14:42:34.095202Z",
      key: "9194A82EF4BB0123",
      message: "long message: Hello, my dear!"
    },
    %{
      id: 1494,
      inserted_at: "2017-03-27 14:42:34.095202Z",
      key: "9194A82EF4BB0123",
      message: "long message: Hallo, meine Liebe! Herzlich willkommen!"
    }
  ]

  def text_bounding_box(font, text) do
    Layout.measure(font, text) |> get_in(["bbox_x1"])
  end

  def row_data, do: @row_data
end

alias Blendend.Text.{Face, Font, Layout}
face_file = "priv/fonts/MapleMono-Regular.otf"
face = Face.load!(face_file)
font = Font.create!(face, 20)
line_height = Layout.line_height(font)

cells = Tabela.row_data() |> Table.to_columns()

columns_in_order =
  cells
  |> Enum.sort_by(fn {key, _} -> to_string(key) end)

largest_cells =
  Enum.map(columns_in_order, fn {key, values} ->
    largest = Enum.max([key | values])
    {key, Tabela.text_bounding_box(font, "#{largest}")}
  end)

height = 800
origin_x = 10
origin_y = 10

# Compute total table width so all vertical lines fit on canvas
col_padding = 12

col_widths_with_padding =
  Enum.map(largest_cells, fn {k, w} -> {k, w + col_padding} end)

{col_lines, final_x} =
  col_widths_with_padding
  |> Enum.map_reduce(origin_x, fn {key, padded_width}, x ->
    next_x = x + padded_width
    {{key, x, next_x}, next_x}
  end)

total_width = final_x - origin_x
width = trunc(max(400, trunc(total_width) + origin_x * 2))

draw width, height do
  clear(fill: rgb(255, 255, 255))

  # Horizontal lines and table height
  {row_lines, table_height} =
    Tabela.row_data()
    |> Enum.map_reduce(origin_y, fn _, acc ->
      next = acc + line_height
      {next, next}
    end)

  # Top border
  line(origin_x, origin_y, origin_x + width, origin_y,
    stroke: rgb(0, 0, 255),
    stroke_width: 2.0
  )

  Enum.each(row_lines, fn y ->
    line(origin_x, y, origin_x + width, y,
      stroke: rgb(0, 0, 255),
      stroke_width: 2.0
    )
  end)

  # Vertical lines with accumulated width and labels
  # Left border + per-column lines + right border
  line(origin_x, origin_y, origin_x, origin_y + table_height,
    stroke: rgb(0, 0, 255),
    stroke_width: 2.0
  )

  Enum.each(col_lines, fn {label, x_start, x_end} ->
    text(font, x_start + 4, origin_y + line_height * 0.7, Atom.to_string(label))

    line(x_end, origin_y, x_end, origin_y + table_height,
      stroke: rgb(0, 0, 255),
      stroke_width: 2.0
    )
  end)

  # Right border (after last column)
  line(final_x, origin_y, final_x, origin_y + table_height,
    stroke: rgb(0, 0, 255),
    stroke_width: 2.0
  )

  # Cell contents
  Enum.with_index(Tabela.row_data())
  |> Enum.each(fn {row, row_idx} ->
    y = origin_y + line_height * (row_idx + 1) + line_height * 0.7

    Enum.each(col_lines, fn {key, x_start, _x_end} ->
      value = Map.get(row, key, "")
      text(font, x_start + 4, y, "#{value}")
    end)
  end)
end
