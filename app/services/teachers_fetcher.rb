class TeachersFetcher
  def initialize(base_scope: Teacher.all, search_query: nil, limit: nil, priority_teacher_id: nil)
    @base_scope = base_scope
    @search_query = search_query.to_s.strip
    @limit = limit
    @priority_teacher_id = priority_teacher_id
  end

  def call
    scope = @base_scope
    scope = search(scope) if @search_query.present?
    scope = scope.limit(@limit) if @limit.present?
    scope
  end


  private

  def search(scope)
    search_term = "%#{@search_query.downcase}%"
    scope.where(
      "LOWER(CONCAT(surname, ' ', name, ' ', patronymic)) LIKE ? OR " \
      "LOWER(surname) LIKE ? OR " \
      "LOWER(name) LIKE ? OR " \
      "LOWER(patronymic) LIKE ?",
      search_term, search_term, search_term, search_term
    )
  end

  def prioritize_teacher(scope)
    return scope unless @priority_teacher_id.present?

    priority_teacher = scope.find_by(id: @priority_teacher_id)
    other_teachers = scope.where.not(id: @priority_teacher_id).to_a

    [priority_teacher, *other_teachers].compact
  end
end