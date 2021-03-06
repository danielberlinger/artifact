class EntriesController < ApplicationController

  before_filter :authenticate_user!, :except => [:new, :create, :show]
  before_filter :require_authenticated_user_or_access_token!, :only => [:show]
  before_filter :set_all_entries

  # GET /entries
  # GET /entries.xml
  def index
    @entries = Entry.limit(10).last_updated.includes(:tags)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @entries }
      format.atom
    end
  end

  def show_by_tag
    @query = params[:tag]
    @entries = Entry.tagged_with(params[:tag]).by_date
    @entries_size = @entries.size
    @search = true

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @entries }
    end
  end

  def search
    @query = params[:query]
    if params[:all]
      @entries = Entry.search(@query)[:full]
    else
      @entries = Entry.search(@query)[:skipped]
    end
    @entries_size = @entries.size
    @search = true

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @entries }
    end
  end

  # GET /entries/1
  # GET /entries/1.xml
  def show
   @entry = Entry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @entry }
      format.json  { render :json => @entry }
    end
  end

  def show_version
   @entry = Version.find(params[:id]).reify

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @entry }
    end
  end

  # GET /entries/new
  # GET /entries/new.xml
  def new
    @entry = Entry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @entry }
    end
  end

  # GET /entries/1/edit
  def edit
    @entry = Entry.find(params[:id])
  end

  # POST /entries
  # POST /entries.xml
  def create
    tag_list = params["entry"]["tags"]
    params["entry"].delete("tags")

    @entry = Entry.new(params["entry"])
    @entry.tag_list = tag_list
    respond_to do |format|
      if @entry.save
        format.html {
          msg = 'Entry was successfully created.'
          user_signed_in? ? redirect_to(@entry, :notice => msg) : render(:text => msg)
        }
        format.xml  { render :xml => @entry, :status => :created, :location => @entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /entries/1
  # PUT /entries/1.xml
  def update
    @entry = Entry.find(params[:id])

    respond_to do |format|
      @entry.tag_list = params[:entry][:tags]
      params[:entry].delete(:tags)
      if @entry.update_attributes(params[:entry])
        format.html { redirect_to(@entry, :notice => 'Entry was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /entries/1
  # DELETE /entries/1.xml
  def destroy
    @entry = Entry.find(params[:id])
    @entry.destroy

    respond_to do |format|
      format.html { redirect_to(entries_url) }
      format.xml  { head :ok }
    end
  end

  def set_token
    @entry = Entry.find(params[:id])
    if @entry.set_token
      flash[:notice] = 'Token successfully set.'
    else
      flash[:error] = 'Error encountered while setting token!'
    end

    redirect_to entries_path
  end

  def remove_token
    @entry = Entry.find(params[:id])
    if @entry.remove_token
      flash[:notice] = 'Token successfully removed.'
    else
      flash[:error] = 'Error encountered while removing token!'
    end

    redirect_to entries_path
  end

  private

  def set_all_entries
     @all_entries = Entry.limit(100).by_date
  end

end
