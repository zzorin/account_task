class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts do |t|
      t.float :balance, default: 0, null: false
      t.references :admin_user, foreign_key: true, index: true
      t.timestamps
    end
  end
end
