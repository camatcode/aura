# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.HexRepo do
  @moduledoc false

  import Aura.Model.Common

  alias Aura.Model.HexRepo

  defstruct [
    :name,
    :public,
    :active,
    :billing_active,
    :inserted_at,
    :updated_at
  ]

  def build(m) when is_map(m) do
    m
    |> prepare()
    |> then(&Kernel.struct(HexRepo, &1))
  end
end
