!
!$ADJXYZ
      SUBROUTINE ADJXYZ(ISATNO,JSPACE,DELTA ,XYZPRV,SUM1  ,             &
     &    COVXYZ,COVELM,XYZCUR,CKEPLR,XYZAPR,CKEPNS,GMX   ,             &
     &    IEPYMD,IEPHM ,EPSEC ,RMSPOS)
!********1*********2*********3*********4*********5*********6*********7**
! ADJXYZ           85/02/14            0000.0    PGMR - BILL EDDY
!
!
! FUNCTION: PRINT ADJUSTED CARTESIAN SATELLITE ELEMENTS
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   ISATNO   I         SATELLITE NUMBER
!   JSPACE   I         COORDINATE SYSTEM THAT ELEMENTS ARE IN
!                      1-CART; 2-KEPLERIAN; 3- NON SING. KEP
!   DELTA    I         DIFFERENCES BETWEEN XYZCUR AND XYZPRV
!                      IF JSPACE=2
!   XYZPRV   I         PREVIOUS CARTESIAN ELEMENTS
!   SUM1     I         ATWA PART OF NORMAL MATRIX
!   COVXYZ   I         VARIANCE/COVARIANCE FOR CART.  COORDINATES
!   COVELM   I         VARAINCE/COVARIANCE FOR EITHER KEPLER OR
!                      NON-SINGULAR KEPLER COORDINATES(SEE ISPACE)
!   XYZCUR   I         CURRENT CARTESIAN ELEMENTS(IF JSPACE EQ 1)
!   CKEPLR   I         CURRENT KEPLERIAN ELEMENTS(IF JSPACE EQ 2)
!   XYZAPR   I         A PRIORI KEPLERIAN ELEMENTS
!   CKEPNS   I         CURRENT NON-SINGULAR KEPLERIAN ELEMENTS
!                      (IF JSPACE EQ 3)
!   GM       O
!   IEPYMD   O
!   IEPHM    O
!   EPSEC    O
!   RMSPOS   O
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      COMMON/CBDSTA/BDSTAT(7,999),XBDSTA
      COMMON/CESTIM/MPARM,MAPARM,MAXDIM,MAXFMG,ICLINK,IPROCS,NXCEST
      COMMON/CITER /NINNER,NARC,NGLOBL
      COMMON/CVIEW /IOUT6 ,ILINE6,IPAGE6,MLINE6,                        &
     &              IOUT8 ,ILINE8,IPAGE8,MLINE8,                        &
     &              IOUT9 ,ILINE9,IPAGE9,MLINE9,                        &
     &              IOUT10,ILIN10,IPAG10,MLIN10,                        &
     &              IOUT15,ILIN15,IPAG15,MLIN15,                        &
     &              IOUT16,ILIN16,IPAG16,MLIN16,                        &
     &              IOUT7 ,NXCVUE
      COMMON/LDUAL/LASTSN,LSTSNX,LSTSNY
!
      DIMENSION CKEPNS(6)
      DIMENSION COVXYZ(6,6),COVELM(6,6),COVSCR(6,6)
      DIMENSION DELTA(1)
      DIMENSION CKEPLR(6)
      DIMENSION PK(6,6)
      DIMENSION RMSPOS(2)
      DIMENSION SD(3),SDELM(6),SUM1(1)
      DIMENSION XYZCUR(6),XYZAPR(6),XYZPRV(6),XDIF(6)
!      DIMENSION XSAV(6)
!
      CHARACTER(8)      :: APRIOR, ADJUST, SD, PREV, ELMNTS, DEL
      CHARACTER(8)      :: CURENT, TOTAL

      DATA APRIOR/'A PRIORI'/
      DATA ADJUST/'ADJUSTED'/
      DATA SD    /'STANDARD','DEVIATIO' ,'N '  /
      DATA PREV  /'PREVIOUS'/
      DATA ELMNTS/'ELEMENTS'/
      DATA DEL   /'DELTA   '/
      DATA CURENT/' CURRENT'/
      DATA TOTAL /'   TOTAL'/

      INDXNO(M)=MAPARM*(M-1)-(M*(M-1))/2

