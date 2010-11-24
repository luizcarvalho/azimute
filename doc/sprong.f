      Program SPRONG


c     Program by John Boursy, FCC, January 1983.
c     Written in Fortran for operation on a VAX computer.
c
c     This program computes a terminal set of coordinates when given
c     a starting set of coordinates and a distance and bearing from
c     the starting set of coordinates.
c
c     The name "SPRONG" is derived from "Prong on a
c     Spherical surface".

c     ******************************************************************
c
c     The following statement is the first statement.
c
c     ******************************************************************
c
      data in/5/
      integer out/6/
      character*1 lat1,lat2,lon1,lon2
      double precision alat,alon,blat,blon,dmstdc,x
      character*1 cdist
      double precision degree /57.2957795131d0/ ! radians to degrees
      double precision radian /0.017453292519443d0/ ! degrees to radians
      character*20 buffer
      character*20 buffers(2)
c
c     ******************************************************************
c
c     Following is the statement function section.
c
c     ******************************************************************
c
      dmstdc(x)=dint(x)+sign(dint(mod(x,1.d0)*100d0)/60+mod(x*100d0,1d0)
     2   /36d0,x)
c     The above statement function converts a latitude or longitude in
c     the form D.MMSS to floating point degrees.
c
c     ******************************************************************
c
c     The following statement is the first statement.
c
c     ******************************************************************
c
      write (out,806)
806   format ('0Welcome to SPRONG',/,
     2   ' SPRONG computes the terminal coordinates when given starting'
     3   ,/,' coordinates, and a distance and bearing from them.')
c
20    continue
      write (out,807)
807   format (' Select units for distances:',/,' Enter M for miles',/,
     2   7x,'K for kilometers',/,'$Selection?  ')
      read (in,808) cdist
808   format (a1)
      call upper(cdist)
      if (cdist.ne.'K'.and.cdist.ne.'M') go to 20
c
10    continue
      write (out,801)
801   format (/,'$Lat (D.MMSS), Lon (D.MMSS) for starting point?  ')
      read (in,*,err=10) alat,alon
c
      alat=dmstdc(alat+0.000001d0)
      alon=dmstdc(alon+0.000001d0)
c
      call degint (alat,latd1,latm1,lats1)
      call degint (alon,lond1,lonm1,lons1)
c
      if (alat.ge.0.0) then
         lat1='N'
       else
         lat1='S'
      endif
c
      if (alon.ge.0.0) then
         lon1='W'
       else
         lon1='E'
      endif
c
      alat=alat*radian
      alon=alon*radian
c
30    continue
      if (cdist.eq.'M') then
         write (out,809)
809      format (/,'$Enter distance (miles), azimuth (degrees):  ')
       else
         write (out,810)
810      format (/,'$Enter distance (kilometers), azimuth (degrees):  ')
      endif
c
      read (in,813) buffer
813   format (a20)
      if (buffer.eq.' ') go to 40
c
      nbuffs=2
      call cparse (buffer,buffers,nbuffs)
      if (nbuffs.lt.2) go to 30
      dist=alfnum(buffers(1),1)
      az=alfnum(buffers(2),1)
c
      if (cdist.eq.'K') then
         distkm=dist
         dist=dist/1.609344
      endif
c
      call dsprong (alat,alon,dist,az,blat,blon)
c
      blat=blat*degree
      blon=blon*degree
c
      call degint (blat,latd2,latm2,lats2)
      call degint (blon,lond2,lonm2,lons2)
c
      if (blat.ge.0.0) then
         lat2='N'
       else
         lat2='S'
      endif
c
      if (blon.ge.0.0) then
         lon2='W'
       else
         lon2='E'
      endif
c
      write (out,802) lat1,latd1,latm1,lats1,lon1,lond1,lonm1,lons1
802   format ('0Starting at ',a1,' Lat',3i3.2,1x,a1,' Long',i4,
     2   2i3.2)
      if (cdist.eq.'K') then
         write (out,811) distkm,az
