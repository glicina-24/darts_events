class RemovePasswordDigestFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :password_digest, :string
  end
end
