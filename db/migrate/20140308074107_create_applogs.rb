class CreateApplogs < ActiveRecord::Migration
  def change
    create_table :applogs do |t|
      t.string :device
      t.string :version
      t.string :content
      t.string :level
      t.string :identifier

      t.timestamps
    end
  end
end
