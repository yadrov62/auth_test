# Devise + CanCanCan Integration Guide

A step-by-step tutorial for integrating authentication (Devise) and authorization (CanCanCan) into a Ruby on Rails 7 Todo application.

---

## Prerequisites

Before starting this tutorial, you should have:

- A working Rails 7 Todo application with a `Task` model
- PostgreSQL database configured
- Basic understanding of Rails MVC architecture

**Current state of the app:**
- `Task` model with `title` (string) and `completed` (boolean)
- Full CRUD operations for tasks
- No authentication or authorization

---

## Understanding the Concepts

Before we dive into the code, let's understand two fundamental security concepts:

| Concept | Question it answers | Example |
|---------|---------------------|---------|
| **Authentication** | "Who are you?" | Logging in with email/password |
| **Authorization** | "What can you do?" | Can this user edit this task? |

**Devise** handles authentication — it manages user accounts, sessions, passwords, and login/logout functionality.

**CanCanCan** handles authorization — it defines and enforces rules about what actions users can perform on resources.

---

# Part 1 — Install and Configure Devise

## Goal

Set up Devise to manage user authentication in our Rails application.

---

### Step 1.1: Add Devise to Gemfile

Open your `Gemfile` and add the Devise gem:

```ruby
# Gemfile

# ... existing gems ...

# Authentication
gem 'devise', '~> 4.9'
```

---

### Step 1.2: Install the gem

Run bundle install to download and install Devise:

```bash
bundle install
```

**What just happened?**
Bundler downloaded the Devise gem and all its dependencies. Devise is now available in your application, but not yet configured.

---

### Step 1.3: Run the Devise installer

Devise provides a generator that sets up the initial configuration:

```bash
rails generate devise:install
```

**Expected output:**
```
      create  config/initializers/devise.rb
      create  config/locales/devise.en.yml
===============================================================================

Depending on your application's configuration some manual setup may be required:

  1. Ensure you have defined default url options in your environments files...
  2. Ensure you have defined root_url...
  3. Ensure you have flash messages in app/views/layouts/application.html.erb...
  4. You can copy Devise views...

===============================================================================
```

**What just happened?**
Devise created two important files:
- `config/initializers/devise.rb` — Main configuration file for Devise
- `config/locales/devise.en.yml` — English translations for Devise messages

---

### Step 1.4: Configure default URL options

Devise needs to know your application's host for sending emails (password reset, etc.). Add this to your development environment config:

```ruby
# config/environments/development.rb

Rails.application.configure do
  # ... existing configuration ...

  # Devise mailer configuration
  config.action_mailer.default_url_options = { host: 'localhost', port: 4000 }
end
```

