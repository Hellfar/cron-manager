# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#

# Environment variable defaults to RAILS_ENV
Variable.create name: "environment_variable", value: "RAILS_ENV"
# Environment defaults to production
Variable.create name: "environment", value: "production"
# Path defaults to the directory `whenever` was run from
Variable.create name: "path", value: Whenever.path

# All jobs are wrapped in this template.
# http://blog.scoutapp.com/articles/2010/09/07/rvm-and-cron-in-production
Variable.create name: "job_template", value: "/bin/bash -l -c ':job'"

Variable.create name: "runner_command", value: case
when Whenever.bin_rails?
  "bin/rails runner"
when Whenever.script_rails?
  "script/rails runner"
else
  "script/runner"
end

Variable.create name: "bundle_command", value: Whenever.bundler? ? "bundle exec" : ""

JobType.create task: "command", template: ":task :output"
JobType.create task: "rake", template:    "cd :path && :environment_variable=:environment :bundle_command rake :task --silent :output"
JobType.create task: "script", template:  "cd :path && :environment_variable=:environment :bundle_command script/:task :output"
JobType.create task: "runner", template:  "cd :path && :bundle_command :runner_command -e :environment ':task' :output"
