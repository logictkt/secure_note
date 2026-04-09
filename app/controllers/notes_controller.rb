class NotesController < ApplicationController
  before_action :set_note, only: %i[show edit update destroy]

  def index
    @notes = Current.user.notes
  end

  def show
    # DB上の生データ（暗号化済み文字列）を取得してデモ表示に使う
    raw = ActiveRecord::Base.connection.select_one(
      "SELECT title, body FROM notes WHERE id = #{@note.id.to_i}"
    )
    @raw_title = raw["title"]
    @raw_body  = raw["body"]
  end

  def new
    @note = Current.user.notes.build
  end

  def create
    @note = Current.user.notes.build(note_params)
    if @note.save
      redirect_to note_path(@note), notice: "ノートを保存しました（暗号化済み）"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @note.update(note_params)
      redirect_to note_path(@note), notice: "ノートを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    redirect_to notes_path, notice: "ノートを削除しました"
  end

  private

  def set_note
    @note = Current.user.notes.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:title, :body)
  end
end
