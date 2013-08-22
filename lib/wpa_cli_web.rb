require 'sinatra/base'
require 'wpa_cli_ruby'
require_relative 'wpa_cli_web/access_point_list'

class WpaCliWeb < Sinatra::Base
  include WpaCliRuby

  configure do
    set :method_override, true
  end

  def wpa_cli_client
    if ENV['RACK_ENV'] == "development"
      WpaCli.new(DummyWpaCliWrapper.new)
    else
      WpaCli.new
    end
  end

  template :networks do
    <<-eos
      <ul>
      <% @access_points.each do |ap| %>
        <li><%= ap.ssid %> (<%= ap.signal_level %>)
            <form method="post" action="/networks">
              <input type="hidden" name="ssid" value="<%= ap.ssid %>" />
              <input type="submit" value="Connect" />
            </form>
        </li>
      <% end %>
      </ul>
    eos
  end

  template :networks_edit do 
    <<-eos
      <h1><%= @ssid %></h1>
      <form method="post" action="/networks/<%= @id %>">
        <input type="hidden" name="_method" value="put" />
        <input type="hidden" name="ssid" value="<%= @ssid %>" />
        <label for="password">
          Password: <input type="text" name="password" />
        </label>
        <input type="submit" value="Save" />
      </form>
    eos
  end

  get '/access_points' do
    access_point_list = AccessPointList.new(wpa_cli_client)
    @access_points = access_point_list.access_points
    erb :networks
  end

  post '/networks' do
    id = wpa_cli_client.add_network
    ssid = params[:ssid]
    redirect "/networks/#{id}?ssid=#{ssid}"
  end

  get '/networks/:id' do
    @id = params[:id]
    begin
      @ssid = wpa_cli_client.get_network(@id, 'ssid')
    rescue WpaCliRuby::NetworkNotFound
      @ssid = params[:ssid]
    end
    erb :networks_edit
  end

  put '/networks/:id' do
    id = params[:id]
    ssid = params[:ssid]
    password = params[:password]
    wpa_cli_client.set_network(id, "ssid", ssid)
    if password
      wpa_cli_client.set_network(id, "psk", password)
    else
      wpa_cli_client.set_network(id, "key_mgmt", "NONE")
    end
    wpa_cli_client.enable_network(id)
    wpa_cli_client.save_config

    redirect "/restart"
  end

  get '/restart' do
    "Restart for these changes to take effect"
  end
end
