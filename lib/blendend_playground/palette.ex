defmodule BlendendPlayground.Palette.Scheme do
  @enforce_keys [:name, :colors]
  defstruct [:name, :colors, :stroke, :background, :source]
end

defmodule BlendendPlayground.Palette do
  @moduledoc """
  Palette helper with ETS-backed storage.

  Palettes are loaded from `priv/palettes/*.json` at startup.
  Each palette carries a `source` tag so the frontend can filter by source then scheme.
  """

  alias BlendendPlayground.Palette.Scheme
  alias Blendend.Style.Color

  @table :palette_cache

  @doc """
  Initialize ETS palette cache. Safe to call multiple times.
  """
  def init_cache do
    table = :ets.whereis(@table)

    if table == :undefined do
      :ets.new(@table, [:set, :public, :named_table, read_concurrency: true])
    end

    :ets.delete_all_objects(@table)

    load_palettes()
    |> Enum.each(fn %Scheme{name: name, source: source} = scheme ->
      key = {source || "unknown", name}
      :ets.insert(@table, {key, scheme})
    end)

    :ok
  end

  @doc """
  Returns a list of `Blendend.Style.Color` structs for a scheme.
  """
  @spec scheme(atom() | String.t(), String.t() | nil) :: [Color.t()]
  def scheme(name, source \\ nil) do
    scheme_hex(name, source) |> Enum.map(&hex_to_color/1)
  end

  @doc """
  Returns a list of hex strings for a scheme.
  """
  @spec scheme_hex(atom() | String.t(), String.t() | nil) :: [String.t()]
  def scheme_hex(name, source \\ nil) do
    palette_lookup!(name, source).colors
  end

  @doc """
  Returns palette metadata.
  """
  @spec scheme_info(atom() | String.t(), String.t() | nil) :: Scheme.t()
  def scheme_info(name, source \\ nil) do
    palette_lookup!(name, source)
  end

  @doc """
  Lists available scheme names. If `source` is provided, filters by source.
  """
  @spec scheme_names(String.t() | nil) :: [String.t()]
  def scheme_names(source \\ nil) do
    ensure_cache()

    :ets.match_object(@table, {{source || :_, :_}, :_})
    |> Enum.map(fn {{src, name}, _} -> {src, name} end)
    |> Enum.filter(fn {src, _} -> is_nil(source) or src == source end)
    |> Enum.map(fn {_src, name} -> name end)
    |> Enum.uniq()
  end

  @doc """
  Lists available sources (strings).
  """
  @spec scheme_sources() :: [String.t()]
  def scheme_sources do
    ensure_cache()

    :ets.match_object(@table, {{:_, :_}, :_})
    |> Enum.map(fn {{src, _}, _} -> src end)
    |> Enum.uniq()
  end

  @doc """
  Returns map of source => [palette names].
  """
  @spec palettes_by_source() :: %{String.t() => [String.t()]}
  def palettes_by_source do
    ensure_cache()

    :ets.match_object(@table, {{:_, :_}, :_})
    |> Enum.reduce(%{}, fn {{src, name}, _}, acc ->
      Map.update(acc, src, [name], &[name | &1])
    end)
    |> Enum.into(%{}, fn {src, names} -> {src, Enum.uniq(names) |> Enum.sort()} end)
  end

  @doc """
  Converts a list of hex strings into `Blendend.Style.Color` structs.
  """
  @spec from_hex_list([String.t()]) :: [Color.t()]
  def from_hex_list(hex_list) when is_list(hex_list) do
    Enum.map(hex_list, &hex_to_color/1)
  end

  @doc """
  Returns HSV triples `{h, s, v}` for a scheme.
  """
  @spec scheme_hsv(atom() | String.t(), String.t() | nil) ::
          [{number(), number(), number()}]
  def scheme_hsv(name, source \\ nil) do
    palette_lookup!(name, source).colors |> Enum.map(&hex_to_hsv/1)
  end

  @doc """
  Converts a list of hex strings into HSV triples `{h, s, v}`.
  """
  @spec from_hex_list_hsv([String.t()]) :: [{number(), number(), number()}]
  def from_hex_list_hsv(hex_list) when is_list(hex_list) do
    Enum.map(hex_list, &hex_to_hsv/1)
  end

  def hex_to_hsv("#" <> <<r::binary-size(2), g::binary-size(2), b::binary-size(2)>>) do
    r = String.to_integer(r, 16) / 255.0
    g = String.to_integer(g, 16) / 255.0
    b = String.to_integer(b, 16) / 255.0

    maxc = max(r, max(g, b))
    minc = min(r, min(g, b))
    delta = maxc - minc

    h =
      cond do
        delta == 0.0 -> 0.0
        maxc == r -> 60.0 * :math.fmod((g - b) / delta, 6.0)
        maxc == g -> 60.0 * ((b - r) / delta + 2.0)
        true -> 60.0 * ((r - g) / delta + 4.0)
      end
      |> normalize_hue()

    s = if maxc == 0.0, do: 0.0, else: delta / maxc
    v = maxc

    {h, s, v}
  end

  def hex_to_rgb("#" <> <<r::binary-size(2), g::binary-size(2), b::binary-size(2)>>) do
    {String.to_integer(r, 16), String.to_integer(g, 16), String.to_integer(b, 16)}
  end

  defp random_scheme_key do
    ensure_cache()

    case :ets.tab2list(@table) do
      [] -> raise ArgumentError, "no palettes available"
      list -> list |> Enum.random() |> elem(1) |> Map.get(:name)
    end
  end

  defp normalize_key(:random), do: random_scheme_key()
  defp normalize_key(atom) when is_atom(atom), do: Atom.to_string(atom)
  defp normalize_key(<<_::binary>> = str), do: str

  defp palette_lookup!(name, source) do
    ensure_cache()

    name = normalize_key(name)
    src = source || :_

    case :ets.match_object(@table, {{src, name}, :_}) do
      [] when source != nil ->
        raise ArgumentError, "palette not found: #{inspect({source, name})}"

      [] ->
        case :ets.match_object(@table, {{:_, name}, :_}) do
          [] -> raise ArgumentError, "palette not found: #{inspect(name)}"
          [{{_, _}, scheme} | _] -> scheme
        end

      [{{_, _}, scheme} | _] ->
        scheme
    end
  end

  defp hex_to_color("#" <> <<r::binary-size(2), g::binary-size(2), b::binary-size(2)>>) do
    Color.rgb!(
      String.to_integer(r, 16),
      String.to_integer(g, 16),
      String.to_integer(b, 16)
    )
  end

  defp normalize_hue(h) when h < 0.0, do: h + 360.0
  defp normalize_hue(h), do: h

  defp ensure_cache do
    case :ets.whereis(@table) do
      :undefined -> init_cache()
      _ -> :ok
    end
  end

  defp load_palettes do
    priv_palette_files()
    |> Enum.flat_map(&load_file_palettes/1)
  end

  defp priv_palette_files do
    app_paths =
      case :code.priv_dir(:blendend_playground) do
        {:error, _} -> []
        dir when is_list(dir) or is_binary(dir) -> [dir]
      end

    project_priv = Path.expand("priv", File.cwd!())
    search_roots = Enum.uniq([project_priv | app_paths])

    search_roots
    |> Enum.flat_map(fn root ->
      Path.wildcard(Path.join([root, "palettes", "*.json"]))
    end)
  end

  defp load_file_palettes(path) do
    with {:ok, body} <- File.read(path),
         {:ok, data} <- JSON.decode(body) do
      normalize_palettes(data, Path.basename(path, ".json"))
    else
      err ->
        IO.warn("failed to load palette file #{path}: #{inspect(err)}")
        []
    end
  end

  defp normalize_palettes(data, default_source)

  defp normalize_palettes(data, default_source) when is_list(data) do
    Enum.flat_map(data, fn
      %{"colors" => colors} = m when is_list(colors) ->
        name = Map.get(m, "name", "palette_#{System.unique_integer([:positive])}")
        source = Map.get(m, "source", default_source)

        [
          %Scheme{
            name: name,
            colors: colors,
            background: Map.get(m, "background"),
            stroke: Map.get(m, "stroke"),
            source: source
          }
        ]

      _ ->
        []
    end)
  end

  defp normalize_palettes(data, default_source) when is_map(data) do
    data
    |> Enum.flat_map(fn {name, value} ->
      cond do
        is_list(value) ->
          [
            %Scheme{
              name: to_string(name),
              colors: value,
              source: default_source
            }
          ]

        is_map(value) ->
          [
            %Scheme{
              name: to_string(name),
              colors: Map.get(value, "colors", []),
              background: Map.get(value, "background"),
              stroke: Map.get(value, "stroke"),
              source: Map.get(value, "source", default_source)
            }
          ]

        true ->
          []
      end
    end)
  end

  defp normalize_palettes(_data, _default_source), do: []
end
