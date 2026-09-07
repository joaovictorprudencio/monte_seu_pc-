class ComputersController < ApplicationController
  before_action :set_computer, only: %i[ show edit update destroy review create_assemble increment_component decrement_component ]

  CATEGORY_ORDER = %W[CPU MOTHERBOARD RAM GPU STORAGE SOURCE CASE REVIEW]

  def index
    @computers = Computer.all
  end

  def show
  end

  def new
    @computer = Computer.new
  end

  def edit
  end

  def create
    @computer = Computer.new(computer_params.merge(
      status: :draft,
      total_price: 0.0,
      user: User.first
    ))

    if @computer.save
      redirect_to select_category_path(category: "CPU", computer_id: @computer.id)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def review
    @computer_parts = @computer.computer_parts.includes(:component)
    @components_by_category = @computer_parts.group_by { |cp| cp.component.category }
    @grouped_components = @components_by_category.transform_values do |parts|
      parts.group_by { |cp| cp.component_id }.map do |_component_id, component_parts|
        { component: component_parts.first.component, count: component_parts.size }
      end
    end
    @total_price = @computer.total_price
  end

  def create_assemble
    @computer = Computer.find(params[:id])
    @component = Component.find(params[:component_id])

    @couple = Computers::CreateComputerService.new(
      computer: @computer,
      component: @component,
    ).call

    current_category = CATEGORY_ORDER.index(@component.category)
    next_category = CATEGORY_ORDER[current_category + 1] || "REVIEW"

    respond_to do |format|
      if next_category == "REVIEW"
        format.html { redirect_to review_computer_path(@computer) }
        format.turbo_stream {
          render turbo_stream: turbo_stream.action(:redirect, review_computer_path(@computer))
        }
      else
        format.html { redirect_to select_category_path(category: next_category, computer_id: @computer.id) }
        format.turbo_stream {
          render turbo_stream: turbo_stream.action(:redirect, select_category_path(category: next_category, computer_id: @computer.id))
        }
      end
    end
  end


  def update
    respond_to do |format|
      if @computer.update(computer_params)
        format.html { redirect_to @computer, notice: "Informações de maquina atualizdas com sucesso", status: :see_other }
        format.json { render :show, status: :ok, location: @computer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @computer.errors, status: :unprocessable_entity }
      end
    end
  end

  def increment_component
    category = params[:category]
    computer_part = @computer.computer_parts.joins(:component).where(components: { category: category }).last

    if computer_part
      Computers::CreateComputerService.new(
        computer: @computer,
        component: computer_part.component
      ).call
    end

    redirect_to review_computer_path(@computer)
  end

  def decrement_component
    category = params[:category]
    computer_part = @computer.computer_parts.joins(:component).where(components: { category: category }).last

    if computer_part
      Computers::RemoveComputerService.new(
        computer: @computer,
        computer_part: computer_part
      ).call
    end

    redirect_to review_computer_path(@computer)
  end

  def destroy
    @computer.destroy!

    respond_to do |format|
      format.html { redirect_to computers_path, notice: "Computer was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def set_computer
      @computer = Computer.find(params.expect(:id))
    end


    def computer_params
      params.expect(computer: [ :name, :description, :type_of_use,  :total_price => 0.0 ])
    end
end
