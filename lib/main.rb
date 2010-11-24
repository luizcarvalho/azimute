require "vincent"
require "kml_template"

#vic = Vincent.new(-10.15618888888889,-48.29239444444444)
#puts vic.calculate(90.0,3000.0) #-10.1098908234521, -48.227165530714

=begin
angulos = [0,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200,210,220,230,240,250,260,270,280,290,300,310,320,330,340,350,360]
#angulos = [0,45,90,135,180,225,270,315,360]
coordenadas = {1=>"",2=>"",3=>"",4=>""}
#distancias = [2000,4000,6000]
distancias = [35000,1000,4590,6000]
distancias.each_with_index do |dist,numero| 
  angulos.each do |angulo|
    #puts "----- Gerando Coordenadas para ANGULO: #{angulo} e Distancia #{dist} Km (CONTORNO: #{numero+1}) ----"
    ponto2 = vinc.calculate(angulo, dist)
    coordenadas[numero+1]="#{coordenadas[numero+1]}\n #{ponto2[:lon]},#{ponto2[:lat]} "
  end
end
#puts coordenadas
=end
xlsdata = Array.new
data = File.open("data.csv", "r")
data.each_line do  |line|
  xlsdata.push line.split(";")
end
lat1 = xlsdata[0][1].gsub(/\./, ",").to_f
lon1 = xlsdata[1][1].gsub(/\./, ",").to_f
angulos = []
contornos = {1=>[],2=>[],3=>[],4=>[]}
coordenadas = {1=>"",2=>"",3=>"",4=>""}
xlsdata.each_with_index do |cel,i|
  if (i > 2)
    angulos.push cel[0].to_f
    4.times do |c|
      contornos[c+1].push cel[c+1].to_f
    end    
  end
end




vinc = Vincent.new(lat1,lon1)

angulos.each_with_index do |angulo,i|
  
  (1..4).each do |contorno|    
    ponto2 = vinc.calculate(angulo, contornos[contorno][i])
    coordenadas[contorno]="#{coordenadas[contorno]}\n #{ponto2[:lon]},#{ponto2[:lat]} "
    #puts "----- ANGULO: #{angulo} e Distancia #{contornos[contorno][i]} m (CONTORNO: #{contorno}) ----"
    #puts "----- LAT: #{ponto2[:lat]}  / LON #{ponto2[:lon]}  ----"
  end
   
   
end

puts kml_default_template(coordenadas)




