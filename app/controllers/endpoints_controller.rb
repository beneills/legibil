class EndpointsController < ApplicationController
  before_action :set_endpoint, only: [:update, :destroy]

  # POST /endpoints
  # POST /endpoints.json
  def create
    respond_to do |format|
      if user_signed_in?
        @endpoint = current_user.endpoints.build(endpoint_params)

        if @endpoint.save
          format.html { redirect_to root_url, notice: 'Endpoint was successfully created.' }
          format.json { head :created }
        else
          format.html { head :conflict }
          format.json { render json: @endpoint.errors, status: :unprocessable_entity }
        end
      else
          format.html { head :forbidden }
          format.json { head :forbidden }
      end
    end
  end

  # PATCH/PUT /endpoints/1
  # PATCH/PUT /endpoints/1.json
  def update
    respond_to do |format|
      if @endpoint.update(endpoint_params)
        format.html { redirect_to root_url, notice: 'Endpoint was successfully updated.' }
        format.json { render :show, status: :ok, location: @endpoint }
      else
        format.html { render :edit }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_endpoint
      @endpoint = Endpoint.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def endpoint_params
      params.require(:endpoint).permit(:url, :name)
    end
end