**What just happened?**
We told Action Mailer (Rails' email system) what host and port to use when generating URLs in emails. This is required by Devise for features like password reset emails.

---

### Step 1.5: Generate the User model

Now let's create a User model that Devise will manage:

```bash
rails generate devise User
```

**Expected output:**
```
      invoke  active_record
      create    db/migrate/XXXXXXXXXXXXXX_devise_create_users.rb
      create    app/models/user.rb
      insert    app/models/user.rb
       route  devise_for :users
```

**What just happened?**
Devise generated:
- A migration file to create the `users` table with email, password, etc.
- A `User` model with Devise modules included
- A route entry that creates all authentication routes

---

### Step 1.6: Review the generated migration

Let's look at what Devise will create in the database:

```ruby
# db/migrate/XXXXXXXXXXXXXX_devise_create_users.rb

class DeviseCreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable (optional - uncomment if needed)
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
```

**Key fields explained:**
- `email` — User's email address (used for login)
- `encrypted_password` — Securely hashed password (never stored in plain text!)
- `reset_password_token` — Used for "forgot password" functionality
- `remember_created_at` — For "remember me" checkbox functionality

---

### Step 1.7: Review the User model

```ruby
# app/models/user.rb

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
```

**Devise modules explained:**
| Module | What it does |
|--------|--------------|
| `database_authenticatable` | Hashes and stores passwords in the database |
| `registerable` | Allows users to sign up and edit their account |
| `recoverable` | Resets the user password via email |
| `rememberable` | Manages "remember me" cookie |
| `validatable` | Validates email and password |

---

### Step 1.8: Run the migration

Create the users table in your database:

```bash
rails db:migrate
```

**Expected output:**
```
== XXXXXXXXXXXXXX DeviseCreateUsers: migrating ================================
-- create_table(:users)
   -> 0.0XXXs
-- add_index(:users, :email, {:unique=>true})
   -> 0.0XXXs
-- add_index(:users, :reset_password_token, {:unique=>true})
   -> 0.0XXXs
== XXXXXXXXXXXXXX DeviseCreateUsers: migrated (0.0XXXs) =======================
```

---

### Step 1.9: Check the new routes

Devise automatically added authentication routes. Let's see them:

```bash
rails routes | grep devise
```

**Expected output:**
```
                  new_user_session GET    /users/sign_in(.:format)          devise/sessions#new
                      user_session POST   /users/sign_in(.:format)          devise/sessions#create
              destroy_user_session DELETE /users/sign_out(.:format)         devise/sessions#destroy
                 new_user_password GET    /users/password/new(.:format)     devise/passwords#new
                edit_user_password GET    /users/password/edit(.:format)    devise/passwords#edit
                     user_password PATCH  /users/password(.:format)         devise/passwords#update
                                   PUT    /users/password(.:format)         devise/passwords#update
                                   POST   /users/password(.:format)         devise/passwords#create
          cancel_user_registration GET    /users/cancel(.:format)           devise/registrations#cancel
             new_user_registration GET    /users/sign_up(.:format)          devise/registrations#new
            edit_user_registration GET    /users/edit(.:format)             devise/registrations#edit
                 user_registration PATCH  /users(.:format)                  devise/registrations#update
                                   PUT    /users(.:format)                  devise/registrations#update
                                   DELETE /users(.:format)                  devise/registrations#destroy
                                   POST   /users(.:format)                  devise/registrations#create
```

**What Devise provided:**
- `/users/sign_in` — Login page
- `/users/sign_up` — Registration page
- `/users/sign_out` — Logout action
- `/users/password/new` — Forgot password page
- `/users/edit` — Edit account page

---

### Step 1.10: Test the setup

Start your server and visit the sign-up page:

```bash
bin/dev
```

Visit: **http://localhost:4000/users/sign_up**

**Expected result:**
You should see a registration form with Email, Password, and Password confirmation fields.

🎉 **Congratulations!** Devise is now installed and configured!

---

# Part 2 — Add Authentication to the App

## Goal

Require users to log in before accessing tasks, and associate tasks with users.

---

### Step 2.1: Update ApplicationController

Remove the placeholder methods we had before and add Devise's authentication requirement:

> ⚠️ **IMPORTANT:** Replace the ENTIRE contents of `application_controller.rb` with the code below. The old placeholder methods (`current_user`, `user_signed_in?`, `authenticate_user!`) must be removed because Devise provides these automatically. If you keep them, they will override Devise's methods and break authentication!

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  # Protect from forgery with exception
  protect_from_forgery with: :exception

  # Require authentication for all actions (can be overridden in controllers)
  before_action :authenticate_user!

  private

  # Configure permitted parameters for Devise
  # (needed if you add custom fields to User model)
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
```

**What just happened?**
- `before_action :authenticate_user!` — This Devise method redirects unauthenticated users to the login page
- We removed our placeholder `current_user` and `user_signed_in?` methods because Devise provides these automatically

---

### Step 2.2: Allow unauthenticated access to the login placeholder (optional cleanup)

Since Devise now handles login, we can remove the old placeholder controller or keep it for other static pages:

```ruby
# app/controllers/pages_controller.rb

class PagesController < ApplicationController
  # Skip authentication for static pages
  skip_before_action :authenticate_user!, only: [:home]

  def home
    # A public landing page (optional)
  end
end
```

---

### Step 2.3: Update the layout with login/logout links

Replace the navigation section in your layout to use Devise helpers:

```erb
<!-- app/views/layouts/application.html.erb -->

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Todo App</title>
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>
  <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
</head>
<body>
  <header class="header">
    <nav class="nav-container">
      <div class="nav-brand">
        <%= link_to "Todo App", root_path, class: "brand-link" %>
      </div>
      <div class="nav-links">
        <% if user_signed_in? %>
          <%= link_to "All Tasks", tasks_path, class: "nav-link" %>
          <%= link_to "New Task", new_task_path, class: "nav-link nav-link-primary" %>
          <span class="nav-user"><%= current_user.email %></span>
          <%= link_to "Edit Profile", edit_user_registration_path, class: "nav-link" %>
          <%= button_to "Logout", destroy_user_session_path, method: :delete, class: "nav-link btn-logout" %>
        <% else %>
          <%= link_to "Login", new_user_session_path, class: "nav-link" %>
          <%= link_to "Sign Up", new_user_registration_path, class: "nav-link nav-link-primary" %>
        <% end %>
      </div>
    </nav>
  </header>

  <main class="main-content">
    <% if flash[:notice] %>
      <div class="flash flash-success">
        <%= flash[:notice] %>
      </div>
    <% end %>
    <% if flash[:alert] %>
      <div class="flash flash-error">
        <%= flash[:alert] %>
      </div>
    <% end %>

    <%= yield %>
  </main>

  <footer class="footer">
    <p>&copy; <%= Date.current.year %> Todo App. Built with Rails <%= Rails::VERSION::STRING %>.</p>
  </footer>
</body>
</html>
```

**Key Devise helpers used:**
| Helper | What it does |
|--------|--------------|
| `user_signed_in?` | Returns true if a user is logged in |
| `current_user` | Returns the currently logged-in User object |
| `new_user_session_path` | Path to login page (`/users/sign_in`) |
| `destroy_user_session_path` | Path to logout action (`/users/sign_out`) |
| `new_user_registration_path` | Path to sign-up page (`/users/sign_up`) |
| `edit_user_registration_path` | Path to edit account page (`/users/edit`) |

---

### Step 2.4: Add CSS for logout button

Add this to your stylesheet:

```css
/* app/assets/stylesheets/application.css */

/* Add to existing styles */

.btn-logout {
  background: none;
  border: none;
  color: var(--gray-600);
  font-weight: 500;
  cursor: pointer;
  font-size: 1rem;
  padding: 0;
}

.btn-logout:hover {
  color: var(--danger-color);
}
```

---

### Step 2.5: Test authentication redirect

1. Stop and restart your server
2. Open an incognito/private browser window
3. Visit **http://localhost:4000/tasks**

**Expected result:**
You should be redirected to **http://localhost:4000/users/sign_in** with a message "You need to sign in or sign up before continuing."

---

### Step 2.6: Create a test user

1. Visit **http://localhost:4000/users/sign_up**
2. Enter an email and password (minimum 6 characters)
3. Click "Sign up"

**Expected result:**
You should be logged in and redirected to the tasks page, with a "Welcome! You have signed up successfully." message.

---

### Step 2.7: Associate Tasks with Users

Now we need to link tasks to users. Each task should belong to the user who created it.

Generate a migration to add `user_id` to tasks:

```bash
rails generate migration AddUserToTasks user:references
```

**What this creates:**

```ruby
# db/migrate/XXXXXXXXXXXXXX_add_user_to_tasks.rb

class AddUserToTasks < ActiveRecord::Migration[7.1]
  def change
    add_reference :tasks, :user, null: false, foreign_key: true
  end
end
```

---

### Step 2.8: Handle existing tasks (important!)

Before running the migration, we need to handle existing tasks that don't have a user. Modify the migration:

```ruby
# db/migrate/XXXXXXXXXXXXXX_add_user_to_tasks.rb

class AddUserToTasks < ActiveRecord::Migration[7.1]
  def change
    # First, add the column allowing null
    add_reference :tasks, :user, foreign_key: true

    # Assign existing tasks to the first user (or create one)
    reversible do |dir|
      dir.up do
        # Find or create a default user for existing tasks
        user = User.first
        if user.nil?
          user = User.create!(
            email: 'default@example.com',
            password: 'password123'
          )
        end

        # Assign all existing tasks to this user
        Task.update_all(user_id: user.id)
      end
    end

    # Now make the column NOT NULL
    change_column_null :tasks, :user_id, false
  end
end
```

---

### Step 2.9: Run the migration

```bash
rails db:migrate
```

**Expected output:**
```
== XXXXXXXXXXXXXX AddUserToTasks: migrating ===================================
-- add_reference(:tasks, :user, {:foreign_key=>true})
   -> 0.0XXXs
-- change_column_null(:tasks, :user_id, false)
   -> 0.0XXXs
== XXXXXXXXXXXXXX AddUserToTasks: migrated (0.0XXXs) ==========================
```

---

### Step 2.10: Update the models

Add the associations between User and Task:

```ruby
# app/models/user.rb

class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :tasks, dependent: :destroy
end
```

```ruby
# app/models/task.rb

class Task < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :title, presence: true

  # Scopes for filtering
  scope :active, -> { where(completed: false) }
  scope :completed, -> { where(completed: true) }
  scope :sorted, -> { order(created_at: :desc) }

  # Toggle the completed status
  def toggle_completed!
    update!(completed: !completed)
  end
end
```

**What just happened?**
- `User has_many :tasks` — A user can have multiple tasks
- `dependent: :destroy` — When a user is deleted, all their tasks are also deleted
- `Task belongs_to :user` — Every task must belong to a user

---

### Step 2.11: Update TasksController to scope tasks to current user

This is crucial for security — users should only see and manage their own tasks:

```ruby
# app/controllers/tasks_controller.rb

class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy, :toggle]

  # GET /tasks
  def index
    @tasks = current_user.tasks.sorted

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
    @task = current_user.tasks.build
  end

  # POST /tasks
  def create
    @task = current_user.tasks.build(task_params)

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

  def set_task
    # IMPORTANT: Only find tasks belonging to the current user
    @task = current_user.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :completed)
  end
