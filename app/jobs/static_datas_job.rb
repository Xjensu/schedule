class StaticDatasJob
  include Sidekiq::Job
  sidekiq_options retry: 3, dead: false

  def perform
    faculties_cache_key = "all_faculties"
    @faculties = Faculty.all.to_a
    Rails.cache.write(faculties_cache_key, @faculties.to_a)
    @faculties.each do |faculty|
      cache_key = "faculty:#{faculty.id}_groups"
      Rails.cache.write(cache_key, StudentGroup.where(faculty_id: faculty.id).to_a, expires_in: 25.hours)
    end
  end
end