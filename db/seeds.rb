# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Creating sample tasks..."

# Clear existing tasks
Task.destroy_all

# Create 10 sample tasks with mixed completed values
tasks_data = [
  { title: "Complete Rails tutorial", completed: true },
  { title: "Set up PostgreSQL database", completed: true },
  { title: "Implement user authentication with Devise", completed: false },
  { title: "Add authorization with CanCanCan", completed: false },
  { title: "Write unit tests for models", completed: false },
  { title: "Design responsive layout", completed: true },
  { title: "Configure production deployment", completed: false },
  { title: "Review code and refactor", completed: false },
  { title: "Update documentation", completed: true },
  { title: "Set up CI/CD pipeline", completed: false }
]

tasks_data.each do |task_attrs|
  Task.create!(task_attrs)
  puts "  Created: #{task_attrs[:title]} (#{task_attrs[:completed] ? 'completed' : 'active'})"
end

puts "\nDone! Created #{Task.count} tasks."
puts "  - Active: #{Task.active.count}"
puts "  - Completed: #{Task.completed.count}"

