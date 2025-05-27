ExUnit.configure(formatters: [JUnitFormatter, ExUnit.CLIFormatter])
{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start(timeout: 2 * 60 * 1000)

defmodule TestHelper do
  @moduledoc false

  def get_mock_repo, do: ExDoppler.get_secret_raw!("gh", "dev", "MOCK_HEX_REPO")
  def get_mock_api_key, do: ExDoppler.get_secret_raw!("gh", "dev", "MOCK_HEX_REPO_KEY")
end
