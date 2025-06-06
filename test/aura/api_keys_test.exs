defmodule Aura.APIKeysTest do
  use ExUnit.Case

  alias Aura.APIKeys

  @moduletag :capture_log
  doctest APIKeys

  setup do
    TestHelper.setup_state()
  end

  test "api_keys", _state do
    assert {:ok, [api_key]} = APIKeys.list_api_keys()
    assert api_key.authing_key
    assert api_key.inserted_at
    assert api_key.updated_at
    assert api_key.name
    assert api_key.url

    assert {:ok, retrieved} = APIKeys.get_api_key(api_key.name)
    assert retrieved.name == api_key.name

    assert :ok = APIKeys.delete_api_key(api_key.name)
  end

  test "delete all api keys", _state do
    assert :ok = APIKeys.delete_all_api_keys()
  end
end
