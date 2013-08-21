class NetworkList
  include WpaCliRuby

  def initialize
    wpa = WpaCli.new(DummyWpaCliWrapper.new)
    wpa.scan
    @networks = wpa.scan_results
  end

  def networks
    @networks.
      group_by {|network| network.ssid}.
      map {|ssid, network_group| network_group}.
      map {|network_group| network_group.sort_by { |network| network.signal_level}.reverse.take(1)}.
      flatten.
      sort_by { |network| network.signal_level }.
      reverse
  end
end
