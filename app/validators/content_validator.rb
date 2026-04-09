# validates_with で使うバリデータの例
# モデルのインスタンス全体にアクセスして複数属性をまたいだ検証ができる
# 使い方: validates_with ContentValidator
class ContentValidator < ActiveModel::Validator
  def validate(record)
    title = record.title.to_s
    body  = record.body.to_s

    if title.present? && body.present? && body.length <= title.length
      record.errors.add(:body, "は title よりも長くなければなりません（本文が短すぎます）")
    end
  end
end
