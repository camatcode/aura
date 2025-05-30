# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Common do
  @moduledoc false

  alias Aura.Requester

  def stream_paginate(path, build_func, opts) do
    qparams =
      Keyword.merge([page: 1], opts)

    opts =
      opts
      |> Keyword.delete(:page)
      |> Keyword.delete(:search)
      |> Keyword.delete(:sort)

    start_fun = fn -> max(1, qparams[:page]) end
    end_fun = fn _ -> :ok end

    continue_fun = &paginate_with_page(&1, path, qparams, build_func, opts)

    Stream.resource(start_fun, continue_fun, end_fun)
  end

  def determine_path(opts, path) do
    if opts[:repo] do
      {Path.join("/repos/#{opts[:repo]}", path), Keyword.delete(opts, :repo)}
    else
      {path, opts}
    end
  end

  defp paginate_with_page(page, _path, _qparams, _build_func, _opts) when page < 1 do
    {:halt, page}
  end

  defp paginate_with_page(page, path, qparams, build_func, opts) when page >= 1 do
    path
    |> get_page(page, qparams, opts)
    |> case do
      {:ok, page_of_items} ->
        items = Enum.map(page_of_items, build_func)
        next_page = if Enum.empty?(items), do: -1, else: page + 1
        {items, next_page}

      # coveralls-ignore-start
      e ->
        {:halt, {:error, e}}
    end

    # coveralls-ignore-stop
  end

  defp get_page(path, page, qparams, opts) do
    qparams = Keyword.put(qparams, :page, page)

    opts = Keyword.put(opts, :qparams, qparams)

    with {:ok, %{body: body}} <- Requester.get(path, opts) do
      {:ok, body}
    end
  end
end
