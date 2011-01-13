class CreateTickets < ActiveRecord::Migration
  def self.up
    create_table(:tickets) do |t|
      t.integer :project_id
      t.string :title
      t.string :description
      t.string :status
    end
  end

  def self.down
    drop_table(:tickets)
  end
end
