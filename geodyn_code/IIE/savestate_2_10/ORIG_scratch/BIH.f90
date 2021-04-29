!$BIH
      SUBROUTINE BIH(MJDSC,FSEC,ETUTC,XBIH,YBIH)
!********1*********2*********3*********4*********5*********6*********7**
! BIH              83/05/01            8305.0    PGMR - D. ROWLANDS
!                  89/09/11                      PGMR - A. MARSHALL
!                  91/04/02                      PGMR - SBL
!
!   FUNCTION:  COMPUTE THE "BIH" VALUE OF POLAR MOTION
!              COMPONENTS AT THE DESIRED EPOCH BASED ON
!              BIQUADRATIC INTERPOLATION UPON BIH TABULATED
!              VALUES.
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   MJDSC    I    S    INTEGER SECONDS SINCE GEODYN REFERENCE TIME
!   FSEC     I    A    REMAINING SECONDS FROM MJDSC
!   ETUTC    I    A    TABLE OF ETUTC VALUES
!   XBIH     O    A    BIQUADRATICALLY INETRPOLATED X POLE VALUE
!                      AT EPOCH MJDSC+FSEC
!   YBIH     O    A    BIQUADRATICALLY INTERPOLATED Y POLE VALUE
!                      AT EPOCH MJDSC+FSEC
!
! COMMENTS:
!
! RESTRICTIONS:  EPHEMERIS BUFFER MUST BE POSITIONED CORRECTLY
!                (CALL BUFPOS)
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      COMMON/EPHM/FSECXY(1),XP(261),YP(261),A1UT(261),EP(261),EC(261),  &
     &            FSCFLX(1),FLUXS(36),AVGFLX(36),FLUXM(288),FSECEP(1),  &
     &            EPHP(816),EPHN(96),ELIB(120),BUFT(2700),FSECNP(4)
      COMMON/EPHMPT/NTOT,NTOTS,NNPDPR,NUTORD,IBODDG(8),IGRPDG(4),       &
     &              NENPD,INRCD(2),KPLAN(11),NINEP,NEPHMR,NEPHEM,       &
     &              IBHINT,NINTBH,NXEPHP
      DIMENSION FSECET(1),FSCUTC(1),ETUTC(1)
      DATA SIXTH/.1666666666666667D0/
      DATA ETA1/32.1496183D0/,ONE/1.D0/,THIRD/.3333333333333333D0/
      DATA FTHRD/1.333333333333333D0/
      DATA C3600/3600.0D0/
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
! CALCULATE INTERVAL IN SECONDS
      XINT=IBHINT*C3600
      XINTI=ONE/XINT
      XINTT=(IBHINT*(NINTBH-2))*C3600
      IPOINT=1
!   GET UTC TIME TO BE ABLE TO USE TABLE VALUES OF THE POLE
      FSECET(1)=FSEC
      CALL UTCET(.FALSE.,1,MJDSC,FSECET,FSCUTC,ETUTC)
! TTIME IS TIME OF FIRST POINT IN BUFFER FROM BIH TABLE
      TTIME=FSECXY(1)+XINTT
      TIME=MJDSC+FSCUTC(1)
!   FIGURE WHICH OF 2 BUFFERS WILL BE USED INCOMPUTATIONS
      IF(TIME.GT.TTIME) IPOINT=IPOINT+NTOT
      TTIME=FSECXY(IPOINT)
! FIND TIME BETWEEN FIRST POINT IN BUFFER AND OBS TIME
      DT=TIME-TTIME
! FIND THE NUMBER OF POINTS IN BUFFER IN INTERVAL DT
      IDX=INT(DT*XINTI)
! POINTER TO FIRST BUFFERED PT TO THE LEFT OF OBS VALUE
      IDX2=IDX+IPOINT
! POINTER TWO TO THE LEFT OF OBS VALUE
      IDX1=IDX2-1
! POINTER ONE TO THE RIGHT OF OBS VALUE
      IDX3=IDX2+1
! POINTER TWO TO THE RIGHT OF OBS VALUE
      IDX4=IDX3+1
! MAP TIME BETWEEN OBS AND TABLE PT INTO INTERVAL  0,1
      TTIME=TTIME+IDX*XINT
      DT1=((MJDSC-TTIME)+FSCUTC(1))*XINTI
!   FIGURE QUADRATIC COEFFCIENTS
      F2X= (XP(IDX3)+XP(IDX1))*SIXTH
      V11X= FTHRD*XP(IDX2)-F2X
      V21X=-THIRD*XP(IDX2)+F2X
      F2X= (XP(IDX4)+XP(IDX2))*SIXTH
      V12X= FTHRD*XP(IDX3)-F2X
      V22X=-THIRD*XP(IDX3)+F2X
      F2Y= (YP(IDX3)+YP(IDX1))*SIXTH
      V11Y= FTHRD*YP(IDX2)-F2Y
      V21Y=-THIRD*YP(IDX2)+F2Y
      F2Y= (YP(IDX4)+YP(IDX2))*SIXTH
      V12Y= FTHRD*YP(IDX3)-F2Y
      V22Y=-THIRD*YP(IDX3)+F2Y
      DT2=ONE-DT1
! INTERPOLATE FOR POLE VALUES
      XBIH=(DT1*(V12X+DT1**2*V22X)+DT2*(V11X+DT2**2*V21X))
      YBIH=(DT1*(V12Y+DT1**2*V22Y)+DT2*(V11Y+DT2**2*V21Y))
      RETURN
      END
