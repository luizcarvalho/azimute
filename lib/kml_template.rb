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


