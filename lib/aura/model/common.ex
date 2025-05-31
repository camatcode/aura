# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.Common do
  @moduledoc """
  Module covering functions common to all Aura Models
  """

  @typedoc """
  Unix DateTime for when the record was inserted into the database
  """
  @type inserted_at :: DateTime.t()

  @typedoc """
  Unix DateTime for when the record was last modified in the database
  """
  @type updated_at :: DateTime.t()

  @typedoc """
  The URL required to perform operations on this record
  """
  @type url :: URI.t()

  @doc """
  Cleans and validates a map into something Aura Model's can easily build
  """
  @spec prepare(m :: map()) :: list()
  def prepare(m) when is_map(m) do
    m
    |> prepare_keys()
    |> prepare_values()
  end

  defp prepare_keys(m) do
    m
    |> snake_case_keys()
    |> atomize_keys()
  end

  defp prepare_values(m) do
    Enum.map(m, fn {key, val} ->
      if val && String.ends_with?("#{key}", "_at"),
        do: {key, DateTimeParser.parse_datetime!(val)},
        else: {key, val}
    end)
  end

  defp snake_case_keys(m) do
    Enum.map(m, fn {key, val} ->
      {ProperCase.snake_case(key), val}
    end)
  end

  defp atomize_keys(m) do
    Enum.map(m, fn {key, val} ->
      key = String.to_atom(key)
      {key, val}
    end)
  end
end
