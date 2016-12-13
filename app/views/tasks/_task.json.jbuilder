json.extract! task, :id, :recurence, :precision, :job_type, :command, :state, :created_at, :updated_at
json.url task_url(task, format: :json)