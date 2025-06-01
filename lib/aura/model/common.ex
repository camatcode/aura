# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.Common do
  @moduledoc """
  Module covering functions common to all Aura Models
  """

  @typedoc """
  UTC `DateTime` for when the record was inserted into the database
  """
  @type inserted_at :: DateTime.t()

  @typedoc """
  URL with human-readable package/release documentation
  """
  @type docs_html_url :: URI.t()

  @typedoc """
  URL with human-readable package/release information
  """
  @type html_url :: URI.t()

  @typedoc """
  An email address associated with this record
  """
  @type email :: String.t()

  @typedoc """
  UTC `DateTime` for when the record was last modified in the database
  """
  @type updated_at :: DateTime.t()

  @typedoc """
  The URL required to perform operations on this record
  """
  @type url :: URI.t()

  @typedoc """
  A unique, human-readable ID for a user
  """
  @type username :: String.t()

  @doc """
  Cleans and validates a map into something Aura models can easily build
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
