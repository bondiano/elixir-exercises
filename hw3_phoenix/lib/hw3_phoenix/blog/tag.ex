defmodule Hw3Phoenix.Blog.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  alias Hw3Phoenix.Blog.{Post, PostTag}

  schema "tags" do
    field(:name, :string)

    has_many(:posts_tags, PostTag, on_delete: :delete_all)
    many_to_many(:posts, Post, join_through: PostTag, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 50)
    |> unique_constraint(:name)
  end
end
