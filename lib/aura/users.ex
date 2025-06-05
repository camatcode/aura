# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Users do
  @moduledoc """
  Service module for interacting with a `Aura.Model.HexUser`

  <!-- tabs-open -->

  #{Aura.Doc.resources()}

  <!-- tabs-close -->
  """

  import Aura.Common

  alias Aura.Common
  alias Aura.Model.HexAuditLog
  alias Aura.Model.HexUser
  alias Aura.Requester

  require Logger

  @base_path "/users"

  @doc """
  Requests a hex user be created

  > #### 📄 Terms of Service {: .warning}
  >
  > If your service is using hex.pm as a backend, you **must** have users to agree to
  > Hex's [Terms of Service](https://hex.pm/policies/termsofservice)

  <!-- tabs-open -->
  ### 🏷️ Params
    * **opts**

  #{Aura.Doc.returns(success: "{:ok, %HexUser{...}}", failure: "{:error, (some error)}")}

  ### 💻 Examples

      iex> Application.delete_env(:aura, :api_key)
      iex> username = Faker.Internet.user_name()
      iex> password = Faker.Internet.slug()
      iex> emails = [Faker.Internet.email()]
      iex> alias Aura.Users
      iex> opts = [repo_url: "http://localhost:4000/api"]
      iex> {:ok, _user} =  Users.create_user(username, password, emails, opts)


  #{Aura.Doc.api_details(%{method: :POST, route: "/api/users", controller: "UserController", action: :create})}
    
  <!-- tabs-close -->
  """
  @spec create_user(
          username :: Common.username(),
          password :: String.t(),
          emails :: [Common.email()],
          opts :: list()
        ) :: {:ok, HexUser.t()} | {:error, any()}
  def create_user(username, password, emails, opts \\ [])
      when is_bitstring(username) and is_bitstring(password) and is_list(emails) do
    if Requester.find_repo_url(opts) == Requester.hex_pm_url() do
      Logger.warning(
        "By using create_user, you are agreeing to Hex's terms of service. See: https://hex.pm/policies/termsofservice"
      )
    end

    emails = Enum.map(emails, fn email -> %{"email" => email} end)
    opts = Keyword.merge([json: %{username: username, password: password, emails: emails}], opts)

    with {:ok, %{body: body}} <- Requester.post(@base_path, opts) do
      {:ok, HexUser.build(body)}
    end
  end

  @doc """
  Grabs a hex user, given their **username_or_email**

  <!-- tabs-open -->
  ### 🏷️ Params
    * **username_or_email** ::  `t:Aura.Common.username/0` |  `t:Aura.Common.email/0`
    * **opts** :: option parameters used to modify requests

  #{Aura.Doc.returns(success: "{:ok, %HexUser{...}}", failure: "{:error, (some error)}")}

  ### 💻 Examples

      iex> alias Aura.Users
      iex> opts = [repo_url: "http://localhost:4000/api"]
      iex> {:ok, _user} =  Users.get_user("eric@example.com", opts)

  #{Aura.Doc.api_details(%{method: :GET, route: "/api/users/:username_or_email", controller: "UserController", action: :show})}

  <!-- tabs-close -->
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
  Grabs the hex user representing the currently authenticated user

  <!-- tabs-open -->
  ### 🏷️ Params
    * **opts**

  #{Aura.Doc.returns(success: "{:ok, %HexUser{...}}", failure: "{:error, (some error)}")}

  ### 💻 Examples

      iex> alias Aura.Users
      iex> opts = [repo_url: "http://localhost:4000/api"]
      iex> {:ok, _user} =  Users.get_current_user(opts)

  #{Aura.Doc.api_details(%{method: :GET, route: "/api/users/me", controller: "UserController", action: :me})}

  <!-- tabs-close -->
  """
  @spec get_current_user(opts :: list) :: {:ok, HexUser.t()} | {:error, any()}
  def get_current_user(opts \\ []) do
    path = Path.join(@base_path, "me")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexUser.build(body)}
    end
  end

  @doc """
  Streams audit logs, scoped to the current authenticated user

  <!-- tabs-open -->
  ### 🏷️ Params
    * **opts**
      * **page** :: page number to start streaming from

  #{Aura.Doc.returns(success: "Stream.resource/3")}

  ### 💻 Examples

      iex> alias Aura.Users
      iex> opts = [repo_url: "http://localhost:4000/api"]
      iex> audit_logs =  Users.stream_audit_logs(opts)
      iex> Enum.empty?(audit_logs)
      false

  #{Aura.Doc.api_details(%{method: :GET, route: "/api/users/audit-logs", controller: "UserController", action: :audit_logs})}

  <!-- tabs-close -->
  """
  @spec stream_audit_logs(opts :: list()) :: Enumerable.t()
  def stream_audit_logs(opts \\ []) do
    path = Path.join(@base_path, "me/audit-logs")
    stream_paginate(path, &HexAuditLog.build/1, opts)
  end

  @doc """
  Resets a specified user's password

  <!-- tabs-open -->
  ### 🏷️ Params
    * **username_or_email** ::  `t:Aura.Common.username/0` |  `t:Aura.Common.email/0`
    * **opts** :: option parameters used to modify requests

  #{Aura.Doc.returns(success: ":ok", failure: "{:error, (some error)}")}

  ### 💻 Examples

      iex> alias Aura.Users
      iex> opts = [repo_url: "http://localhost:4000/api"]
      iex> {:ok, user} =  Users.get_current_user(opts)
      iex> Users.reset_user_password(user.email, opts)
      :ok

  #{Aura.Doc.api_details(%{method: :GET, route: "/api/users/:username_or_email/reset", controller: "UserController", action: :reset})}

  <!-- tabs-close -->
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
