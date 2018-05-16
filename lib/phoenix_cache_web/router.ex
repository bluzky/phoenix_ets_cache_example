defmodule PhoenixCacheWeb.Router do
  use PhoenixCacheWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(PhoenixCache.Plug.Cache, 100)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", PhoenixCacheWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    resources("/posts", PostController)
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhoenixCacheWeb do
  #   pipe_through :api
  # end
end
