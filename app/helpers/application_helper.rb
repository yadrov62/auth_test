module ApplicationHelper
  # Display flash messages with appropriate styling
  def flash_class(type)
    case type.to_sym
    when :notice, :success
      "flash-success"
    when :alert, :error
      "flash-error"
    when :warning
      "flash-warning"
    else
      "flash-info"
    end
  end
end

