require "whenever"

module TasksHelper
  def self.crontab
    c_task = Task.where.not state: "archived"

    # c_task
  end
end
