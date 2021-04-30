!$ELIPSE
      SUBROUTINE ELIPSE(Z,XY2,H2,WORK,HEIGHT,ZT,RT,NM)
!********1*********2*********3*********4*********5*********6*********7**
! ELIPSE           83/05/13            8305.0    PGMR - TOM MARTIN
!
! FUNCTION:  COMPUTE THE S/C HEIGHT ABOVE THE EARTH ELLIPSOID
!            FOR A VECTOR OF S/C POSITIONS
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   Z        I    A    Z COMPONENTS OF S/C POSITIONS
!   XY2      I    A    SUM OF SQUARES OF S/C X AND Y POSITIONS
!   H2            A    ARRAY OF LENGTH NM USED FOR TEMPORARY STORAGE
!   WORK          A    ARRAY OF LENGTH NM USED FOR TEMPORARY STORAGE
!   HEIGHT   O    A    S/C HEIGHTS ABOVE EARTH ELLIPSOID
!   ZT       O    A    Z COMPONENT OF S/C POSITIONS W.R.T. SURFACE
!                      CENTER OF CURVATURE
!   RT       O    A    DISTANCE FROM S/C TO SURFACE CENTER OF CURV.
!   NM       I    S    NUMBER OF MEASUREMENTS
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      COMMON/CGRAV/GM,AE,AESQ,FE,FFSQ32,FSQ32,XK2,XK3,XLAM,SIGXK2,      &
     &      SIGXK3,SIGLAM,RATIOM(2),AU,RPRESS
      COMMON/CCBODY/ESQ,ESQP1,OMESQ
      DIMENSION Z(NM),XY2(NM),H2(NM),RT(NM),HEIGHT(NM),ZT(NM),WORK(NM)
      DATA ZERO/0.0D0/,ONE/1.0D0/,ERRMAX/1.0D-9/
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
!
! INITIAL ESTIMATE OF ZT
      DO 800 N=1,NM
      ZT(N)=Z(N)*ESQP1
  800 END DO
! INITIAL ESTIMATE OF RADIAL DISTANCE FROM SURFACE CENTER OF CURVATURE
      DO 1800 N=1,NM
      HEIGHT(N)=XY2(N)+ZT(N)**2
 1800 END DO
      DO 2800 N=1,NM
      HEIGHT(N)=SQRT(HEIGHT(N))
 2800 END DO
! INTERATIVELY IMPROVE ESTIMATES UNTIL ERROR LEVEL IS ACCEPTABLE
      DO 14000 I=1,5
! UNIT ZT
      DO 3800 N=1,NM
      RT(N)=ZT(N)/HEIGHT(N)
 3800 END DO
! UNIT ZT*ESQ
      DO 4800 N=1,NM
      ZT(N)=RT(N)*ESQ
 4800 END DO
! 1.0-ESQ*UNIT ZT SQUARED
      DO 5800 N=1,NM
      H2(N)=ONE-ZT(N)*RT(N)
 5800 END DO
! DISTANCE FROM CENTER OF CURVATURE TO EARTH SURFACE AT SUBSATELLITE POI
      DO 6800 N=1,NM
      H2(N)=SQRT(H2(N))
 6800 END DO
      DO 7800 N=1,NM
      H2(N)=AE/H2(N)
 7800 END DO
! IMPROVED ESTIMATE OF ZT
      DO 8800 N=1,NM
      ZT(N)=Z(N)+H2(N)*ZT(N)
 8800 END DO
! IMPROVED ESTIMATE OF DISTANCE FROM CENTER OF CURVATURE TO S/C
      DO 9800 N=1,NM
      RT(N)=XY2(N)+ZT(N)**2
 9800 END DO
      DO 10800 N=1,NM
      RT(N)=SQRT(RT(N))
10800 END DO
! COMPARE PREVIOUS BEST ESTIMATE AND CURRENT BEST ESTIMATE
!         OF DISTANCE TO S/C FROM CENTER OF CURVATURE
!....COMPUTE ERROR
      DO 11800 N=1,NM
      HEIGHT(N)=ABS((HEIGHT(N)-RT(N))/RT(N))
11800 END DO
!....DETERMINE MAXIMUM ERROR VALUE
      DIFMAX=ZERO
      DO 12800 N=1,NM
      DIFMAX=MAX(HEIGHT(N),DIFMAX)
12800 END DO
! EXIT LOOP IF ERROR LEVEL ACCEPTABLE
      IF(DIFMAX.LT.ERRMAX) GO TO 15000
! SAVE CURRENT BEST ESTIMATE
      DO 13800 N=1,NM
      HEIGHT(N)=RT(N)
13800 END DO
14000 END DO
! ELLIPSOID HEIGHT IS DIFFERENCE BETWEEN DISTANCE TO S/C AND
!           DISTANCE TO SURFACE
15000 CONTINUE
      DO 15800 N=1,NM
      HEIGHT(N)=RT(N)-H2(N)
15800 END DO
      RETURN
      END