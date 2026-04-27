alias Hw3Phoenix.Blog

elixir = Blog.upsert_tags(["elixir"]) |> List.first()
phoenix = Blog.upsert_tags(["phoenix"]) |> List.first()
ecto = Blog.upsert_tags(["ecto"]) |> List.first()

Blog.create_post(%{title: "Hello Phoenix", body: "Hello world!"}, [phoenix, elixir])
Blog.create_post(%{title: "Many to many", body: "Three tables example."}, [ecto, elixir])
