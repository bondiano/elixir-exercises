defmodule Hw3Phoenix.BlogTest do
  use Hw3Phoenix.DataCase, async: true

  alias Hw3Phoenix.Blog
  alias Hw3Phoenix.Blog.{Post, PostTag, Tag}

  describe "many-to-many associations" do
    test "creating a post with tags inserts rows into all three tables" do
      tags = Blog.upsert_tags(["elixir", "ecto"])

      assert {:ok, %Post{} = post} =
               Blog.create_post(%{title: "Hello", body: "World"}, tags)

      post = Repo.preload(post, :tags)
      assert length(post.tags) == 2
      assert Enum.map(post.tags, & &1.name) |> Enum.sort() == ["ecto", "elixir"]

      assert Blog.count_posts_tags() == 2
      assert Repo.aggregate(Post, :count) == 1
      assert Repo.aggregate(Tag, :count) == 2
    end

    test "a single tag can be attached to multiple posts" do
      [elixir] = Blog.upsert_tags(["elixir"])

      {:ok, post1} = Blog.create_post(%{title: "Post 1", body: "Body 1"}, [elixir])
      {:ok, post2} = Blog.create_post(%{title: "Post 2", body: "Body 2"}, [elixir])

      tag = Blog.get_tag!(elixir.id)
      post_ids = Enum.map(tag.posts, & &1.id) |> Enum.sort()
      assert post_ids == Enum.sort([post1.id, post2.id])
    end

    test "updating a post via put_assoc replaces rows in the join table" do
      [elixir, ecto, phoenix] = Blog.upsert_tags(["elixir", "ecto", "phoenix"])

      {:ok, post} = Blog.create_post(%{title: "Hi", body: "Body"}, [elixir, ecto])
      assert Blog.count_posts_tags() == 2

      {:ok, updated} = Blog.update_post(post, %{title: "Hi"}, [phoenix])
      updated = Repo.preload(updated, :tags, force: true)

      assert Enum.map(updated.tags, & &1.name) == ["phoenix"]
      assert Blog.count_posts_tags() == 1
    end
  end

  describe "cascade deletion" do
    test "deleting a post removes join-table rows but keeps tags" do
      tags = Blog.upsert_tags(["elixir", "ecto"])
      {:ok, post} = Blog.create_post(%{title: "T", body: "B"}, tags)

      assert Blog.count_posts_tags() == 2
      assert Repo.aggregate(Tag, :count) == 2

      {:ok, _} = Blog.delete_post(post)

      assert Blog.count_posts_tags() == 0
      assert Repo.aggregate(Post, :count) == 0

      assert Repo.aggregate(Tag, :count) == 2,
             "tags must survive after a post is deleted"
    end

    test "deleting a tag removes join-table rows but keeps posts" do
      [elixir, ecto] = Blog.upsert_tags(["elixir", "ecto"])

      {:ok, _post1} = Blog.create_post(%{title: "P1", body: "B1"}, [elixir, ecto])
      {:ok, _post2} = Blog.create_post(%{title: "P2", body: "B2"}, [elixir])

      assert Blog.count_posts_tags() == 3

      {:ok, _} = Blog.delete_tag(elixir)

      assert Blog.count_posts_tags() == 1,
             "only the Post1 <-> ecto link should remain"

      assert Repo.aggregate(Post, :count) == 2
      assert Repo.aggregate(Tag, :count) == 1
    end

    test "cascade works at the DB level, without Ecto schema involvement" do
      tags = Blog.upsert_tags(["elixir"])
      {:ok, post} = Blog.create_post(%{title: "Raw", body: "SQL"}, tags)
      [tag] = tags

      assert Blog.count_posts_tags() == 1

      {:ok, _} = Repo.query("DELETE FROM posts WHERE id = $1", [post.id])

      assert Blog.count_posts_tags() == 0
      assert Repo.get(Tag, tag.id), "tag survives -- cascade only targets the join table"
    end

    test "deleting all posts and all tags leaves the join table empty" do
      tags = Blog.upsert_tags(["a", "b", "c"])
      {:ok, _} = Blog.create_post(%{title: "P", body: "B"}, tags)

      assert Blog.count_posts_tags() == 3

      Repo.delete_all(Post)
      assert Blog.count_posts_tags() == 0

      Repo.delete_all(Tag)
      assert Repo.aggregate(PostTag, :count) == 0
    end
  end
end
