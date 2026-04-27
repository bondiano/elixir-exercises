defmodule Hw3Phoenix.Blog.PostTag do
  use Ecto.Schema
  import Ecto.Changeset

  alias Hw3Phoenix.Blog.{Post, Tag}

  @primary_key false
  schema "posts_tags" do
    belongs_to(:post, Post, primary_key: true)
    belongs_to(:tag, Tag, primary_key: true)

    timestamps(type: :utc_datetime)
  end

  def changeset(post_tag, attrs) do
    post_tag
    |> cast(attrs, [:post_id, :tag_id])
    |> validate_required([:post_id, :tag_id])
    |> assoc_constraint(:post)
    |> assoc_constraint(:tag)
    |> unique_constraint([:post_id, :tag_id], name: :posts_tags_post_id_tag_id_index)
  end
end
