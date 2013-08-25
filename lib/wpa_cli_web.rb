require 'sinatra/base'
require 'wpa_cli_ruby'
require_relative 'wpa_cli_web/access_point_list'

class WpaCliWeb < Sinatra::Base
  include WpaCliRuby

  configure do
    set :method_override, true
    set :public_folder,   File.expand_path(File.join(File.dirname(__FILE__), 'wpa_cli_web', 'public'))
    set :views,           File.expand_path(File.join(File.dirname(__FILE__), 'wpa_cli_web', 'views'))
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

  get '/' do
    redirect '/access_points'
  end

  get '/access_points' do
    access_point_list = AccessPointList.new(wpa_cli_client)
    @access_points = access_point_list.access_points
    erb :access_points, :layout => !request.xhr?
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
    erb :restart
  end

  post '/restart' do
    erb :restarting
  end
end
