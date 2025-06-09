# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Packages do
  @moduledoc Aura.Doc.mod_doc("Service module for interacting with Hex Packages")

  import Aura.Common

  alias Aura.Model.HexAuditLog
  alias Aura.Model.HexPackage
  alias Aura.Model.HexPackageOwner
  alias Aura.Requester

  @base_path "/packages"

  @typedoc Aura.Doc.type_doc("The number of results per internal page. Aura sets this to 1000.")
  @type per_page :: non_neg_integer()

  @typedoc Aura.Doc.type_doc("Sorting criteria for response")
  @type sort_order :: :name | :recent_downloads | :total_downloads | :inserted_at | :updated_at

  @typedoc Aura.Doc.type_doc([
             "Search term that filters package results",
             """
             By default search will do a wildcard match on the package name and full text search on the package 
             description. If the search string is `nerves`, package names matching `*nerves*` will be found and 
             packages having `nerves` or a stemmed version of the string in the description.
             """,
             "Search can also be performed on specific fields, for example: `name:nerves* extra:package,name,postgresql`.",
             "The search fields are:",
             """
             * `name` - Package name, can include the wildcard operator `*` at the end or start of the string.
             * `description` - Full text search package description.
             * `extra` - Comma-separated search on `extra` map in metadata. `extra:type,nerves` will match 
             `{"type": "nerves"}`.
             """
           ])
  @type search_term :: String.t()

  @typedoc Aura.Doc.type_doc("Options to modify a Package stream request",
             keys: %{
               repo: {Aura.Common, :repo_name},
               repo_url: Aura.Common,
               page: {Aura.Common, :start_page},
               per_page: Aura.Packages,
               sort: {Aura.Packages, :sort_order},
               search: {Aura.Packages, :search_term}
             }
           )
  @type pkg_stream_opts :: [
          repo: Aura.Common.repo_name(),
          page: Aura.Common.start_page(),
          per_page: per_page(),
          sort: sort_order(),
          search: search_term()
        ]

  @typedoc Aura.Doc.type_doc("Options to modify a Packages request",
             keys: %{
               repo_url: Aura.Common
             }
           )
  @type pkg_opts :: [repo_url: Aura.Common.repo_url()]

  @doc Aura.Doc.func_doc("Grabs a stream of packages, given optional criteria",
         params: [
           {"opts[:repo_url]", {Aura.Common, :repo_url}},
           {"opts[:page]", {Aura.Common, :start_page}},
           {"opts[:per_page]", {Aura.Packages, :per_page}},
           {"opts[:sort]", {Aura.Packages, :sort_order}},
           {"opts[:search]", {Aura.Packages, :search_term}}
         ],
         success: "Stream.resource/3",
         api: %{method: :get, route: @base_path, controller: :Package, action: :index, repo_scope: true},
         example: """
         # request packages,
         #   from the local test instance
         #   scoped to the repo "hexpm"
         #   sorted by total downloads
         #   starting with page 2
         iex> alias Aura.Packages
         iex> opts = [repo_url: "http://localhost:4000/api", repo: "hexpm",
         ...>         sort: :total_downloads]
         iex> packages = Packages.stream_packages(
         ...>  opts ++ [page: 2])
         iex> Enum.empty?(packages)
         false

         # Use search term
         iex> alias Aura.Packages
         iex> opts = [repo_url: "http://localhost:4000/api", repo: "hexpm",
         ...>         sort: :total_downloads, per_page: 5]
         iex> packages = Packages.stream_packages(
         ...>  opts ++ [search: "nerves"]) |> Enum.take(50)
         iex> Enum.empty?(packages)
         false
         """
       )
  @spec stream_packages(opts :: pkg_stream_opts()) :: Enumerable.t()
  def stream_packages(opts \\ []) do
    {path, opts} = determine_path(opts, @base_path)
    stream_paginate(path, &HexPackage.build/1, opts)
  end

  @doc Aura.Doc.func_doc("Grabs all owners of a given package",
         params: [
           {:name, {Aura.Common, :package_name}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}}
         ],
         success: "{:ok, [%HexPackageOwner{}...]}",
         failure: "{:error, (some failure)}",
         api: %{
           method: :get,
           route: Path.join(@base_path, ":name/owners"),
           controller: :Owner,
           action: :index,
           repo_scope: true
         },
         example: """
         iex> alias Aura.Packages
         iex> {:ok, [owner | _]} =
         ...>   Packages.list_package_owners("decimal", repo_url: "http://localhost:4000/api")
         iex> owner.email
         "eric@example.com"
         """
       )
  @spec list_package_owners(name :: Aura.Common.package_name(), opts :: pkg_opts()) ::
          {:ok, [HexPackageOwner.t()]} | {:error, any()}
  def list_package_owners(name, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{name}/owners"))

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, Enum.map(body, &HexPackageOwner.build/1)}
    end
  end

  @doc Aura.Doc.func_doc("Grabs a single package owner by their username",
         params: [
           {:name, {Aura.Common, :package_name}},
           {:username, {Aura.Common, :username}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}}
         ],
         success: "{:ok, %HexPackageOwner{}}",
         failure: "{:error, (some failure)}",
         api: %{
           route: Path.join(@base_path, ":package_name/owners/:username"),
           controller: :Owner,
           action: :show,
           repo_scope: true
         },
         example: """
         iex> alias Aura.Packages
         iex> {:ok, owner} = Packages.get_package_owner("decimal", "eric", repo_url: "http://localhost:4000/api")
         iex> owner.email
         "eric@example.com"
         """
       )
  @spec get_package_owner(
          package_name :: Aura.Common.package_name(),
          username :: Aura.Common.username(),
          opts :: pkg_opts()
        ) :: {:ok, HexPackageOwner.t()} | {:error, any()}
  def get_package_owner(package_name, username, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{package_name}/owners/#{username}"))

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexPackageOwner.build(body)}
    end
  end

  @doc Aura.Doc.func_doc("Grabs a package given its name",
         params: [
           {:name, {Aura.Common, :package_name}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}}
         ],
         success: "{:ok, %HexPackage{}}",
         failure: "{:error, (some failure)}",
         api: %{route: Path.join(@base_path, ":name"), controller: :Package, action: :show, repo_scope: true},
         example: """
         iex> alias Aura.Packages
         iex> {:ok, pkg} = Packages.get_package("decimal", repo_url: "http://localhost:4000/api")
         iex> pkg.name
         "decimal"
         """
       )
  @spec get_package(name :: Aura.Common.package_name(), opts :: pkg_opts()) :: {:ok, HexPackage.t()} | {:error, any()}
  def get_package(name, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{name}"))

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexPackage.build(body)}
    end
  end

  @doc Aura.Doc.func_doc("Adds a new owner to the list of package owners",
         params: [
           {:package_name, {Aura.Common, :package_name}},
           {:owner_email, {Aura.Common, :email}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}}
         ],
         success: ":ok",
         failure: "{:error, (some failure)}",
         api: %{
           method: :put,
           route: Path.join(@base_path, ":package_name/owners/:owner_email"),
           controller: :Owner,
           action: :create,
           repo_scope: true
         }
       )
  @spec add_package_owner(
          package_name :: Aura.Common.package_name(),
          owner_email :: Aura.Common.email(),
          opts :: pkg_opts()
        ) :: :ok | {:error, any()}
  def add_package_owner(package_name, owner_email, opts \\ []) do
    encoded_email = URI.encode_www_form(owner_email)
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{package_name}/owners/#{encoded_email}"))

    with {:ok, _} <- Requester.put(path, opts) do
      :ok
    end
  end

  @doc Aura.Doc.func_doc("Removes an existing owner from the list of package owners",
         params: [
           {:package_name, {Aura.Common, :package_name}},
           {:owner_email, {Aura.Common, :email}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}}
         ],
         success: ":ok",
         failure: "{:error, (some failure)}",
         api: %{
           method: :delete,
           route: Path.join(@base_path, ":package_name/owners/:owner_email"),
           controller: :Owner,
           action: :delete,
           repo_scope: true
         }
       )
  @spec remove_package_owner(
          package_name :: Aura.Common.package_name(),
          owner_email :: Aura.Common.email(),
          opts :: pkg_opts()
        ) :: :ok | {:error, any()}
  def remove_package_owner(package_name, owner_email, opts \\ []) do
    encoded_email = URI.encode_www_form(owner_email)
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{package_name}/owners/#{encoded_email}"))

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end

  @doc Aura.Doc.func_doc("Streams audit logs, scoped to a package",
         params: [
           {:package_name, {Aura.Common, :package_name}},
           {"opts[:repo_url]", {Aura.Common, :repo_url}},
           {"opts[:page]", {Aura.Common, :start_page}}
         ],
         success: "Stream.resource/3",
         api: %{
           route: Path.join(@base_path, ":package_name/audit-logs"),
           controller: :Package,
           action: :audit_logs,
           repo_scope: true
         },
         example: """
         iex> alias Aura.Packages
         iex> opts = [repo_url: "http://localhost:4000/api"]
         iex> audit_logs = Packages.stream_audit_logs("decimal", opts) |> Enum.take(20)
         iex> _actions = Enum.map(audit_logs, fn audit_log -> audit_log.action end)
         """
       )
  @spec stream_audit_logs(package_name :: Aura.Common.package_name(), opts :: Aura.Common.audit_opts()) :: Enumerable.t()
  def stream_audit_logs(package_name, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{package_name}/audit-logs"))
    stream_paginate(path, &HexAuditLog.build/1, opts)
  end
end
