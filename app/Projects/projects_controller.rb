require 'rho/rhocontroller'
require 'helpers/browser_helper'

class ProjectsController < Rho::RhoController
  include BrowserHelper

  #GET /Projects
  def index
    Rho::AsyncHttp.get(
                :url =>  "http://voeis.msu.montana.edu/projects/get_user_projects.json?api_key=d7ef0f4fe901e5dfd136c23a4ddb33303da104ee1903929cf3c1d9bd271ed1a7",
                :callback => (url_for :action => :get_returned_projects),
                :callback_param => "")
    render :action => :wait
  end
  
  def projects
    Rho::AsyncHttp.get(
                :url =>  "http://voeis.msu.montana.edu/projects/get_user_projects.json?api_key=e79b135dcfeb6699bbaa6c9ba9c1d0fc474d7adb755fa215446c398cae057adf",
                :callback => (url_for :action => :get_returned_projects),
                :callback_param => "")
    render :action => :wait
  end
  
  def get_error
      @@error_params
  end
  
  def get_returned_projects
    puts "httpget_callback: #{@params}"
    if @params['status'] != 'ok'
        http_error = @params['http_error'].to_i if @params['http_error']
            @@error_params = @params
            WebView.navigate ( url_for :action => :show_error )         
    else
        @@projects= @params['body']
        WebView.navigate ( url_for :action => :show_result )
    end
  end
  
  def show_result
   render :action => :index, :back => '/app'
  end

  def show_error
   render :action => :error, :back => '/app'
  end

  def get_projects
    @@projects
  end

  
  def cancel_httpcall
    Rho::AsyncHttp.cancel( url_for( :action => :httpget_callback) )

    @@get_result  = 'Request was cancelled.'
    render :action => :index, :back => '/app'
  end
  
  # GET /Projects/{1}
  def show
    @project = @params['project']
    render :action => :show
  end

  # GET /Projects/new
  def new
    @projects = Projects.new
    render :action => :new
  end

  # GET /Projects/{1}/edit
  def edit
    @projects = Projects.find(@params['id'])
    if @projects
      render :action => :edit
    else
      redirect :action => :index
    end
  end

  # POST /Projects/create
  def create
    @projects = Projects.create(@params['projects'])
    redirect :action => :index
  end

  # POST /Projects/{1}/update
  def update
    @projects = Projects.find(@params['id'])
    @projects.update_attributes(@params['projects']) if @projects
    redirect :action => :index
  end

  # POST /Projects/{1}/delete
  def delete
    @projects = Projects.find(@params['id'])
    @projects.destroy if @projects
    redirect :action => :index
  end
end
