class Task < ApplicationRecord
  STATES = %w[created current archived]
  validates :state, inclusion: { in: STATES }
end