!********1*********2*********3*********4*********5*********6*********7**
! START OF EXECUTABLE CODE
!********1*********2*********3*********4*********5*********6*********7**
      GM=GMX
      IF(LASTSN.AND.ISATNO.EQ.1) GM=BDSTAT(7,8)
      IF(JSPACE.EQ.1) GO TO 500
      IF(JSPACE.EQ.2) GO TO 300
! OBTAIN UPDATED CARTESIAN ELEMENTS FROM UPDATED NON SINGULAR KEPLERIAN
! ELEMENTS
      CALL PVNSK(XYZCUR,CKEPNS,1,GM)
      KEPTYP=10
      GO TO 320
!  KEPLERIAN SPACE
  300 CONTINUE
! OBTAIN UPDATED CARTESIAN ELEMENTS FROM UPDATED KEPLERIAN ELEMENTS
      CALL POSVEL(XYZCUR,CKEPLR,1,GM)
      KEPTYP=2
! OBTAIN PARTIALS NECESSARY FOR VARCOV TRANSFORMATION
  320 CALL ELEM(XYZCUR(1),XYZCUR(2),XYZCUR(3),XYZCUR(4),XYZCUR(5),      &
     &          XYZCUR(6),XDIF,KEPTYP,PK,GM)
      CALL DNVERT(6,PK,6,XDIF)
      CALL CLEARA(COVSCR,36)
      CALL CLEARA(COVXYZ,36)
!  FORM  PK*COVELM
      DO 350 I=1,6
      DO 350 K=1,6
      DO 350 J=1,6
      COVSCR(I,K)=PK(I,J)*COVELM(J,K)+COVSCR(I,K)
  350 CONTINUE
! FORM PK*COVELM*(PK TRANSPOSE)
      DO 370 I1=1,6
      DO 370 K1=1,6
      DO 370 J1=1,6
      COVXYZ(I1,K1)= COVSCR(I1,J1)*PK(K1,J1)+COVXYZ(I1,K1)
  370 CONTINUE
!  COMPUTE DIFFERENCE BETWEEN UPDATED AND PREVIOUS CARTESIAN ELEMENTS
      DO 390 I=1,6
  390 XDIF(I)=XYZCUR(I)-XYZPRV(I)
      GO TO 550
! CARTESIAN SPACE
  500 DO 510 I=1,6
  510 XDIF(I)=DELTA(I)
! STORE CARTESIAN VARCOV MATRIX IN PROPER LOCATION
      DO 530 I=1,6
      II =INDXNO(I+6*(ISATNO-1))
      DO 530 J=I,6
      JJ=J+6*(ISATNO-1)
      COVXYZ(I,J)=SUM1(II+JJ)
      COVXYZ(J,I)=SUM1(II+JJ)
  530 CONTINUE
!  CALCULATE RMS FOR POSITION AND VELOCITY AND TAKE SQRT OF DIAGONAL
!  ELEMENTS TO OBTAIN STANDARD DEVIATIONS
  550 RMSPOS(1)=0.0D0
      RMSPOS(2)=0.0D0
      DO 600 I=1,6
! CALCULATE ADJUSTED ELEMENTS - APRIORI ELEMENTS
! COVSCR(I,1),I=1,6 IS USED TO STORE ADJUSTED-APRIORI VALUE
      COVSCR(I,1)=XYZCUR(I)-XYZAPR(I)
      IF(COVXYZ(I,I).LT.0.0D0) WRITE(IOUT6,45000) I
      I3=1+(I-1)/3
      RMSPOS(I3)=RMSPOS(I3)+COVXYZ(I,I)
      SDELM(I)=SQRT(ABS(COVXYZ(I,I)))
  600 END DO
      RMSPOS(1)=SQRT(ABS(RMSPOS(1)))
      RMSPOS(2)=SQRT(ABS(RMSPOS(2)))
      IPAGE6=IPAGE6+1
      WRITE(IOUT6,10100) IPAGE6
      WRITE(IOUT6,10108) ISATNO,NARC,NINNER,NGLOBL,IEPYMD,IEPHM,EPSEC
      WRITE(IOUT6,10109) APRIOR,ELMNTS,XYZAPR
      WRITE(IOUT6,10109) PREV,ELMNTS,XYZPRV
      WRITE(IOUT6,10109) ADJUST,ELMNTS,XYZCUR
      WRITE(IOUT6,10109) TOTAL,DEL,(COVSCR(M,1),M=1,6)
      WRITE(IOUT6,10109) CURENT,DEL,XDIF
      WRITE(IOUT6,10111) SD,SDELM
      WRITE(IOUT6,10110) RMSPOS
