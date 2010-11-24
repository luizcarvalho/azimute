
#vic = Vincent.new(-10.15618888888889,-48.29239444444444)
#puts vic.calculate(90.0,3000.0) #-10.1098908234521, -48.227165530714

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

  end


end
