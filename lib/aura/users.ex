# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Users do
  @moduledoc Aura.Doc.mod_doc("Service module for interacting with Hex users")

  import Aura.Common

  alias Aura.Common
  alias Aura.Model.HexAuditLog
  alias Aura.Model.HexUser
  alias Aura.Requester

  require Logger

  @base_path "/users"

  @tos_warning """
  If your service is using hex.pm as a backend, you **must** have users to agree to Hex's [Terms of Service](https://hex.pm/policies/termsofservice)
  """

  @doc Aura.Doc.func_doc("Requests a hex user be created",
         warning: {"📄 Terms of Service", @tos_warning},
         params: %{
           username: "`t:Aura.Common.username/0`",
           password: "User's password",
           emails: "[`t:Aura.Common.email/0`]",
           opts: "option parameters used to modify requests"
         },
         success: "{:ok, %HexUser{...}}",
         failure: "{:error, (some error)}",
         api: %{method: :post, route: @base_path, controller: :User, action: :create},
         example: """
         iex> Application.delete_env(:aura, :api_key)
         iex> username = Faker.Internet.user_name()
         iex> password = Faker.Internet.slug()
         iex> emails = [Faker.Internet.email()]
         iex> alias Aura.Users
         iex> opts = [repo_url: "http://localhost:4000/api"]
         iex> {:ok, _user} =  Users.create_user(username, password, emails, opts)
         """
       )
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

  @doc Aura.Doc.func_doc("Grabs a hex user, given their **username_or_email**",
         params: %{
           username_or_email: "`t:Aura.Common.username/0` |  `t:Aura.Common.email/0`",
           opts: "option parameters used to modify requests"
         },
         success: "{:ok, %HexUser{...}}",
         failure: "{:error, (some error)}",
         api: %{route: Path.join(@base_path, ":username_or_email"), controller: :User, action: :show},
         example: """
         iex> alias Aura.Users
         iex> opts = [repo_url: "http://localhost:4000/api"]
         iex> {:ok, _user} =  Users.get_user("eric@example.com", opts)
         """
       )
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

  @doc Aura.Doc.func_doc(
         "Grabs the hex user representing the currently authenticated user",
         params: %{opts: "option parameters used to modify requests"},
         success: "{:ok, %HexUser{...}}",
         failure: "{:error, (some error)}",
         api: %{route: Path.join(@base_path, "me"), controller: :User, action: :me},
         example: """
         iex> alias Aura.Users
         iex> opts = [repo_url: "http://localhost:4000/api"]
         iex> {:ok, _user} =  Users.get_current_user(opts)
         """
       )
  @spec get_current_user(opts :: list) :: {:ok, HexUser.t()} | {:error, any()}
  def get_current_user(opts \\ []) do
    path = Path.join(@base_path, "me")

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, HexUser.build(body)}
    end
  end

  @doc Aura.Doc.func_doc("Streams audit logs, scoped to the current authenticated user",
         params: %{"opts.page": "start from this page number"},
         success: "Stream.resource/3",
         example: """
         iex> alias Aura.Users
         iex> opts = [repo_url: "http://localhost:4000/api"]
         iex> audit_logs =  Users.stream_audit_logs(opts)
         iex> Enum.empty?(audit_logs)
         false
         """,
         api: %{route: Path.join(@base_path, "me/audit-logs"), controller: :User, action: :audit_logs}
       )
  @spec stream_audit_logs(opts :: list()) :: Enumerable.t()
  def stream_audit_logs(opts \\ []) do
    path = Path.join(@base_path, "me/audit-logs")
    stream_paginate(path, &HexAuditLog.build/1, opts)
  end

  @doc Aura.Doc.func_doc("Resets a specified user's password",
         params: %{
           username_or_email: "`t:Aura.Common.username/0` |  `t:Aura.Common.email/0`",
           opts: "option parameters used to modify requests"
         },
         success: ":ok",
         failure: "{:error, (some error)}",
         api: %{route: Path.join(@base_path, ":username_or_email/reset"), controller: :User, action: :reset},
         example: """
         iex> alias Aura.Users
         iex> opts = [repo_url: "http://localhost:4000/api"]
         iex> {:ok, user} =  Users.get_current_user(opts)
         iex> Users.reset_user_password(user.email, opts)
         :ok
         """
       )
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
