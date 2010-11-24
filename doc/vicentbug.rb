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
def calculate(lat1, lon1, az, dist)
  #LAT1: -10.15618888888889
  #LON1: -48.29239444444444
  a = 6378137 #6378137
  b = 6356752.3142#6356752.3142
  f = 1/298.257223563 # WGS-84 ellipsiod #0.0033528106647474805
  s = dist #3000.271
  alpha1 = torad(az)#1.5707963267948966
  cos_alpha1 = Math.cos(alpha1) #6.123233995736766e-17
  sin_alpha1 = Math.sin(alpha1) #1

  tan_u1 = (1-f) * Math.tan(torad(lat1)) #-0.17853848518576196
  cos_u1 = 1 / Math.sqrt((1 + tan_u1*tan_u1))# 0.9844331872178003
  sin_u1 = tan_u1*cos_u1 # -0.17575921001245767
  sigma1 = Math.atan2(tan_u1, cos_alpha1) # -1.5707963267948963
  sin_alpha = cos_u1 * sin_alpha1; # 0.9844331872178003
  cos_sq_alpha = 1 - sin_alpha*sin_alpha;# 0.030891299904203362
  u_sq = cos_sq_alpha * (a*a - b*b) / (b*b); # 0.00020819181551113186
  an = 1 + u_sq/16384*(4096+u_sq*(-768+u_sq*(320-175*u_sq))); # 1.000052045922312
  bn = u_sq/1024 * (256+u_sq*(-128+u_sq*(74-47*u_sq))); # 0.0000520425365508038

 sigma = (s / (b*an)) # 0.0004719571737211584
 sigma_p = (2*Math::PI) #6.283185307179586
  while true
    cos2_sigma_m = Math.cos(2*sigma1 + sigma); #-0.9999998886282152
    sin_sigma = Math.sin(sigma) #0.000471957156200254
    cos_sigma = Math.cos(sigma) #0.9999998886282152
    delta_sigma = bn*sin_sigma*(cos2_sigma_m+bn/4*(cos_sigma*(-1+2*cos2_sigma_m*cos2_sigma_m)-
          bn/6*cos2_sigma_m*(-3+4*sin_sigma*sin_sigma)*(-3+4*cos2_sigma_m*cos2_sigma_m))); #-2.4561525259749528e-8
    sigma_p = sigma; #1) 0.0004719326121958986 //2)0.0004719326121958986 //3)0.00047193261347412555
    sigma = s / (b*an) + delta_sigma; #1)0.0004719571737211584 //2) 0.00047193261347412555 //3)0.000471932613474059
    break if ((sigma.abs-sigma_p) > 1.0e-012)
  end

  tmp = sin_u1*sin_sigma - cos_u1*cos_sigma*cos_alpha1; #-0.00008294650024440754
  lat2 = Math.atan2(sin_u1*cos_sigma + cos_u1*sin_sigma*cos_alpha1, #-0.17725891562076265
      (1-f)*Math.sqrt(sin_alpha*sin_alpha + tmp*tmp)); #
  lambda = Math.atan2(sin_sigma*sin_alpha1, cos_u1*cos_sigma - sin_u1*sin_sigma*cos_alpha1); #0.00047939526875468406
  cn = f/16*cos_sq_alpha*(4+f*(4-3*cos_sq_alpha)); #0.000025977973469257165
  ln = lambda - (1-cn) * f * sin_alpha *
      (sigma + cn*sin_sigma*(cos2_sigma_m+cn*cos_sigma*(-1+2*cos2_sigma_m*cos2_sigma_m))); #0.0004778376803620165

  rev_az = Math.atan2(sin_alpha, -tmp);  # final bearing #1.5707120686643041

  #[todeg(lat2), todeg(lon1+ln)]
  [todeg(lat2), lon1+todeg(ln)] # lat2: -10.15618774613528  // lon2: -48.26501636206738

end


puts calculate(-10.15618888888889,-48.29239444444444,90,3000)
#puts 10**-12