811      format (' and going',f9.2,' kilometers at',f7.2,
     2      ' degrees true,')
       else
         write (6,812) dist,az
812      format (' and going',f9.2,' miles at',f7.2,' degrees true,')
      endif
      write (out,803) lat2,latd2,latm2,lats2,lon2,lond2,lonm2,lons2
803   format (' we arrive at ',a1,' Lat',3i3.2,1x,a1,' Long',i4,2i3.2)
      go to 30   ! go get next distance and azimuth
c
40    continue
      write (out,805)
805   format (/,'$More?  ')
      call yesno (*50,*40,*40,in)
      go to 10
c
50    continue
      stop
      end



C =====================================================================

      subroutine degint (x,ideg,min,isec)
c
c     Subroutine by John Boursy, FCC, October 1982.
c
c     This subroutine takes a latitude or longitude in double precision
c     floating point degrees, and converts it to degrees, minutes, and
c     seconds.
c
c     Only the absolute value of 'x', the input argument, is used.  The
c     calling routine must take account of any conventions used
c     that involved negative numbers.
c
      double precision x
      double precision xabs
c
      xabs=abs(x)
      ideg=xabs
      xlatm1=(xabs-ideg)*60.
      min=xlatm1
      xlats1=(xabs-ideg-float(min)/60.)*3600.
      isec=xlats1+0.5

C NOTE: If you modify this subroutine to use decimal seconds
C for (output) isec in place of integer seconds,
C change the previous line to isec=xlats (delete the 0.5).
C    (Dale Bickel, FCC Oct 2000)

c
      if (isec.eq.60) then
         isec=0
         min=min+1
      endif
c
      if (min.eq.60) then
         min=0
         ideg=ideg+1
      endif
c
      return
      end

C ============================================================

      SUBROUTINE dSPRONG (ALAT,ALONG,DIST,AZ,BLAT,BLONG)
c
c     Subroutine by John Boursy, FCC.
C
C     GIVEN A STARTING SET OF COORDINATES, AND A DISTANCE AND AZIMUTH,
C        THE COORDINATES OF A TERMINAL POINT (LOCATED AT THAT DISTANCE
C        AND AZIMUTH FROM THE STARTING POINT) ARE FOUND.
C
C     COORDINATES ARE GIVEN IN RADIANS, BUT THE AZIMUTH IS IN DEGREES.
C     THE DISTANCE IS IN MILES.
c
c     The coordinates are double precision.
C
c     ******************************************************************
c
c     The following statement is the first statement.
c
c     ******************************************************************
c
      double precision alat,along,blat,blong
      double precision aa,bb,cc,c
      double precision cosaa,sinbb,cosbb,coscc,cosc
      double precision radian /0.017453292519943d0/
      double precision pihalf /1.570796326794896d0/    ! pi/2
      double precision pi     /3.141592653589793d0/
      double precision twopi  /6.283185307179586d0/     ! 2*pi
C
      DOUBLE PRECISION DMC / 69.08404915D0 /
C
*************************************************************************
C     Note: The value for DMC is determined as follows:
C
C           111.18 km/degree
C           ----------------   =  69.08404915 miles/degree
C           1.609344 km/mile
C
C           111.18 km/degree comes from our international agreements, and
C           is the value which is used in the skywave curves formula
C           adopted in MM Docket 88-508.
C
C           If a spherical earth of equal area is assumed, (radius of
C           3958.7 miles) then the value would be:
C
C           (3958.7 miles)(2pi)
C           --------------------   = 69.09234911 miles/degree
C              360 degrees
C
C            Which is the more common number. To be consistant with the
C            FCC's international agreements, we are using the 69.08 value.
C            This is in agreement with Tom Lucy, Larry Olson,
C            Gary Kalagian and Bill Ball, all of Mass Media Bureau, FCC
C            January 1992.
C
C***********************************************************************
C
      DATA TOL/0.05/           ! TOL IS 0.05 MILES
