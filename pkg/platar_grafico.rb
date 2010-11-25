#-------------------------------------- ALGORITMO DE CAUCULO-------------------

class Vincent
  def initialize(lat1,lon1)
    #Origem e Destino
    @lat1 = lat1
    @lon1=lon1

    #---- Dados do Elipsóide de Revolução --------------------------------------
    #http://pt.wikipedia.org/wiki/Figura_da_Terra
    @a = 6378137 # Maior semi-eixo da Elipsóide Terrestre - WGS66 (1966)[EUA/DoD]
    @b = 6356752.3142 # Maior semi-eixo da Elipsóide Terrestre - WGS66 (1966)[EUA/DoD]
    @f = 1/298.257223563 #	Achatamento inverso - WGS66 (1966)[EUA/DoD]
  end

  #------------ ADDONS ------------------------
  def todeg(num)
    num*57.29578
  end

  def torad(angle)
    angle/57.29578
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  #
  #{} Calculate destination point given start point lat/long (numeric degrees),
  # bearing (numeric degrees) & distance (in m).
  #
  # from: Vincenty direct formula - T Vincenty, "Direct and Inverse Solutions of Geodesics on the
  #       Ellipsoid with application of nested equations", Survey Review, vol XXII no 176, 1975
  #       http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf
  #
  def calculate(az, dist)
    s = dist
    alpha1 = torad(az)
    cos_alpha1 = Math.cos(alpha1)
    sin_alpha1 = Math.sin(alpha1)

    tan_u1 = (1-@f) * Math.tan(torad(@lat1))
    cos_u1 = 1 / Math.sqrt((1 + tan_u1*tan_u1))
    sin_u1 = tan_u1*cos_u1
    sigma1 = Math.atan2(tan_u1, cos_alpha1)
    sin_alpha = cos_u1 * sin_alpha1;
    cos_sq_alpha = 1 - sin_alpha*sin_alpha;
    u_sq = cos_sq_alpha * (@a*@a - @b*@b) / (@b*@b)
    an = 1 + u_sq/16384*(4096+u_sq*(-768+u_sq*(320-175*u_sq)));
    bn = u_sq/1024 * (256+u_sq*(-128+u_sq*(74-47*u_sq)));

    sigma = (s / (@b*an))
    sigma_p = (2*Math::PI)
    while true
      cos2_sigma_m = Math.cos(2*sigma1 + sigma);
      sin_sigma = Math.sin(sigma)
      cos_sigma = Math.cos(sigma)
      delta_sigma = bn*sin_sigma*(cos2_sigma_m+bn/4*(cos_sigma*(-1+2*cos2_sigma_m*cos2_sigma_m)-
            bn/6*cos2_sigma_m*(-3+4*sin_sigma*sin_sigma)*(-3+4*cos2_sigma_m*cos2_sigma_m)));
      sigma_p = sigma;
      sigma = s / (@b*an) + delta_sigma;
      break if ((sigma.abs-sigma_p) > 1.0e-012) or sigma.abs==sigma_p
    end

    tmp = sin_u1*sin_sigma - cos_u1*cos_sigma*cos_alpha1;
    lat2 = Math.atan2(sin_u1*cos_sigma + cos_u1*sin_sigma*cos_alpha1,
      (1-@f)*Math.sqrt(sin_alpha*sin_alpha + tmp*tmp));
    lambda = Math.atan2(sin_sigma*sin_alpha1, cos_u1*cos_sigma - sin_u1*sin_sigma*cos_alpha1);
    cn = @f/16*cos_sq_alpha*(4+@f*(4-3*cos_sq_alpha));
    ln = lambda - (1-cn) * @f * sin_alpha *
    (sigma + cn*sin_sigma*(cos2_sigma_m+cn*cos_sigma*(-1+2*cos2_sigma_m*cos2_sigma_m)));

    rev_az = Math.atan2(sin_alpha, -tmp);

    {:lat=>todeg(lat2),:lon=> @lon1+todeg(ln),:rev_az=>rev_az}
