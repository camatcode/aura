# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Users do
  @moduledoc """
  Service module for interacting with a `Aura.Model.HexUser`
  """

  import Aura.Common

  alias Aura.Common
  alias Aura.Model.HexAuditLog
  alias Aura.Model.HexUser
  alias Aura.Requester

  require Logger

  @base_path "/users"

  @doc """
  Requests a Hex user be created
  """
  @spec create_user(
          username :: Common.username(),
          password :: String.t(),
          email :: Common.email(),
          opts :: list()
        ) :: {:ok, HexUser.t()} | {:error, any()}
  def create_user(username, password, email, opts \\ [])
      when is_bitstring(username) and is_bitstring(password) and is_bitstring(email) do
    if Requester.find_repo_url(opts) == Requester.hex_pm_url() do
      Logger.warning(
        "By using create_user, you are agreeing to Hex's terms of service. See: https://hex.pm/policies/termsofservice"
      )
    end

    opts = Keyword.merge([json: %{username: username, password: password, email: email}], opts)

    with {:ok, %{body: body}} <- Requester.post(@base_path, opts) do
      {:ok, HexUser.build(body)}
    end
  end

  @doc """
  Returns a `Aura.Model.HexUser`, given their **username_or_email**
  """
  @spec get_user(
          username_or_email :: Common.username() | Common.email(),
          opts :: list()
        ) :: {:ok, HexUser.t()} | {:error, any()}
  def get_user(username_or_email, opts \\ []) when is_bitstring(username_or_email) do
    path = Path.join(@base_path, username_or_email)

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexUser.build(body)}
    end
  end

  @doc """
  Returns a `Aura.Model.HexUser` representing the authenticated requester
  """
  @spec get_current_user(opts :: list) :: {:ok, HexUser.t()} | {:error, any()}
  def get_current_user(opts \\ []) do
    path = Path.join(@base_path, "me")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexUser.build(body)}
    end
  end

  @doc """
  Returns a stream of `Aura.Model.HexAuditLog`, scoped to the authenticated requester
  """
  @spec stream_audit_logs(opts :: list()) :: Enumerable.t()
  def stream_audit_logs(opts \\ []) do
    path = Path.join(@base_path, "me/audit-logs")
    stream_paginate(path, &HexAuditLog.build/1, opts)
  end

  @doc """
  Resets a specified user's password  
  """
  @spec reset_user_password(
          username_or_email :: Common.username() | Common.email(),
          opts :: list()
        ) :: :ok | {:error, any()}
  def reset_user_password(username_or_email, opts \\ []) do
    path = Path.join(@base_path, "#{username_or_email}/reset")

    with {:ok, _} <- Requester.post(path, opts) do
      :ok
    end
  end
end
