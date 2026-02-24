# Todo App

A minimal Ruby on Rails 7 todo application with PostgreSQL, designed for easy integration with Devise (authentication) and CanCanCan (authorization).

## Requirements

- Ruby 3.2+
- Rails 7.1+
- PostgreSQL

## Quick Start

### 1. Install dependencies

```bash
bundle install
```

### 2. Setup database

```bash
rails db:create db:migrate db:seed
```

### 3. Start the server

**Option A: Using bin/dev (recommended)**
```bash
bin/dev
```

**Option B: Using rails server**
```bash
rails server
```

Both commands will start the server on **port 4000** by default.

### 4. Open the application

Visit [http://localhost:4000](http://localhost:4000) in your browser.

## Features

### Current Features
- **Task CRUD**: Create, read, update, and delete tasks
- **Task Model**: Title (required), completed (boolean, default false), timestamps
- **Toggle Complete**: Quick toggle task completion from the index page
- **Filtering**: Filter tasks by All / Active / Completed
- **Flash Messages**: User feedback for all actions
- **Responsive Design**: Clean, mobile-friendly interface

### Devise/CanCanCan Readiness

The application includes placeholder authentication methods in `ApplicationController`:

```ruby
# Stub methods ready to be replaced by Devise
current_user       # Returns nil (will return User object)
user_signed_in?    # Returns false (will check session)
authenticate_user! # Redirects to /login placeholder
```

A placeholder login page exists at `/login` with instructions for Devise integration.

## Port Configuration

The application is configured to run on **port 4000** by default:

- `config/puma.rb` - Sets default port to 4000
- `Procfile.dev` - Specifies port 4000 for foreman
- `bin/dev` - Exports PORT=4000

## Project Structure

```
auth/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb  # Auth placeholders
│   │   ├── tasks_controller.rb        # Full CRUD + toggle
│   │   └── pages_controller.rb        # Login placeholder
│   ├── models/
│   │   ├── application_record.rb
│   │   └── task.rb                    # Validations & scopes
│   ├── views/
│   │   ├── layouts/application.html.erb
│   │   ├── tasks/                     # index, show, new, edit, _form
│   │   └── pages/login.html.erb       # Devise placeholder
│   ├── helpers/
│   │   ├── application_helper.rb
│   │   └── tasks_helper.rb
│   └── assets/
│       └── stylesheets/application.css
├── config/
│   ├── routes.rb                      # Tasks resources + toggle
│   ├── database.yml                   # PostgreSQL config
│   ├── puma.rb                        # Port 4000 default
│   └── environments/
├── db/
│   ├── migrate/
│   │   └── 20260224000001_create_tasks.rb
│   ├── schema.rb
│   └── seeds.rb                       # 10 sample tasks
├── test/
│   ├── controllers/tasks_controller_test.rb
│   ├── models/task_test.rb
│   └── fixtures/tasks.yml
├── Gemfile
├── Procfile.dev
├── bin/
│   ├── dev                            # Development server script
│   ├── rails
│   ├── rake
│   └── setup
└── README.md
```

## Routes

| Method | Path | Action | Description |
|--------|------|--------|-------------|
| GET | / | tasks#index | List all tasks |
| GET | /tasks | tasks#index | List tasks (with optional filter) |
| GET | /tasks/new | tasks#new | New task form |
| POST | /tasks | tasks#create | Create task |
| GET | /tasks/:id | tasks#show | Show task details |
| GET | /tasks/:id/edit | tasks#edit | Edit task form |
| PATCH | /tasks/:id | tasks#update | Update task |
| DELETE | /tasks/:id | tasks#destroy | Delete task |
| PATCH | /tasks/:id/toggle | tasks#toggle | Toggle completion |
| GET | /login | pages#login | Login placeholder |

## Next Steps: Adding Devise & CanCanCan

### Adding Devise

1. Add to Gemfile:
   ```ruby
   gem 'devise'
   ```

2. Install:
   ```bash
   bundle install
   rails generate devise:install
   rails generate devise User
   rails db:migrate
   ```

3. Remove placeholder methods from `ApplicationController`

4. Add `before_action :authenticate_user!` to controllers

### Adding CanCanCan

1. Add to Gemfile:
   ```ruby
   gem 'cancancan'
   ```

2. Install:
   ```bash
   bundle install
   rails generate cancan:ability
   ```

3. Define abilities in `app/models/ability.rb`

4. Use `authorize!` or `load_and_authorize_resource` in controllers

## Running Tests

```bash
rails test
```

## License

MIT License