#C: -9.740848496159662,-48.04187046994603

  end


end


#------------------------ TEMPLATE --------------------------------------------

  def desenhar_poligonos(numero,coordenadas)
    "	<Placemark>
    		<name>Contorno #{numero}</name>
    		<styleUrl>#contorno#{numero}</styleUrl>
    		<Polygon>
    			<tessellate>1</tessellate>
    			<outerBoundaryIs>
    				<LinearRing>
    					<coordinates>
                  #{coordenadas}
              </coordinates>
    				</LinearRing>
    			</outerBoundaryIs>
    		</Polygon>
    	</Placemark>"
  end


  def kml_inicio
    "<?xml version='1.0' encoding='UTF-8'?>
        <kml xmlns='http://www.opengis.net/kml/2.2'
             xmlns:gx='http://www.google.com/kml/ext/2.2'
             xmlns:kml='http://www.opengis.net/kml/2.2'
             xmlns:atom='http://www.w3.org/2005/Atom'>
        <Document>
          <name>Contornos de Propagação para Radiodifusão</name>
          <open>1</open>"

  end

  def kml_estilos
    template = ""
    cor={1=>"00ffff",2=>"FF6600",3=>"0000ff",4=>"33CCFF"}
    tipos = ["normal","highlight"]
    (1..4).each do |numero|
      tipos.each do |tipo|
        template+="<Style id='contorno#{numero}_#{tipo}'>
            <LineStyle>
              <color>ff#{cor[numero]}</color>
              <width>2</width>
            </LineStyle>
            <PolyStyle>
              <color>00#{cor[numero]}</color>
            </PolyStyle>
          </Style>"
      end

      template+="<StyleMap id='contorno#{numero}'>
            <Pair>
              <key>normal</key>
              <styleUrl>#contorno#{numero}_normal</styleUrl>
            </Pair>
            <Pair>
              <key>highlight</key>
              <styleUrl>#contorno#{numero}_highlight</styleUrl>
            </Pair>
          </StyleMap>"
    end
    template
  end

  def kml_fim
    "\n  </Document>\n</kml>"
  end

  def kml_icon(coordenadas,nome)
"

	<Style id='icon_normal'>
		<IconStyle>
			<scale>1.2</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/shapes/triangle.png</href>
			</Icon>
		</IconStyle>
		<ListStyle>
		</ListStyle>
	</Style>
	<Style id='icon_highlight'>
		<IconStyle>
			<scale>1.4</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/shapes/triangle.png</href>
			</Icon>
		</IconStyle>
		<ListStyle>
		</ListStyle>
	</Style>
	<StyleMap id='style_icon'>
		<Pair>
			<key>normal</key>
			<styleUrl>#icon_normal</styleUrl>
		</Pair>
		<Pair>
			<key>highlight</key>
			<styleUrl>#icon_highlight</styleUrl>
		</Pair>
	</StyleMap>
	<Placemark>
		<name>#{nome} (#{coordenadas[:lat]},#{coordenadas[:lon]})</name>
		<LookAt>
			<longitude>#{coordenadas[:lon]}</longitude>
			<latitude>#{coordenadas[:lat]}</latitude>
			<altitude>0</altitude>
			<heading>0.03</heading>
			<tilt>0</tilt>
			<range>2000.0</range>
			<altitudeMode>relativeToGround</altitudeMode>
			<gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>
		</LookAt>
		<styleUrl>#style_icon</styleUrl>
		<Point>
			<coordinates>#{coordenadas[:lon]},#{coordenadas[:lat]},0</coordinates>
		</Point>
	</Placemark>


"



  end

def kml_default_template(origem,coordenadas)
  default_template = kml_inicio
  default_template+= kml_estilos
  default_template+= kml_icon(origem, "Antena")
  (1..4).each do |numero|
    default_template+= desenhar_poligonos(numero, coordenadas[numero])
  end
  default_template+=kml_fim
end



#------------------------ EXECUTOR --------------------------------------------

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
puts "Concluido!"




