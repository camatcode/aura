# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Releases do
  @moduledoc """
  Service module for interacting with Hex package releases
  """

  import Aura.Common

  alias Aura.Common
  alias Aura.Model.HexRelease
  alias Aura.PackageTarUtil
  alias Aura.Requester

  @packages_path "/packages"

  @typedoc """
  The reason for retiring a release
  """
  @type retire_reason :: :renamed | :security | :invalid | :deprecated | :other

  @doc """
  Returns a `Aura.Model.HexRelease` for a given package / version
  """
  @spec get_release(
          package_name :: Common.package_name(),
          version :: Common.release_version(),
          opts :: list()
        ) :: {:ok, HexRelease.t()} | {:error, any()}
  def get_release(package_name, version, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{version}"))

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexRelease.build(body)}
    end
  end

  @doc """
  Returns the contents of the release's docs **tar.gz**
  """
  @spec get_release_docs(
          package_name :: Common.package_name(),
          version :: Common.release_version(),
          opts :: list()
        ) :: {:ok, PackageTarUtil.tar_contents()} | {:error, any()}
  def get_release_docs(package_name, version, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{version}/docs"))

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      PackageTarUtil.read_release_tar(body)
    end
  end

  @doc """
  Permanently deletes a release
  """
  @spec delete_release(
          package_name :: Common.package_name(),
          version :: Common.release_version(),
          opts :: list()
        ) :: :ok | {:error, any()}
  def delete_release(package_name, version, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{version}"))

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end

  @doc """
  Publishes a release **.tar** packaged by a build tool to a Hex-compliant repository
  """
  @spec publish_release(
          release_code_tar :: String.t(),
          opts :: list()
        ) :: {:ok, HexRelease.t()} | {:error, any()}
  def publish_release(release_code_tar, opts \\ []) when is_bitstring(release_code_tar) do
    {path, opts} = determine_path(opts, "/publish")

    with {:ok, _streams} <- PackageTarUtil.read_release_tar(release_code_tar) do
      opts = Keyword.merge([body: File.read!(release_code_tar)], opts)

      with {:ok, %{body: body}} <- Requester.post(path, opts) do
        {:ok, HexRelease.build(body)}
      end
    end
  end

  @doc """
  Publishes associated release docs **tar.gz** to a Hex-compliant repository
  """
  @spec publish_release_docs(
          package_name :: Common.package_name(),
          release_version :: Common.release_version(),
          doc_tar :: String.t(),
          opts :: list
        ) :: {:ok, URI.t()} | {:error, any()}
  def publish_release_docs(package_name, release_version, doc_tar, opts \\ []) when is_bitstring(doc_tar) do
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{release_version}/docs"))

    with {:ok, _streams} <- PackageTarUtil.read_release_tar(doc_tar) do
      opts = Keyword.merge([body: File.read!(doc_tar)], opts)

      with {:ok, %{headers: %{"location" => [location]}}} <- Requester.post(path, opts) do
        {:ok, location}
      end
    end
  end

  @doc """
  Marks a release as **retired**, signaling to others that it should not be used
  """
  @spec retire_release(
          package_name :: Common.package_name(),
          version :: Common.release_version(),
          reason :: retire_reason(),
          message :: String.t(),
          opts :: list()
        ) :: :ok | {:error, any()}
  def retire_release(package_name, version, reason \\ :other, message, opts \\ []) when is_bitstring(message) do
    reason = validate_reason(reason)
    opts = Keyword.merge([json: %{reason: reason, message: message}], opts)
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{version}/retire"))

    with {:ok, _} <- Requester.post(path, opts) do
      :ok
    end
  end

  @doc """
  Removes the **retired** status from a release, signaling to others that it can still be used
  """
  @spec undo_retire_release(
          package_name :: Common.package_name(),
          version :: Common.release_version(),
          opts :: list()
        ) :: :ok | {:error, any()}
  def undo_retire_release(package_name, version, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{version}/retire"))

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end

  @doc """
  Permanently deletes associated documentation for a release
  """
  @spec delete_release_docs(
          package_name :: Common.package_name(),
          version :: Common.release_version(),
          opts :: list()
        ) :: :ok | {:error, any()}
  def delete_release_docs(package_name, version, opts \\ []) do
    {path, opts} = determine_path(opts, Path.join(@packages_path, "#{package_name}/releases/#{version}/docs"))

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end

  defp validate_reason(reason) when is_bitstring(reason) do
    reason
    |> String.downcase()
    |> String.to_atom()
    |> validate_reason()
  end

  defp validate_reason(reason)
       when reason == :renamed or reason == :security or reason == :invalid or reason == :deprecated do
    reason
  end

  defp validate_reason(_), do: :other
end
