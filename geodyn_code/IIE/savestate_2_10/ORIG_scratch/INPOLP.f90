!$INPOLP
      SUBROUTINE INPOLP(ETUTC,DPSR,XPUT,YPUT,LINTRP,LDNPOL,LPOLAD,MJDSC,&
     &           FSEC,NM,XM,INDPI,NINTVL,NMP,INDP,PXPOLE,RPOLE,S,XDPOLE,&
     &           XDOTP)
!********1*********2*********3*********4*********5*********6*********7**
! INPOLE           83/05/01            8305.0    PGMR - D. ROWLANDS
!
! FUNCTION:   THIS SUBROUTINE HAS 2 MODES OF OPERATION.  IF LINTRP
!             IS TRUE, THEN THE ROUTINE FINDS THE POLAR MOTION MATRIX
!             (AND -IF REQUESTED- THE POLAR MOTION PARTIAL MATRIX) AT
!             INTERPOLATION INTERVAL ENDPOINT TIMES.  THE INTERPOLATION
!             ENDPOINT TIMES ARE DETERMINED (BY THIS SUBROUTINE) SO
!             THAT NO INTERPOLATION WILL CUT ACROSS BIH OFFSET INTERVAL
!             TIMES.
!             IF LINTRP IS FALSE,  THEN THE REQUESTED INFORMATION IS
!             AT THE SINGLE REQUESTED TIME.
!
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   ETUTC    I    A    TABLE OF ET-UTC TIMES
!   DPSR     I    A    STARTING TIMES (IN MJD SEC) OF BIH POLE
!                      OFFSET TIMES
!   XPUT     I    A    X VALUES OF BIH POLE OFFSETS
!   YPUT     I    A    Y VALUES OF BIH POLE OFFSETS
!   LINTRP   I    S    INTERPOLATION REQUEST LOGICAL INDICATOR
!   LDNPOL   I    S    DIURNAL POLAR MOTION LOGICAL INDICATOR
!   LPOLAD   I    S    CREATE POLAR MOTION PARTIALS LOGICAL INDICATOR
!   MJDSC    I    S    MJD SEC OF TIME(S) FOR WHICH ENDPOINT MATRIX
!                      (OR ACTUAL MATRICES ARE TO BE FOUND)
!   FSEC     I    A    REMAINING SECONDS FROM MJDSC
!   NM       I    S    NUMBER OF TIMES AT WHICH INTERPOLATION WILL
!                      BE PERFORMED (IF LINTRP=.FALSE.,NM=1)
!   XM       I    A    STATION MEAN X,Y,Z (IF PARTIALS ARE REQUESTED)
!   INDPI    I    A    ADJUSTED POLE PERIOD POINTER
!   NINTVL   O    S    NUMBER OF INTERPOLATION INTERVALS REQUIRED
!   NMP      O    A    ARRAY POINTING TO NUMBER OF TIMES IN EACH
!                      INTERPOLATION GROUP
!   INDP     O    A    POINTER TO ADJUSTED POLES USED IN CURRENT
!                      CALL
!   PXPOLE   O    A    PARTIAL ARRAY
!   XDPOLE   O    A    PARTIAL ARRAY FOR RATES
!   RPOLE    O    A    POLAR MOTION MATRIX
!   S        O    A    INTERPOLATION FRACTIONS FOR FIRST END TIME
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      DIMENSION FSEC(NM),NMP(1),INDPI(1),INDP(1),DPSR(1),XPUT(3,1),     &
     & YPUT(1),RPOLE(3,3,1),PXPOLE(3,2,1),XM(3),IPTT(2),S(NM),ETUTC(1)
      DIMENSION XDPOLE(3,2,1)
      DIMENSION XDOTP(3,NPOLE)
