class Book < ActiveRecord::Base
  include PgSearch
  extend FriendlyId

  friendly_id :title, use: :slugged
  pg_search_scope :search_full_text, :against => [
    :title,
    :recommend,
    :keys,
    :lessons
  ]

  acts_as_taggable

  has_many :librarians
  has_many :libraries, through: :librarians

  has_attached_file :cover, 
    :styles => { 
      :full => "128x128>", 
      :thumb => "107x107#" 
    }, 
    :default_url => lambda { |a| "#{a.instance.create_default_url}" },
    :storage => :s3,
    :s3_credentials => Proc.new{|a| a.instance.s3_credentials },
    :url => ":s3_domain_url",
    :path => "/:class/covers/:id_:basename.:style.:extension"

  validates_attachment_content_type :cover, :content_type => /\Aimage\/.*\Z/

  validates :title, uniqueness: true

  def should_generate_new_friendly_id?
    new_record? || slug.blank?
  end

  def create_default_url
    ActionController::Base.helpers.asset_path("missing-cover.png")
  end

  def s3_credentials
    { 
      :bucket => ENV['BUCKET'], 
      :access_key_id => ENV['AWS_S3_KEY'], 
      :secret_access_key => ENV['AWS_S3_SECRET'] 
    }
  end
end
