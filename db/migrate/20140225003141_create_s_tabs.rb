class CreateSTabs < ActiveRecord::Migration
  def change
    create_table :s_tabs do |t|
      t.string :name
      t.string :contents

      t.timestamps
    end
  end
end
