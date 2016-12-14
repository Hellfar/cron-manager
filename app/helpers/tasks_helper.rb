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

    @identifier = c_variables.find_by(name: "identifier").value

    jobs = job_list.generate_cron_output
    jobs if write_crontab updated_crontab jobs
  end

  def self.whenever_cron contents = ''
    return '' unless contents && contents.length > 0
    [comment_open, contents, comment_close].compact.join("\n") + "\n"
  end

  def self.read_crontab
    # whoami = %x[whoami]

    command = ['crontab', '-l']
    command << "-u #{whoami}" if defined? whoami

    command_results  = %x[#{command.join(' ')} 2> /dev/null]

    $?.exitstatus.zero? ? prepare(command_results) : ''
  end

  def self.write_crontab contents
    # whoami = %x[whoami]

    command = ['crontab']
    command << "-u #{whoami}" if defined? whoami
    # Solaris/SmartOS cron does not support the - option to read from stdin.
    command << "-" unless Whenever::OS.solaris?

    IO.popen(command.join(' '), 'r+') do |crontab|
      crontab.write(contents)
      crontab.close_write
    end

    success = $?.exitstatus.zero?

    if success
      Rails.logger.info "[write] crontab file updated"
    else
      Rails.logger.error "[fail] Couldn't write crontab; try running `whenever' with no options to ensure your schedule file is valid."
    end
  end

  def self.updated_crontab contents
    current_crontab = read_crontab

    # Check for unopened or unclosed identifier blocks
    if current_crontab =~ Regexp.new("^#{comment_open}\s*$") && (current_crontab =~ Regexp.new("^#{comment_close}\s*$")).nil?
      Rails.logger.error "[fail] Unclosed indentifier; Your crontab file contains '#{comment_open}', but no '#{comment_close}'"
      return ''
    elsif (current_crontab =~ Regexp.new("^#{comment_open}\s*$")).nil? && current_crontab =~ Regexp.new("^#{comment_close}\s*$")
      Rails.logger.error "[fail] Unopened indentifier; Your crontab file contains '#{comment_close}', but no '#{comment_open}'"
      return ''
    end

    # If an existing identier block is found, replace it with the new cron entries
    if current_crontab =~ Regexp.new("^#{comment_open}\s*$") && current_crontab =~ Regexp.new("^#{comment_close}\s*$")
      # If the existing crontab file contains backslashes they get lost going through gsub.
      # .gsub('\\', '\\\\\\') preserves them. Go figure.
      current_crontab.gsub(Regexp.new("^#{comment_open}\s*$.+^#{comment_close}\s*$", Regexp::MULTILINE), whenever_cron(contents).chomp.gsub('\\', '\\\\\\'))
    else # Otherwise, append the new cron entries after any existing ones
      [current_crontab, whenever_cron(contents)].join("\n\n")
    end.gsub(/\n{3,}/, "\n\n") # More than two newlines becomes just two.
  end

  def self.prepare contents
    # Some cron implementations require all non-comment lines to be newline-
    # terminated. (issue #95) Strip all newlines and replace with the default
    # platform record seperator ($/)
    contents.gsub!(/\s+$/, $/)
  end

  def self.comment_base
    "Whenever through rails generated tasks with internal DB data, identifier: #{@identifier}"
  end

  def self.comment_open
    "# Begin #{comment_base}"
  end

  def self.comment_close
    "# End #{comment_base}"
  end
end
