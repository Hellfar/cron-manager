require "whenever"

module TasksHelper
  def self.crontab
    c_variables = Variable.all
    c_job_types = JobType.all
    c_tasks = Task.where.not state: "archived"

    job_list = Whenever::JobList.new ""

    c_variables.each do | variable |
      job_list.set variable.name, variable.value
    end

    c_job_types.each do | job_type |
      job_list.job_type job_type.task, job_type.template
    end

    c_tasks.each do | task |
      job_list.every task.recurence.method(task.precision).call do
        job_list.method(task.job_type).call task.command
      end
    end

    jobs = job_list.generate_cron_output
Rails.logger.info jobs
  end
end
