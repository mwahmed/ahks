class TranscriptionsController < ApplicationController
  before_action :set_transcription, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!
  # GET /transcriptions
  # GET /transcriptions.json
  def index
    @transcriptions = Transcription.all
  end

  # GET /transcriptions/1
  # GET /transcriptions/1.json
  def show
  end

  # GET /transcriptions/new
  def new
    @transcription = Transcription.new
  end

  # GET /transcriptions/1/edit
  def edit
  end

  # POST /transcriptions
  # POST /transcriptions.json
  def create
    @transcription = Transcription.new(transcription_params)

    respond_to do |format|
      if @transcription.save
        format.html { redirect_to @transcription, notice: 'Transcription was successfully created.' }
        format.json { render action: 'show', status: :created, location: @transcription }
      else
        format.html { render action: 'new' }
        format.json { render json: @transcription.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transcriptions/1
  # PATCH/PUT /transcriptions/1.json
  def update
    respond_to do |format|
      if @transcription.update(transcription_params)
        format.html { redirect_to @transcription, notice: 'Transcription was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @transcription.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transcriptions/1
  # DELETE /transcriptions/1.json
  def destroy
    @transcription.destroy
    respond_to do |format|
      format.html { redirect_to transcriptions_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transcription
      @transcription = Transcription.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transcription_params
      params.require(:transcription).permit(:name, :description, :path_to_audio, :text, :user_id, :date_created)
    end
end
