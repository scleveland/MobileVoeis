require 'rho/rhocontroller'
require 'helpers/browser_helper'

class SitesController < Rho::RhoController
  include BrowserHelper
  @@sensor_values = nil
  
  #GET /Sites
  def index
    render
  end
  
  def sites
    @@project_id = @params['project_id']
    Rho::AsyncHttp.get(
                :url =>  "http://voeis.msu.montana.edu/projects/" + @params['project_id'] + "/apivs/get_project_sites.json?api_key=e79b135dcfeb6699bbaa6c9ba9c1d0fc474d7adb755fa215446c398cae057adf",
                :callback => (url_for :action => :get_returned_sites),
                :callback_param => "")
    render :action => :wait
  end
  
  def get_error
      @@error_params
  end
  
  def get_returned_sites
    puts "httpget_callback: #{@params}"
    if @params['status'] != 'ok'
        http_error = @params['http_error'].to_i if @params['http_error']
            @@error_params = @params
            WebView.navigate ( url_for :action => :show_error )         
    else
        @@sites= @params['body']
        WebView.navigate ( url_for :action => :show_result )
    end
  end
  
  def show_result
   render :action => :index, :back => '/app'
  end

  def show_error
   render :action => :error, :back => '/app'
  end

  def get_sites
    @@sites
  end

  
  def cancel_httpcall
    Rho::AsyncHttp.cancel( url_for( :action => :httpget_callback) )

    @@get_result  = 'Request was cancelled.'
    render :action => :index, :back => '/app'
  end
  
  

  # GET /Sites/{1}
  def show
    @site = Hash.new
    @site['id'] = @params['id']
    @site['code'] = @params['code']
    @site['lat'] = @params['lat']
    @site['long'] = @params['long']
    @site['name'] = @params['name']
    render :action => :show
  end

  def sensor_values
    Rho::AsyncHttp.get(
                :url =>  "http://voeis.msu.montana.edu/projects/" + @@project_id + "/apivs/get_project_site_sensor_data_last_update.json?api_key=e79b135dcfeb6699bbaa6c9ba9c1d0fc474d7adb755fa215446c398cae057adf&site_id=" + @params['site_id'],
                :callback => (url_for :action => :get_returned_sensor_values),
                :callback_param => "")
    render :action => :sensor_wait
  end

  def get_returned_sensor_values
    puts "httpget_callback: #{@params}"
    if @params['status'] != 'ok'
        http_error = @params['http_error'].to_i if @params['http_error']
            @@error_params = @params
            WebView.navigate ( url_for :action => :show_error )         
    else
        @@sensor_values= @params['body']
        WebView.navigate ( url_for :action => :show_sensor_values )
    end
  end
  
  def show_sensor_values
   render :action => :show_sensor_values, :back => '/app'
  end
  
  def get_sites
    @@sensor_values
  end
  
  def map_it
    # Build up the parameters for the call
    map_params = {:provider => 'Google',
          # General settings for the map, type, viewable area, zoom, scrolling etc.
          # We center on the user, with 0.2 degrees view
    :settings => {:map_type => "hybrid",:region => [@params['lat'].to_f, @params['long'].to_f, 0.2, 0.2],
                  :zoom_enabled => true,:scroll_enabled => true,:shows_user_location => false,
                  :api_key => '04mfYKG8i5P8fl60_4vYignpUCFXSz2v-CRUEGA'},

          # This annotation shows the user, give the marker a title, and a link directly to that user
    :annotations => [{
                       :latitude => @params['lat'].to_f, 
                       :longitude => @params['long'].to_f, 
                       :title => "#{@params['name']}", 
                       :subtitle => "Go to ",
                       :url => "/app/Sites/{#{@params['name']}}"
                    }]
  }

  # This call displays the map on top of the entire screen
    MapView.create map_params

      # After the user closes the map, they will be shown with whatever you redirect or render here.
    redirect :action => :index
  end

  # GET /Sites/new
  def new
    @sites = Sites.new
    render :action => :new
  end

  # GET /Sites/{1}/edit
  def edit
    @sites = Sites.find(@params['id'])
    if @sites
      render :action => :edit
    else
      redirect :action => :index
    end
  end

  # POST /Sites/create
  def create
    @sites = Sites.create(@params['sites'])
    redirect :action => :index
  end

  # POST /Sites/{1}/update
  def update
    @sites = Sites.find(@params['id'])
    @sites.update_attributes(@params['sites']) if @sites
    redirect :action => :index
  end

  # POST /Sites/{1}/delete
  def delete
    @sites = Sites.find(@params['id'])
    @sites.destroy if @sites
    redirect :action => :index
  end
end
