defmodule PhoenixCacheWeb.PostController do
  use PhoenixCacheWeb, :controller

  alias PhoenixCache.Posts
  alias PhoenixCache.Posts.Post

  def index(conn, _params) do
    posts =
      case PhoenixCache.Bucket.get("posts-page1") do
        {:ok, posts} ->
          IO.puts("HIT")
          posts

        {:error, _} ->
          IO.puts("MISS")
          posts = Posts.list_posts()
          PhoenixCache.Bucket.set("posts-page1", posts)
          posts
      end

    render(conn, "index.html", posts: posts)
  end

  def new(conn, _params) do
    changeset = Posts.change_post(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    case Posts.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post =
      case PhoenixCache.Bucket.get("posts-#{id}") do
        {:ok, post} ->
          IO.puts("HIT")
          post

        {:error, _} ->
          IO.puts("MISS")
          post = Posts.get_post!(id)

          # cache 60s
          PhoenixCache.Bucket.set("posts-#{id}", post, 60)
          post
      end

    render(conn, "show.html", post: post)
  end

  def edit(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    changeset = Posts.change_post(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(id)

    case Posts.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    {:ok, _post} = Posts.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: post_path(conn, :index))
  end
end
