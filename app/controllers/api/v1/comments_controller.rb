class Api::V1::CommentsController < Api::V1::BaseController
  before_action :authorize_request
  before_action :set_post
  before_action :set_comment, only: %i[show update destroy]

  # GET /posts/:post_id/comments
  api :GET, "/v1/posts/:post_id/comments", "List all comments for a post"
  param :post_id, :number, desc: "ID of the post", required: true
  def index
    comments = @post.comments
    pagy, records = pagy(comments, page: params[:page], items: params[:items] || 20)
    render json: records, meta: pagy_metadata(pagy), each_serializer: CommentSerializer
  end

  # GET /posts/:post_id/comments/:id
  api :GET, "/v1/posts/:post_id/comments/:id", "Show a specific comment"
  param :post_id, :number, desc: "ID of the post", required: true
  param :id, :number, desc: "ID of the comment", required: true
  def show
    render json: @comment, serializer: CommentSerializer
  end

  # POST /posts/:post_id/comments
  api :POST, "/v1/posts/:post_id/comments", "Create a new comment"
  param :post_id, :number, desc: "ID of the post", required: true
  param :body, String, desc: "Body of the comment", required: true
  def create
    comment = @post.comments.new(comment_params)
    comment.user = @current_user
    if comment.save
      render json: comment, status: :created, serializer: CommentSerializer
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /posts/:post_id/comments/:id
  api :PUT, "/v1/posts/:post_id/comments/:id", "Update a specific comment"
  param :post_id, :number, desc: "ID of the post", required: true
  param :id, :number, desc: "ID of the comment", required: true
  param :body, String, desc: "Body of the comment", required: false
  def update
    if @comment.update(comment_params)
      render json: @comment, serializer: CommentSerializer
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /posts/:post_id/comments/:id
  api :DELETE, "/v1/posts/:post_id/comments/:id", "Delete a specific comment"
  param :post_id, :number, desc: "ID of the post", required: true
  param :id, :number, desc: "ID of the comment", required: true
  def destroy
    @comment.destroy
    head :no_content
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
