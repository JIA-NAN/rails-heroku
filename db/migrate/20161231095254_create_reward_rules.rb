class CreateRewardRules < ActiveRecord::Migration
  def change
    create_table :reward_rules do |t|
      t.integer :num_of_days
      t.decimal :reward, :precision => 8, :scale => 2
      t.timestamps
    end
  end
end
