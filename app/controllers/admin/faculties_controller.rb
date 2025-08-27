class Admin::FacultiesController < Admin::BaseAdminController
  before_action :get_faculty, only: [:edit, :update, :destroy]
  def index
    @faculties = Rails.cache.read('all_faculties')
  end

  def new
    @faculty = Faculty.new
  end

  def create
    @faculty = Faculty.new(faculty_params)
    
    respond_to do |format|
      if @faculty.save
        format.turbo_stream
        format.html { redirect_to faculty_index_path, notice: 'Faculty was successfully created.' }
      else
        format.turbo_stream { render :create_error }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @faculty.update(faculty_params)
        format.turbo_stream
        format.html { redirect_to faculty_index_path, notice: 'Faculty was successfully updated.' }
      else
        format.turbo_stream { render :update }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @faculty.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to faculty_index_path, notice: 'Faculty was successfully deleted.' }
    end
  end

  private

  def get_faculty
    @faculty = Faculty.find(params[:id])
  end

  def faculty_params
    params.require(:faculty).permit(:full_name, :short_name)
  end
end