!
      COMMON/COBGLO/MABIAS,MCBIAS,MPVECT,MINTPL,MPARAM,MSTA,MOBBUF,     &
     &       MNPITR,MWIDTH,MSIZE ,MPART ,MBUF  ,NXCOBG
      COMMON/CONTRL/LSIMDT,LOBS  ,LORB  ,LNOADJ,LNADJL,LORFST,LORLST,   &
     &              LORALL,LORBOB,LOBFST,LOBLST,LOBALL,LPREPO,LORBVX,   &
     &              LORBVK,LACC3D,LSDATA,LCUTOT,LACCEL,LDYNAC,LFRCAT,   &
     &              LNIAU, NXCONT
      COMMON/CVIEW /IOUT6 ,ILINE6,IPAGE6,MLINE6,                        &
     &              IOUT8 ,ILINE8,IPAGE8,MLINE8,                        &
     &              IOUT9 ,ILINE9,IPAGE9,MLINE9,                        &
     &              IOUT10,ILIN10,IPAG10,MLIN10,                        &
     &              IOUT15,ILIN15,IPAG15,MLIN15,                        &
     &              IOUT16,ILIN16,IPAG16,MLIN16,                        &
     &              IOUT7 ,NXCVUE
      COMMON/EOPRAT/ETAG,THTAG,ZTAG,EPSMG,DPSIG,EPSTG,TETAG,XPOLE,   &
     &     YPOLE,ETAR,THTAR,ZTAR,EPSMR,DPSIR,EPSTR,THETAGR,XPOLER,   &
     &     YPOLER,SP2,DSP2
      COMMON/INPOL /NMN(500),NINTVN
      COMMON/OLOADA/LXYZCO,LEOPTO
      COMMON/POLINF/NPOLE,NPOLEA,NUTA,MXUTC,NMODEL,NXPOLI
      COMMON/POLRAT/XPD(15000),YPD(15000),A1D(15000),TIMEPR(15000),XPOLR
      COMMON/TIDEOP/EOPTID(2,3)
      COMMON/UNITS/IUNT11,IUNT12,IUNT13,IUNT19,IUNT30,IUNT71,IUNT72,    &
     &             IUNT73,IUNT05,IUNT14,IUNT65,IUNT88,IUNT21,IUNT22,    &
     &             IUNT23,IUNT24,IUNT25,IUNT26
!
      DATA ZERO/0.D0/,ONE/1.D0/
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
      SP2=0.D0
      DXDT=ZERO
      DYDT=ZERO
      IF(NM.GT.1.AND.LEOPTO) THEN
      DXDT=(EOPTID(2,1)-EOPTID(1,1))/(FSEC(NM)-FSEC(1))
      DYDT=(EOPTID(2,2)-EOPTID(1,2))/(FSEC(NM)-FSEC(1))
      ENDIF
      NOEMPT=0
      IF(NPOLE.GT.1) GO TO 5
      NPOLE1=1
      NPOLE2=1
      GO TO 30
    5 CONTINUE
!   CALCULTE NPOLEC ; NUMBER OF POLE PERIODS IN THIS CALL
!   CALCULATE FIRST INTERVAL
      TTEST=MJDSC+FSEC(1)
      DO 10 I=2,NPOLE
      IF(DPSR(I).GT.TTEST) GO TO 15
   10 END DO
      NPOLE1=NPOLE
      NPOLE2=NPOLE
      GO TO 30
   15 NPOLE1=I-1
      NPOLE2=NPOLE1
!DEP
!     IF(NM.EQ.1) GO TO 30
!   WHEN MORE THAN ONE INTERVAL, CALCULATE LAST INTERVAL
      TTEST=MJDSC+FSEC(NM)
      II=0
      DO 20 I=NPOLE1,NPOLE
      III=NPOLE-II
      II=II+1
      IF(TTEST.GE.DPSR(III)) GO TO 25
   20 END DO
!cc   write(6,99999) MJDSC,FSEC
99999 FORMAT(' INPOLE: TERMINATING WITH STOP 6969  MJDSC,FSEC= ',       &
     &   I12/(1X,3G24.16))
      STOP 6969
   25 NPOLE2=III
      NINTVN=NPOLE2
   30 NINTVL=NPOLE2-NPOLE1+1
      IF(NINTVL.GT.MINTPL) GO TO 500
!   NOW FIND LATEST MEASUREMENT IN EACH GROUP
      NMP(NINTVL)=NM
      IF(NINTVL.LT.2) GO TO 75
