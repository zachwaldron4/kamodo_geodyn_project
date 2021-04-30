!$ADJKEP
      SUBROUTINE ADJKEP(ISATNO,JSPACE,DELTA ,PKEPLR,SUM1  ,COVXYZ,      &
     &                  COVKEP,XYZCUR,CKEPLR,AKEPLR,GMX   ,IEPYMD,      &
     &                  IEPHM ,EPSEC )
!********1*********2*********3*********4*********5*********6*********7**
! ADJKEP           85/01/12            0000.0    PGMR - BILL EDDY
!
!
! FUNCTION: PRINT ADJUSTED KEPLERIAN SATELLITE ELEMENTS
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   ISATNO   I         SATELLITE NUMBER
!   JSPACE   I         COORDINATE SYSTEM THAT ELEMENTS ARE IN
!                      1-CART; 2-KEPLERIAN; 3- NON SING. KEP
!   DELTA    I         DIFFERENCES BETWEEN CKEPLR AND PKEPLR
!                      IF JSPACE=2
!   PKEPLR   I         PREVIOUS KEPLERIAN ELEMENTS
!   SUM1     I         ATWA PART OF NORMAL MATRIX
!   COVXYZ   I         VARIANCE/COVARIANCE FOR CART.  COORDINATES
!   COVKEP   I         VARAINCE/COVARIANCE FOR KEPLER COORDINATES
!   XYZCUR   I         CURRENT CARTESIAN ELEMENTS(IF JSPACE NE 2)
!   CKEPLR   I         CURRENT KEPLERIAN ELEMENTS(IF JSPACE EQ 2)
!   AKEPLR   I         A PRIORI KEPLERIAN ELEMENTS
!   GM       I         GRAVITATIONAL CONSTANT * MASS OF EARTH
!   IEPYMD
!   IEPHM
!   EPSEC
!
! COMMENTS:
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      CHARACTER(8)      ::  APRIOR
      CHARACTER(8)      ::  ADJUST
      CHARACTER(8)      ::  SD
      CHARACTER(8)      ::  PREV
      CHARACTER(8)      ::  ELMNTS
      CHARACTER(8)      ::  DEL
      CHARACTER(8)      ::  CURENT
      CHARACTER(8)      ::  TOTAL

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
      COMMON/IBODPT/IBDCF(999),IBDSF(999),IBDGM(999),IBDAE(999),    &
     &              IBDPF(999),                                     &
     &              ICBDCF,ICBDSF,ICBDGM,ICBDAE,ICBDPF,             &
     &              ITBDCF,ITBDSF,ITBDGM,ITBDAE,ITBDPF,NXBDPT
      COMMON/LDUAL/LASTSN,LSTSNX,LSTSNY
      COMMON/UNITS/IUNT11,IUNT12,IUNT13,IUNT19,IUNT30,IUNT71,IUNT72,    &
     &             IUNT73,IUNT05,IUNT14,IUNT65,IUNT88,IUNT21,IUNT22,    &
     &             IUNT23,IUNT24,IUNT25,IUNT26
!
      DIMENSION ADJAPR(6)
      DIMENSION COVXYZ(6,6),COVKEP(6,6),COVSCR(6,6)
      DIMENSION DELTA(1)
      DIMENSION AKEPLR(6),PKEPLR(6),CKEPLR(6)
      DIMENSION ORBDIF(6),PK(6,6)
      DIMENSION SD(3),SDELM(6),SUM1(1)
      DIMENSION XYZCUR(6)
!
      EQUIVALENCE(ORBDIF(1),COVSCR(1,1)),(ADJAPR(1),COVSCR(1,2))
!
      DATA APRIOR/'A PRIORI'/
      DATA ADJUST/'ADJUSTED'/
      DATA SD    /'STANDARD','DEVIATIO ','N '  /
                                ! jjm 8/98
      DATA PREV  /'PREVIOUS'/
!      DATA PREV  /'PREVIOUS/   ! original
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
      IF(JSPACE.EQ.2) GO TO 500
!  OBTAIN UPDATED KEPLERIAN ELEMENTS FROM UPDATED CARTESIAN ELEMENTS
      CALL ELEM (XYZCUR(1),XYZCUR(2),XYZCUR(3),XYZCUR(4),XYZCUR(5),     &
     &           XYZCUR(6),CKEPLR,2,PK,GM)
!  TRANSFORM VARCOV TO KEPLERIAN SPACE
      CALL CLEARA(COVKEP,36)
      CALL CLEARA(COVSCR,36)
! FORM PK*COVXYZ
      DO 350 I=1,6
      DO 350 K=1,6
      DO 350 J=1,6
      COVSCR(I,K)=PK(I,J)*COVXYZ(J,K)+COVSCR(I,K)
  350 CONTINUE
!  FORM PK*COVXYZ*(PK TRANSPOSE)
      DO 370 I=1,6
      DO 370 K=1,6
      DO 370 J=1,6
      COVKEP(I,K)=COVSCR(I,J)*PK(K,J)+COVKEP(I,K)
  370 CONTINUE
