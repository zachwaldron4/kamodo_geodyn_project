!$LUNFRC
      SUBROUTINE LUNFRC(MJDSEC,FSEC,XTEMP,XDD,YDD,ZDD,AA,C20M,ACCTD1,   &
     & ACCTD2,ACCTD3,II)
!********1*********2*********3*********4*********5*********6*********7**
!  ROUTINE NAME:    LUNFRC   DATE:  05/08/91     PGMR: SBL
!
!  FUNCTION         COMPUTES THE PERTURBATIONS ON A LUNAR ORBITER DUE
!                   TO THE DIRECT AND INDIRECT EARTH OBLATION.  ALSO
!                   COMPUTES THE MOON'S INDIRECT OBLATION PERTURBATION.
!                   THIS ROUTINE IS ONLY EXECUTED FOR LUNAR ORBITERS.
!
! I/O PARAMETERS:
!  NAME   I/O   DESCRIPTION OF I/O PARAMETERS IN ARGUMENT LIST ORDER
!  ----   ---   ------------------------------------------------------
!  MJDSEC I/O   INTEGER SECONDS SINCE GEODYN REFERENCE TIME
!  FSEC   I/O   FRACTIONAL REMAINING SECONDS (COORDINATE ET)
!  XTEMP  I/O   TRUE OF DATE IAU S/C POS. AND VEL. VECTOR
!  XDD -  I/O   TOTAL OF TRUE OF REFERENCE MOON EQUATOR AND IAU VECTOR
!  ZDD          OF REFERENCE DATE ACCELERATIONS
!  AA     I/O   REAL DYNAMIC ARRAY
!  C20M   I/O   MOON'S J2 FROM INPUT GRAVITY FIELD
!  ACCTD1  O    TRUE OF DATE MOON EQUATOR AND IAU VECTOR OF DATE
! -ACCTD3       LUNAR INDIRECT J2 ACCELERATION
!  II     I/O   INTEGER DYNAMIC ARRAY
!
! COMMENT: THE EARTH'S J2 CONSTANT IS HARD CODED IN THIS ROUTINE.
!          THIS ROUTINE ONLY CONSIDERS THE CONTRIBUTION FROM THE EARTH'S
!          SECOND DEGREE ZONAL HARMONIC.
!          THESE ACCELERATIONS ARE TOO SMALL AND DO NOT CHANGE ENOUGH
!          WITH CHANGES IN THE S/C POSITION AND VELOCITY TO BE ADDED TO
!          THE VMATRX.
!
!***********************************************************************
!
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      COMMON/CBDTRU/BDTRUE(7,999)
      COMMON/CBDSTA/BDSTAT(7,999),XBDSTA
      COMMON/CRM5OE/RM5OE(9)
      COMMON/CORA03/KRFMT ,KROTMT,KSRTCH,KCFSC ,KTHG  ,KCOSTG,KSINTG,   &
     &              KDPSI ,KEPST ,KEPSM ,KETA  ,KZTA  ,KTHTA ,KEQN  ,   &
     &              KDPSR ,KSL   ,KH2   ,KL2   ,KXPUT ,KYPUT ,KUT   ,   &
     &              KSPCRD,KSPSIG,KSTAIN,KSXYZ ,KSPWT ,KDXSDP,KDPSDP,   &
     &              KXLOCV,KSTNAM,KA1UT ,KPLTIN,KPLTVL,KPLTDV,KPUTBH,   &
     &              KABCOF,KSPEED,KANGFC,KSCROL,KSTVEL,KSTVDV,KTIMVL,   &
     &              KSTEL2,KSTEH2,KSL2DV,KSH2DV,                        &
     &              KAPRES, KASCAL, KASOFF,KXDOTP,KSAVST,               &
     &              KANGT , KSPDT , KCONAM,KGRDAN,KUANG ,KFAMP ,        &
     &              KOFACT, KOTSGN,KWRKRS,KANFSD,KSPDSD,KPRMFS,KSCRFR,  &
     &              KCOSAS,KSINAS,KDXTID,KALCOF,KSTANF,KNUTIN,KNUTMD,   &
     &              KPDPSI,KPEPST,KDXDNU,KDPSIE,KEPSTE,NXCA03
      COMMON/CREFMT/REFMT(9)
      COMMON/CGRAV/GM,AE,AESQ,FE,FFSQ32,FSQ32,XK2,XK3,XLAM,SIGXK2,      &
     &      SIGXK3,SIGLAM,RATIOM(2),AU,RPRESS
