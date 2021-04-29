!$ETUTP
      SUBROUTINE ETUTP(MJDS,FSECET,DPSR,UT,FSECUT,FSCUTC,ETUTC,NM,      &
     &           XDOTP,UTDT)
!********1*********2*********3*********4*********5*********6*********7**
! ETUT             83/06/15            8306.0    PGMR - D.ROWLANDS
!                  91/04/02            9104.0    PGMR - SBL
!
! FUNCTION:  CONVERT ET TIMES TO UT TIMES.
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   MJDS    I/O   S    ET SECONDS SINCE GEODYN REF. TIME AS INPUT
!                      UT SECONDS SINCE GEODYN REFERENCE TIME IF
!                      USED WITH FSECUT AS OUTPUT
!   FSECET   I    A    FRACTIONAL REMAINING SECONDS (ET)
!   DPSR     I    A    START TIMES OF POLE/UT OFFSETS
!   UT       I    A    UT OFFSET TIMES
!   FSECUT   O    A    FRACTIONAL REMAINING SECONDS FROM MJDS
!   FSCUTC   I    A    FRACTIONAL REMAINING SECONDS FROM MJDS IN UTC
!   ETUTC    I    A    ET-UTC TIME DIFFERENCES, A1-UTC RATES, TIME AT
!                      WHICH DIFF. APPLIES
!   NM       I    S    # OF TIMES FOR WHICH CONVERSION REQUESTED
!
! COMMENTS:
!
!        NOTE - NUMERICALLY MJDS REMAINS UNCHANGED ITS SENSE CHANGES
!               DEPENDING ON WHICH FSEC IT IS USED WITH.
!               BIQUADRATIC INTERPOLATION USED.
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      COMMON/COBGLO/MABIAS,MCBIAS,MPVECT,MINTPL,MPARAM,MSTA,MOBBUF,     &
     &       MNPITR,MWIDTH,MSIZE ,MPART ,MBUF  ,NXCOBG
      COMMON/EPHM/FSECXY(1),XP(261),YP(261),A1UT(261),EP(261),EC(261),  &
     &            FSCFLX(1),FLUXS(36),AVGFLX(36),FLUXM(288),FSECEP(1),  &
     &            EPHP(816),EPHN(96),ELIB(120),BUFT(2700),FSECNP(4)
      COMMON/EPHMPT/NTOT,NTOTS,NNPDPR,NUTORD,IBODDG(8),IGRPDG(4),       &
     &              NENPD,INRCD(2),KPLAN(11),NINEP,NEPHMR,NEPHEM,       &
     &              IBHINT,NINTBH,NXEPHP
      COMMON/POLINF/NPOLE,NPOLEA,NUTA,MXUTC,NMODEL,NXPOLI
      COMMON/POLRAT/XPD(15000),YPD(15000),A1D(15000),TIMEPR(15000),XPOLR
      COMMON/TIDEOP/EOPTID(2,3)
      DATA SIXTH/.1666666666666667D0/
      DATA ETA1/32.1496183D0/,ONE/1.D0/,THIRD/.3333333333333333D0/
      DATA FTHRD/1.333333333333333D0/
      DATA C3600/3600.0D0/
      DIMENSION FSECET(NM),FSECUT(NM),FSCUTC(NM)
      DIMENSION DPSR(1),UT(3,1),ETUTC(1)
      DIMENSION XDOTP(3,NPOLE)
      DIMENSION UTDT(NM)
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
! CALCULATE INTERVAL IN SECONDS
      XINT=IBHINT*C3600
      XINTI=ONE/XINT
      XINTT=(IBHINT*(NINTBH-2))*C3600
      IOFST=1
      ISOFST=2
! GET UTC TIMES TO BE ABLE TO USE TABLES
      CALL UTCET(.FALSE.,NM,MJDS,FSECET,FSCUTC,ETUTC)
! LOOP THROUGH ALL POINTS IN BLOCK
      DO 100 II=1,NM
      IPOINT=1
! TTIME IS TIME OF FIRST POINT IN BUFFER FROM BIH TABLE
      TTIME=FSECXY(1)+XINTT
      TIME=MJDS+FSCUTC(II)