!   NOTE: THIS LOOP ASSUMES EVERY POLE INTERVAL IS REPRESENTED
      NPOL21=NPOLE2-1
      IPT=1
      IPD=1
      DO 50 I=NPOLE1,NPOL21
      DO 45 J=IPT,NM
      TTEST=MJDSC+FSEC(J)
      IF(TTEST.GE.DPSR(I+1)) GO TO 46
   45 END DO
      I1=I+1
      write(6, 99998) TTEST,DPSR(1),I1
99998 FORMAT(' ** INPOLE **  TTEST=',G24.16,'  DPSR='/(1X,3G24.16))
!cc   write(6, 99999) MJDSC,FSEC
      STOP 6969
   46 CONTINUE
!********* START CODE TO CHECK FOR EMPTY PERIODS
      INC=I+2
      IF(INC.GT.NPOLE) GO TO 48
      IF(TTEST.LT.DPSR(INC)) GO TO 48
      NOEMPT=NOEMPT+1
      NMP(IPD)=0
      IPT=J
      IPD=IPD+1
      GO TO 50
!********* END CODE TO CHECK FOR EMPTY PERIODS
   48 CONTINUE
      NMP(IPD)=J-IPT
      IPT=J
      IPD=IPD+1
   50 END DO
! GET LAST PERIOD
      NMP(IPD)=NM+1-IPT
   75 CONTINUE
!  CALCULATE REQUESTED MATRICES
      IUL=2
!  ON CALLS WHERE LINTRP=.FALSE., DON'T INTERPOLATE
      IF(.NOT.LINTRP) IUL=1
      IPTT(1)=1
!  IF DIURNAL OPTION TURNED ON, GO TO A DIFFERENT SECTION OF CODE
      IF(LDNPOL) GO TO 210
      IC=0
      ICC=0
      DO 200 I=1,NINTVL
      IF(NMP(I).LE.0) GO TO 200
      IC=IC+1
      IPD=I-1+NPOLE1
      IPTT(2)=NMP(I)+IPTT(1)-1
      DO 190 J=1,IUL
      JD=(IC-1)*2+J
      IF(NMODEL.EQ.1) THEN
      TTT=DBLE(MJDSC)+FSEC(IPTT(J))
      CALL FNDRN(TTT,TIMEPR,15000,IRET)
       IF(TIMEPR(IRET).LE.TTT) THEN
       T1=TIMEPR(IRET)
       ELSE
       T1=TIMEPR(IRET-1)
       ENDIF
       DT=TTT-T1
      CALL BIH2(MJDSC,FSEC(IPTT(J)),ETUTC,X1,X2,Y1,Y2)
      X=X1+ XDOTP(1,IPD)*DT
      Y=Y1+ XDOTP(2,IPD)*DT
      XPOLE=X
      YPOLE=Y
      GOTO 180
      ENDIF
      CALL BIH(MJDSC,FSEC(IPTT(J)),ETUTC,XBIH,YBIH)
      IF(LEOPTO) THEN
         TDX=EOPTID(1,1)+DXDT*(FSEC(IPTT(J))-FSEC(1))
         TDY=EOPTID(1,2)+DYDT*(FSEC(IPTT(J))-FSEC(1))
      ELSE
         TDX=0.D0
         TDY=0.D0
      ENDIF
      X=XBIH+XPUT(1,IPD)+TDX
      Y=YBIH+XPUT(2,IPD)+TDY
      XPOLE=X
      YPOLE=Y
  180 CONTINUE
      IF(LNIAU) THEN
      CALL SP2000(MJDSC,FSEC(IPTT(J)),SP2)
      ENDIF
      RPOLE(1,1,JD)=ONE-SP2*X*Y
      RPOLE(2,1,JD)=X*Y+SP2
      RPOLE(3,1,JD)=X
      RPOLE(1,2,JD)=ZERO-SP2
      RPOLE(2,2,JD)=ONE
      RPOLE(3,2,JD)=-Y
      RPOLE(1,3,JD)=-X-SP2*Y
      RPOLE(2,3,JD)=Y-SP2*X
      RPOLE(3,3,JD)=ONE
