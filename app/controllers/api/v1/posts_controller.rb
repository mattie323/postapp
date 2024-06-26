class Api::V1::PostsController < Api::V1::BaseController
  before_action :authorize_request
  before_action :set_post, only: %i[show update destroy]

  api :GET, "/v1/posts", "List all posts"
  param :title, String, desc: "Title to filter posts", required: false
  param :sort, %w[asc desc], desc: "Sort order of the posts", required: false
  param :page, :number, desc: "Page number for pagination", required: false
  param :items, :number, desc: "Number of items per page for pagination", required: false

  def index
    posts = apply_filters(Post.all)
    pagy, records = paginate(posts)
    render json:    { posts: records, each_serializer: PostSerializer, pagy: pagy_metadata(pagy) },
           include: :comments
  end


  api :POST, "/v1/posts", "Create a new post"
  param :title, String, desc: "Title of the post", required: true
  param :body, String, desc: "Body of the post", required: true
  def create
    post = @current_user.posts.new(post_params)
    if post.save
      render json: post, status: :created, serializer: PostSerializer
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  api :GET, "/v1/posts/:id", "Show a specific post"
  param :id, :number, desc: "ID of the post", required: true
  def show
    render json: @post, serializer: PostSerializer, include: :comments
  end

  api :PUT, "/v1/posts/:id", "Update a specific post"
  param :id, :number, desc: "ID of the post", required: true
  param :title, String, desc: "Title of the post", required: false
  param :body, String, desc: "Body of the post", required: false
  def update
    if @post.update(post_params)
      render json: @post, serializer: PostSerializer
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  api :DELETE, "/v1/posts/:id", "Delete a specific post"
  param :id, :number, desc: "ID of the post", required: true
  def destroy
    @post.destroy
    head :no_content
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body)
  end

  def paginate(posts)
    pagy, records = pagy(posts, page: params[:page], items: params[:items] || 20)
    [pagy, records]
  end

  def apply_filters(posts)
    posts = posts.where("title ILIKE ?", "%#{params[:title]}%") if params[:title].present?
    posts = posts.order(created_at: params[:sort] || :asc) if params[:sort].present?
    posts
  end
end
