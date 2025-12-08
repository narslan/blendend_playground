defmodule BlendendPlayground.HttpPreview do
  @moduledoc """
  Tiny HTTP endpoint to render an example file into a PNG for editor previews.

  Starts a Plug.Cowboy server on port 4711 and exposes:
    POST /render with form body: file=/absolute/path/to/example.exs

  On success writes PNG to `tmp/preview.png` (relative to project root) and returns:
    200 {"ok": true, "png": "tmp/preview.png"}
  On error returns 422 with {"ok": false, "error": "..."}.
  """

  use Plug.Router

  plug(:match)
  plug(Plug.Parsers, parsers: [:urlencoded, :multipart], pass: ["*/*"])
  plug(:dispatch)

  @png_out Path.expand("tmp/preview.png", File.cwd!())

  post "/render" do
    case conn.params do
      %{"file" => path} ->
        render_file(conn, path)

      _ ->
        send_resp(conn, 400, encode(%{ok: false, error: "missing file param"}))
    end
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  def start_link(_opts) do
    Plug.Cowboy.http(__MODULE__, [], port: 4711)
  end

  defp render_file(conn, path) do
    case File.exists?(path) do
      false ->
        send_resp(conn, 404, encode(%{ok: false, error: "file not found"}))

      true ->
        case do_render(path) do
          :ok ->
            body = encode(%{ok: true, png: @png_out})
            send_resp(conn, 200, body)

          {:error, reason} ->
            send_resp(conn, 422, encode(%{ok: false, error: reason}))
        end
    end
  end

  defp do_render(path) do
    File.mkdir_p!(Path.dirname(@png_out))

    {out, status} =
      System.cmd(
        "mix",
        ["run", "--no-start", "--no-deps-check", "--no-compile", "priv/preview_runner.exs"],
        env: [{"MIX_ENV", "dev"}, {"PREVIEW_FILE", path}, {"PREVIEW_OUT", @png_out}],
        stderr_to_stdout: true,
        cd: File.cwd!()
      )

    cond do
      status == 0 and File.exists?(@png_out) ->
        :ok

      status == 0 ->
        {:error, "rendered without png output: #{@png_out} missing"}

      true ->
        {:error, String.trim(out)}
    end
  end

  defp encode(map) do
    JSON.encode!(map)
  end
end
