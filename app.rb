require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require 'wpa_cli_ruby'
require_relative 'lib/network_list'

class WpaCliWeb < Sinatra::Base
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
