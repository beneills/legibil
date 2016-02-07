class EndpointsController < ApplicationController
  before_action :forbid_non_users
  before_action :set_endpoint,             only: [:update, :destroy, :refresh]
  before_action :check_endpoint_ownership, only: [:update, :destroy, :refresh]

  # POST /endpoints
  # POST /endpoints.json
  def create
    respond_to do |format|
      @endpoint = current_user.endpoints.build(endpoint_params)

      if @endpoint.save
        format.html { redirect_to root_url, notice: 'Endpoint was successfully created.' }
        format.json { head :created }
      else
        format.html { head :unprocessable_entity }
        format.json { render json: @endpoint.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /endpoints/1
  # PATCH/PUT /endpoints/1.json
  def update
    respond_to do |format|
      if @endpoint.update(endpoint_params)
        format.html { redirect_to root_url, notice: 'Endpoint was successfully updated.' }
        format.json { head :ok }
      else
        format.html { head :unprocessable_entity }
        format.json { render json: @endpoint.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /endpoints/1
  # DELETE /endpoints/1.json
  def destroy
    @endpoint.destroy
    respond_to do |format|
      format.html { redirect_to root_url, notice: 'Endpoint was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # PATCH /endpoints/1/refresh
  # PATCH /endpoints/1/refresh.json
  def refresh
    respond_to do |format|
      RefreshEndpointJob.perform_later @endpoint

      format.html { redirect_to root_url, notice: 'Endpoint refreshing.' }
      format.json { head :ok }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_endpoint
      @endpoint = Endpoint.find(params[:id])
    end

    def check_endpoint_ownership
      unless @endpoint.user.id == current_user.id
        respond_to do |format|
          format.html { head :forbidden }
          format.json { head :forbidden }
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def endpoint_params
      params.require(:endpoint).permit(:url, :name)
    end
end
