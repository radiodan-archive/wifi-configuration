require 'sinatra/base'
require 'wpa_cli_ruby'
require_relative 'wpa_cli_web/access_point_list'

class WpaCliWeb < Sinatra::Base
  include WpaCliRuby

  configure do
    set :method_override, true
    set :public_folder, File.expand_path(File.join(File.dirname(__FILE__), 'wpa_cli_web', 'public'))
  end

  def wpa_cli_client
    if ENV['RACK_ENV'] == "development"
      WpaCli.new(DummyWpaCliWrapper.new)
    else
      WpaCli.new
    end
  end

  before do
    @host = request.host_with_port
  end

  template :index do
    <<-eos
    <html>
       <head>
          <title>Network Authentication Required</title>
          <meta http-equiv="refresh"
                content="0; url=//<%= @host %>/access_points">
       </head>
       <body>
          <p>You need to <a href="//<%= @host %>/access_points">
          authenticate with the local network</a> in order to gain
          access.</p>
       </body>
    </html>
    eos
  end

  template :layout do
    <<-eos
      <html>
        <head>
          <title>Wi-Fi Configuration</title>
          <link rel="stylesheet" href="/bower_components/house-style/house-style.min.css">
        </head>
        <body>
          <header class="masthead">
            <div class="grid">
              <div class="grid-col grid-10">
                <span class="masterbrand">BBC</span>
                <span class="dept">Radiodan</span>
              </div>
              <div class="grid-col grid-2"><%= @host %></div>
            </div><!-- .grid -->
          </header>
          <div class="grid">
          <%= yield %>
          </div>
        </body>
      </html>
    eos
  end

  template :networks do
    <<-eos
      <ul class="grid-col grid-12">
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
      <h1 class="grid-col grid-12"><%= @ssid %></h1>
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

  get '/' do
    status 511
    erb :index, :layout => false
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
    wpa_cli_client.set_network(id, "disabled", 0)
    wpa_cli_client.save_config

    redirect "/restart"
  end

  get '/restart' do
    "Restart for these changes to take effect"
  end
end
