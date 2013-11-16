class AccessPointList
  include WpaCliRuby

  # Initialize with scan results. This assumes that cli_client.scan()
  # has been called elsewhere. When this application is run with the
  # wifi interface in AP mode, calling scan() is destructive.
  def initialize(cli_client = WpaCli.new)
    @access_points = cli_client.scan_results
  end

  def access_points
    strongest_unique_ssids_sorted_alphabetically
  end

  def strongest_unique_ssids_sorted_alphabetically
    strongest_unique_ssids.
      sort_by { |network| network.ssid.downcase }
  end

  def strongest_unique_ssids
    network_groups.
      map {|network_group| network_group.sort_by { |network| network.signal_level}.reverse.take(1)}.
      flatten
  end

  def network_groups
    access_points_grouped_by_ssid.map {|ssid, network_group| network_group}
  end

  def access_points_grouped_by_ssid
    access_points_with_an_ssid.group_by {|network| network.ssid}
  end

  def access_points_with_an_ssid
    @access_points.reject { |network| network.ssid.nil? }
  end
end
