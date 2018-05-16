defmodule PhoenixCacheWeb.PageController do
  use PhoenixCacheWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