end
```

**Key changes:**
1. `current_user.tasks` — All queries now scope to the logged-in user
2. `current_user.tasks.build` — New tasks are automatically associated with the current user
3. `current_user.tasks.find(params[:id])` — Users can only access their own tasks

---

### Step 2.12: Update seeds for testing

Update the seed file to create tasks for a specific user:

```ruby
# db/seeds.rb

puts "Creating sample data..."

# Clear existing data
Task.destroy_all
User.destroy_all

# Create test users
user1 = User.create!(
  email: 'alice@example.com',
  password: 'password123'
)

user2 = User.create!(
  email: 'bob@example.com',
  password: 'password123'
)

puts "Created users: #{user1.email}, #{user2.email}"

# Create tasks for Alice
alice_tasks = [
  { title: "Complete Rails tutorial", completed: true },
  { title: "Set up PostgreSQL database", completed: true },
  { title: "Implement user authentication", completed: true },
  { title: "Add authorization with CanCanCan", completed: false },
  { title: "Write unit tests", completed: false },
]

alice_tasks.each do |task_attrs|
  user1.tasks.create!(task_attrs)
end

# Create tasks for Bob
bob_tasks = [
  { title: "Learn Ruby basics", completed: true },
  { title: "Build first Rails app", completed: false },
  { title: "Deploy to production", completed: false },
  { title: "Study Devise documentation", completed: false },
  { title: "Practice CanCanCan", completed: false },
]