!
      DIMENSION AA(1),II(1)
      DIMENSION XTEMP(6),ROTTMP(9),ACC1(3),ACC2(3)
      DIMENSION XPE1(3),XPE2(3),XPM1(3),XPM2(3)
      DIMENSION DUM(3),DUM2(3,2,1)
!
! CJ2 IS THE NORMALIZED J2 FOR THE EARTH
! AEARTH IS THE SEMI-MAJOR AXIS OF THE EARTH
!
      DATA CJ2/-4.8416498999999D-4/,AEARTH/6378.138D3/
      DATA SQRT5/2.236067977499790D0/,C1P5/1.50D0/
      DATA ONE/1.0D0/,THREE/3.0D0/
!
!***********************************************************************
!* START OF EXECUTABLE CODE
!***********************************************************************
!
! COMPUTE EARTH CENTERED S/C AND MOON POSITIONS FROM MOON CENTERED
!
      XPE1(1)=XTEMP(1)-BDTRUE(1,9)
      XPE1(2)=XTEMP(2)-BDTRUE(2,9)
      XPE1(3)=XTEMP(3)-BDTRUE(3,9)
      XPM1(1)=-BDTRUE(1,9)
      XPM1(2)=-BDTRUE(2,9)
      XPM1(3)=-BDTRUE(3,9)
!
! ROTATE TRUE OF DATE IAU EARTH CENTERED COORDS. TO MEAN OF 2000/50
! EARTH EQUATOR AND EQUINOX COORDS.
!
      XPE2(1)=RM5OE(1)*XPE1(1) + RM5OE(2)*XPE1(2) + RM5OE(3)*XPE1(3)
      XPE2(2)=RM5OE(4)*XPE1(1) + RM5OE(5)*XPE1(2) + RM5OE(6)*XPE1(3)
      XPE2(3)=RM5OE(7)*XPE1(1) + RM5OE(8)*XPE1(2) + RM5OE(9)*XPE1(3)
      XPM2(1)=RM5OE(1)*XPM1(1) + RM5OE(2)*XPM1(2) + RM5OE(3)*XPM1(3)
      XPM2(2)=RM5OE(4)*XPM1(1) + RM5OE(5)*XPM1(2) + RM5OE(6)*XPM1(3)
      XPM2(3)=RM5OE(7)*XPM1(1) + RM5OE(8)*XPM1(2) + RM5OE(9)*XPM1(3)
!
! EVALUATE PRECESSION AND NUTATION MATRIX FROM MEAN 2000/50 TO TRUE
! OF DATE FOR THE EARTH
!
      CALL BUFEAR(MJDSEC,FSEC,MJDSEC,FSEC,1,IDUM1,DUM1,LDUM1,           &
     &            AA,II)
      CALL PRECSS(MJDSEC,FSEC,AA(KETA),AA(KZTA),AA(KTHTA),              &
     &            AA(KSRTCH),1)
      CALL NUVECT(MJDSEC,FSEC,AA(KDPSI),AA(KEPST),AA(KEPSM),            &
     &            1,AA(KSRTCH))
      CALL NPVECT(MJDSEC,FSEC,AA(KDPSI),AA(KEPST),AA(KEPSM),            &
     &            AA(KETA),AA(KTHTA),AA(KZTA),1,AA(KSRTCH),             &
     &            ROTTMP,AA(KEQN),1,.FALSE.,                            &
     &            AA(KPDPSI),AA(KPEPST),AA(KNUTIN),AA(KNUTMD),.FALSE.,  &
     &            AA(KDXDNU),AA(KDPSIE),AA(KEPSTE),DUM,DUM2)
!
! ROTATE FROM MEAN 2000/50 TO TRUE OF DATE EARTH EQUATOR AND EQUINOX
!
      XPE1(1)=ROTTMP(1)*XPE2(1) + ROTTMP(4)*XPE2(2) + ROTTMP(7)*XPE2(3)
      XPE1(2)=ROTTMP(2)*XPE2(1) + ROTTMP(5)*XPE2(2) + ROTTMP(8)*XPE2(3)
      XPE1(3)=ROTTMP(3)*XPE2(1) + ROTTMP(6)*XPE2(2) + ROTTMP(9)*XPE2(3)
      XPM1(1)=ROTTMP(1)*XPM2(1) + ROTTMP(4)*XPM2(2) + ROTTMP(7)*XPM2(3)
      XPM1(2)=ROTTMP(2)*XPM2(1) + ROTTMP(5)*XPM2(2) + ROTTMP(8)*XPM2(3)
      XPM1(3)=ROTTMP(3)*XPM2(1) + ROTTMP(6)*XPM2(2) + ROTTMP(9)*XPM2(3)
