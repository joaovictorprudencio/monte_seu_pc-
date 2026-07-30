class ComponentsController < ApplicationController
  before_action :set_component, only: %i[ show edit update destroy ]

  def index
    @components = Component.by_category(params[:category])
    .by_brand(params[:brand])
    .by_price_range(params[:min_price], params[:max_price])

    @components = case params[:order_by]
    when "expensive_first"
       @components.expensive_first
    when "by_name"
      @components.by_name
    else
      @components.cheaper_first
    end
     @components = @components.page(params[:page]).per(8)
  end

  def select_category
    @category = params[:category]
    @components = Component.by_category(@category)
                            .by_brand(params[:brand])
                            .by_price_range(params[:min_price], params[:max_price])
                            .page(params[:page])
                            .per(6)

    @selected_component = Component.find(params[:selected_id]) if params[:selected_id].present?
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end


  def show
  end


  def new
    @component = Component.new
  end


  def edit
  end


  def create
    @component = Component.new(component_params)

    respond_to do |format|
      if @component.save
        format.html { redirect_to @component, notice: "Component was successfully created." }
        format.json { render :show, status: :created, location: @component }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @component.errors, status: :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @component.update(component_params)
        format.html { redirect_to @component, notice: "Component was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @component }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @component.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @component.destroy!

    respond_to do |format|
      format.html { redirect_to components_path, notice: "Component was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

    def set_component
      @component = Component.find(params.expect(:id))
    end

    def component_params
      params.expect(component: [ :name, :brand,  :category, :architecture, :price, :image ])
    end
end
