class Note < ApplicationRecord
  belongs_to :user

  # title は deterministic: true にすることで WHERE 検索が可能になる
  # body は非決定論的暗号化（デフォルト）のため毎回異なる暗号文になる
  encrypts :title, deterministic: true
  encrypts :body

  validates :title, presence: true, length: { maximum: 255 }
  validates :body,  presence: true

  default_scope { order(created_at: :desc) }
end