!
! EVALUATE EARTH FIXED DIRECT J2 PERTURBATION ON LUNAR ORBITER
!
      RSAT2=XPE1(1)**2 + XPE1(2)**2 + XPE1(3)**2
      RSAT=SQRT(RSAT2)
      RSAT3=RSAT2*RSAT
      RXYSQ=RSAT2 - XPE1(3)**2
      RXY=SQRT(RXYSQ)
      RSAT4=RSAT2*RSAT2
!
! ..EVALUATE PARTIALS TO TRANSFORM FROM R,PSI,LAMDA TO TRUE OF DATE XYZ
!
      SINPSI=XPE1(3)/RSAT
      COSPSI=RXY/RSAT
! ...PARTIALS OF R WRT X Y AND Z
      PRWRTX=XPE1(1)/RSAT
      PRWRTY=XPE1(2)/RSAT
      PRWRTZ=SINPSI
! ...PARTIALS OF PSI WRT X Y AND Z (REFER TO PAGE 109 OF VOLUME 1)
      PPWRTX=-(XPE1(3)*XPE1(1))/(RXY*RSAT2)
      PPWRTY=-(XPE1(3)*XPE1(2))/(RXY*RSAT2)
      PPWRTZ=RXY/RSAT2
! ..EVALUATE DIRECT J2 ACCELERATION IN R AND PSI
      CONS=BDTRUE(4,9)*AEARTH*AEARTH*CJ2*SQRT5
! ...ACCELERATION IS GRADIENT OF POTENTIAL WRT R AND PSI
! ....PARTIAL OF THE POTENTIAL WRT R AND PSI IS:
      PPWRTR=(-C1P5*CONS*(THREE*SINPSI*SINPSI - ONE))/RSAT4
      PPWRTP=THREE*CONS*SINPSI*COSPSI/RSAT3
! ..TRANSFORM ACCELERATION TO TRUE OF DATE XYZ EARTH EQUATOR AND EQ.
      ACC1(1)=PPWRTR*PRWRTX + PPWRTP*PPWRTX
      ACC1(2)=PPWRTR*PRWRTY + PPWRTP*PPWRTY
      ACC1(3)=PPWRTR*PRWRTZ + PPWRTP*PPWRTZ
!
! EVALUATE EARTH FIXED INDIRECT J2 PERTURBATION ON LUNAR ORBITER
!
      RSAT2=XPM1(1)**2 + XPM1(2)**2 + XPM1(3)**2
      RSAT=SQRT(RSAT2)
      RSAT3=RSAT2*RSAT
      RXYSQ=RSAT2 - XPM1(3)**2
      RXY=SQRT(RXYSQ)
      RSAT4=RSAT2*RSAT2
!
! ..EVALUATE PARTIALS TO TRANSFORM FROM R,PSI,LAMDA TO TRUE OF DATE XYZ
!
      SINPSI=XPM1(3)/RSAT
      COSPSI=RXY/RSAT
! ...PARTIALS OF R WRT X Y AND Z
      PRWRTX=XPM1(1)/RSAT
      PRWRTY=XPM1(2)/RSAT
      PRWRTZ=SINPSI
! ...PARTIALS OF PSI WRT X Y AND Z (REFER TO PAGE 109 OF VOLUME 1)
      PPWRTX=-(XPM1(3)*XPM1(1))/(RXY*RSAT2)
      PPWRTY=-(XPM1(3)*XPM1(2))/(RXY*RSAT2)
      PPWRTZ=RXY/RSAT2
! ..EVALUATE DIRECT J2 ACCELERATION IN R AND PSI
      CONS=BDTRUE(4,9)*AEARTH*AEARTH*CJ2*SQRT5
! ...ACCELERATION IS GRADIENT OF POTENTIAL WRT R AND PSI
! ....PARTIAL OF THE POTENTIAL WRT R AND PSI IS:
      PPWRTR=(-C1P5*CONS*(THREE*SINPSI*SINPSI - ONE))/RSAT4
      PPWRTP=THREE*CONS*SINPSI*COSPSI/RSAT3
! ..TRANSFORM ACCELERATION TO TRUE OF DATE XYZ EARTH EQUATOR AND EQ.
! ...THE ACCELERATION ON THE LUNAR ORBITER IS EQUAL AND OPPOSITE TO
! ...TO THE ACCELERATION ON THE MOON SO ADD IN THE NEGATIVE OF THE
! ...ACCELERATION ON THE MOON
      ACC1(1)=ACC1(1) - (PPWRTR*PRWRTX + PPWRTP*PPWRTX)
      ACC1(2)=ACC1(2) - (PPWRTR*PRWRTY + PPWRTP*PPWRTY)
      ACC1(3)=ACC1(3) - (PPWRTR*PRWRTZ + PPWRTP*PPWRTZ)
