defmodule PhoenixCache.Plug.Cache do
  import Plug.Conn

  # 6 minute
  @default_ttl 6 * 60

  def init(ttl \\ nil), do: ttl

  def call(conn, ttl \\ nil) do
    ttl = ttl || @default_ttl

    # only cache for GET request
    if conn.method == "GET" do
      key = "#{conn.request_path}-#{conn.query_string}"

      case PhoenixCache.Bucket.get(key) do
        {:ok, body} ->
          IO.puts("PLUG HIT")

          conn
          |> send_resp(200, body)
          |> halt

        _ ->
          IO.puts("PLUG MISS")

          conn
          |> assign(:ttl, ttl)
          |> register_before_send(&cache_before_send/1)
      end
    else
      conn
    end
  end

  def cache_before_send(conn) do
    # only cache if success
    if conn.status == 200 do
      key = "#{conn.request_path}-#{conn.query_string}"
      data = conn.resp_body
      PhoenixCache.Bucket.set(key, data, conn.assigns[:ttl] || @default_ttl)
      conn
    else
      conn
    end
  end
end
