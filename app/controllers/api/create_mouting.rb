module API
 class ComputerController < ApplicationController::API 


    def index
        computers = Computer.all 
        render json: computers
    end

    def create_mouting_load
        mouting = create_mounting(mouting_params)

        if mouting.save
            render json: mouting, status: :created
        else 
         render json: { errors:mouting.errors }, status: :unprocessable_entity  
        end
    end

    mouting_params.require(:mounting_params).permit(:architecture,:brand, :category, :form_factor, :max_gpu_length, :name, :price, :ram_type, :slots, :socket, :wattage)

 end
