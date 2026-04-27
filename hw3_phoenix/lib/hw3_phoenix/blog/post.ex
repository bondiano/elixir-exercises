defmodule Hw3Phoenix.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias Hw3Phoenix.Blog.{PostTag, Tag}

  schema "posts" do
    field(:title, :string)
    field(:body, :string)

    has_many(:posts_tags, PostTag, on_delete: :delete_all)
    many_to_many(:tags, Tag, join_through: PostTag, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
    |> validate_length(:title, min: 1, max: 200)
  end
end
