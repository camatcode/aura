# SPDX-License-Identifier: Apache-2.0
defmodule Aura.Requester do
  @moduledoc false

  require Logger

  @base_url "https://hex.pm/api"

  def request(method, path, opts \\ []) do
    qparams = opts[:qparams]
    is_retry = opts[:is_retry]

    opts =
      opts
      |> Keyword.delete(:qparams)
      |> Keyword.delete(:is_retry)
      |> Keyword.put(:headers, [user_agent_header()])

    path =
      @base_url
      |> Path.join(path)
      |> handle_qparams(qparams)

    method
    |> make_request(path, opts)
    |> case do
      {:ok,
       %Req.Response{
         status: 200,
         body: _body,
         headers: headers
       }} = resp ->
        respect_limits(headers)
        resp

      {:ok, %Req.Response{status: 204, body: _body, headers: headers}} = resp ->
        respect_limits(headers)
        resp

      {:ok, %Req.Response{status: 429, headers: headers}} ->
        if is_retry do
          {:error, "Rate limit exceeded"}
        else
          respect_limits(headers)
          new_opts = Keyword.put(opts, :is_retry, true)
          request(method, path, new_opts)
        end

      other ->
        {:error, other}
    end
  end

  def get(path, opts \\ []), do: request(:get, path, opts)

  def post(path, opts \\ []), do: request(:post, path, opts)

  def put(path, opts \\ []), do: request(:put, path, opts)

  def patch(path, opts \\ []), do: request(:patch, path, opts)

  def delete(path, opts \\ []), do: request(:delete, path, opts)

  defp user_agent_header do
    config = Mix.Project.config()
    app = config[:app] || :unknown
    version = config[:version] || "0.0.0"
    e_version = System.version()
    mix_env = Mix.env()
    user_agent = "#{app}/#{version} (Elixir/#{e_version}) (OTP/#{otp_version()})(#{mix_env})"
    {"User-Agent", user_agent}
  end

  defp otp_version do
    major = :erlang.system_info(:otp_release) |> List.to_string()
    vsn_file = Path.join([:code.root_dir(), "releases", major, "OTP_VERSION"])

    try do
      {:ok, contents} = File.read(vsn_file)
      String.split(contents, "\n", trim: true)
    else
      [full] -> full
      _ -> major
    catch
      :error, _ -> major
    end
  end

  defp handle_qparams(url, nil), do: url

  defp handle_qparams(url, qparams) do
    qparams =
      qparams
      |> Enum.filter(fn {_k, v} -> v end)
      |> URI.encode_query()

    url
    |> URI.parse()
    |> Map.put(:query, qparams)
    |> URI.to_string()
  end

  defp make_request(:get, path, opts), do: Req.get(path, opts)
  defp make_request(:post, path, opts), do: Req.post(path, opts)
  defp make_request(:put, path, opts), do: Req.put(path, opts)
  defp make_request(:delete, path, opts), do: Req.delete(path, opts)
  defp make_request(:patch, path, opts), do: Req.patch(path, opts)

  defp respect_limits(%{"x-ratelimit-remaining" => ["0"]} = headers) do
    [reset] = headers["x-ratelimit-reset"] || ["0"]

    unix_reset =
      reset
      |> String.to_integer()
      |> DateTime.from_unix!()

    wait_ms =
      unix_reset
      |> DateTime.diff(DateTime.now!("Etc/UTC"), :millisecond)
      |> max(0)

    Logger.warning("Hit a rate limit, waiting #{wait_ms} milliseconds and retrying.")

    :timer.sleep(wait_ms)
  end

  defp respect_limits(_), do: :ok
end
