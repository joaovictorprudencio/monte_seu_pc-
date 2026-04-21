class ComponentsController < ApplicationController
  before_action :set_component, only: %i[ show edit update destroy ]


  def index
    @components = Component.all
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
      params.expect(component: [ :name, :brand, :computer_id, :category, :architecture, :price ])
    end
end
