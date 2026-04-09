# =============================================================================
# Article モデル — Rails バリデーション網羅サンプル
#
# DB を使わないため ActiveRecord ではなく ActiveModel::Model を include する。
# ActiveModel::Attributes でカラム型を定義することで type casting が有効になる。
# =============================================================================
class Article
  include ActiveModel::Model
  include ActiveModel::Attributes

  # ---------------------------------------------------------------------------
  # Attribute 定義
  # ---------------------------------------------------------------------------
  attribute :title,              :string
  attribute :body,               :string
  attribute :summary,            :string
  attribute :author_name,        :string
  attribute :status,             :string
  attribute :content_type,       :string
  attribute :email,              :string
  attribute :email_confirmation, :string   # confirmation バリデーション用
  attribute :zip_code,           :string
  attribute :slug,               :string
  attribute :color_code,         :string
  attribute :legacy_field,       :string
  attribute :price,              :decimal
  attribute :priority,           :integer
  attribute :score,              :integer
  attribute :terms_accepted,     :boolean
  attribute :published,          :boolean, default: false
  attribute :published_at,       :datetime
  attribute :expiry_date,        :datetime

  # ---------------------------------------------------------------------------
  # 1. presence — 必須チェック
  # ---------------------------------------------------------------------------
  validates :title,       presence: true
  validates :body,        presence: true
  validates :author_name, presence: true
  validates :email,       presence: true

  # ---------------------------------------------------------------------------
  # 2. absence — 値が空であることを強制（廃止フィールドなど）
  # ---------------------------------------------------------------------------
  validates :legacy_field, absence: true

  # ---------------------------------------------------------------------------
  # 3. length — minimum / maximum
  # title は 3 文字以上、100 文字以下
  # ---------------------------------------------------------------------------
  validates :title, length: { minimum: 3, maximum: 100 }

  # body は最低 10 文字
  validates :body, length: { minimum: 10 }

  # ---------------------------------------------------------------------------
  # 4. length — in: (Range で範囲指定)
  # ---------------------------------------------------------------------------
  validates :author_name, length: { in: 2..50 }

  # ---------------------------------------------------------------------------
  # 5. length — is: (ちょうど N 文字)
  # ---------------------------------------------------------------------------
  validates :zip_code, length: { is: 7 }, allow_blank: true

  # ---------------------------------------------------------------------------
  # 6. length — maximum + allow_blank
  # summary は入力任意だが、書いた場合は 200 文字以内
  # ---------------------------------------------------------------------------
  validates :summary, length: { maximum: 200 }, allow_blank: true

  # ---------------------------------------------------------------------------
  # 7. format — 正規表現によるフォーマットチェック
  # URI::MailTo::EMAIL_REGEXP は標準ライブラリが提供するメールアドレス正規表現
  # ---------------------------------------------------------------------------
  validates :email,
    format: {
      with:    URI::MailTo::EMAIL_REGEXP,
      message: "の形式が正しくありません（例: user@example.com）"
    }

  # ---------------------------------------------------------------------------
  # 8. inclusion — 許可値リストに含まれることを確認
  # ---------------------------------------------------------------------------
  validates :status,
    inclusion: {
      in:      %w[draft published archived],
      message: "%{value} は不正なステータスです。draft / published / archived のいずれかを指定してください"
    }

  # ---------------------------------------------------------------------------
  # 9. exclusion — 禁止値リストに含まれないことを確認
  # ---------------------------------------------------------------------------
  validates :content_type,
    exclusion: {
      in:      %w[admin system root],
      message: "%{value} は予約済みのため使用できません"
    },
    allow_blank: true

  # ---------------------------------------------------------------------------
  # 10. numericality — greater_than / less_than_or_equal_to
  # price は 0 より大きく、1,000,000 以下
  # ---------------------------------------------------------------------------
  validates :price,
    numericality: {
      greater_than:              0,
      less_than_or_equal_to:     1_000_000,
      message:                   "は 0 より大きく 1,000,000 以下で入力してください"
    }

  # ---------------------------------------------------------------------------
  # 11. numericality — only_integer + 範囲指定
  # priority は 1〜10 の整数
  # ---------------------------------------------------------------------------
  validates :priority,
    numericality: {
      only_integer:           true,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to:    10
    }

  # ---------------------------------------------------------------------------
  # 12. numericality — even + allow_nil
  # score は偶数のみ許可。nil の場合はスキップ
  # ---------------------------------------------------------------------------
  validates :score,
    numericality: { even: true },
    allow_nil: true

  # ---------------------------------------------------------------------------
  # 13. acceptance — チェックボックスなど「同意」の確認
  # accept: オプションを省略すると "1" または true が許可値
  # ---------------------------------------------------------------------------
  validates :terms_accepted, acceptance: true

  # ---------------------------------------------------------------------------
  # 14. confirmation — 入力確認フィールドとの一致チェック
  # email_confirmation アトリビュートを自動的に参照する
  # case_sensitive: false で大文字小文字を無視
  # ---------------------------------------------------------------------------
  validates :email, confirmation: { case_sensitive: false }

  # ---------------------------------------------------------------------------
  # 15. comparison — Rails 7+ で追加。値の大小比較バリデーション
  # expiry_date が published_at より後であることを保証
  # allow_nil: true のため片方が nil なら比較をスキップ
  # ---------------------------------------------------------------------------
  validates :expiry_date,
    comparison: { greater_than: :published_at },
    allow_nil:  true

  # ★ uniqueness は ActiveRecord 専用（DB クエリが必要）
  #    ActiveModel::Model では使えない。AR モデルでは以下のように書く:
  #    validates :slug, uniqueness: { case_sensitive: false, scope: :status }

  # ---------------------------------------------------------------------------
  # 16. 条件付きバリデーション — if: オプション
  # published が true のときだけ published_at の presence を要求
  # ---------------------------------------------------------------------------
  validates :published_at, presence: true, if: :published?

  # ---------------------------------------------------------------------------
  # 17. on: :create — 新規作成時のみ適用
  # ActiveModel では save/create の概念がないため valid?(:create) で確認できる
  # ---------------------------------------------------------------------------
  validates :slug, presence: true, on: :create

  # ---------------------------------------------------------------------------
  # 18. on: :update — 更新時のみ適用
  # valid?(:update) で確認できる
  # ---------------------------------------------------------------------------
  validates :summary, presence: true, on: :update

  # ★ strict: true — バリデーション失敗時に errors への追加ではなく
  #    ActiveModel::StrictValidationFailed 例外を raise する。
  #    主にデバッグ用途や「絶対に通過させてはいけない」ガードに使う。
  #    例: validates :title, presence: { strict: true }

  # ---------------------------------------------------------------------------
  # 19. カスタム EachValidator (app/validators/color_code_validator.rb)
  # #RRGGBB 形式かどうかを ColorCodeValidator で検証
  # ---------------------------------------------------------------------------
  validates :color_code, color_code: { allow_blank: true }

  # ---------------------------------------------------------------------------
  # 20. validates_with — バリデータクラス全体でモデルを検証
  # ContentValidator: body は title より長くなければならない
  # ---------------------------------------------------------------------------
  validates_with ContentValidator

  private

  # ---------------------------------------------------------------------------
  # Helper — status == "published" のとき真を返すメソッド
  # validates の if: オプションから参照される
  # ---------------------------------------------------------------------------
  def published?
    status == "published" || published == true
  end
end