c
c     ******************************************************************
c
c     The following statement is the first executable statement.
c
c     ******************************************************************
C
      IF (DIST.LT.TOL) GO TO 20  ! SMALL DIST, THEN POINT1=POINT2
C
      ISIG=0  ! MEANS AZIMUTH < 180 DEGREES
      A=AMOD(AZ,360.0)
      IF (A.LT.0.0) A=360.0+A
      IF (A.GT.180.0) THEN
         A=360.0-A
         ISIG=1  ! MEANS AZIMUTH > 180 DEGREES
      ENDIF
C
      A=A*RADIAN
      BB=PIHALF-ALAT
      CC=DIST*RADIAN/DMC
      SINBB=SIN(BB)
      COSBB=COS(BB)
      COSCC=COS(CC)
      COSAA=COSBB*COSCC+SINBB*SIN(CC)*COS(A)
      IF (COSAA.LE.-1.0d0) COSAA=-1.0d0
      IF (COSAA.GE.1.0d0) COSAA=1.0d0
      AA=ACOS(COSAA)
      COSC=(COSCC-COSAA*COSBB)/(SIN(AA)*SINBB)
      IF (COSC.LE.-1.0d0) COSC=-1.0d0
      IF (COSC.GE.1.0d0) COSC=1.0d0
      C=ACOS(COSC)
      BLAT=PIHALF-AA
      BLONG=ALONG-C
      IF (ISIG.EQ.1) BLONG=ALONG+C
      IF (BLONG.GT.PI) BLONG=BLONG-TWOPI
      IF (BLONG.LT.-PI) BLONG=BLONG+TWOPI
      RETURN
C
20    CONTINUE
C     WE ARE HERE WHEN THE DISTANCE IS VERY SMALL
      BLAT=ALAT
      BLONG=ALONG
      RETURN
      END

C ==============================================================

      SUBROUTINE CPARSE (BUFF,BUFFS,N)
c
c     Subroutine by John Boursy.
C
C     THIS SUBROUTINE TAKES A CHARACTER STRING, BUFF, AND BREAKS
C     IT UP INTO MANY SMALLER CHARACTER STRINGS, BUFFS, USING
C     COMMAS AND SPACES FOR DELIMETERS.  ON INPUT, N IS THE MAXIMUM
C     NUMBER OF SMALLER STRINGS; ON OUTPUT, N IS THE NUMBER OF
C     SMALLER STRINGS THAT WERE ACTUALLY FOUND. EXCEPT THAT ON OUTPUT
C     N CANNOT BE GREATER THAN THE INPUT VALUE. IF THERE WERE MORE THAN
C     THE MAXIMUM NUMBER OF SMALLER STRINGS, N IS SET NEGATIVE OF THE
C     MAXIMUM VALUE.
c
c     Note that, if N on output is smaller than N on input, this
c     routine will space-fill buffs(Noutput+1) through buffs(Ninput).
C
      CHARACTER BUFF*(*),BUFFS(N)*(*)
C
      NTEMP    = 0
      IPOINT   = 1
      BUFFS(1) = ' '
      maxchar  = len ( buff )
c
      do 5 loop=1,n,1
      buffs(loop)=' '   ! initialize as spaces
5     continue
C
10    CONTINUE
      DO 20 LOOP = IPOINT, MAXCHAR, 1
         IF ( BUFF(LOOP:LOOP) .NE. ' ' ) GO TO 30
20    CONTINUE
      N = NTEMP
      RETURN
C
30    CONTINUE
C
C     WE ARE NOW AT THE STARTING POINT OF A STRING
C
      IPOINT = LOOP
      DO 40 LOOP = IPOINT, MAXCHAR, 1
         IF ( BUFF(LOOP:LOOP) .EQ. ' ' .OR.
     &        BUFF(LOOP:LOOP) .EQ. ','        ) GO TO 50
40    CONTINUE
      LOOP = MAXCHAR + 1
50    CONTINUE
      JPOINT = LOOP - 1
C
      NTEMP = NTEMP + 1