!
! ROTATE ACCEL FROM TRUE OF DATE TO MEAN OF 2000/50 EARTH EQUATOR AND EQ
!
      ACC2(1)=ROTTMP(1)*ACC1(1) + ROTTMP(2)*ACC1(2) + ROTTMP(3)*ACC1(3)
      ACC2(2)=ROTTMP(4)*ACC1(1) + ROTTMP(5)*ACC1(2) + ROTTMP(6)*ACC1(3)
      ACC2(3)=ROTTMP(7)*ACC1(1) + ROTTMP(8)*ACC1(2) + ROTTMP(9)*ACC1(3)
!
! ROTATE ACCEL FROM MEAN OF 2000/50 EQUATOR AND EQUINOX TO TRUE OF
! REFERENCE PLANET EQUATOR AND IAU VECTOR OF REFERENCE DATE
!
      ACC1(1)=REFMT(1)*ACC2(1) + REFMT(2)*ACC2(2) + REFMT(3)*ACC2(3)
      ACC1(2)=REFMT(4)*ACC2(1) + REFMT(5)*ACC2(2) + REFMT(6)*ACC2(3)
      ACC1(3)=REFMT(7)*ACC2(1) + REFMT(8)*ACC2(2) + REFMT(9)*ACC2(3)
!
! ADD TRUE OF REFERENCE IAU ACCELERATION TO TOTAL
!
      XDD=XDD + ACC1(1)
      YDD=YDD + ACC1(2)
      ZDD=ZDD + ACC1(3)
!
! EVALUATE MOON'S INDIRECT J2 PERTURBATION ON A LUNAR ORBITER
! IN TRUE OF DATE MOON EQUATOR AND IAU VECTOR OF DATE
!
      RSAT2=BDTRUE(1,9)**2 + BDTRUE(2,9)**2 + BDTRUE(3,9)**2
      RSAT=SQRT(RSAT2)
      RSAT3=RSAT2*RSAT
      RXYSQ=RSAT2 - BDTRUE(3,9)**2
      RXY=SQRT(RXYSQ)
      RSAT4=RSAT2*RSAT2
!
! ..EVALUATE PARTIALS TO TRANSFORM FROM R,PSI,LAMDA TO TRUE OF DATE XYZ
!
      SINPSI=BDTRUE(3,9)/RSAT
      COSPSI=RXY/RSAT
! ...PARTIALS OF R WRT X Y AND Z
      PRWRTX=BDTRUE(1,9)/RSAT
      PRWRTY=BDTRUE(2,9)/RSAT
      PRWRTZ=SINPSI
! ...PARTIALS OF PSI WRT X Y AND Z (REFER TO PAGE 109 OF VOLUME 1)
      PPWRTX=-(BDTRUE(3,9)*BDTRUE(1,9))/(RXY*RSAT2)
      PPWRTY=-(BDTRUE(3,9)*BDTRUE(2,9))/(RXY*RSAT2)
      PPWRTZ=RXY/RSAT2
! ..EVALUATE DIRECT J2 ACCELERATION IN R AND PSI
      CONS=BDTRUE(4,9)*AE*AE*C20M*SQRT5
! ...ACCELERATION IS GRADIENT OF POTENTIAL WRT R AND PSI
! ....PARTIAL OF THE POTENTIAL WRT R AND PSI IS:
      PPWRTR=(-C1P5*CONS*(THREE*SINPSI*SINPSI - ONE))/RSAT4
      PPWRTP=THREE*CONS*SINPSI*COSPSI/RSAT3
! ..TRANSFORM ACCELERATION TO TRUE OF DATE XYZ MOON EQUATOR AND IAU
! ..VECTOR OF DATE
! ...THE ACCELERATION ON THE LUNAR ORBITER IS EQUAL AND OPPOSITE TO
! ...THE ACCELERATION ON THE MOON (REMEMBER THIS IS THE MOON'S INDIRECT
! ...J2 ACCELERATION)
      ACCTD1= PPWRTR*PRWRTX + PPWRTP*PPWRTX
      ACCTD2= PPWRTR*PRWRTY + PPWRTP*PPWRTY
      ACCTD3= PPWRTR*PRWRTZ + PPWRTP*PPWRTZ
!
      RETURN
      END