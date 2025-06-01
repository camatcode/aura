# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Repos do
  @moduledoc """
  Service module for interacting with `Aura.Model.HexRepo`
  """

  alias Aura.Common
  alias Aura.Model.HexAPIKey
  alias Aura.Model.HexRepo
  alias Aura.Requester

  @repos_path "/repos"
  @keys_path "/keys"

  @doc """
  Returns all visible `Aura.Model.HexRepo`s available
  """
  @spec list_repos(opts :: list()) :: {:ok, [HexRepo.t()]} | {:error, any()}
  def list_repos(opts \\ []) do
    with {:ok, %{body: body}} <- Requester.get(@repos_path, opts) do
      results = Enum.map(body, &HexRepo.build/1)

      {:ok, results}
    end
  end

  @doc """
  Returns a list of `Aura.Model.HexAPIKey`, given the requester's authentication
  """
  @spec list_api_keys(opts :: list()) :: {:ok, [HexAPIKey.t()]} | {:error, any()}
  def list_api_keys(opts \\ []) do
    with {:ok, %{body: body}} <- Requester.get(@keys_path, opts) do
      {:ok, Enum.map(body, &HexAPIKey.build/1)}
    end
  end

  @doc """
  Returns a `Aura.Model.HexRepo` associated with a given **repo_name**
  """
  @spec get_repo(repo_name :: Common.repo_name(), opts :: list()) :: {:ok, HexRepo.t()} | {:error, any()}
  def get_repo(repo_name, opts \\ []) when is_bitstring(repo_name) do
    path = Path.join(@repos_path, "#{repo_name}")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexRepo.build(body)}
    end
  end

  @doc """
  Returns a `Aura.Model.HexAPIKey` associated with a given **key_name**
  """
  @spec get_api_key(key_name :: Common.api_key_name(), opts :: list()) :: {:ok, HexAPIKey.t()} | {:error, any()}
  def get_api_key(key_name, opts \\ []) do
    path = Path.join(@keys_path, "#{key_name}")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexAPIKey.build(body)}
    end
  end

  @doc """
  Creates a new `Aura.Model.HexAPIKey`
  """
  @spec create_api_key(
          key_name :: Common.api_key_name(),
          username :: Common.username(),
          password :: String.t(),
          allow_write :: boolean(),
          opts :: list()
        ) :: {:ok, HexAPIKey.t()} | {:error, any()}
  def create_api_key(key_name, username, password, allow_write \\ false, opts \\ []) do
    opts = Keyword.merge([auth: {:basic, "#{username}:#{password}"}], opts)
    read_write = if allow_write, do: [:read, :write], else: [:read]
    permissions = Enum.map(read_write, fn action -> %{domain: :api, resource: action} end)
    opts = Keyword.merge([json: %{name: key_name, permissions: permissions}], opts)

    with {:ok, %{body: body}} <- Requester.post(@keys_path, opts) do
      {:ok, HexAPIKey.build(body)}
    end
  end

  @doc """
  Deletes **all** API keys for the authenticated requester
  """
  @spec delete_all_api_keys(opts :: list()) :: :ok | {:error, any()}
  def delete_all_api_keys(opts \\ []) do
    path = @keys_path

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end

  @doc """
  Deletes an API key for the authenticated requester, given a **key_name**
  """
  @spec delete_api_key(key_name :: Common.api_key_name(), opts :: list()) :: :ok | {:error, any()}
  def delete_api_key(key_name, opts \\ []) do
    path = Path.join(@keys_path, "#{key_name}")

    with {:ok, _} <- Requester.delete(path, opts) do
      :ok
    end
  end
end