C
C     HERE WE CHECK TO SEE IF WE HAVE MORE SMALLER STRINGS THAN
C     WERE SPECIFIED ON INPUT.
C
      IF ( NTEMP .GT. N ) THEN
         N = - N
         RETURN
      END IF
C
      BUFFS(NTEMP) = ' '
      BUFFS(NTEMP)(1:JPOINT-IPOINT+1) = BUFF(IPOINT:JPOINT)
      IPOINT = JPOINT + 2
      IF ( IPOINT .GT. MAXCHAR ) THEN
         N = NTEMP
         RETURN
      ELSE
         GO TO 10
      ENDIF
C
      END

C ==========================================================


      SUBROUTINE YESNO (*,*,*,IN)
c
c     Subroutine by John Boursy, FCC.
C
C     THIS SUBROUTINE READS A 84-CHARACTER (OR LESS) INPUT FROM
C     FILE CODE 'IN', AND DETERMINES WHETHER IT IS A 'YES' OR
C     'NO' ANSWER.  IN ADDITION, OTHER RESPONSES ARE ACCEPTABLE.
C
C     THE ACCEPTABLE RESPONSES ARE --
C
C        YES   MEANS 'YES'
C        Y     MEANS 'YES'
C        NO    MEANS 'NO'
C        N     MEANS 'NO'
C     (BLANK)  MEANS 'NO'
C        STOP  STOPS THE RUN
c        EXIT  same as STOP
c        QUIT  same as STOP
c        DONE  same as STOP
C     <Ctrl>Z  ACTS AS IF AN END-OF-FILE HAS BEEN READ ON UNIT IN
c
c     The acceptable responses may be either lower or upper case.
C
C     THERE IS THE ONE NORMAL RETURN FROM THIS SUBROUTINE.  THERE ARE
C     ALSO THREE ABNORMAL RETURNS.  THEY ARE USED AS FOLLOWS --
C
C        NORMAL RETURN -- WHEN THE ANSWER IS 'YES'
C        1ST ABNORMAL RETURN -- WHEN THE ANSWER IS 'NO'
C        2ND ABNORMAL RETURN -- WHEN THE ANSWER IS NOT YES/NO AND THE
C                  SUBSYSTEM HAS BEEN CALLED, AND WE HAVE RETURNED
C                  FROM IT.
C        3RD ABNORMAL RETURN -- WHEN THE ANSWER IS <Ctrl>Z
C
C     ******************************************************************
C
C     THE NEXT STATEMENT IS THE FIRST STATEMENT
C
C     ******************************************************************
C
      CHARACTER*84 CBUFF
C
C     ******************************************************************
C
C     THE FOLLOWING STATEMENT IS THE FIRST EXECUTABLE STATEMENT
C
C     ******************************************************************
C
      READ ( IN, 800, END=805 ) CBUFF
800   FORMAT (A84)
      call upper (cbuff)  ! puts cbuff all in upper case
c
      if (cbuff.eq.'Y'.or.cbuff.eq.'YES') then
         return
       else if (cbuff.eq.'N'.or.cbuff.eq.' '.or.cbuff.eq.'NO') then
         return 1
       else if (cbuff.eq.'STOP'.or.cbuff.eq.'EXIT'.or.cbuff.eq.'QUIT'
     3   .or.cbuff.eq.'DONE') then
         stop
       else
         return 2
      endif
C
805   RETURN 3
c
      end


C ==================================================================

      subroutine upper (string)
c
c     Subroutine by John Boursy, FCC, December 1982.
c
c     This subroutine takes a character string and converts all lower
c     case letters to upper case letters.  That is, letters in the range
c     from a to z, inclusive, are converted to letters in the range
c     from A to Z.  Characters outside of this range are not touched.
c
c     string, the input argument, must be a character variable; it can
c     be any length.
c
c     ******************************************************************
c
      character string*(*)
c
      do 100 i=1,len(string),1
      if (string(i:i).ge.'a'.and.string(i:i).le.'z')
     2   string(i:i)=char(ichar(string(i:i))-32)
100   continue
c
      return
      end




