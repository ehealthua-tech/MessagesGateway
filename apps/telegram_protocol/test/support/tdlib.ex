defmodule TDLibTest do
  alias TDLib.Object
  @default_config %Object.TdlibParameters{
    :use_test_dc              => false,
    :database_directory       => "/tmp/tdlib",
    :use_file_database        => true,
    :use_chat_info_database   => true,
    :use_message_database     => true,
    :use_secret_chats         => false,
    :api_id                   => "0",
    :api_hash                 => "0",
    :system_language_code     => "en",
    :device_model             => "Unknown",
    :system_version           => "Unknown",
    :application_version      => "Unknown",
    :enable_storage_optimizer => true,
    :ignore_file_names        => true
  }

  def default_config(), do: @default_config
  def open(_,_,_), do: {:ok, self()}
  def transmit(_,_), do: :ok
end