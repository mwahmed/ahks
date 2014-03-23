class DocumentsController < ApplicationController
  before_action :set_document, only: [:show, :edit, :update, :destroy]

  # GET /documents
  # GET /documents.json
  def index
    @nav_select = "documents"
    if !params[:format].nil?
      _d_id = params[:format] # check if coming from a fresh upload with this id
      _check_doc = Document.find(_d_id)
      if !_check_doc.file.path.nil? and _check_doc.data.empty?
            _path = _check_doc.file.path
      
            
              fp = File.open(_path, "r")
              _check_doc.data = fp.read
              _check_doc.save
              fp.close    

      end
    end
    if params[:search].nil?
        @documents = current_user.documents.sort_by {|obj| obj.date_created}.reverse
    else
      @search = Document.search do
            keywords params[:search] do
              query_phrase_slop 1
              minimum_match 1
            end
            
          end

          @documents =  @search.nil? ? [] : @search.results.sort_by {|obj| obj.date_created}.reverse
    end
    #@documents = Document.all
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
  end

  # GET /documents/new
  def new
    @document = Document.new
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = Document.new(document_params)
    @document.date_created = Time.now
    if !@document.file_file_name.nil?
    end
    respond_to do |format|
      if @document.save
        format.html { redirect_to documents_path(@document), notice: 'Document was successfully created.' }
        format.json { render action: 'show', status: :created, location: @document }
      else
        format.html { render action: 'new' }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update
    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to documents_path(@document), notice: 'Document was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.destroy
    respond_to do |format|
      format.html { redirect_to documents_url }
      format.json { head :no_content }
    end
  end

  def summary
	@document = Document.find(params[:id])

	@length = params[:summary_length].empty? ? "50" : params[:summary_length]
	_z = params[:zwords]
	_az = params[:antiz]
	
	_delimiter = "fullstop"
	
	@result = `python /home/ubuntu/falcon/summarizer/summarizer.py #{@document.id} #{@length} '#{_z}' '#{_az}' #{_delimiter} 'documents'`

	@summary = @result.split(";;;ayush;;;")

  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:document).permit(:title, :description, :data, :file, :user_id, :date_created, :tag_ids=>[])
    end
end
