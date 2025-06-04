# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Packages do
  @moduledoc """
  Service module for interacting with Hex Packages

  <!-- tabs-open -->

  #{Aura.Doc.resources()}

  <!-- tabs-close -->
  """

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
    * **opts** :: option parameters used to modify requests

  #{Aura.Doc.returns(success: "Stream.resource/3")}

  ### 💻 Examples
    
      # request packages,
        # from the local test instance
        # scoped to the repo "hexpm"
        # starting with page 2,
        # sorted by total downloads
      iex> alias Aura.Packages
      iex> packages = Packages.stream_packages(
      ...>  repo_url: "http://localhost:4000/api",
      ...>  repo: "hexpm",
      ...>  page: 2,
      ...>  sort: :total_downloads)
      iex> Enum.empty?(packages)
      false

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
    * **opts** :: option parameters used to modify requests

  #{Aura.Doc.returns(success: ":ok", failure: "{:error, (some failure)}")}
    
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
    * **opts** :: option parameters used to modify requests

  #{Aura.Doc.returns(success: ":ok", failure: "{:error, (some failure)}")}

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
  Streams `Aura.Model.HexAuditLog`, scoped to a package

  <!-- tabs-open -->
  ### 🏷️ Params
    * **package_name** :: `t:Aura.Common.package_name/0`
    * **opts** :: option parameters used to modify requests

  #{Aura.Doc.returns(success: "Stream.resource/3")}

  ### 💻 Examples

      iex> alias Aura.Packages
      iex> audit_logs = Packages.stream_audit_logs("decimal", repo_url: "http://localhost:4000/api")
      iex> _actions = Enum.map(audit_logs, fn audit_log -> audit_log.action end)

  <!-- tabs-close -->
  """
  @spec stream_audit_logs(package_name :: Aura.Common.package_name(), opts :: list) :: Enumerable.t()
  def stream_audit_logs(package_name, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{package_name}/audit-logs"))
    stream_paginate(path, &HexAuditLog.build/1, opts)
  end
end
