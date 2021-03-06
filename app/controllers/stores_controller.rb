class StoresController < ApplicationController
  skip_filter :scope_current_store, only: [:landing, :index, :new, :create, :update, :change_status]
  before_filter :require_login, only: [:new]

  def landing
    if logged_in?
      redirect_to stores_path
    else
      render :layout => "landing"
    end
  end

  def index
    @stores = Store.unscoped.all
  end
  
  def show
    store ||= current_store
    if store.status == "pending"
      render :inline => "Store Not Found",:layout => "dead_store"
    elsif store.status == "disabled"
      render :inline => "This store is down for maintenance",:layout => "dead_store"
    elsif store.status == "rejected"
      render :inline => "This store has been rejected. Please email the administrator",:layout => "dead_store"
    else
      @store = store
    end
  end

  def new
    @store = Store.new
  end

  def create
    @store = Store.new(params[:store])

    if @store.save
      StoreAdmin.create(customer_id: current_user.id, store_id: @store.id)
      Store.include_admin(current_user.id, @store.id)
      redirect_to store_admin_path(Store.find(@store.id).path), notice: 'Thank you. Your store is currently pending acceptance'
    else
      render action: 'new'
    end
  end

  def change_status
    store = Store.find(params[:id])
    
    store.update_attribute(:status, params[:status])
    
    Resque.enqueue(SendStatusEmail, store.id)

    redirect_to admin_stores_path, notice: 'Store updated successfully.'
  end

end
