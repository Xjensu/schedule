class ScheduleRenderer
  def initialize(view_context, options = {})
    @view = view_context
    @options = options
    @options[:card_stimulus] ||= default_card_stimulus
    @options[:card_attributes] ||= {}
    @options[:partial] ||= 'shared/schedule/schedule_container'
  end

  def render
    @view.render partial: @options[:partial], locals: {
      default_times: @options[:default_times] || ['08:30', '10:10', '11:45', '14:00', '15:35', '17:10', '18:45'],
      param: @options[:param],
      schedules: @options[:schedules],
      card_stimulus: @options[:card_stimulus],
      card_attributes: @options[:card_attributes],
      card_partial: @options[:card_partial] || 'shared/schedule/schedule_card'
    }
  end

  private

  def default_card_stimulus
    { 
      controller: 'default-schedule', 
      action: 'click->default-schedule#select' 
    }
  end
end