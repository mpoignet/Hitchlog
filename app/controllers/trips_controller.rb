class TripsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :find_trip_and_redirect_if_not_owner, :only => [:edit]
  
  def new
    @trip = Trip.new
  end
  
  def show
    @trip = Trip.find(params[:id])
    @user = @trip.user
    @photos = @trip.rides.map{|t| t.photo}.delete_if{|photo| !photo.file?}
    get_user_settings(@user)
  end
  
  def create
    @trip = Trip.new(params[:trip])
    @trip.user = current_user
    if @trip.save
      redirect_to edit_trip_path(@trip)
    else
      render :new
    end
  end
  
  def index
    @trips = Trip.order("created_at DESC").paginate(:page => params[:page])
    @rides = Ride.not_empty
    respond_to do |wants|
      wants.html
      wants.js { render :partial => 'trips/trips', :locals => {:trips => @trips} }
    end
  end
  
  def edit
  end
    
  def update
    @trip = Trip.find(params[:id])
    if @trip.update_attributes(params[:trip])
      respond_to do |wants|
        wants.html { redirect_to edit_trip_path(@trip) }
        wants.js {}
      end
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @trip = Trip.find(params[:id])
    @trip.destroy
    redirect_to trips_url
  end  

  private

  def find_trip_and_redirect_if_not_owner
    @trip = Trip.find(params[:id])
    if @trip.user != current_user
      flash[:error] = "This is not your trip."
      redirect_to trips_path
    end
  end
end
