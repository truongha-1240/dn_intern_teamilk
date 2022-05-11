class CreateAuthJwts < ActiveRecord::Migration[6.1]
  def change
    create_table :auth_jwts do |t|
      t.string :token_jwt

      t.timestamps
    end
  end
end
