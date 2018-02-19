class CreatePillSequences < ActiveRecord::Migration
  def change
    create_table :pill_sequences do |t|
      t.string :name
      t.boolean :default, default: false

      t.timestamps
    end
  end
end
