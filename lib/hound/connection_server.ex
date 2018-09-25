defmodule Hound.ConnectionServer do
  @moduledoc false

  def start_link(options \\ []) do
    Agent.start_link(fn ->
      %{
        driver_info: load_driver_info(options),
        configs: load_configs(options)
      }
    end, name: __MODULE__)
  end

  def driver_info do
    {:ok, Agent.get(__MODULE__, &(&1.driver_info))}
  end

  def configs do
    {:ok, Agent.get(__MODULE__, &(&1.configs))}
  end

  def put_in_configs(key, value) do
    {:ok, Agent.update(__MODULE__, fn %{configs: configs} = state ->
      %{state | configs: Map.put(configs, key, value)}
    end)}
  end

  def put_in_driver_info(key, value) do
    {:ok, Agent.update(__MODULE__, fn %{driver_info: driver_info} = state ->
      %{state | driver_info: Map.put(driver_info, key, value)}
    end)}
  end

  defp load_driver_info(options) do
    driver = options[:driver] || Application.get_env(:hound, :driver, "selenium")

    {default_port, default_path_prefix, default_browser} = case driver do
      "chrome_driver" ->
        {9515, nil, "chrome"}
      "phantomjs" ->
        {8910, nil, "phantomjs"}
      _ -> # assume selenium
        {4444, "wd/hub/", "firefox"}
    end

    browser = options[:browser] || Application.get_env(:hound, :browser, default_browser)
    host = options[:host] || Application.get_env(:hound, :host, "http://localhost")
    port = options[:port] || Application.get_env(:hound, :port, default_port)
    path_prefix = options[:path_prefix] || Application.get_env(:hound, :path_prefix, default_path_prefix)

    %{
      driver: driver,
      browser: browser,
      host: host,
      port: port,
      path_prefix: path_prefix
    }
  end

  defp load_configs(options) do
    %{
      host: options[:app_host] || Application.get_env(:hound, :app_host, "http://localhost"),
      port: options[:app_port] || Application.get_env(:hound, :app_port, 4001)
    }
  end
end
