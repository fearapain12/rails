class RoutesController < ApplicationController
  def draw

  end

  def route
    uploaded_file = params[:file]
    @file_content = uploaded_file.read
    @objson = JSON.parse(@file_content)
    rutan = @objson.fetch("route")
    @ruta = rutan.to_json
    @nombre = params[:nombre]



    Person.create(:name => @nombre)
    #createuser(@nombre)
    @persona = Person.find_by_name(@nombre)




    rutan.each do |point|

      @persona.samples.create(:latitude => point["latitude"], :longitude => point["longitude"], :timestamp => point["timestamp"])



    end

  end

  def users
    @users = Person.all


  end

  def usersmap

    puts "esto"

    checks = params[:us_ids]
    @allsamples = Array.new
    checks.each do |ch|
      Person.find(ch.to_i).samples.each do |sa|
        @allsamples << sa
      end
    end

    @puntos = @allsamples.to_json

  end
end
