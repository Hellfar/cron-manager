class CreateJobTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :job_types do |t|
      t.string :task
      t.string :template

      t.timestamps
    end
  end
end
