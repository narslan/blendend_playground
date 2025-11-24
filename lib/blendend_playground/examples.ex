defmodule BlendendPlayground.Examples do
  @examples_dir Path.join(:code.priv_dir(:blendend_playground), "examples")

  @doc """
  List all examples in the examples directory.
  """
  def all() do
    File.mkdir_p!(@examples_dir)

    case File.ls(@examples_dir) do
      {:ok, files} ->
        files
        |> Enum.filter(&String.ends_with?(&1, ".exs"))
        |> Enum.map(&String.trim_trailing(&1, ".exs"))
        |> Enum.sort()

      _ ->
        []
    end
  end

  @doc """
  Read the example.
  """
  def get(name) do
    path = Path.join(@examples_dir, name <> ".exs")
    if File.exists?(path), do: File.read!(path), else: nil
  end

  def save(name, code) when is_binary(name) and is_binary(code) do
    File.mkdir_p!(@examples_dir)
    path = Path.join(@examples_dir, name <> ".exs")

    if File.exists?(path) do
      {:error, :already_exists}
    else
      case File.write(path, code) do
        :ok -> {:ok, path}
        {:error, reason} -> {:error, reason}
      end
    end
  end

  def update(name, code) when is_binary(name) and is_binary(code) do
    File.mkdir_p!(@examples_dir)
    path = Path.join(@examples_dir, name <> ".exs")

    if File.exists?(path) do
      case File.write(path, code, [:write]) do
        :ok -> :ok
        {:error, reason} -> {:error, reason}
      end
    else
      {:error, :not_found}
    end
  end
end
