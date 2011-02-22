class DogsController < ApplicationController
  before_filter :set_tenant

  #set the tenant either through a get variable `tenant` or the subdomain
  def set_tenant
    PgActiveSchema.search_path = request.subdomain unless request.subdomain.blank?
    PgActiveSchema.search_path = params[:tenant] unless params[:tenant].blank?
  end

  def index
    @dogs = Dog.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dogs }
    end
  end

  # GET /dogs/1
  # GET /dogs/1.xml
  def show
    @dog = Dog.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dog }
    end
  end

  # GET /dogs/new
  # GET /dogs/new.xml
  def new
    @dog = Dog.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dog }
    end
  end

  # GET /dogs/1/edit
  def edit
    @dog = Dog.find(params[:id])
  end

  # POST /dogs
  # POST /dogs.xml
  def create
    @dog = Dog.new(params[:dog])

    respond_to do |format|
      if @dog.save
        format.html { redirect_to(@dog, :notice => 'Dog was successfully created.') }
        format.xml  { render :xml => @dog, :status => :created, :location => @dog }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dog.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dogs/1
  # PUT /dogs/1.xml
  def update
    @dog = Dog.find(params[:id])

    respond_to do |format|
      if @dog.update_attributes(params[:dog])
        format.html { redirect_to(@dog, :notice => 'Dog was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dog.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dogs/1
  # DELETE /dogs/1.xml
  def destroy
    @dog = Dog.find(params[:id])
    @dog.destroy

    respond_to do |format|
      format.html { redirect_to(dogs_url) }
      format.xml  { head :ok }
    end
  end
end
