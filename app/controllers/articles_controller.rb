class ArticlesController < ApplicationController
  allow_unauthenticated_access

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    # valid?(:create) を呼ぶことで on: :create バリデーションも含めて検証する
    # on: :update バリデーションは valid?(:update) で検証される
    if @article.valid?(:create)
      redirect_to new_article_path, notice: "すべてのバリデーションを通過しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def article_params
    params.require(:article).permit(
      :title, :body, :summary, :author_name,
      :status, :content_type,
      :email, :email_confirmation,
      :zip_code, :slug, :color_code, :legacy_field,
      :price, :priority, :score,
      :terms_accepted, :published, :published_at, :expiry_date
    )
  end
end
