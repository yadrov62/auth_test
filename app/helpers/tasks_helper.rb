module TasksHelper
  # Return CSS class based on task completion status
  def task_status_class(task)
    task.completed? ? "task-completed" : "task-active"
  end

  # Return human-readable status text
  def task_status_text(task)
    task.completed? ? "Completed" : "Active"
  end

  # Return toggle button text
  def toggle_button_text(task)
    task.completed? ? "Mark Active" : "Mark Complete"
  end

  # Check if a filter is currently active
  def filter_active?(filter)
    current_filter = params[:filter] || "all"
    current_filter == filter
  end

  # CSS class for filter links
  def filter_link_class(filter)
    filter_active?(filter) ? "filter-link filter-link-active" : "filter-link"
  end
end