bob_tasks.each do |task_attrs|
  user2.tasks.create!(task_attrs)
end

puts "\nDone! Created:"
puts "  - #{User.count} users"
puts "  - #{Task.count} tasks total"
puts "  - Alice has #{user1.tasks.count} tasks"
puts "  - Bob has #{user2.tasks.count} tasks"
puts "\nTest accounts:"
puts "  - alice@example.com / password123"
puts "  - bob@example.com / password123"
```

---

### Step 2.13: Reset and reseed the database

```bash
rails db:reset
```

This runs `db:drop`, `db:create`, `db:migrate`, and `db:seed`.

---

### Step 2.14: Test user isolation

1. Start your server: `bin/dev`
2. Log in as Alice (alice@example.com / password123)
3. You should see only Alice's 5 tasks
4. Log out and log in as Bob (bob@example.com / password123)
5. You should see only Bob's 5 tasks

**Expected result:**
Each user sees only their own tasks. Users cannot access each other's tasks.

🎉 **Authentication is now complete!** Users must log in, and tasks are scoped to each user.

---

# Part 3 — Install and Configure CanCanCan

## Goal

Set up CanCanCan to manage authorization rules in our application.

---

### Why CanCanCan?

While we've scoped tasks to users in our controller, this approach has limitations:

1. **Code duplication** — We repeat `current_user.tasks` everywhere
2. **Easy to forget** — A developer might accidentally write `Task.find(params[:id])`
3. **No centralized rules** — Authorization logic is scattered across controllers

CanCanCan solves this by:
- Centralizing all authorization rules in one place (`Ability` class)
- Automatically loading and authorizing resources
- Raising exceptions when access is denied

---

### Step 3.1: Add CanCanCan to Gemfile

```ruby
# Gemfile

# ... existing gems ...

# Authentication
gem 'devise', '~> 4.9'

# Authorization
gem 'cancancan', '~> 3.5'
```

---

### Step 3.2: Install the gem

```bash
bundle install
```

---

### Step 3.3: Generate the Ability class

CanCanCan uses an `Ability` class to define all authorization rules:

```bash
rails generate cancan:ability
```

**Expected output:**
```
      create  app/models/ability.rb
