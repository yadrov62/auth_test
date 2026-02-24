class Task < ApplicationRecord
  # Validations
  validates :title, presence: true

  belongs_to :user

  # Scopes for filtering
  scope :active, -> { where(completed: false) }
  scope :completed, -> { where(completed: true) }
  scope :sorted, -> { order(created_at: :desc) }

  # Toggle the completed status
  def toggle_completed!
    update!(completed: !completed)
  end
end

