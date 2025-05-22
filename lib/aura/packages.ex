defmodule Aura.Packages do
  @moduledoc false

  def list_packages(opts \\ []) do
  end

  defp stream_paginate(path, opts \\ []) do
    qparams =
      Keyword.merge([page: 1], opts)

    start_fun = fn -> max(1, qparams[:page]) end

    end_fun = fn -> nil end

    continue_fun = fn page ->
      qparams = Keyword.put(qparams, :page, page)

      :get
      |> Aura.Requester.request("/packages", qparams: qparams)
      |> case do
        {:ok, body} ->
          {body, page + 1}

        _ ->
          {:halt, nil}
      end
    end

    Stream.resource(start_fun, continue_fun, end_fun)
  end
end
