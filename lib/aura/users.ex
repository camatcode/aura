defmodule Aura.Users do
  @moduledoc false

  alias Aura.Model.HexUser
  alias Aura.Requester

  require Logger

  def create_user(username, password, email, opts \\ [])
      when is_bitstring(username) and is_bitstring(password) and is_bitstring(email) do
    if !opts[:repo_url] do
      Logger.warning(
        "By using create_user, you are agreeing to Hex's terms of service. See: https://hex.pm/policies/termsofservice"
      )
    end

    opts = Keyword.merge([json: %{username: username, password: password, email: email}], opts)

    # See:  https://github.com/hexpm/specifications/issues/41
    "/users"
    |> Requester.post(opts)
    |> case do
      {:ok, %{body: body}} ->
        try do
          {:ok, HexUser.build(body)}
        rescue
          _ -> {:ok, :got_good_status}
        end

      err ->
        err
    end
  end

  def get_user(username_or_email, opts \\ []) when is_bitstring(username_or_email) do
    with {:ok, %{body: body}} <- Requester.get("/users/#{username_or_email}", opts) do
      {:ok, HexUser.build(body)}
    end
  end

  def get_current_user(opts \\ []) do
    with {:ok, %{body: body}} <- Requester.get("/users/me", opts) do
      {:ok, HexUser.build(body)}
    end
  end

  def reset_user_password(username_or_email, opts \\ []) do
    with {:ok, _} <- Requester.post("/users/#{username_or_email}/reset", opts) do
      :ok
    end
  end
end
