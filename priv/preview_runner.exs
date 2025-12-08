import Blendend.Draw

file = System.fetch_env!("PREVIEW_FILE")
out = System.get_env("PREVIEW_OUT") || Path.expand("tmp/preview.png", File.cwd!())

source =
  file
  |> File.read!()
  |> then(&("import Blendend.Draw\n" <> &1))

{result, _bindings} = Code.eval_string(source, [], file: file)

png =
  cond do
    match?({:ok, _bin}, result) ->
      case result do
        {:ok, bin} when is_binary(bin) ->
          case Base.decode64(bin) do
            {:ok, decoded} -> decoded
            _ -> bin
          end

        _ ->
          nil
      end

    File.exists?(out) ->
      File.read!(out)

    true ->
      nil
  end

if is_binary(png) do
  File.write!(out, png)
else
  IO.puts(
    "preview_runner: no PNG produced. Ensure your script returns draw/… base64 or writes to #{out}. Last result: #{inspect(result)}"
  )

  System.halt(1)
end
