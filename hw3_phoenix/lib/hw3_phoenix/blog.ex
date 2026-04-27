defmodule Hw3Phoenix.Blog do
  @moduledoc """
  Контекст для работы с постами, тегами и связью многие-ко-многим между ними.

  Связь реализована через три таблицы: `posts`, `tags` и join-таблицу `posts_tags`.
  Каскадное удаление настроено на уровне БД (`on_delete: :delete_all`),
  поэтому при удалении поста или тега соответствующие строки в join-таблице
  удаляются автоматически.
  """

  import Ecto.Query

  alias Hw3Phoenix.Repo
  alias Hw3Phoenix.Blog.{Post, PostTag, Tag}

  def list_posts, do: Repo.all(Post) |> Repo.preload(:tags)

  def get_post!(id), do: Post |> Repo.get!(id) |> Repo.preload(:tags)

  def create_post(attrs, tags \\ []) do
    %Post{}
    |> Post.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:tags, tags)
    |> Repo.insert()
  end

  def update_post(%Post{} = post, attrs, tags) do
    post
    |> Repo.preload(:tags)
    |> Post.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:tags, tags)
    |> Repo.update()
  end

  def delete_post(%Post{} = post), do: Repo.delete(post)

  def list_tags, do: Repo.all(Tag)

  def get_tag!(id), do: Tag |> Repo.get!(id) |> Repo.preload(:posts)

  def upsert_tag(name) when is_binary(name) do
    %Tag{}
    |> Tag.changeset(%{name: name})
    |> Repo.insert(on_conflict: [set: [name: name]], conflict_target: :name, returning: true)
  end

  def upsert_tags(names) when is_list(names) do
    Enum.map(names, fn name ->
      {:ok, tag} = upsert_tag(name)
      tag
    end)
  end

  def delete_tag(%Tag{} = tag), do: Repo.delete(tag)

  def count_posts_tags do
    Repo.aggregate(PostTag, :count)
  end

  def list_posts_tags do
    PostTag
    |> order_by([pt], asc: pt.post_id, asc: pt.tag_id)
    |> Repo.all()
  end
end
