defmodule Aura.Users do
  @moduledoc false

  alias Aura.Model.HexUser
  alias Aura.Requester

  def get_user(username_or_email, opts \\ []) do
    with {:ok, %{body: body}} <- Requester.get("/users/#{username_or_email}", opts) do
      {:ok, HexUser.build(body)}
    end
  end
end
