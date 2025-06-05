# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Packages do
  @moduledoc Aura.Doc.mod_doc("Service module for interacting with Hex Packages")

  import Aura.Common

  alias Aura.Model.HexAuditLog
  alias Aura.Model.HexPackage
  alias Aura.Model.HexPackageOwner
  alias Aura.Requester

  @base_path "/packages"

  @doc """
  Grabs a stream of packages, given optional criteria

  <!-- tabs-open -->
  ### 🏷️ Params
    * **opts**
      * repo :: `t:Aura.Common.repo_name/0`
      * page :: page to start streaming from (default: `1`)
      * per_page :: number of results per page number (default: `1000`)
      * sort :: sorting criteria (`:name` `:recent_downloads` `:total_downloads` `:inserted_at` `:updated_at`)
      * search :: search term

  #{Aura.Doc.returns(success: "Stream.resource/3")}

  ### 💻 Examples
    
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

  #{Aura.Doc.api_details([%{method: :GET, route: @base_path, controller: "PackageController", action: :index}, %{method: :GET, route: Path.join("/repos/`opts[:repo]`", @base_path), controller: "PackageController", action: :index}])}
    
  <!-- tabs-close -->
  """
  @spec stream_packages(opts :: list()) :: Enumerable.t()
  def stream_packages(opts \\ []) do
    {path, opts} = determine_path(opts, @base_path)
    stream_paginate(path, &HexPackage.build/1, opts)
  end

  @doc """
  Grabs all owners of a given package

  <!-- tabs-open -->
  ### 🏷️ Params
    * **name** :: `t:Aura.Common.package_name/0`
    * **opts** :: option parameters used to modify requests

  #{Aura.Doc.returns(success: "{:ok, [%HexPackageOwner{}...]}", failure: "{:error, (some failure)}")}

  ### 💻 Examples
    
      iex> alias Aura.Packages
      iex> {:ok, [owner | _]} =
      ...>   Packages.list_package_owners("decimal", repo_url: "http://localhost:4000/api")
      iex> owner.email
      "eric@example.com"

  #{Aura.Doc.api_details([%{method: :GET, route: Path.join(@base_path, ":name/owners"), controller: "OwnerController", action: :index}, %{method: :GET, route: Path.join("/repos/`opts[:repo]`", Path.join(@base_path, ":name/owners")), controller: "OwnerController", action: :index}])}

  <!-- tabs-close -->
  """
  @spec list_package_owners(name :: Aura.Common.package_name(), opts :: list()) ::
          {:ok, [HexPackageOwner.t()]} | {:error, any()}
  def list_package_owners(name, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{name}/owners"))

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, Enum.map(body, &HexPackageOwner.build/1)}
    end
  end

  @doc """
  Grabs a single package owner by their username

  <!-- tabs-open -->
  ### 🏷️ Params
    * **package_name** :: `t:Aura.Common.package_name/0`
    * **username** :: `t:Aura.Common.username/0`
    * **opts** :: option parameters used to modify requests

  #{Aura.Doc.returns(success: "{:ok, %HexPackageOwner{}}", failure: "{:error, (some failure)}")}

  ### 💻 Examples

      iex> alias Aura.Packages
      iex> {:ok, owner} = Packages.get_package_owner("decimal", "eric", repo_url: "http://localhost:4000/api")
      iex> owner.email
      "eric@example.com"

  #{Aura.Doc.api_details([%{method: :GET, route: Path.join(@base_path, ":package_name/owners/:username"), controller: "OwnerController", action: :show}, %{method: :GET, route: Path.join("/repos/`opts[:repo]`", Path.join(@base_path, ":package_name/owners/:username")), controller: "OwnerController", action: :show}])}
    
  <!-- tabs-close -->
  """
  @spec get_package_owner(package_name :: Aura.Common.package_name(), username :: Aura.Common.username(), opts :: list()) ::
          {:ok, HexPackageOwner.t()} | {:error, any()}
  def get_package_owner(package_name, username, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{package_name}/owners/#{username}"))

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexPackageOwner.build(body)}
    end
  end

  @doc """
  Grabs a package given its name

  <!-- tabs-open -->
  ### 🏷️ Params
    * **package_name** :: `t:Aura.Common.package_name/0`
    * **opts** :: option parameters used to modify requests

  #{Aura.Doc.returns(success: "{:ok, %HexPackage{}}", failure: "{:error, (some failure)}")}

  ### 💻 Examples

      iex> alias Aura.Packages
      iex> {:ok, pkg} = Packages.get_package("decimal", repo_url: "http://localhost:4000/api")
      iex> pkg.name
      "decimal"

  #{Aura.Doc.api_details([%{method: :GET, route: Path.join(@base_path, ":name"), controller: "PackageController", action: :show}, %{method: :GET, route: Path.join("/repos/`opts[:repo]`", Path.join(@base_path, ":name")), controller: "PackageController", action: :show}])}
    
  <!-- tabs-close -->
  """
  @spec get_package(name :: Aura.Common.package_name(), opts :: list()) :: {:ok, HexPackage.t()} | {:error, any()}
  def get_package(name, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{name}"))

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexPackage.build(body)}
    end
  end

  @doc """
  Adds a new owner to the list of package owners

  <!-- tabs-open -->
  ### 🏷️ Params
    * **package_name** :: `t:Aura.Common.package_name/0`
    * **owner_email** :: `t:Aura.Common.email/0`
    * **opts**
      * transfer
      * level

  #{Aura.Doc.returns(success: ":ok", failure: "{:error, (some failure)}")}

  #{Aura.Doc.api_details([%{method: :PUT, route: Path.join(@base_path, ":package_name/owners/:owner_email"), controller: "OwnerController", action: :create}, %{method: :PUT, route: Path.join("/repos/`opts[:repo]`", Path.join(@base_path, ":package_name/owners/:owner_email")), controller: "OwnerController", action: :create}])}
    
  <!-- tabs-close -->
  """
  @spec add_package_owner(package_name :: Aura.Common.package_name(), owner_email :: Aura.Common.email(), opts :: list()) ::
          :ok | {:error, any()}
  def add_package_owner(package_name, owner_email, opts \\ []) do
    encoded_email = URI.encode_www_form(owner_email)
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{package_name}/owners/#{encoded_email}"))

    with {:ok, _} <- Requester.put(path, opts) do
      :ok
    end
  end

  @doc """
  Removes an existing owner from the list of package owners

  <!-- tabs-open -->
  ### 🏷️ Params
    * **package_name** :: `t:Aura.Common.package_name/0`
    * **owner_email** :: `t:Aura.Common.email/0`
    * **opts**
      * **repo** :: `t:Aura.Common.repo_name/0`

  #{Aura.Doc.returns(success: ":ok", failure: "{:error, (some failure)}")}

  #{Aura.Doc.api_details([%{method: :DELETE, route: Path.join(@base_path, ":package_name/owners/:owner_email"), controller: "OwnerController", action: :delete}, %{method: :DELETE, route: Path.join("/repos/`opts[:repo]`", Path.join(@base_path, ":package_name/owners/:owner_email")), controller: "OwnerController", action: :delete}])}

  <!-- tabs-close -->
  """
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

  @doc """
  Streams audit logs, scoped to a package

  <!-- tabs-open -->
  ### 🏷️ Params
    * **package_name** :: `t:Aura.Common.package_name/0`
    * **opts**
      * **repo** :: `t:Aura.Common.repo_name/0`
      * **page** :: page number to start from (each page is 100 items)

  #{Aura.Doc.returns(success: "Stream.resource/3")}

  ### 💻 Examples

      iex> alias Aura.Packages
      iex> audit_logs = Packages.stream_audit_logs("decimal", repo_url: "http://localhost:4000/api")
      iex> _actions = Enum.map(audit_logs, fn audit_log -> audit_log.action end)

  #{Aura.Doc.api_details([%{method: :GET, route: Path.join(@base_path, ":package_name/audit-logs"), controller: "PackageController", action: :audit_logs}, %{method: :GET, route: Path.join("/repos/`opts[:repo]`", Path.join(@base_path, ":package_name/audit-logs")), controller: "PackageController", action: :audit_logs}])}

  <!-- tabs-close -->
  """
  @spec stream_audit_logs(package_name :: Aura.Common.package_name(), opts :: list) :: Enumerable.t()
  def stream_audit_logs(package_name, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{package_name}/audit-logs"))
    stream_paginate(path, &HexAuditLog.build/1, opts)
  end
end
