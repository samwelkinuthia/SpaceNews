class LinksController < ApplicationController
  before_action :prevent_unauthorized_user_access, except: %i[show index]
``
  #display all links in the newest page in desc order of time.
  def newest
    @links = Link.newest
  end

  def show
    @link = Link.find_by(id: params[:id])
    @comments = @link.comments
  end

  def index
    @links = Link.hottest
  end

  def new
    @link = Link.new
  end

  def create
    @link = current_user.links.new(link_params)

    if @link.save
      redirect_to root_path, notice: 'Link successfully created'
    else
      render :new
    end
  end

  def edit
    link = Link.find_by(id: params[:id])

    if current_user.owns_link?(link)
      @link = link
    else
      redirect_to root_path, notice: 'Not authorized'
    end
  end

  def destroy
    link = Link.find_by(id: params[:id])
    if current_user.owns_link?(link)
      link.destroy
      redirect_to root_path, notice: 'Link deleted'
    else
      redirect_to root_path, notice: 'Not authorized'
    end
  end

  def update
    @link = current_user.links.find_by(id: params[:id])
    if @link.update(link_params)
      redirect_to root_path, notice: 'Updated'
    else
      render :edit
    end
  end

  # upvote method for links
  def upvote
    link = Link.find_by(id: params[:id])
    if current_user.upvoted?(link)
      current_user.remove_vote(link)
    elsif current_user.downvoted?(link)
      current_user.remove_vote(link)
      current_user.upvote(link)
    else
      current_user.upvote(link)
    end

    link.calc_hot_score
    redirect_to root_path
  end

  # downvotes
  def downvote
    link = Link.find_by(id: params[:id])

    if current_user.downvoted?(link)
      current_user.remove_vote(link)
    elsif current_user.upvoted?(link)
      current_user.remove_vote(link)
      current_user.downvote(link)
    else
      current_user.downvote(link)
    end

    link.calc_hot_score
    redirect_to root_path
  end

  private

  def link_params
    params.require(:link).permit(:title, :url, :description)
  end
end
