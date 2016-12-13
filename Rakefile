# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

desc 'stop rails'
task :stop do
	pid_file = 'tmp/pids/server.pid'
	if File.exist? pid_file then
		pid = File.read(pid_file).to_i
		Process.kill 15, pid
		File.delete pid_file
	else
		puts "Rails was not running."
	end
end

desc 'print the pid of rails'
task :pid do
	pid_file = 'tmp/pids/server.pid'
	if File.exist? pid_file then
		puts File.read(pid_file).to_i
	else
		puts "Rails is not running."
	end
end
