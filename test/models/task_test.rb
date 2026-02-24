require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "should not save task without title" do
    task = Task.new
    assert_not task.save, "Saved the task without a title"
  end

  test "should save task with valid title" do
    task = Task.new(title: "Test task")
    assert task.save, "Could not save a valid task"
  end

  test "completed should default to false" do
    task = Task.create!(title: "New task")
    assert_not task.completed, "New task should not be completed by default"
  end

  test "toggle_completed! should toggle the completed status" do
    task = Task.create!(title: "Test task", completed: false)

    task.toggle_completed!
    assert task.completed, "Task should be completed after toggle"

    task.toggle_completed!
    assert_not task.completed, "Task should be active after second toggle"
  end

  test "active scope should return only incomplete tasks" do
    active_count = Task.active.count
    assert_equal 2, active_count, "Should have 2 active tasks from fixtures"
  end

  test "completed scope should return only completed tasks" do
    completed_count = Task.completed.count
    assert_equal 1, completed_count, "Should have 1 completed task from fixtures"
  end
end

