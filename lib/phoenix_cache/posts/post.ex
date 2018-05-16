defmodule PhoenixCache.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset


  schema "posts" do
    field :content, :string
    field :summary, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :summary, :content])
    |> validate_required([:title, :summary, :content])
  end
end
