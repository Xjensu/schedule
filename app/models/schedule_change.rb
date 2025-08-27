class ScheduleChange
  attr_reader :action, :record, :created_at, :target_id

  def initialize(action, record, created_at)
    @action = action
    @record = record
    @created_at = created_at
    @target_id = extract_target_id(record, action)
  end

  private

  def extract_target_id(record, action)
    case action
    when :delete
      record.is_a?(Array) ? record[0] : record.schedule_id
    when :add
      record.schedule_id
    end
  end
end