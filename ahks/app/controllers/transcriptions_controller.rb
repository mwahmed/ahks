class TranscriptionsController < ApplicationController
  before_action :set_transcription, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token  
  before_filter :authenticate_user!
  # GET /transcriptions
  # GET /transcriptions.json
  def index
     flash.now[:notice] = params[:notice] if !params[:notice].nil?
     @transcriptions = current_user.transcriptions
#    @transcriptions = Transcription.all
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
    flash.now[:alert] = "New Upload or 'Continue to Record' will overwrite the previously stored audio."
  end

  # POST /transcriptions
  # POST /transcriptions.json
  def create
    @transcription = Transcription.new(transcription_params)
    @transcription.date_created = Time.now
    respond_to do |format|
      if @transcription.save
        if params[:done].nil?
          format.html { redirect_to :action=>"recorder", :transcription=>@transcription }
          format.json { render action: 'index', status: :created }
        else
          format.html { redirect_to "/transcriptions", :notice => 'Transcription was successfully stored.' }
          format.json { render action: 'index', status: :created }
        end
      else
        format.html { render action: 'new' }
        format.json { render json: @transcription.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transcriptions/1
  # PATCH/PUT /transcriptions/1.json
  def update
    @transcription.date_created = Time.now
    respond_to do |format|
      if @transcription.update(transcription_params)
        if params[:done].nil?
          format.html { redirect_to :action=>'recorder', :transcription=>@transcription}
          format.json { head :no_content }
        else
          format.html { redirect_to "/transcriptions", :notice=> 'Transcription was successfully stored.'}
          format.json { head :no_content }
        end
      else
        format.html { render action: 'edit' }
        format.json { render json: @transcription.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transcriptions/1
  # DELETE /transcriptions/1.json
  def destroy
    _path_flac = Rails.root.to_s + '/public/' + current_user.id.to_s + "/" + @transcription.id.to_s + ".flac"
    _path_wav = Rails.root.to_s + '/public/' + current_user.id.to_s + "/" + @transcription.id.to_s + ".wav"
    
    if File.exist?(_path_flac)
      File.delete(_path_flac)
      File.delete(_path_wav)
    end

    @transcription.destroy
    respond_to do |format|
      format.html { redirect_to transcriptions_url }
      format.json { head :no_content }
    end
  end


  def recorder
    @transcription = Transcription.find(params[:transcription])
    # Rails.logger.debug("debug::" + @transcription.name)
  end

  def file
  Rails.logger.debug("debug::" + params.to_s)
  @transcription = Transcription.find(params[:id])
  @user = @transcription.user
  _path = Rails.root.to_s + '/public/' + @user.id.to_s
  
  Dir.mkdir(_path) unless File.exists?(_path)


  file = File.new("#{_path}/#{@transcription.id}.wav", "w+b")
  file.write request.raw_post
  file.close
    
  file = File.new("#{_path}/#{@transcription.id}.flac", "w+b")
  file.write request.raw_post
  file.close
    
  render json: params
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transcription
      @transcription = Transcription.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transcription_params
      params.require(:transcription).permit(:name, :description, :path_to_audio, :text, :user_id, :date_created, :tag_ids=>[])
    end
end
