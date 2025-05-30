# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexUser do
  @moduledoc false

  import Aura.Model.Common

  defstruct [
    :username,
    :email,
    :inserted_at,
    :updated_at,
    :url
  ]

  def build(m) when is_map(m) do
    m
    |> prepare()
    |> then(&struct(Aura.Model.HexUser, &1))
  end
end
