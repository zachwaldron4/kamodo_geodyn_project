!$NUTMAR
      SUBROUTINE NUTMAR(T,DPSIM,DEPSM,EPSMA)
!********1*********2*********3*********4*********5*********6*********7
! NUTMR            05/30/92            0000.0    PGMR - S.LUO
!
! FUNCTION:  CALCULATE MARS NUTATION IN MARS ORBIT PLANE REFRENCE
!            FRAME
!
! I/O PARAMETERS
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   T        I         INTERVAL TIME IN DAY FROM J2000.0(JD2451545)
!   DEPSM    O         MARS NUTATION IN OBLIQUITY (0."001)
!   DPSIM    O         MARS NUTATION IN LONGITUDE (0."001)
!   EPSMA    O         MARS MEAN OBLIQUITY (ARC DEGREE)
!
! REFERENCES:
!
! 1. R.D.REASENBERG AND R.W.KING,   THE ROTATION OF MARS
!                  J.G.R. VO.84, NO.B11, P6231 (OCT., 1979)
!
! 2. J.L.HILTON,   THE MOTION OF MAR'S POLE I. RIGID BODY PRECESSION
!                  AND NUTATION
!          THE ASTRONOMICAL JOURNAL  VO.102, NO.4,P1510 (OCT.,1990)
!
! 3. L.BASS AND R.CESARONE, MARS OBSERVER:PLANETARY CONSTANT AND
!                           MODELS
!          JPL D-3444 (DRAFT)  (NOVEMBER, 1990)
!
! 4. C.A. MURRAY, VECTORIAL ASTROMETRY
!          ADAM HILGER LTD, BRISTOL (1983)
!
! 5. P.K.SELDELMANN, 1980 IAU THEORY OF NUTATION: THE FINAL REPORT
!                    OF THE IAU WORKING GROUP ON NUTATION
!          CELESTIAL MECHANICS VO.27, P79-106(1982)
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
!
      IMPLICIT DOUBLE PRECISION (A-H,O-Z), LOGICAL (L)
      SAVE
      DIMENSION AMPLDE(6),AMPLDL(6),AMPL(3)
      COMMON/CONSTR/PI,TWOPI,DEGRAD,SECRAD,SECDAY
!
!**********************************************************************
! START OF EXECUTABLE CODE ********************************************
!**********************************************************************
!
! GET THE AMPLITUDES OF MARS NUTATION TERMS IN LONGITUDE AND LATITUDE
! FROM SUN
!
      DATA AMPLDE/-49.3D0, 515.8D0,113.0D0,19.3D0,3.0D0,0.0D0/
      DATA AMPLDL/-104.7D0,1096.2D0,240.1D0,40.9D0,6.3D0,0.9D0/
      DATA AMPL/-635.7D0,-44.5D0,-4.1D0/
!
!
      T1=T/365.25
!
! GET THE MEAN ANOMLY,SL, PHASE ANGLE, 2*SLMD AND MEAN OBLIQUITY
!
      CALL ARGMN(T,SL,SLMD,EPSMM)
      EPSMA=EPSMM/DEGRAD
      SLMD2=SLMD*2.D0
!
      SL0=SL/DEGRAD
      SLMD0=SLMD/DEGRAD
!CC   WRITE(6,5)SL0,SLMD0,DEGRAD
    5 FORMAT(1X,'SL0,SLMD20,DEGRAD (HNUT)=', 2F15.4,F15.10)
!
! INITIALIZE DEPSM AND DPSIM TO ZERO
!
      DEPSM=0.D0
      DPSIM=0.D0
!.. TEST EACH TERM OF MARS NUTATION
      S1=AMPL(1)*SIN(SL)
      S2=AMPL(2)*SIN(2.D0*SL)
      S3=AMPL(3)*SIN(3.D0*SL)
      S4=AMPLDL(1)*SIN(SL+SLMD2)
      S5=AMPLDL(2)*SIN(2.D0*SL+SLMD2)
      S6=AMPLDL(3)*SIN(3.D0*SL+SLMD2)
      S7=AMPLDL(4)*SIN(4.D0*SL+SLMD2)
      S8=AMPLDL(5)*SIN(5.D0*SL+SLMD2)
      S9=AMPLDL(6)*SIN(6.D0*SL+SLMD2)
      E1=AMPLDE(1)*COS(SL+SLMD2)
      E2=AMPLDE(2)*COS(2.D0*SL+SLMD2)
      E3=AMPLDE(3)*COS(3.D0*SL+SLMD2)
      E4=AMPLDE(4)*COS(4.D0*SL+SLMD2)
      E5=AMPLDE(5)*COS(5.D0*SL+SLMD2)
      E6=AMPLDE(6)*COS(6.D0*SL+SLMD2)
!
! CALCULATE MARS NUTATION FROM SUN
!
      DO 20 J =1,3
      DPSIM=DPSIM + AMPL(J) * SIN(J*SL)
   20 END DO
!
      DO 10 I = 1,6
      DEPSM = AMPLDE(I)*COS(I*SL+SLMD2) + DEPSM
      DPSIM = AMPLDL(I)*SIN(I*SL+SLMD2) + DPSIM
   10 END DO
!
!.. ADD THE TERMS FROM MARS SATELLITES
!
      A1=-2.776*T1+2.65
      A2=-0.116*T1+0.16
      DEPSM = DEPSM + 4.D0*SIN(A1) + 2.8D0*SIN(A2)
      DPSIM = DPSIM + 230.D0*COS(A1) + 60D0*COS(A2)
!
      DI=E1+E2+E3+E4+E5+E6
      DPSI=S1+S2+S3+S4+S5+S6+S7+S8+S9
!
!C    WRITE(6,1000)T,S1,S2,S3,S4,S5,S6,S7,S8,S9,E1,E2,E3,E4,E5,E6,
!C   * DPSI,DI,DEPSM,DPSIM
 1000 FORMAT(1X,F10.1, 9F7.1/10F7.1)
      RETURN
      END
