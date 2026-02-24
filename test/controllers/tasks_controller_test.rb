require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @task = tasks(:one)
  end

  test "should get index" do
    get tasks_url
    assert_response :success
  end

  test "should get index with active filter" do
    get tasks_url(filter: "active")
    assert_response :success
  end

  test "should get index with completed filter" do
    get tasks_url(filter: "completed")
    assert_response :success
  end

  test "should get new" do
    get new_task_url
    assert_response :success
  end

  test "should create task" do
    assert_difference("Task.count") do
      post tasks_url, params: { task: { title: "New task", completed: false } }
    end
    assert_redirected_to tasks_url
  end

  test "should not create task without title" do
    assert_no_difference("Task.count") do
      post tasks_url, params: { task: { title: "", completed: false } }
    end
    assert_response :unprocessable_entity
  end

  test "should show task" do
    get task_url(@task)
    assert_response :success
  end

  test "should get edit" do
    get edit_task_url(@task)
    assert_response :success
  end

  test "should update task" do
    patch task_url(@task), params: { task: { title: "Updated task" } }
    assert_redirected_to tasks_url
    @task.reload
    assert_equal "Updated task", @task.title
  end

  test "should destroy task" do
    assert_difference("Task.count", -1) do
      delete task_url(@task)
    end
    assert_redirected_to tasks_url
  end

  test "should toggle task completion" do
    original_status = @task.completed
    patch toggle_task_url(@task)
    assert_redirected_to tasks_url
    @task.reload
    assert_equal !original_status, @task.completed
  end
end

