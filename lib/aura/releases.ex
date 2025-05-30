defmodule Aura.Releases do
  @moduledoc false

  alias Aura.Model.HexRelease
  alias Aura.PackageTarUtil
  alias Aura.Requester

  @packages_path "/packages"

  def get_release(package_name, version, opts \\ []) do
    path = Path.join(@packages_path, "#{package_name}/releases/#{version}")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexRelease.build(body)}
    end
  end

  def get_release_docs(package_name, version, opts \\ []) do
    path = "/docs/#{package_name}-#{version}.tar.gz"

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      PackageTarUtil.read_release_tar(body)
    end
  end

  def publish_release(code_tar, opts \\ []) when is_bitstring(code_tar) do
    with {:ok, _streams} <- PackageTarUtil.read_release_tar(code_tar) do
      opts = Keyword.merge([body: File.read!(code_tar)], opts)

      with {:ok, %{body: body}} <- Requester.post("/publish", opts) do
        {:ok, HexRelease.build(body)}
      end
    end
  end

  def publish_release_docs(package_name, release_version, doc_tar, opts \\ []) when is_bitstring(doc_tar) do
    with {:ok, _streams} <- PackageTarUtil.read_release_tar(doc_tar) do
      opts = Keyword.merge([body: File.read!(doc_tar)], opts)
      path = Path.join(@packages_path, "#{package_name}/releases/#{release_version}/docs")

      with {:ok, %{headers: %{"location" => [location]}}} <- Requester.post(path, opts) do
        {:ok, location}
      end
    end
  end

  def retire_release(package_name, version, reason \\ :other, message, opts \\ []) when is_bitstring(message) do
    reason = validate_reason(reason)
    opts = Keyword.merge([json: %{reason: reason, message: message}], opts)
    path = Path.join(@packages_path, "#{package_name}/releases/#{version}/retire")

    with {:ok, _} <- Requester.post(path, opts) do
      :ok
    end
  end

  def delete_release_docs(package_name, version) do
    path = Path.join(@packages_path, "#{package_name}/releases/#{version}/docs")

    with {:ok, _} <- Requester.delete(path) do
      :ok
    end
  end

  def undo_retire_release(package_name, version, opts \\ []) do
    path = Path.join(@packages_path, "#{package_name}/releases/#{version}/retire")

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
