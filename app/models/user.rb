class User < ApplicationRecord
    before_save { self.email.downcase! }
    validates :name, presence: true, length: { maximum: 50 }
    validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
    has_secure_password
    
     has_many :microposts
     has_many :relationships
     has_many :favorites
     has_many :followings, through: :relationships, source: :follow
     has_many :likes, through: :favorites, source: :micropost 
     has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
     has_many :reverses_of_favorite, class_name: 'Favorite', foreign_key: 'micropost_id'
     has_many :followers, through: :reverses_of_relationship, source: :user
     has_many :favoritted_users, through: :reverses_of_favorite, source: :user
     
    def follow(other_user)
        #自分自身でないか自分でなければ下記の処理を実行
        unless self == other_user
        #すでにフォローしているかしていればそのまま返ししてなければフォロする
            self.relationships.find_or_create_by(follow_id: other_user.id)
        end
    end 

    def unfollow(other_user)
        #自分が中間テーブルを経由してフォロしてるユーザとこれからフォローしようとしてるゆーざの関係を取得
        relationship = self.relationships.find_by(follow_id: other_user.id)
        relationship.destroy if relationship
    end

    def following?(other_user)
        self.followings.include?(other_user)
    end
    
    def feed_microposts
        Micropost.where(user_id: self.following_ids + [self.id])
    end
    
    def favorite(other_micropost)
        #selfにはお気に入りついかしてる投稿を持ったユーザが代入
        #すでにお気に入り追加してないかチェックしてればそのまましてなければつくる
        self.favorites.find_or_create_by(micropost_id: other_micropost.id)
    end
    
    def unfavorite(other_micropost)
        favorite = self.favorites.find_by(micropost_id: other_micropost.id)
        favorite.destroy if favorite
    end    
    
    def like?(other_micropost)
        self.likes.include?(other_micropost)
    end
end
