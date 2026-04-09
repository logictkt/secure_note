class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def to_markdown
    <<~MD
      # User ##{id}

      - **Email**: #{email_address}
      - **Created**: #{created_at.strftime("%Y-%m-%d")}
    MD
  end
end
