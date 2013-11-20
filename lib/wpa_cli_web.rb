require 'sinatra/base'
require 'wpa_cli_ruby'
require_relative 'wpa_cli_web/access_point_list'

class WpaCliWeb < Sinatra::Base
  include WpaCliRuby

  def self.wpa_cli_client
    raise 'wpa_cli not available' if settings.production? && !WpaCliWrapper.available?

    if WpaCliWrapper.available?
      WpaCli.new
    else
      WpaCli.new(DummyWpaCliWrapper.new)
    end
  end

  configure do
    set :method_override,   true
    set :public_folder,     File.expand_path(File.join(File.dirname(__FILE__), 'wpa_cli_web', 'public'))
    set :views,             File.expand_path(File.join(File.dirname(__FILE__), 'wpa_cli_web', 'views'))
    set :wpa_cli_client,    wpa_cli_client
    set :access_point_list, AccessPointList.new(settings.wpa_cli_client)
  end

  helpers do
    def product_name
      ENV['APPLICATION_NAME'] || ENV['application_name'] || "Raspberry Pi Wi-Fi"
    end

    def wpa_cli_client
      settings.wpa_cli_client
    end
  end

  before do
    @host = request.host_with_port
  end

  get '/' do
    redirect '/access_points'
  end

  get '/access_points' do
    @access_points = settings.access_point_list.access_points
    if request.xhr?
      erb :access_points_list, :layout => false
    else
      erb :access_points
    end
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
    if password.empty?
      wpa_cli_client.set_network(id, "key_mgmt", :NONE)
    else
      wpa_cli_client.set_network(id, "psk", password)
    end
    wpa_cli_client.set_network(id, "disabled", 0)
    wpa_cli_client.save_config

    redirect "/restart"
  end

  get '/restart' do
    erb :restart
  end

  post '/restart' do
    `sudo reboot` if ENV['RACK_ENV'] == "production"
    erb :restarting
  end
end
