class PostsController < ApplicationController
  # The cancancan load_and_authorize_resource takes care of several things automatically
  # see docs at: https://github.com/cancancommunity/cancancan/wiki/authorizing-controller-actions
  # permissions: :create, :read, :update, :destroy; also there is :manage that lets you do everything (good for admins)
  # 1. takes care of the before_action :set_post
  #       before_action :set_post, only: %i[ show edit update destroy ]
  #
  # 2. Handles access for all the methods
  #    NOTE: manually specifying access control for each function is a bad approach because you can forget a method
  #    - These are not needed any longer
  #        authorize! :index, @posts   # manual way for index function
  #        authorize! :show, @posts    # manual way for show function
  #
  # 3. index: takes care  setting posts for index:   @posts = Post.all
  # 4. new: takes care of creating the new post in the new function, @post = Post.new
  # 5. create: takes care of populating post_params and the post from parameters: @post = Post.new(post_params)
  # 6. update: no changes required, takes care of populating post_params, loading the @post
  #    from the database and authorizing that. It will authorize when it does the find to create the @post
  #    which was in the removed before filter: before_action :set_post
  # 7. destroy: does the same work as :update
  # 8. replaces the private set_post method
  load_and_authorize_resource


  # GET /posts or /posts.json
  def index; end

  # GET /posts/1 or /posts/1.json
  def show; end

  # GET /posts/new
  def new; end

  # GET /posts/1/edit
  def edit; end

  # POST /posts or /posts.json
  def create
    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # taken care of by load_and_authorize_resource
  # Use callbacks to share common setup or constraints between actions.
  # def set_post
  #   @post = Post.find(params[:id])
  # end

  # NOTE: cancancan will in the absence of (singular model name)_params look for
  # function specific names like, create_params, update_params. This allows support
  # of separate different forms for these actions
  # Only allow a list of trusted parameters through.
  def post_params
    params.require(:post).permit(:title, :body, :published, :publish_date)
  end
end
