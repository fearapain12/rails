class LocationsController < ApplicationController
  def index
    # get all locations in the table locations
    @locations = Location.all

    # to json format
    @locations_json = @locations.to_json
  end

  def new
    # default: render ’new’ template (\app\views\locations\new.html.haml)
  end

  def create
    # create a new instance variable called @location that holds a Location object built from the data the user submitted
    @location = Location.new(location_params)

    # if the object saves correctly to the database
    if @location.save
      # redirect the user to index
      redirect_to locations_path, notice: 'Location was successfully created.'
    else
      # redirect the user to the new method
      render action: 'new'
    end
  end

  def edit
    # find only the location that has the id defined in params[:id]
    @location = Location.find(params[:id])
  end

  def update
    # find only the location that has the id defined in params[:id]
    @location = Location.find(params[:id])

    # if the object saves correctly to the database
    if @location.update_attributes(location_params)
      # redirect the user to index
      redirect_to locations_path, notice: 'Location was successfully updated.'
    else
      # redirect the user to the edit method
      render action: 'edit'
    end
  end

  def destroy
    # find only the location that has the id defined in params[:id]
    @location = Location.find(params[:id])

    # delete the location object and any child objects associated with it
    @location.destroy

    # redirect the user to index
    redirect_to locations_path, notice: 'Location was successfully deleted.'
  end

  def destroy_all
    # delete all location objects and any child objects associated with them
    Location.destroy_all

    # redirect the user to index
    redirect_to locations_path, notice: 'All locations were successfully deleted.'
  end

  def show
    # default: render ’show’ template (\app\views\locations\show.html.haml)
  end

  def radio
    dtor = Math::PI/180 #conversion a radianes
    r = 6378.14*1000 #ecuacion de radio multiplicado por mil para convertir de km a metros
    contador=0
    @aux1=[]
    @aux2=[]
    @aux3=[]
    @aux4=[]

    if request.post?
      @latitude= params[:latitude];
      @longitude = params[:longitude];
      @radio=params[:radio]

      @locations = Location.all

      @locations.each do |location|
        rlat1 = @latitude.to_f * dtor
        rlong1 = @longitude.to_f * dtor
        aux1=location.latitude
        aux2=location.longitude
        rlat2 = aux1.to_f * dtor
        rlong2 = aux2.to_f * dtor

        dlon = rlong1 - rlong2
        dlat = rlat1 - rlat2

        a = (Math::sin(dlat/2))**2 + Math::cos(rlat1) * Math::cos(rlat2) * (Math::sin(dlon/2))**2
        c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
        distancia = r * c #distancia en metros de los puntos
        @prueba=distancia
        if distancia<=@radio.to_f
          @aux1[contador]=location.name
          @aux2[contador]=location.latitude
          @aux3[contador]=location.longitude
          @aux4[contador]=location.description
          contador+=1

        end

      end



    end
  end

  def convex_hull
    mi_casa = Location.find_by_name('alfredo_house')
    @puntos=Location.all

    points  = Array.new()


    @puntos.each do |punto|
      points << [punto[:latitude], punto[:longitude], punto[:id]]
    end

    points = calculate_convex_hull(points)

    @convex_locations = Array.new()
    points.each do |point|
      @convex_locations << Location.find_by_id(point)
    end

    perimeter_convex_hull = Array.new()
    i = @convex_locations.size
    until i < 1
      i -= 1
      perimeter_convex_hull << [@convex_locations[i][:name], @convex_locations[i-1][:name], calculate_distance(@convex_locations[i].latitude,@convex_locations[i].longitude, @convex_locations[i-1].latitude, @convex_locations[i-1].longitude)]
    end

    @perimeter =  0
    perimeter_convex_hull.each do |data|
      @perimeter += data[2]
    end

    @longest_distance = [['alfredo_house', 0]]
    @aux_distancia_mas_larga=['alfredo_house']
    distance = 0
    @puntos.each do |punto|

      distance = calculate_distance(mi_casa.latitude , mi_casa.longitude, punto.latitude, punto.longitude)
      if distance > @longest_distance[@longest_distance.size-1][1]
        @longest_distance << [punto[:name], distance]
        @aux_distancia_mas_larga<<punto[:name]
      end

    end

  end

  def calculate_distance(lat_1,long_1,lat_2,lon_2)
    lat1 = lat_1
    long1 = long_1
    lat2 = lat_2
    long2 = lon_2

    dtor = Math::PI/180
    r = 6378.14*1000

    rlat1 = lat1 * dtor
    rlong1 = long1 * dtor
    rlat2 = lat2 * dtor
    rlong2 = long2 * dtor

    dlon = rlong1 - rlong2
    dlat = rlat1 - rlat2

    a = (Math::sin(dlat/2))**2 + Math::cos(rlat1) * Math::cos(rlat2) * (Math::sin(dlon/2))**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
    d = r * c

    return d.round
  end

  def visited

  end

  def poivisited
    uploaded_file = params[:file]
    @file_content = uploaded_file.read
    @objson = JSON.parse(@file_content)
    ruta = @objson.fetch("route")
    @locations = Location.all
    @visitedplaces = Array.new

    ruta.each do |point|
      location = Location.new
      location.latitude = point["latitude"]
      location.longitude = point["longitude"]
      @visitedplaces = @visitedplaces | where?(location, @locations,50)
    end
    @visitedplaces
  end

  def distance(l1,l2)
    lat1 = l1.latitude
    long1 = l1.longitude
    lat2 = l2.latitude
    long2 = l2.longitude

    dtor = Math::PI/180
    r = 6378.14*1000

    rlat1 = lat1 * dtor
    rlong1 = long1 * dtor
    rlat2 = lat2 * dtor
    rlong2 = long2 * dtor

    dlon = rlong1 - rlong2
    dlat = rlat1 - rlat2

    a = power(Math::sin(dlat/2), 2) + Math::cos(rlat1) * Math::cos(rlat2) * power(Math::sin(dlon/2), 2)
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
    d = r * c

    return d.round
  end

  def power(num, pow)
    num ** pow
  end

  def inside?(l1,l2,r)
    distancia = distance(l1,l2)
    if distancia > r
      return false
    else
      return true
    end
  end

  def where?(l1,locations,r)
    lugares = Array.new
    locations.each{|x|
      if inside?(l1,x,r)
        lugares.push(x.name)
      end
    }
    return lugares
  end

  private

  def location_params
    params.require(:location).permit(:latitude, :longitude, :description, :name)
  end

  def calculate_convex_hull(points)
    points.sort!.uniq!
    return points if points.length < 3

    def cross(o, a, b)
      (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])
    end

    lower = Array.new
    points.each{|p|
      while lower.length > 1 and cross(lower[-2], lower[-1], p) <= 0 do lower.pop end
      lower.push(p)
    }

    upper = Array.new
    points.reverse_each{|p|
      while upper.length > 1 and cross(upper[-2], upper[-1], p) <= 0 do upper.pop end
      upper.push(p)
    }

    return lower[0...-1] + upper[0...-1]
  end
end
