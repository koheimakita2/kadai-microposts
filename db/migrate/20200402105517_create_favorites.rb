class CreateFavorites < ActiveRecord::Migration[5.2]
  def change
    create_table :favorites do |t|
      t.references :user, foreign_key: true
      t.references :micropost, foreign_key: true

      t.timestamps
      #同じ投稿をお気に入り登録できないようにする
      t.index [:user_id, :micropost_id], unique: true
    end
  end
end
