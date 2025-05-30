# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Packages do
  @moduledoc false

  import Aura.Common

  alias Aura.Model.HexAuditLog
  alias Aura.Model.HexPackage
  alias Aura.Model.HexPackageOwner
  alias Aura.Requester

  @base_path "/packages"

  def stream_packages(opts \\ []) do
    stream_paginate(@base_path, &HexPackage.build/1, opts)
  end

  def list_package_owners(name, opts \\ []) do
    path = Path.join(@base_path, "#{name}/owners")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, Enum.map(body, &HexPackageOwner.build/1)}
    end
  end

  def get_package(name, opts \\ []) do
    path = Path.join(@base_path, "#{name}")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexPackage.build(body)}
    end
  end

  def add_package_owner(package_name, owner_email, opts \\ []) do
    encoded_email = URI.encode_www_form(owner_email)
    path = Path.join(@base_path, "#{package_name}/owners/#{encoded_email}")

    with {:ok, _} <- Requester.put(path, opts) do
      :ok
    end
  end

  def remove_package_owner(package_name, owner_email, opts \\ []) do
    encoded_email = URI.encode_www_form(owner_email)
    path = Path.join(@base_path, "#{package_name}/owners/#{encoded_email}")

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end

  def stream_audit_logs(package_name, opts \\ []) do
    path = Path.join(@base_path, "#{package_name}/audit-logs")
    stream_paginate(path, &HexAuditLog.build/1, opts)
  end
end