! NEW
      INDP(IC)=INDPI(IPD)
! NEW
      IF(.NOT.LPOLAD) GO TO 190
! OLD
      INDP(IC)=INDPI(IPD)
! OLD
      IF(INDPI(IPD).LE.0) GO TO 190
      IF(J.EQ.1) ICC=ICC+1
      JDD=(ICC-1)*2+J
!   FILL IN PARTIAL MATRIX
      PXPOLE(1,1,JD)=-XM(3)-SP2*Y*XM(1)
      PXPOLE(1,2,JD)=ZERO-SP2*X*XM(1)-SP2*XM(3)
      PXPOLE(2,1,JD)=XM(1)*Y-SP2*XM(3)
      PXPOLE(2,2,JD)=XM(1)*X+XM(3)
      PXPOLE(3,1,JD)=XM(1)
      PXPOLE(3,2,JD)=-XM(2)
      IF(NMODEL.EQ.1) THEN
      XDPOLE(1,1,JD)=PXPOLE(1,1,JD)*DT
      XDPOLE(1,2,JD)=PXPOLE(1,2,JD)*DT
      XDPOLE(2,1,JD)=PXPOLE(2,1,JD)*DT
      XDPOLE(2,2,JD)=PXPOLE(2,2,JD)*DT
      XDPOLE(3,1,JD)=PXPOLE(3,1,JD)*DT
      XDPOLE(3,2,JD)=PXPOLE(3,2,JD)*DT
      ENDIF
  190 END DO
      IPTT(1)=IPTT(2)+1
  200 END DO
      GO TO 305
!   THE FOLLOWING SECTION OF CODE WILL BE FOR DIURNAL CALCULATIONS
  210 CONTINUE
!cc   write(6, 99997)
99997 FORMAT(' ** INPOLE **  DIURNAL POLE NOT YET IMPLEMENTED')
!cc   write(6,99999) MJDSC,FSEC
      STOP 6969
!
  305 CONTINUE
!   COMPRESS NMP ARRAY: SQUEEZE OUT MISSING INTERVALS
!     IF(.NOT.LINTRP) RETURN
      JINTVL=NINTVL-NOEMPT
      IF(NOEMPT.EQ.0) GO TO 319
      DO 315 I=1,JINTVL
      IF(NMP(I).GT.0) GO TO 315
      I1=I+1
      DO 310 J=I1,NINTVL
      IF(NMP(J).GT.0) GO TO 311
  310 END DO
  311 JJ=MIN(J,NINTVL)
      NMP(I)=NMP(JJ)
      NMP(JJ)=ZERO
  315 END DO
  319 NINTVL=JINTVL
!   GET INTERPOLATION FRACTIONS FOR FIRST ENDPOINT
      IPT1=1
      DO 400 I=1,NINTVL
      IPT2=NMP(I)+IPT1-1
      TTOT=FSEC(IPT2)-FSEC(IPT1)
      IF(TTOT.GT.ZERO) GO TO 320
      S(IPT2)=ZERO
      GO TO 399
  320 CONTINUE
      DRAT=ONE/TTOT
      DO 350 J=IPT1,IPT2
      S(J)=(FSEC(IPT2)-FSEC(J))*DRAT
  350 END DO
  399 CONTINUE
      IPT1=IPT2+1
  400 END DO
      RETURN
  500 CONTINUE
      JLINE6=ILINE6+3
      IF(JLINE6.LE.MLINE6) GO TO 1000
      IPAGE6=IPAGE6+1
      JLINE6=4
      WRITE(IOUT6,10000) IPAGE6
 1000 CONTINUE
      WRITE(IOUT6,20000)
      WRITE(IUNT88,20000)
      ILINE6=JLINE6
      RETURN
10000 FORMAT('1',109X,'UNIT  6 PAGE NO.',I6)
20000 FORMAT(//' INPOLE ** NUMBER OF POLE PERIODS EXCEEDED MINTPL.'//)
      END
