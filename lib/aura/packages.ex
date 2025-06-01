# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Packages do
  @moduledoc """
  Service module for interacting with Hex Packages
  """

  import Aura.Common

  alias Aura.Model.HexAuditLog
  alias Aura.Model.HexPackage
  alias Aura.Model.HexPackageOwner
  alias Aura.Requester

  @base_path "/packages"

  @doc """
  Returns a stream of `Aura.Model.HexPackage`s
  """
  @spec stream_packages(opts :: list()) :: Enumerable.t()
  def stream_packages(opts \\ []) do
    {path, opts} = determine_path(opts, @base_path)
    stream_paginate(path, &HexPackage.build/1, opts)
  end

  @doc """
  Returns a list of `Aura.Model.HexPackageOwner`
  """
  @spec list_package_owners(name :: Aura.Common.package_name(), opts :: list()) :: [HexPackageOwner.t()]
  def list_package_owners(name, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{name}/owners"))

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, Enum.map(body, &HexPackageOwner.build/1)}
    end
  end

  @doc """
  Returns a `Aura.Model.HexPackageOwner` for a given username / package
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
  Returns a single `Aura.Model.HexPackage`
  """
  @spec get_package(name :: Aura.Common.package_name(), opts :: list()) :: {:ok, HexPackage.t()} | {:error, any()}
  def get_package(name, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{name}"))

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexPackage.build(body)}
    end
  end

  @doc """
  Adds a new `Aura.Model.HexPackageOwner` to a `Aura.Model.HexPackage`
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
  Removes a `Aura.Model.HexPackageOwner` from a `Aura.Model.HexPackage`
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
  Returns a stream of `Aura.Model.HexAuditLog`, scoped to a package
  """
  @spec stream_audit_logs(package_name :: Aura.Common.package_name(), opts :: list) :: Enumerable.t()
  def stream_audit_logs(package_name, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@base_path, "#{package_name}/audit-logs"))
    stream_paginate(path, &HexAuditLog.build/1, opts)
  end
end
