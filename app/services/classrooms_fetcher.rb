class ClassroomsFetcher
  def initialize(base_scope: Classroom.all, search_query: nil, limit: nil)
    @base_scope = base_scope
    @search_query = search_query.to_s.strip
    @limit = limit
  end

  def call
    scope = @base_scope
    scope = search(scope) if @search_query.present?
    scope
  end


  private

  def search(scope)
    search_term = "%#{@search_query.downcase}%"
    scope.where(
      "LOWER(name) LIKE ?",
      search_term
    )
  end
end