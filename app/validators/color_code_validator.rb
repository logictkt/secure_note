# カスタム EachValidator の例
# validates :color_code, color_code: true のように使う
# アトリビュート値を1つずつ検証する場合は ActiveModel::EachValidator を継承する
class ColorCodeValidator < ActiveModel::EachValidator
  FORMAT = /\A#[0-9A-Fa-f]{6}\z/

  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]
    return if value.nil? && options[:allow_nil]

    unless FORMAT.match?(value.to_s)
      record.errors.add(attribute, options[:message] || :invalid,
        message: "は #RRGGBB 形式で入力してください（例: #FF5733）")
    end
  end
end
