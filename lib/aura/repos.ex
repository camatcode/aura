# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Repos do
  @moduledoc false

  alias Aura.Model.HexAPIKey
  alias Aura.Model.HexRepo
  alias Aura.Requester

  @repos_path "/repos"
  @keys_path "/keys"

  def list_repos(opts \\ []) do
    with {:ok, %{body: body}} <- Requester.get(@repos_path, opts) do
      results = Enum.map(body, &HexRepo.build/1)

      {:ok, results}
    end
  end

  def list_api_keys(opts \\ []) do
    with {:ok, %{body: body}} <- Requester.get(@keys_path, opts) do
      {:ok, Enum.map(body, &HexAPIKey.build/1)}
    end
  end

  def get_repo(repo_name, opts \\ []) when is_bitstring(repo_name) do
    path = Path.join(@repos_path, "#{repo_name}")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexRepo.build(body)}
    end
  end

  def get_api_key(key_name, opts \\ []) do
    path = Path.join(@keys_path, "#{key_name}")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexAPIKey.build(body)}
    end
  end

  def create_api_key(key_name, username, password, allow_write \\ false, opts \\ []) do
    opts = Keyword.merge([auth: {:basic, "#{username}:#{password}"}], opts)
    read_write = if allow_write, do: [:read, :write], else: [:read]
    permissions = Enum.map(read_write, fn action -> %{domain: :api, resource: action} end)
    opts = Keyword.merge([json: %{name: key_name, permissions: permissions}], opts)

    with {:ok, %{body: body}} <- Requester.post(@keys_path, opts) do
      {:ok, HexAPIKey.build(body)}
    end
  end

  def delete_all_api_keys(opts \\ []) do
    path = @keys_path

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end

  def delete_api_key(key_name, opts \\ []) do
    path = Path.join(@keys_path, "#{key_name}")

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end
end
