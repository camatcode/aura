# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Packages do
  @moduledoc Aura.Doc.mod_doc("Service module for interacting with Hex Packages")

  import Aura.Common

  alias Aura.Model.HexAuditLog
  alias Aura.Model.HexPackage
  alias Aura.Model.HexPackageOwner
  alias Aura.Requester

  @base_path "/packages"

  @doc Aura.Doc.func_doc("Grabs a stream of packages, given optional criteria",
         params: %{
           "opts.repo": "`t:Aura.Common.repo_name/0`",
           "opts.page": "page to start streaming from (default: `1`)",
           "opts.per_page": "number of results per page number (default: `1000`)",
           "opts.sort": "sorting criteria (`:name` `:recent_downloads` `:total_downloads` `:inserted_at` `:updated_at`)",
           "opts.search": "search term"
         },
         success: "Stream.resource/3",
         api: %{method: :get, route: @base_path, controller: :Package, action: :index, repo_scope: true},
         example: """
         # request packages,
         # from the local test instance
         # scoped to the repo "hexpm"
         # starting with page 2
         # sorted by total downloads
         iex> alias Aura.Packages
         iex> packages = Packages.stream_packages(
         ...>  repo_url: "http://localhost:4000/api",
         ...>  repo: "hexpm",
         ...>  page: 2,
         ...>  sort: :total_downloads)
         iex> Enum.empty?(packages)
         false
         """
       )
  @spec stream_packages(opts :: list()) :: Enumerable.t()
  def stream_packages(opts \\ []) do
    {path, opts} = determine_path(opts, @base_path)
    stream_paginate(path, &HexPackage.build/1, opts)
  end

  @doc Aura.Doc.func_doc("Grabs all owners of a given package",
         params: %{name: "`t:Aura.Common.package_name/0`", opts: "option parameters used to modify requests"},
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
  @spec list_package_owners(name :: Aura.Common.package_name(), opts :: list()) ::
          {:ok, [HexPackageOwner.t()]} | {:error, any()}
  def list_package_owners(name, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{name}/owners"))

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, Enum.map(body, &HexPackageOwner.build/1)}
    end
  end

  @doc Aura.Doc.func_doc("Grabs a single package owner by their username",
         params: %{
           package_name: "`t:Aura.Common.package_name/0`",
           username: "`t:Aura.Common.username/0`",
           opts: "option parameters used to modify requests"
         },
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
  @spec get_package_owner(package_name :: Aura.Common.package_name(), username :: Aura.Common.username(), opts :: list()) ::
          {:ok, HexPackageOwner.t()} | {:error, any()}
  def get_package_owner(package_name, username, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{package_name}/owners/#{username}"))

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexPackageOwner.build(body)}
    end
  end

  @doc Aura.Doc.func_doc("Grabs a package given its name",
         params: %{package_name: "`t:Aura.Common.package_name/0`", opts: "option parameters used to modify requests"},
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
  @spec get_package(name :: Aura.Common.package_name(), opts :: list()) :: {:ok, HexPackage.t()} | {:error, any()}
  def get_package(name, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{name}"))

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexPackage.build(body)}
    end
  end

  @doc Aura.Doc.func_doc("Adds a new owner to the list of package owners",
         params: %{
           package_name: "`t:Aura.Common.package_name/0`",
           owner_email: "`t:Aura.Common.email/0`",
           "opts.transfer": "",
           "opts.level": ""
         },
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
  @spec add_package_owner(package_name :: Aura.Common.package_name(), owner_email :: Aura.Common.email(), opts :: list()) ::
          :ok | {:error, any()}
  def add_package_owner(package_name, owner_email, opts \\ []) do
    encoded_email = URI.encode_www_form(owner_email)
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{package_name}/owners/#{encoded_email}"))

    with {:ok, _} <- Requester.put(path, opts) do
      :ok
    end
  end

  @doc Aura.Doc.func_doc("Removes an existing owner from the list of package owners",
         params: %{
           package_name: "`t:Aura.Common.package_name/0`",
           owner_email: "`t:Aura.Common.email/0`",
           "opts.repo": "`t:Aura.Common.repo_name/0`"
         },
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
          opts :: list()
        ) ::
          :ok | {:error, any()}
  def remove_package_owner(package_name, owner_email, opts \\ []) do
    encoded_email = URI.encode_www_form(owner_email)
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{package_name}/owners/#{encoded_email}"))

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end

  @doc Aura.Doc.func_doc("Streams audit logs, scoped to a package",
         params: %{
           package_name: "`t:Aura.Common.package_name/0`",
           "opts.repo": "`t:Aura.Common.repo_name/0`",
           "opts.page": "page number to start from (each page is 100 items)"
         },
         success: "Stream.resource/3",
         api: %{
           route: Path.join(@base_path, ":package_name/audit-logs"),
           controller: :Package,
           action: :audit_logs,
           repo_scope: true
         },
         example: """
         iex> alias Aura.Packages
         iex> audit_logs = Packages.stream_audit_logs("decimal", repo_url: "http://localhost:4000/api")
         iex> _actions = Enum.map(audit_logs, fn audit_log -> audit_log.action end)
         """
       )
  @spec stream_audit_logs(package_name :: Aura.Common.package_name(), opts :: list) :: Enumerable.t()
  def stream_audit_logs(package_name, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{package_name}/audit-logs"))
    stream_paginate(path, &HexAuditLog.build/1, opts)
  end
end
