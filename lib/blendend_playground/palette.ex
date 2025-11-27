defmodule BlendendPlayground.Palette do
  @moduledoc """
  Small color palette helper for examples and demos.

  Provides named palettes, random picks, shuffling, and conversion to
  `Blendend.Style.Color` resources.
  """
  alias Blendend.Style.Color
  # @enforce_keys [:name, :colors]

  # defstruct [:name, :colors, :stroke, :background]

  # Palette set adapted from takawo (https://openprocessing.org/user/6533) —
  # used here to ease multicolor experimentation.
  # and from https://github.com/kgolid/chromotome/tree/master/palettes
  @scheme_palette %{
    benedictus: ["#F27EA9", "#366CD9", "#5EADF2", "#636E73", "#F2E6D8"],
    cross: ["#D962AF", "#58A6A6", "#8AA66F", "#F29F05", "#F26D6D"],
    demuth: ["#222940", "#D98E04", "#F2A950", "#BF3E21", "#F2F2F2"],
    hiroshige: ["#1B618C", "#55CCD9", "#F2BC57", "#F2DAAC", "#F24949"],
    hokusai: ["#074A59", "#F2C166", "#F28241", "#F26B5E", "#F2F2F2"],
    hokusai_blue: ["#023059", "#459DBF", "#87BF60", "#D9D16A", "#F2F2F2"],
    java: ["#632973", "#02734A", "#F25C05", "#F29188", "#F2E0DF"],
    kandinsky: ["#8D95A6", "#0A7360", "#F28705", "#D98825", "#F2F2F2"],
    monet: ["#4146A6", "#063573", "#5EC8F2", "#8C4E03", "#D98A29"],
    nizami: ["#034AA6", "#72B6F2", "#73BFB1", "#F2A30F", "#F26F63"],
    renoir: ["#303E8C", "#F2AE2E", "#F28705", "#D91414", "#F2F2F2"],
    vangogh: ["#424D8C", "#84A9BF", "#C1D9CE", "#F2B705", "#F25C05"],
    mono: ["#D9D7D8", "#3B5159", "#5D848C", "#7CA2A6", "#262321"],
    tsu_arcade: [
      "#251c12",
      "#cfc7b9",
      "#4aad8b",
      "#e15147",
      "#f3b551",
      "#cec8b8",
      "#d1af84",
      "#544e47"
    ],
    mem1: ["#20191b", "#67875c", "#f3cb4d", "#f2f5e3"],
    mem2: [
      "#001219",
      "#005f73",
      "#0a9396",
      "#94d2bd",
      "#e9d8a6",
      "#ee9b00",
      "#ca6702",
      "#bb3e03",
      "#ae2012",
      "#9b2226"
    ],
    mem3: ["#bab9a4", "#311f27", "#ff3931", "#007861"],
    mem4: ["#f94144", "#f3722c", "#f8961e", "#f9c74f", "#90be6d", "#43aa8b", "#577590"],
    mem5: ["#f4c172", "#7b8a56", "#363d4a", "#ff9369"],
    mem6: ["#af592c", "#f0e0c6", "#2a1f1d", "#7a999c", "#df4a33", "#475b62", "#fbaf3c"],
    mem7: ["#20342a", "#f74713", "#e9b4a6", "#686d2c"],
    mem8: ["#687d99", "#aa3a33", "#6c843e", "#705f84", "#dc383a", "#9c4257", "#fc9a1a"],
    mem9: ["#ef476f", "#ffd166", "#06d6a0", "#118ab2", "#073b4c"]
  }

  @doc """
  Returns a list of RGBA colors from a named scheme.

  Accepts atoms for the scheme name (e.g., `:hokusai_blue`).
  Use `scheme_names/0` to see available options. Passing `:random` picks a random scheme.

      iex> Blendend.Style.Color.scheme(:hokusai) |> length()
      5
      iex> Blendend.Style.Color.scheme(:random) |> is_list()
      true
  """
  @spec scheme(atom()) :: [Color.t()]
  def scheme(name) when is_atom(name) do
    key =
      case name do
        :random -> random_scheme_key()
        atom -> atom
      end

    palette =
      Map.fetch(@scheme_palette, key)
      |> case do
        {:ok, list} -> list
        :error -> Map.fetch!(@scheme_palette, random_scheme_key())
      end

    Enum.map(palette, &hex_to_color/1)
  end

  def scheme(name) do
    raise ArgumentError,
          "scheme/1 expects an atom scheme name such as :hokusai or :random, got: #{inspect(name)}"
  end

  @doc """
  Lists available scheme names as atoms.
  """
  @spec scheme_names() :: [atom()]
  def scheme_names, do: Map.keys(@scheme_palette)

  @doc """
  Converts a list of `#RRGGBB` hex strings into `Blendend.Style.Color` structs.

  Useful for palettes built from literal hex values.
  """
  @spec from_hex_list([String.t()]) :: [Color.t()]
  def from_hex_list(hex_list) when is_list(hex_list) do
    Enum.map(hex_list, &hex_to_color/1)
  end

  defp random_scheme_key, do: Enum.random(Map.keys(@scheme_palette))

  defp hex_to_color("#" <> <<r::binary-size(2), g::binary-size(2), b::binary-size(2)>>) do
    Color.rgb!(
      String.to_integer(r, 16),
      String.to_integer(g, 16),
      String.to_integer(b, 16)
    )
  end
end
