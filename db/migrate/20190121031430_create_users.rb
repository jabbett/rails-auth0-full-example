class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, null: false
      t.string :auth0_id, null: false
      t.datetime :last_sign_in_at

      t.timestamps
    end
  end
end
