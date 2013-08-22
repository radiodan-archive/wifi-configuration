require 'sinatra/base'
require 'wpa_cli_ruby'
require_relative 'wpa_cli_web/access_point_list'

class WpaCliWeb < Sinatra::Base
  include WpaCliRuby

  def wpa_cli_client
    WpaCli.new(DummyWpaCliWrapper.new)
  end

  template :networks do
    <<-eos
      <ul>
      <% @access_points.each do |ap| %>
        <li><%= ap.ssid%> (<%= ap.signal_level %>)</li>
      <% end %>
      </ul>
    eos
  end

  get '/networks' do
    access_point_list = AccessPointList.new(wpa_cli_client)
    @access_points = access_point_list.access_points
    erb :networks
  end

  get '/connection/new' do
  end
end