```

---

### Step 3.4: Review the generated Ability class

```ruby
# app/models/ability.rb

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the user here. For example:
    #
    #   return unless user.present?
    #   can :read, :all
    #   return unless user.admin?
    #   can :manage, :all
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, published: true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
  end
end
```

**What is the Ability class?**
- It's where you define ALL authorization rules for your application
- The `initialize` method receives the current user
- You use `can` and `cannot` methods to define permissions

---

# Part 4 — Define Authorization Rules

## Goal

Create simple ownership-based rules: users can only manage their own tasks.

---

### Step 4.1: Define abilities for tasks

Replace the generated Ability class with our rules:

```ruby
# app/models/ability.rb

class Ability
  include CanCan::Ability

  def initialize(user)
    # Return early if no user is signed in (guest user)
    return unless user.present?

    # Users can manage (create, read, update, delete) their own tasks
    can :manage, Task, user_id: user.id

    # Alternative syntax using a block (more flexible):
    # can :manage, Task do |task|
    #   task.user_id == user.id
    # end
  end
end
```

**Understanding the rule:**

```ruby
can :manage, Task, user_id: user.id
```

This single line means:
- `:manage` — All actions (create, read, update, destroy, and any custom actions)
- `Task` — On the Task model
- `user_id: user.id` — But only where the task's `user_id` matches the current user's id

---

### Step 4.2: Understanding CanCanCan actions

CanCanCan uses these standard actions:

| Action | Controller methods |
|--------|-------------------|
| `:read` | `index`, `show` |
| `:create` | `new`, `create` |
| `:update` | `edit`, `update` |
| `:destroy` | `destroy` |
| `:manage` | All of the above + any custom actions |

You can also define custom actions:

```ruby
# Example (we'll use this for toggle)
can :toggle, Task, user_id: user.id
```

---

### Step 4.3: Add toggle ability

Let's explicitly add the toggle action:

```ruby
# app/models/ability.rb

class Ability
  include CanCan::Ability

  def initialize(user)
    # Return early if no user is signed in
    return unless user.present?

    # Users can manage their own tasks (CRUD + toggle)
    can :manage, Task, user_id: user.id
    
    # The :manage action includes all actions, including custom ones like :toggle
    # But you could also be explicit:
    # can [:read, :create, :update, :destroy, :toggle], Task, user_id: user.id
  end
end
```

---

# Part 5 — Apply Authorization in Controllers

## Goal

Use CanCanCan to automatically load and authorize resources, replacing manual scoping.

---

### Step 5.1: Update TasksController with load_and_authorize_resource

CanCanCan provides a powerful helper that:
1. Loads the resource (like our `set_task` method)
2. Authorizes the action (checks the Ability)

```ruby
# app/controllers/tasks_controller.rb

