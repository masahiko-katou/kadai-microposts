class FavoritesController < ApplicationController
  before_action :require_user_logged_in
  
  def create
    micropost = Micropost.find(params[:like_id])
    current_micropost.like(micropost)
    flash[:success] = '投稿をお気に入りに追加しました。'
    redirect_to toppage
  end

  def destroy
    micropost = Micropost.find(params[:like_id])
    current_micropost.unlike(micropost)
    flash[:success] = '投稿をお気に入りから解除しました。'
    redirect_to toppage
  end
end
