class AccessPointList
  include WpaCliRuby

  def initialize(cli_client = WpaCli.new)
    cli_client.scan
    @access_points = cli_client.scan_results
  end

  def access_points
    @access_points.
      group_by {|network| network.ssid}.
      map {|ssid, network_group| network_group}.
      map {|network_group| network_group.sort_by { |network| network.signal_level}.reverse.take(1)}.
      flatten.
      sort_by { |network| network.signal_level }.
      reverse
  end
end
