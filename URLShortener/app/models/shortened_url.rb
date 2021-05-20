# == Schema Information
#
# Table name: shortened_urls
#
#  id         :bigint           not null, primary key
#  long_url   :string           not null
#  short_url  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
class ShortenedUrl < ApplicationRecord
    validates :short_url, presence: true, uniqueness:true
    validates :long_url, presence: true

    def self.random_code
        random_url = SecureRandom.urlsafe_base64
        while ShortenedUrl.exists?(short_url:random_url)
            random_url = SecureRandom.urlsafe_base64
        end
        random_url
    end

    def self.generate(user, url)
        ShortenedUrl.create!(user_id:user.id, long_url:url, short_url:ShortenedUrl.random_code)
    end

    belongs_to :submitter,
        primary_key: :id,
        foreign_key: :user_id,
        class_name: :User

    has_many :visits,
        primary_key: :id,
        foreign_key: :url_id,
        class_name: :Visit

    has_many :visitors,
    Proc.new { distinct },
        through: :visits,
        source: :visitor

        def num_clicks
            Visit.select(:user_id).where(url_id:self.id).count
        end

        def num_uniques
            Visit.select(:user_id).where(url_id:self.id).distinct.count
        end

        def num_recent_uniques
            Visit.select(:user_id).where(url_id:self.id).where("created_at >?",10.minutes.ago).distinct.count
        end
        
end
# user1 = User.create!(email:"abc")
# user2 = User.create!(email:"abdfc")
# url1 = ShortenedUrl.generate(user1,"abc.com")
# url2 = ShortenedUrl.generate(user2,"defc.com")
# visit1= Visit.record_visit!(user1,url1)
# visit2 = Visit.record_visit!(user2,url2)
# visit3= Visit.record_visit!(user1,url2)
