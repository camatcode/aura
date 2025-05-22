defmodule Aura.Model.Common do
  @moduledoc false

  @spec prepare(m :: map()) :: map()
  def prepare(m) when is_map(m) do
    m
    |> prepare_keys()
    |> prepare_values()
    |> Enum.reject(fn {_k, v} -> v == nil end)
    |> Enum.map(fn {key, val} ->
      {key, serialize(key, val)}
    end)
  end

  defp prepare_keys(m) do
    m
    |> snake_case_keys()
    |> atomize_keys()
  end

  def prepare_values(m) do
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

  defp serialize(_k, v), do: v
end
