require 'minitest/autorun'
require 'wpa_cli_ruby'
require 'mocha'
require_relative '../../lib/wpa_cli_web/access_point_list.rb'

describe AccessPointList do
  before do
    mock_wrapper = stub()
    response = <<-eos
Selected interface 'wlan0'
bssid / frequency / signal level / flags / ssid
12:34:56:78:aa:bb	2437	-47	[WPA-EAP-TKIP][WPA2-EAP-CCMP][ESS]	z_ssid
12:34:56:78:bb:cc	2412	-57	[WPA2-PSK-CCMP][ESS]	a_ssid
43:34:56:78:bb:cc	2412	-87	[WPA-EAP-TKIP][WPA2-EAP-CCMP][ESS]	z_ssid
12:34:56:78:bb:cc	2412	-57	[WPA2-PSK-CCMP][ESS]	B_ssid
eos
    mock_wrapper.expects(:scan_results).returns(response)
    @access_point_list = AccessPointList.new(WpaCliRuby::WpaCli.new(mock_wrapper))
  end

  describe "access_points" do
    it "returns a list of unique, strongest access points sorted alphabetically" do
      assert_equal 3, @access_point_list.access_points.size
      assert_equal "a_ssid", @access_point_list.access_points[0].ssid
      assert_equal "B_ssid", @access_point_list.access_points[1].ssid
      assert_equal "z_ssid", @access_point_list.access_points[2].ssid
    end
  end
end