!  COMPUTE AND PRINT CARTESIAN CORRELATIONS
      DO 620 KK=1,36
  620 COVSCR(KK,1)=COVXYZ(KK,1)
      CALL CORELM(1,COVSCR)
      IF(JSPACE.NE.1) GO TO 630
      WRITE(IOUT6,10303) ISATNO,NARC,XYZCUR
  630 RETURN
!630   IF(JBODY.EQ.0) GO TO 700
!      DO 640 I1=1,2
!      DO 640 I=1,3
!      J=I+(I1-1)*3
!640   XSAV(J)=XCENTR(I,I1)
!      CALL REFCOR(DSTART,.TRUE.,XCENTR(1,1))
!      CALL REFCOR(DSTART,.TRUE.,XCENTR(1,2))
!      DO 645 I1=1,2
!      DO 645 I=1,3
!      J=I+(I1-1)*3
!      PVCNTR(J)=XCENTR(I,I1)
!645   XCENTR(I,I1)=XSAV(J)
!      CALL EPHEM(DSTART,.FALSE.,.FALSE.,.FALSE.)
!      DO 650 J=1,6
!      PVCNTR(J)=PVCNTR(J)+XYZCUR(IREF+J)
!650   CONTINUE
!      WRITE(IOUT6,20303) (PVCNTR(J),J=1,6)
!700   RETURN
10100 FORMAT('1',40X,'CARTESIAN SATELLITE ELEMENTS',41X,                &
     & 'UNIT  6 PAGE NO.',I6)
10108 FORMAT('0',17X,'SATELLITE',I2,' ARC',I3,                          &
     &   ' RECTANGULAR COORDINATE SUMMARY FOR',                         &
     &   ' INNER ITERATION',I3,' OF GLOBAL ITERATION',I2/               &
     &   '0',22X,'EPOCH OF ELEMENTS - YEAR,MONTH,DAY ',I7,3X,           &
     &   'HOUR,MINUTE,SECOND',I5,F8.4/'0',36X,'X',15X,'Y',15X,'Z',      &
     &   13X,'XDOT',12X,'YDOT',12X,'ZDOT'/23X,3(13X,'(M)'),1X,3(11X,    &
     &   '(M/S)')/1X )
10109 FORMAT(8X,2(A8,1X),1X,3F19.4,3F16.7/1X )
!10109 FORMAT(8X,2(A8,1X),1X,3F16.4,3F16.7/1H )
10110 FORMAT('0'/35X,'RMS POSITION',F11.4,4X,'RMS VELOCITY',F11.6/1X )
10111 FORMAT(8X,A8,1X,A8,A2,3F16.4,3F16.7/1X )
10303 FORMAT('0',44X,'SATELLITE',I2,' CURRENT BEST ELEMENTS FOR ARC',   &
     &   I3/1X /44X,'X',25X,'Y',25X,'Z'/1X /30X,                        &
     &   3G24.16/1X /42X,'XDOT',22X,'YDOT',22X,'ZDOT'/1X /30X,3G24.16)
!0303 FORMAT('0'/51X,'CURRENT BEST GEOCENTRIC ELEMENTS'/1X /44X,'X',
!    .   23X,'Y',23X,'Z'/1X /30X,3G24.16/1X /42X,'XDOT',20X,'YDOT',20X,
!    .   'ZDOT'/1X /30X,3G24.16)
45000 FORMAT('0**********$ NEGATIVE ARGUMENT TO DSQRT FOR ELEMENT',     &
     &   I2,' $*********')
      END