!
!
      IF(NMODEL.EQ.1) THEN
      CALL FNDRN(TIME,TIMEPR,15000,IRET)
      IF(TIMEPR(IRET).LE.TIME) THEN
       T1=TIMEPR(IRET)
      ELSE
       T1=TIMEPR(IRET-1)
      ENDIF
       DTN=TIME-T1
      ENDIF
!
!
! FIGURE WHICH OF 2 BUFFERS WILL BE USED IN COMPUTATIONS
      IF(TIME.GT.TTIME) IPOINT=1+NTOT
      TTIME=FSECXY(IPOINT)
! FIND TIME BETWEEN FIRST POINT IN BUFFER AND OBS TIME
      DT=TIME-TTIME
! FIND THE NUMBER OF POINTS IN BUFFER IN INTERVAL DT
      IDX=DT*XINTI
! POINTER TO FIRST BUFFERED PT TO THE LEFT OF OBS VALUE
      IDX2=IDX+IPOINT
! POINTER TWO TO THE LEFT OF OBS VALUE
      IDX1=IDX2-1
! POINTER ONE TO THE RIGHT OF OBS VALUE
      IDX3=IDX2+1
! POINTER TWO TO THE RIGHT OF OBS VALUE
      IDX4=IDX3+1
!   MAP MJDS+FSECET(II) INTO INTERVAL  0,1
      TTIME=TTIME+IDX*XINT
      DT1=((MJDS-TTIME)+FSCUTC(II))*XINTI
!   FIGURE QUADRATIC COEFFCIENTS
      F2=(A1UT(IDX3)+A1UT(IDX1))*SIXTH
      Y11=FTHRD*A1UT(IDX2)-F2
      Y21=-THIRD*A1UT(IDX2)+F2
      F2=(A1UT(IDX4)+A1UT(IDX2))*SIXTH
      Y12=FTHRD*A1UT(IDX3)-F2
      Y22=-THIRD*A1UT(IDX3)+F2
      DT2=ONE-DT1
! INTERPOLATE FOR A1UT CORRECTION
      A1UTVL=(DT1*(Y12+DT1**2*Y22)+DT2*(Y11+DT2**2*Y21))
! ADD ETA1 CONSTANT CORRECTION TO GET ETUT CORRECTION
      CORR=A1UTVL+ETA1
! CONVERT FROM ET TO UT
      FSECUT(II)=FSECET(II)-CORR
      IF(NPOLE.LE.IOFST) GO TO 20
!   ADD IN OFFSET
      DO 10 IOF=ISOFST,NPOLE
      IF(TIME.LT.DPSR(IOF)) GO TO 15
   10 END DO
   15 IOFST=IOF-1
      IOFST=MIN(IOFST,NPOLE)
      ISOFST=IOFST+1
   20 CONTINUE
      FSECUT(II)=FSECUT(II)-UT(3,IOFST)
!
!
      IF(NMODEL.EQ.1) THEN
      A1UTVL=A1UT(IDX2)+XDOTP(3,IOFST)*DTN
      CORR=A1UTVL+ETA1
      FSECUT(II)=FSECET(II)-CORR
      UTDT(II)=DTN
      ENDIF
!
!
  100 END DO
!   ADD IN TIDAL EFFECTS
      MM=MIN(2,NM)
      CALL UTTIDE(MJDS,FSECET(1),MJDS,FSECET(NM),MM,DEL1,DEL2)
      DEL1=DEL1+EOPTID(1,3)
      DEL2=DEL2+EOPTID(2,3)
      IF(NM.GT.1) GO TO 110
      FSECUT(1)=FSECUT(1)+DEL1
      RETURN
  110 CONTINUE
      SLOPE=(DEL2-DEL1)/(FSECUT(NM)-FSECUT(1))
      SLOPE1=ONE+SLOPE
      HLD=DEL1-FSECUT(1)*SLOPE
      DO 200 II=1,NM
      FSECUT(II)=FSECUT(II)*SLOPE1+HLD
  200 END DO
      RETURN
      END
