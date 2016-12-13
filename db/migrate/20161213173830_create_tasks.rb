class CreateTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :tasks do |t|
      t.integer :recurence, default: 1
      t.string :precision, default: "minute", null: false
      t.string :job_type, default: "command", null: false
      t.string :command, null: true
      t.string :state, default: "created", null: false

      t.timestamps
    end
  end
end
