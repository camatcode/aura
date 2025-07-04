# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Common do
  @moduledoc Aura.Doc.mod_doc("Common capabilities across all Aura services")

  alias Aura.Requester

  require Logger

  @typedoc Aura.Doc.type_doc("A human-readable name for this API key",
             example: """
              "my_computer"
             """
           )
  @type api_key_name :: String.t()

  @typedoc Aura.Doc.type_doc("The path parameter of the request",
             examples: """
                 "/packages"
             """
           )
  @type api_path :: String.t()

  @typedoc Aura.Doc.type_doc("Options to modify an audit request",
             keys: %{
               repo_url: Aura.Common,
               page: {Aura.Common, :start_page}
             }
           )
  @type audit_opts :: [repo_url: Aura.Common.repo_url(), page: Aura.Common.start_page()]

  @typedoc Aura.Doc.type_doc("Name of the package",
             example: """
             "plug"
             """
           )
  @type package_name :: String.t()

  @typedoc Aura.Doc.type_doc("When streaming, start at this page number. Default: 1")
  @type start_page :: non_neg_integer()

  @typedoc Aura.Doc.type_doc("A unique, human-readable ID for a user",
             example: """
               "camatcode"
             """
           )
  @type username :: String.t()

  @typedoc Aura.Doc.type_doc("An email address associated with this record",
             example: """
             "hello@example.com"
             """
           )
  @type email :: String.t()

  @typedoc Aura.Doc.type_doc("Name of the Hex organization",
             example: """
             "my_org"
             """,
             related: [Aura.Orgs]
           )
  @type org_name :: String.t()

  @typedoc Aura.Doc.type_doc("The version of a release",
             example: """
             "1.2.3"
             """
           )
  @type release_version :: String.t()

  @typedoc Aura.Doc.type_doc("The name of the repository",
             example: """
             "hexpm"
             """
           )
  @type repo_name :: String.t()

  @typedoc Aura.Doc.type_doc("A Hex compliant API endpoint",
             example: """
             "https://hex.pm/api"
             "http://localhost:4000/api"
             """
           )
  @type repo_url :: URI.t()

  @doc Aura.Doc.func_doc("Implements Hex API's pagination mechanism by returning a `Stream.resource/3`",
         params: %{
           path: "`t:api_path/0`",
           build_func: "a function that takes in a map and returns a struct representing what's being paginated",
           opts: "option parameters used to modify requests"
         },
         success: "Stream.resource/3",
         example: """
         iex> alias Aura.Common
         iex> alias Aura.Model.HexPackage
         iex> opts = [repo_url: "http://localhost:4000/api", repo: "hexpm", page: 2, sort: :total_downloads]
         iex> {path, opts} = Common.determine_path(opts, "/packages")
         iex> packages = Common.stream_paginate(path, &HexPackage.build/1, opts)
         iex> Enum.empty?(packages)
         false
         """
       )
  @spec stream_paginate(path :: api_path(), build_func :: (map() -> map()), opts :: list()) :: Enumerable.t()
  def stream_paginate(path, build_func, opts) do
    qparams =
      Keyword.merge([page: 1, per_page: 1000], opts)

    opts =
      opts
      |> Keyword.delete(:page)
      |> Keyword.delete(:search)
      |> Keyword.delete(:sort)
      |> Keyword.delete(:per_page)

    start_fun = fn -> max(1, qparams[:page]) end
    end_fun = fn _ -> :ok end

    continue_fun = &paginate_with_page(&1, path, qparams, build_func, opts)

    Stream.resource(start_fun, continue_fun, end_fun)
  end

  @doc Aura.Doc.func_doc(
         [
           "Determines a `t:api_path/0` by investigating **opts** for a `:repo` or `:org` key, representing a `Aura.Model.HexRepo` or a `Aura.Model.HexOrganization`.",
           "If present, **path** will be modified to scope solely to that repo or org, otherwise the **path** is unmodified."
         ],
         params: %{opts: "option parameters used to modify requests", path: "`t:api_path/0`"},
         success: "{path, opts}",
         example: """
         iex> alias Aura.Common
         iex> alias Aura.Model.HexPackage
         iex> opts = [repo_url: "http://localhost:4000/api", repo: "hexpm", page: 2, sort: :total_downloads]
         iex> {_path, _opts} = Common.determine_path(opts, "/packages")
         {"/repos/hexpm/packages", [repo_url: "http://localhost:4000/api", page: 2, sort: :total_downloads]}
         iex> opts = [repo_url: "http://localhost:4000/api", org: "my_org", page: 2]
         iex> {_path, _opts} = Common.determine_path(opts, "/keys")
         {"/orgs/my_org/keys", [repo_url: "http://localhost:4000/api", page: 2]}
         """
       )
  @spec determine_path(opts :: [any()], path :: api_path()) :: {api_path(), [any()]}
  def determine_path(opts, path) do
    {path, opts} =
      if opts[:repo] do
        {Path.join("/repos/#{opts[:repo]}", path), Keyword.delete(opts, :repo)}
      else
        {path, opts}
      end

    if opts[:org] do
      {Path.join("/orgs/#{opts[:org]}", path), Keyword.delete(opts, :org)}
    else
      {path, opts}
    end
  end

  defp paginate_with_page(page, _path, _qparams, _build_func, _opts) when page < 1 do
    {:halt, page}
  end

  defp paginate_with_page(page, path, qparams, build_func, opts) when page >= 1 do
    path
    |> get_page(page, qparams, opts)
    |> case do
      {:ok, page_of_items} ->
        items = Enum.map(page_of_items, build_func)
        next_page = if Enum.empty?(items), do: -1, else: page + 1
        {items, next_page}

      # coveralls-ignore-start
      {:error, reason} ->
        # Log the error for debugging
        Logger.error("Failed to fetch page #{page}: #{inspect(reason)}")
        {:halt, {:error, reason}}
    end

    # coveralls-ignore-stop
  end

  defp get_page(path, page, qparams, opts) do
    qparams = Keyword.put(qparams, :page, page)

    opts = Keyword.put(opts, :qparams, qparams)

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, body}
    end
  end
end
