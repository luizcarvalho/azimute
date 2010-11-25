require "vincent"
require "kml_template"

xlsdata = Array.new
data = File.open("data.csv", "r")
data.each_line do  |line|
  xlsdata.push line.split(";")
end
lat1 = xlsdata[0][1].gsub(/\,/, ".").to_f
lon1 = xlsdata[1][1].gsub(/\,/, ".").to_f
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
   #C: -9.740848496159662,-48.04187046994603

   
end

output = File.new("contornos.kml","w+")
output.puts kml_default_template({:lat=>lat1,:lon=>lon1},coordenadas)




