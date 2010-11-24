
#     Subroutine by John Boursy, FCC.
#
#     GIVEN A STARTING SET OF COORDINATES, AND A DISTANCE AND AZIMUTH,
#        THE COORDINATES OF A TERMINAL POINT (LOCATED AT THAT DISTANCE
#        AND AZIMUTH FROM THE STARTING POINT) ARE FOUND.
#
#     COORDINATES ARE GIVEN IN RADIANS, BUT THE AZIMUTH IS IN DEGREES.
#     THE DISTANCE IS IN MILES.


alat=convert_coordinates(alat+0.000001)
alon=convert_coordinates(alon+0.000001)

def convert_coordinates(x)
  #dmstdc = dint(x)+sign(dint(mod(x,1.d0)*100d0)/60+mod(x*100d0,1d0) 2   /36d0,x)
end

def degint (x,ideg,min,isec)

      xabs=x.abs
      ideg=xabs
      xlatm1=(xabs-ideg)*60.0
      min=xlatm1
      xlats1=(xabs-ideg-min/60.0)*3600.0 #min deve ser convertido para float
      isec=xlats1+0.5

      if (isec == 60)
         isec=0
         min=min+1
      end

      if (min == 60)
         min=0
         ideg=ideg+1
      end

      [ideg,min,isec]
end



def calculate()
  alat = 0.0;
  along = 0.0;
  dist = 0.0;
  az = 0.0;
  blat = 0.0;
  blong = 0.0;

  alat = along = blat = blong  = 0.0

  radian  = 0.017453292519943;
  pihalf = 1.570796326794896; # pi/2
  pi = 3.141592653589793;
  twopi = 6.283185307179586; # 2*pi
  dmc = 69.08404915; #
  tol = 0.05; #tol é 0,05 Miles

  unless dist < tol # SMALL DIST, THEN POINT1=POINT2
    isig = 0  # MEANS AZIMUTH < 180 DEGREES
    a = az.divmod(360.0)
    a = 360.0 + a if (a  < 0.0)

    if (a > 180.0)
      a=360.0-a
      isig =1  # MEANS AZIMUTH > 180 DEGREES
    end


    a = a*radian
    bb = pihalf-alat
    cc = dist*radian/dmc
    sinbb = Math.sin(bb)
    cosbb = Math.cos(bb)
    coscc = Math.cos(cc)
    cosaa = cosbb*coscc+sinbb*Math.sin(cc)*Math.cos(a)

    cosaa = -1.0 if cosaa < -1.0
    cosaa = 1.0 if cosaa > 1.0
    aa = Math.acos(cosaa)
    cosc = (coscc-cosaa*cosbb)/(Math.sin(aa)*sinbb)
    cosc = -1.0 if cosc < -1.0
    cosc =1.0 if cosc > 1.0
    c = Math.acos(cosc)
    blat = pihalf-aa
    blong = along-c

    blong=along+c if isig == 1
    blong = blong-twopi if blong > pi
    blong = blong+twopi if blong < (-pi)

  else
    blong = along
    blat = alat

  end

  [blat,blong]
end



