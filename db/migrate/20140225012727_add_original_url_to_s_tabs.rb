class AddOriginalUrlToSTabs < ActiveRecord::Migration
  def change
    add_column :s_tabs, :original_url, :string
  end
end