!  COMPUTE DIFFERENCE BETWEEN UPDATED AND PREVIOUS ELEMENTS
      DO 320 N=1,6
  320 ORBDIF(N)=CKEPLR(N)-PKEPLR(N)
      GO TO 550
!  KEPLERIAN SPACE
  500 DO 510 I=1,6
  510 ORBDIF(I)=DELTA(I)
!  STORE KEPLERIAN VARCOV MATRIX IN PROPER LOCATION
      DO 530 I=1,6
      II=INDXNO(I+6*(ISATNO-1))
      DO 530 J=I,6
      JJ=J+6*(ISATNO-1)
      COVKEP(I,J)=SUM1(II+JJ)
      COVKEP(J,I)=SUM1(II+JJ)
  530 CONTINUE
!  TAKE SQRT OF DIAGONAL ELEMENTS TO OBTAIN STANDARD DEVIATIONS
  550 DO 600 I=1,6
! CALCULATE ADJUSTED ELEMENTS - APRIORI ELEMENTS
      ADJAPR(I)=CKEPLR(I)-AKEPLR(I)
      IF(COVKEP(I,I).LT.0.0D0) WRITE(IOUT6,81004) I,COVKEP(I,I)
      IF(COVKEP(I,I).LT.0.0D0) WRITE(IUNT88,81004) I,COVKEP(I,I)
      SDELM(I)=SQRT(ABS(COVKEP(I,I)))
  600 END DO
      IPAGE6=IPAGE6+1
      WRITE(IOUT6,81200) IPAGE6
      WRITE(IOUT6,81000) ISATNO,NARC,NINNER,NGLOBL,IEPYMD,IEPHM,EPSEC
      WRITE(IOUT6,81001) APRIOR,ELMNTS, AKEPLR
      WRITE(IOUT6,81001)   PREV,ELMNTS, PKEPLR
      WRITE(IOUT6,81001) ADJUST,ELMNTS, CKEPLR
      WRITE(IOUT6,81001) TOTAL,DEL,ADJAPR
      WRITE(IOUT6,81001) CURENT,DEL,ORBDIF
      WRITE(IOUT6,81005) SD,SDELM
!  COMPUTE AND PRINT KEPLER CORRELATIONS
      DO 620 KK=1,36
  620 COVSCR(KK,1)=COVKEP(KK,1)
      CALL CORELM(2,COVSCR)
! IF INTERPLANETARY, GET ELVATION OF TRACKING BODY FROM ORBIT PLANE
      IF(ICBDGM.EQ.11) GO TO 625
      IF(ICBDGM.NE.ITBDGM.AND.JSPACE.NE.2) CALL PLANPR(PKEPLR)
625   CONTINUE
      IF(JSPACE.NE.2) RETURN
      WRITE(IOUT6,81002) ISATNO,NARC, CKEPLR
! IF INTERPLANETARY, GET ELVATION OF TRACKING BODY FROM ORBIT PLANE
      IF(ICBDGM.EQ.11) GO TO 630
      IF(ICBDGM.NE.ITBDGM) CALL PLANPR(PKEPLR)
630   CONTINUE
      RETURN
81000 FORMAT('0',17X,'SATELLITE',I2, ' ARC', I3,                        &
     & ' KEPLERIAN COORDINATE SUMMARY FOR ',                            &
     & ' INNER ITERATION ',I3, ' OF GLOBAL ITERATION',                  &
     & I2/ '0',22X ,'EPOCH OF ELEMENTS - YEAR,MONTH,DAY',I7,3X,         &
     & 'HOUR,MINUTE,SECOND ', I5,F8.4/'0',36X,'A', 14X,'E',15X,'I',10X, &
     & 'RA ASC NODE ',6X, 'ARG PERIGEE ',3X, 'MEAN ANOMALY  '/34X,      &
     & '(METERS)',15X,2(7X,'(DEGREES)'),2X,2(6X,'(DEGREES)')/' ')
81001 FORMAT(' ',7X,2(A8,1X),F17.4,F16.12,4F16.9/' ')
81002 FORMAT('0',44X,'SATELLITE',I2,' CURRENT BEST ELEMENTS FOR ARC ',  &
     &   I3/' '/42X,'A',23X,'E', 23X, 'I'/' '/30X,3D24.16/' '/37X,      &
     &   'RA ASC NODE ',13X,'ARG PERIGEE ',12X,'MEAN ANOMALY '/' '/     &
     &   30X,3D24.16)
81004 FORMAT(                                                           &
     & '0********* $ NEGATIVE ARGUMENT TO DSQRT FOR KEPLERIAN ELEMENT', &
     & I2,' = ', D24.16,' $*********')
81005 FORMAT(' ',7X,A8,1X,A8,A2,F16.4,F16.12,4F16.9/' ')
81200 FORMAT('1',40X,'KEPLERIAN SATELLITE ELEMENTS',41X,                &
     & 'UNIT  6 PAGE NO.',I6)
      END