class TasksController < ApplicationController
  # CanCanCan will:
  # - For collection actions (index): load @tasks with accessible tasks
  # - For member actions (show, edit, update, destroy, toggle): load @task and authorize
  # - For new/create: build @task and authorize
  load_and_authorize_resource

  # GET /tasks
  def index
    # @tasks is automatically loaded by CanCanCan
    # We just need to apply our additional scopes
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
    # @task is automatically loaded and authorized
  end

  # GET /tasks/new
  def new
    # @task is automatically built (Task.new)
  end

  # POST /tasks
  def create
    # @task is automatically built with task_params
    # We need to assign the user
    @task.user = current_user

    if @task.save
      redirect_to tasks_path, notice: t("flash.tasks.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /tasks/:id/edit
  def edit
    # @task is automatically loaded and authorized
  end

  # PATCH/PUT /tasks/:id
  def update
    # @task is automatically loaded and authorized
    if @task.update(task_params)
      redirect_to tasks_path, notice: t("flash.tasks.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /tasks/:id
  def destroy
    # @task is automatically loaded and authorized
    @task.destroy
    redirect_to tasks_path, notice: t("flash.tasks.destroyed")
  end

  # PATCH /tasks/:id/toggle
  def toggle
    # @task is automatically loaded and authorized
    @task.toggle_completed!
    redirect_to tasks_path, notice: t("flash.tasks.toggled")
  end

  private

  # No longer needed! CanCanCan handles this
  # def set_task
  #   @task = current_user.tasks.find(params[:id])
  # end

  def task_params
    params.require(:task).permit(:title, :completed)
  end
end
```

**What `load_and_authorize_resource` does:**

| Action | What CanCanCan does |
|--------|---------------------|
| `index` | `@tasks = Task.accessible_by(current_ability)` |
| `show`, `edit`, `update`, `destroy`, `toggle` | `@task = Task.find(params[:id])` then `authorize! :action, @task` |
| `new` | `@task = Task.new` then `authorize! :new, @task` |
| `create` | `@task = Task.new(task_params)` then `authorize! :create, @task` |

---

### Step 5.2: Understanding accessible_by

For the `index` action, CanCanCan uses `accessible_by` to fetch only records the user can access:

```ruby
# This is what CanCanCan does internally for index
@tasks = Task.accessible_by(current_ability)

# Which translates to (based on our ability):
@tasks = Task.where(user_id: current_user.id)
```

This is why we no longer need `current_user.tasks` — CanCanCan handles it!

---

### Step 5.3: Restart and test

```bash
bin/dev
```

1. Log in as Alice
2. Visit /tasks — you should see only Alice's tasks
3. The application should work exactly as before

**Expected result:**
Everything works the same, but now authorization is handled by CanCanCan.

---

# Part 6 — Demonstrate Authorization in Action

## Goal

Verify that CanCanCan properly blocks unauthorized access.

---

### Step 6.1: Test unauthorized access

Try to access another user's task:

1. Log in as Alice (alice@example.com)
2. Note the ID of one of Alice's tasks (e.g., `/tasks/1`)
3. Log out
4. Log in as Bob (bob@example.com)
5. Manually visit `/tasks/1` (Alice's task)

**Expected result:**
You should see an error page with `CanCan::AccessDenied` exception.

---

### Step 6.2: Understand what happened

When Bob tried to access Alice's task:

1. CanCanCan loaded the task: `Task.find(1)`
2. CanCanCan checked: `can? :show, @task`
3. The Ability class evaluated: `task.user_id == current_user.id`
4. Since Alice's task has `user_id = 1` and Bob has `id = 2`, the check failed
5. CanCanCan raised `CanCan::AccessDenied`

---

### Step 6.3: The difference between Authentication and Authorization

| Scenario | What happens |
|----------|--------------|
| User not logged in, visits /tasks | **Devise** redirects to login (Authentication) |
| Bob logged in, visits his own task | CanCanCan allows access (Authorization ✓) |
| Bob logged in, visits Alice's task | **CanCanCan** raises AccessDenied (Authorization ✗) |

**Remember:**
- **Authentication** = Who are you? (Handled by Devise)
- **Authorization** = What can you do? (Handled by CanCanCan)

---

# Part 7 — Handle AccessDenied Gracefully

## Goal

Instead of showing an ugly error page, redirect users with a friendly message.

---

### Step 7.1: Add rescue_from in ApplicationController

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  # Handle CanCanCan authorization errors
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        redirect_to root_path, alert: "Access denied. You are not authorized to perform this action."
      end
      format.json { head :forbidden }
    end
  end
end
```

---

### Step 7.2: Test the friendly error

1. Log in as Bob
2. Try to access Alice's task by URL
3. You should be redirected to the tasks page with a flash message

**Expected result:**
"Access denied. You are not authorized to perform this action."

---

### Step 7.3: Optional - Log authorization failures

For debugging and security monitoring:

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    # Log the failed attempt
    Rails.logger.warn "ACCESS DENIED: User #{current_user&.id} (#{current_user&.email}) " \
                      "tried to #{exception.action} #{exception.subject.class} " \
                      "(#{exception.subject.try(:id)})"

    respond_to do |format|
      format.html do
        redirect_to root_path, alert: "Access denied. You are not authorized to perform this action."
      end
      format.json { head :forbidden }
    end
  end
end
```

---

### Step 7.4: Using can? in views

You can also use CanCanCan helpers in views to show/hide elements:

```erb
<!-- app/views/tasks/index.html.erb -->

<% @tasks.each do |task| %>
  <div class="task-item">
    <div class="task-title"><%= task.title %></div>
    
    <div class="task-actions">
      <% if can? :update, task %>
        <%= link_to "Edit", edit_task_path(task), class: "btn btn-small" %>
      <% end %>
      
      <% if can? :destroy, task %>
        <%= button_to "Delete", task_path(task), method: :delete, class: "btn btn-small btn-danger" %>
      <% end %>
    </div>
  </div>
<% end %>
```

**Available view helpers:**
- `can? :action, object` — Returns true if the user can perform the action
- `cannot? :action, object` — Returns true if the user cannot perform the action

---

# Part 8 — Creating an Admin User

## Goal

Add an admin role that can manage ALL tasks, not just their own.

---

### Step 8.1: Generate migration to add admin column

We need a way to identify admin users. The simplest approach is adding a boolean `admin` column:

```bash
rails generate migration AddAdminToUsers admin:boolean
```

---

### Step 8.2: Edit the migration

Set the default value to `false` so regular users are not admins by default:

```ruby
# db/migrate/XXXXXXXXXXXXXX_add_admin_to_users.rb

class AddAdminToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :admin, :boolean, default: false, null: false
  end
end
```

---

### Step 8.3: Run the migration

```bash
rails db:migrate
```

**Expected output:**
```
== XXXXXXXXXXXXXX AddAdminToUsers: migrating ==================================
-- add_column(:users, :admin, :boolean, {:default=>false, :null=>false})
   -> 0.0XXXs
== XXXXXXXXXXXXXX AddAdminToUsers: migrated (0.0XXXs) =========================
```

---

### Step 8.4: Update the Ability class

Now update CanCanCan to give admins full access:

```ruby
# app/models/ability.rb

class Ability
  include CanCan::Ability

  def initialize(user)
    # Return early if no user is signed in
    return unless user.present?

    # Admin users can manage everything
    if user.admin?
      can :manage, :all
    else
      # Regular users can only manage their own tasks
      can :manage, Task, user_id: user.id
    end
  end
end
```

**What this does:**
- `can :manage, :all` — Admins can perform any action on any resource
- Regular users still only see and manage their own tasks

---

### Step 8.5: Create an admin user via Rails console

Open the Rails console:

```bash
rails console
```

Create an admin user:

```ruby
# Create a new admin user
User.create!(
  email: 'admin@example.com',
  password: 'password123',
  admin: true
)

# Or make an existing user an admin
user = User.find_by(email: 'alice@example.com')
user.update!(admin: true)
```

Verify the admin status:

```ruby
User.find_by(email: 'admin@example.com').admin?
# => true
```

---

### Step 8.6: Create admin via seeds (optional)

Update your seeds file to include an admin user:

```ruby
# db/seeds.rb

puts "Creating users..."

# Create admin user
admin = User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.password = 'password123'
  user.admin = true
end
puts "  Admin: #{admin.email} (admin: #{admin.admin?})"

# Create regular users
alice = User.find_or_create_by!(email: 'alice@example.com') do |user|
  user.password = 'password123'
  user.admin = false
end
puts "  User: #{alice.email} (admin: #{alice.admin?})"

bob = User.find_or_create_by!(email: 'bob@example.com') do |user|
  user.password = 'password123'
  user.admin = false
end
puts "  User: #{bob.email} (admin: #{bob.admin?})"

# Create tasks for each user
puts "\nCreating tasks..."

alice.tasks.find_or_create_by!(title: "Alice's task 1")
alice.tasks.find_or_create_by!(title: "Alice's task 2")
bob.tasks.find_or_create_by!(title: "Bob's task 1")
bob.tasks.find_or_create_by!(title: "Bob's task 2")

puts "  Created #{Task.count} tasks"

puts "\nDone!"
puts "\nTest accounts:"
puts "  Admin: admin@example.com / password123"
puts "  User:  alice@example.com / password123"
puts "  User:  bob@example.com / password123"
```

Run seeds:

```bash
rails db:seed
```

---

### Step 8.7: Test admin access

1. Log in as **admin@example.com**
2. You should see ALL tasks from all users
3. You can edit, delete, or toggle any task

4. Log out and log in as **alice@example.com**
5. You should only see Alice's tasks
6. Trying to access Bob's task URL will redirect with "Access denied"

---

### Step 8.8: Show admin badge in the UI (optional)

Update your layout to indicate when an admin is logged in:

```erb
<!-- app/views/layouts/application.html.erb -->

<div class="nav-links">
  <% if user_signed_in? %>
    <%= link_to "All Tasks", tasks_path, class: "nav-link" %>
    <%= link_to "New Task", new_task_path, class: "nav-link nav-link-primary" %>
    <span class="nav-user">
      <%= current_user.email %>
      <% if current_user.admin? %>
        <span class="admin-badge">ADMIN</span>
      <% end %>
    </span>
    <%= button_to "Logout", destroy_user_session_path, method: :delete, class: "nav-link btn-logout" %>
  <% else %>
    <!-- ... -->
  <% end %>
</div>
```

Add CSS for the admin badge:

```css
/* app/assets/stylesheets/application.css */

.admin-badge {
  background-color: #ef4444;
  color: white;
  font-size: 0.625rem;
  font-weight: 700;
  padding: 0.125rem 0.375rem;
  border-radius: 4px;
  margin-left: 0.5rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
```

---

### Step 8.9: Security consideration — Protect the admin attribute

> ⚠️ **IMPORTANT:** Never allow the `admin` attribute to be set via forms!

Make sure `admin` is NOT in your strong parameters. Users should not be able to make themselves admin through the registration form.

```ruby
# This is WRONG - never do this:
params.require(:user).permit(:email, :password, :admin)  # ❌ DANGEROUS!

# The admin attribute should only be set via:
# - Rails console
# - Database seeds
# - Admin panel (if you build one)
```

Devise by default does not include `admin` in permitted parameters, so you're safe as long as you don't add it.

---

## Admin Summary

| User Type | Permissions |
|-----------|-------------|
| **Guest** (not logged in) | Cannot access tasks (redirected to login) |
| **Regular User** | Can manage only their own tasks |
| **Admin** | Can manage ALL tasks from all users |

---

# Summary

## What We Accomplished

### Part 1-2: Devise (Authentication)
- Installed and configured Devise
- Created a User model with secure authentication
- Added login/logout/registration functionality
- Associated Tasks with Users
- Scoped tasks to the current user

### Part 3-6: CanCanCan (Authorization)
- Installed and configured CanCanCan
- Defined abilities in a centralized Ability class
- Used `load_and_authorize_resource` for automatic authorization
- Handled unauthorized access gracefully

### Part 7: Graceful Error Handling
- Added `rescue_from CanCan::AccessDenied` for friendly redirects
- Used `can?` helpers in views to show/hide elements

### Part 8: Admin Users
- Added `admin` boolean column to users
- Updated Ability class to give admins full access (`can :manage, :all`)
- Created admin users via console and seeds

---

## Key Files Changed

| File | Purpose |
|------|---------|
| `Gemfile` | Added devise and cancancan gems |
| `config/initializers/devise.rb` | Devise configuration |
| `app/models/user.rb` | User model with Devise modules |
| `app/models/task.rb` | Added belongs_to :user |
| `app/models/ability.rb` | CanCanCan authorization rules (including admin) |
| `app/controllers/application_controller.rb` | authenticate_user! and AccessDenied handler |
| `app/controllers/tasks_controller.rb` | load_and_authorize_resource |
| `app/views/layouts/application.html.erb` | Login/logout links |
| `db/migrate/*_add_admin_to_users.rb` | Admin column migration |

---

## Quick Reference

### Devise Helpers
```ruby
user_signed_in?          # Is a user logged in?
current_user             # The logged-in User object
authenticate_user!       # Before action to require login
new_user_session_path    # Login page path
destroy_user_session_path # Logout path
new_user_registration_path # Sign up path
```

### CanCanCan Helpers
```ruby
# In controllers
load_and_authorize_resource  # Auto-load and authorize
authorize! :action, @object  # Manual authorization

# In views
can? :action, @object        # Check if user can do action
cannot? :action, @object     # Check if user cannot do action

# In Ability class
can :manage, Model, condition  # Allow all actions
can :read, Model               # Allow read actions
cannot :destroy, Model         # Deny destroy action
```

---

## Next Steps (Beyond This Tutorial)

Once you're comfortable with the basics, you can explore:

1. **Multiple roles** — Add roles like `moderator`, `manager` using gems like `rolify`
2. **Devise modules** — Confirmable (email verification), Lockable, etc.
3. **Custom Devise views** — `rails g devise:views`
4. **Admin dashboard** — Build an admin panel to manage users
5. **Testing** — Write tests for your abilities
6. **API authentication** — Use `devise-jwt` for token-based auth

---

## Troubleshooting

### "You need to sign in or sign up before continuing"
- This means Devise is working! Log in or create an account.

### CanCan::AccessDenied error
- The user doesn't have permission for that action
- Check your Ability class rules

### "undefined method 'current_user'"
- Make sure Devise is properly installed
- Check that the User model exists and migrations are run

### Tasks not showing up
- Make sure tasks are associated with the logged-in user
- Check that `load_and_authorize_resource` is in the controller

---

**Congratulations!** 🎉 You've successfully integrated authentication and authorization into your Rails application!

