class ChangeUsers < ActiveRecord::Migration[6.0]
 def change
    change_table :users do |t|
      t.string :encrypted_password, null: false, default: ''
      t.string   :reset_password_token
      t.string :email, null: false
      t.datetime :reset_password_sent_at
    end

    add_index :users, :reset_password_token, unique: true
    add_index :users, :email, unique: true
  end
end
