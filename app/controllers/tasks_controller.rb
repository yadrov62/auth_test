class TasksController < ApplicationController
  load_and_authorize_resource
  # GET /tasks
  # GET /tasks?filter=active
  # GET /tasks?filter=completed
  def index
    @tasks = @tasks.sorted

    case params[:filter]
    when "active"
      @tasks = @tasks.active
    when "completed"
      @tasks = @tasks.completed
    end

    @current_filter = params[:filter] || "all"
  end

  # GET /tasks/:id
  def show
  end

  # GET /tasks/new
  def new
  end

  # POST /tasks
  def create
    @task.user = current_user

    if @task.save
      redirect_to tasks_path, notice: t("flash.tasks.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /tasks/:id/edit
  def edit
  end

  # PATCH/PUT /tasks/:id
  def update
    if @task.update(task_params)
      redirect_to tasks_path, notice: t("flash.tasks.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /tasks/:id
  def destroy
    @task.destroy
    redirect_to tasks_path, notice: t("flash.tasks.destroyed")
  end

  # PATCH /tasks/:id/toggle
  def toggle
    @task.toggle_completed!
    redirect_to tasks_path, notice: t("flash.tasks.toggled")
  end

  private

  def task_params
    params.require(:task).permit(:title, :completed)
  end
end

