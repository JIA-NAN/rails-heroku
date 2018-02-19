class CreateSideEffects < ActiveRecord::Migration
  def change
    create_table :side_effects do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
