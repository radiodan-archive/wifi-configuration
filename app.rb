require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require 'wpa_cli_ruby'

class WpaCliWeb < Sinatra::Base
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

  template :networks do
    <<-eos
      <ul>
      <% @networks.each do |network| %>
        <li><%= network.ssid%> (<%= network.signal_level %>)</li>
      <% end %>
      </ul>
    eos
  end

  get '/networks' do
    network_list = NetworkList.new
    @networks = network_list.networks
    erb :networks
  end

  get '/connection/new' do
  end
end
