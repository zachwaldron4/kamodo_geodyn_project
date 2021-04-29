!$BODYC
      SUBROUTINE BODYC(WRATDS)
!********1*********2*********3*********4*********5*********6*********7**
! BODYC            90/10/17            9010.0    PGMR - DESPINA PAVLIS
!
! FUNCTION:   BODYC CALCULATES GEOMETRIC QUANITITES WHICH ARE
!             PLANET DEPENDENT.
!             IT ALSO COMPUTES QUANITIES NECESSARY FOR GEOID
!             CALCULATIONS.
!
! COMMENTS
!
!**********************************************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      COMMON/CEBODY/APL(11),APLSQ,FINVPL(11),FGP,EGSQP,EGSQPP,C1P,C2P,  &
     &              FOURCP,TWOC2P,WREFP(11),RPMEAN,RFPC20,              &
     &              RFPC40,RFPC60,BEGP,CBLTCP,                          &
     &              WAE2P,GAMMAP,FSTARP,F4P
      COMMON/CGRAV/GM,AE,AESQ,FE,FFSQ32,FSQ32,XK2,XK3,XLAM,SIGXK2,      &
     &      SIGXK3,SIGLAM,RATIOM(2),AU,RPRESS
      COMMON/CLIGHT/VLIGHT,ERRLIM,XCLITE
      COMMON/CONSTR/PI,TWOPI,DEGRAD,SECRAD,SECDAY
      COMMON/IBODPT/IBDCF(999),IBDSF(999),IBDGM(999),IBDAE(999),    &
     &              IBDPF(999),                                     &
     &              ICBDCF,ICBDSF,ICBDGM,ICBDAE,ICBDPF,             &
     &              ITBDCF,ITBDSF,ITBDGM,ITBDAE,ITBDPF,NXBDPT
      DATA HALF/0.5D0/,ONE/1.0D0/,TWO/2.0D0/,P8/.8D0/
      DATA THREE/3.0D0/,FOUR/4.0D0/,FIVE/5.D0/,SEVEN/7.D0/
      DATA ELEVEN/11.D0/,C13/13.D0/,C21/21.D0/,C35/35.D0/
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
      IF(ICBDGM.LE.11) THEN
        WRATE=WREFP(ICBDGM)
      ELSE
        WRATE=WRATDS*DEGRAD/SECDAY
      ENDIF
!     APLSQ=APL(ICBDGM)**2
      APLSQ=AE**2
!     FGP=ONE/FINVPL(ICBDGM)
      FGP=FE
      C1LESQ=(ONE-FGP)**2
      EGSQP=ONE-C1LESQ
!     BEGP=APL(ICBDGM)*SQRT(ONE-EGSQP)
      BEGP=AE*SQRT(ONE-EGSQP)
      EGSQPP=EGSQP+ONE
!     C1P=THREE*HALF*APL(ICBDGM)*FGP**2
      C1P=THREE*HALF*AE*FGP**2
!     C2P=APL(ICBDGM)*FGP+C1P
      C2P=AE*FGP+C1P
      FOURCP=FOUR*C1P
      TWOC2P=TWO*C2P
      THIRD=ONE/THREE
!     RPMEAN=APL(ICBDGM)*(ONE-FGP)**THIRD
      RPMEAN=AE*(ONE-FGP)**THIRD
!
!     REFM=WREFP(ICBDGM)*WREFP(ICBDGM)*APL(ICBDGM)**3*(ONE-FGP)/GM
      REFM=WRATE*WRATE*AE**3*(ONE-FGP)/GM
! REF ZONALS UNNORMALIZED
      RFPC20=-TWO*(FGP*(ONE-HALF*FGP)-HALF*REFM*(ONE-TWO/SEVEN*FGP+     &
     & ELEVEN/49.D0*FGP*FGP))/3.D0
      RFPC40=4.D0*FGP*(ONE-HALF*FGP)*(SEVEN*FGP*(ONE-HALF*FGP)-FIVE*    &
     & REFM*(ONE-TWO/SEVEN*FGP))/C35
      RFPC60=-4.D0*FGP*FGP*(6.D0*FGP-FIVE*REFM)/C21
! REF ZONALS NORMALIZED
      RFPC20=RFPC20/SQRT(FIVE)
      RFPC40=RFPC40*THIRD
      RFPC60=RFPC60/SQRT(C13)
!
! COMPUTE QUANTITIES FOR GRAVITY FORMULA
      BEGSQ=BEGP*BEGP
      EPSQ=(APLSQ-BEGSQ)/BEGSQ
!     XM=WREFP(ICBDGM)*WREFP(ICBDGM)*APLSQ*BEGP/GM
      XM=WRATE*WRATE*APLSQ*BEGP/GM
      GAMMAP=ONE-1.5D0*XM-(3.D0/14.D0)*EPSQ*XM
!     GAMMAP=GAMMAP*GM/(APL(ICBDGM)*BEGP)
      GAMMAP=GAMMAP*GM/(AE*BEGP)
      F2=-FGP+2.5D0*XM+.5D0*FGP*FGP-(26.D0/7.D0)*FGP*XM+                &
     &    (15.D0/4.D0)*XM*XM
      F4P=-.5D0*FGP*FGP+2.5D0*FGP*XM
      FSTARP=F2+F4P
!
! COMPUTE SATELLITE INDEPENDENT (CENTRAL BODY DEPENDENT)
! PART OF LENSE-THIRRING
!
!  BELOW NEEDS TO BE UPDATED (MADE MORE GENERAL)
!     WCB=WREFP(ICBDGM)
      WCB=WRATE
!  ABOVE NEEDS TO BE UPDATED (MADE MORE GENERAL)
      CBLTCP=P8*GM*WCB*(RPMEAN/VLIGHT)**2
!     WAE2P=AESQ*WREFP(ICBDGM)
      WAE2P=AESQ*WRATE
      RETURN
      END
