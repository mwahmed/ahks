class TranscriptionsController < ApplicationController
  before_action :set_transcription, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token  
  before_filter :authenticate_user!
  # GET /transcriptions
  # GET /transcriptions.json
  def index
     @nav_select = "transcriptions"
     flash.now[:notice] = params[:notice] if !params[:notice].nil?

     if params[:search].nil?
        @transcriptions = current_user.transcriptions
     else
          @search = Transcription.search do
            keywords params[:search] do
              query_phrase_slop 1
              minimum_match 1
            end
            
          end

          @transcriptions =  @search.nil? ? [] : @search.results
     end

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
    flash.now[:info] = "New Upload or 'Continue to Record' will overwrite the previously stored audio."
  end

  # POST /transcriptions
  # POST /transcriptions.json
  def create
    @transcription = Transcription.new(transcription_params)
    @transcription.date_created = Time.now
    @transcription.text = ""
    
    if params[:done].nil?
      # User used online audio recorder
      _path = Rails.root.to_s + '/public/audio/flash/' + current_user.id.to_s + "/" + @transcription.id.to_s + ".flac"
      @transcription.path_to_audio = _path
    else
      # User uploaded audio
      @transcription.path_to_audio = @transcription.audio.path
    end

    respond_to do |format|
      if @transcription.save
        if params[:done].nil?
          format.html { redirect_to :action=>"recorder", :transcription=>@transcription }
          format.json { render action: 'index', status: :created }
        else
	  if !@transcription.path_to_audio.nil?
          `echo "#{Rails.root}/script/init_transcribe.sh #{@transcription.path_to_audio} #{@transcription.id} upload #{@transcription.path_to_audio.gsub('.wav','')}"| at now`
	  end
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
    @transcription.text = "" if @transcription.text.nil?
    if params[:done].nil?
      # User used online audio recorder
      _path = Rails.root.to_s + '/public/audio/flash/' + current_user.id.to_s + "/" + @transcription.id.to_s + ".flac"
      @transcription.path_to_audio = _path
    else
      # User uploaded audio
      @transcription.path_to_audio = @transcription.audio.path
    end
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
    _path_flac = Rails.root.to_s + '/public/audio/flash/' + current_user.id.to_s + "/" + @transcription.id.to_s + ".flac"
    _path_wav = Rails.root.to_s + '/public/audio/flash/' + current_user.id.to_s + "/" + @transcription.id.to_s + ".wav"
    
    if File.exist?(_path_flac)
      File.delete(_path_flac)
      File.delete(_path_wav)
    end
    @transcription.audio.destroy

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

  def summary
	@transcription = Transcription.find(params[:id])

	@length = params[:summary_length].empty? ? "50" : params[:summary_length]
	_z = params[:zwords]
	_az = params[:antiz]
	
	_delimiter = @transcription.text.include?("\n") ? "newline" : "fullstop"
	
	@result = `python /home/ubuntu/falcon/summarizer/summarizer.py #{@transcription.id} #{@length} '#{_z}' '#{_az}' #{_delimiter}`

	@summary = @result.split(";;;ayush;;;")

  end


  def deliverables
	@transcription = Transcription.find(params[:id])
	@type = params[:type]
	
#	@result = `python /home/ubuntu/falcon/extract/extract2.py #{@transcription.id} #{_type}`

  end

  def file
  #Rails.logger.debug("debug::" + params.to_s)
  @transcription = Transcription.find(params[:id])
  @user = @transcription.user
  _path = Rails.root.to_s + '/public/audio/flash/' + @user.id.to_s
  
  Dir.mkdir(_path) unless File.exists?(_path)


  file = File.new("#{_path}/#{@transcription.id}.wav", "w+b")
  file.write request.raw_post
  file.close

  
  `echo "#{Rails.root}/script/init_transcribe.sh #{_path}/#{@transcription.id} #{@transcription.id}"| at now`

  render json: params
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transcription
      @transcription = Transcription.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transcription_params
      params.require(:transcription).permit(:name, :description, :path_to_audio, :text, :user_id, :date_created, :audio, :tag_ids=>[])
    end
end
