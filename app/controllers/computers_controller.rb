class ComputersController < ApplicationController
  before_action :set_computer, only: %i[ show edit update destroy ]


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
      redirect_to select_category_path(category: "CPU")
    else
      render :new, status: :unprocessable_entity
    end
  end


  def create_assemble
        computer = Computers::CreateComputerService.new(
      computer: Computer.find(params[:computer_id]),
      component: Component.find(params[:component_id]),
    ).call

    redirect_to computer
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
