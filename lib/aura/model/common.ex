# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Model.Common do
  @moduledoc """
  Common capabilities across all Aura models

  <!-- tabs-open -->

  #{Aura.Doc.resources()}

  <!-- tabs-close -->
  """

  @typedoc """
  `DateTime` for when the record was inserted into the database

  <!-- tabs-open -->
  ### 💻 Examples

  ```elixir
  ~U[2025-05-29 18:15:18.244790Z]
  ```
  <!-- tabs-close -->
  """
  @type inserted_at :: DateTime.t()

  @typedoc """
  URL with human-readable package/release documentation

  <!-- tabs-open -->
  ### 💻 Examples

  ```elixir
  "https://hexdocs.pm/aura/0.9.0/"
  ```
  <!-- tabs-close -->
  """
  @type docs_html_url :: URI.t()

  @typedoc """
  URL with human-readable package/release information

  <!-- tabs-open -->
  ### 💻 Examples

  ```elixir
  "https://hex.pm/packages/aura/0.9.0"
  ```

  <!-- tabs-close -->
  """
  @type html_url :: URI.t()

  @typedoc """
  `DateTime` for when the record was last modified in the database

  <!-- tabs-open -->
  ### 💻 Examples

  ```elixir
  ~U[2025-06-01 15:13:04.347130Z]
  ```

  <!-- tabs-close -->
  """
  @type updated_at :: DateTime.t()

  @typedoc """
  The URL required to perform operations on this record

  <!-- tabs-open -->
  ### 💻 Examples

  ```elixir
  "https://hex.pm/api/packages/aura/releases/0.9.0"
  ```

  <!-- tabs-close -->
  """
  @type url :: URI.t()

  @doc """
  Cleans and validates a map into something Aura models can easily build

  <!-- tabs-open -->

  ### 🏷️ Params
    * **m** :: A map to clean and validate

  #{Aura.Doc.returns(success: "[{k,v}, {k,v}...]", failure: "raises Error")}

  <!-- tabs-close -->
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
