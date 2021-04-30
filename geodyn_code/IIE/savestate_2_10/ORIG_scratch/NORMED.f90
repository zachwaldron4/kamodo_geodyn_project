!$NORMED
      SUBROUTINE NORMED(PXPK  ,DIAGNL,PMPA  ,RESID ,EDTSIG,OBSSIG,      &
     &    RATIO ,EDFLAG,IXPARM,LEDIT ,LEDIT1,LEDIT2,NM    ,ISAT  ,      &
     &    KNTBLK,SEGMNT,LAVOID)
!********1*********2*********3*********4*********5*********6*********7**
! NORMED           86/06/04            8606.0    PGMR - TOM MARTIN
!
! FUNCTION:  EDIT OBSERVATION BLOCK FOR NORMAL POINT PROCESSING.
!            FIT ENTIRE BLOCK TO ORBIT STATE PARAMETERS AND
!            ITERATE SOLUTION TO EDIT OUT BAD DATA POINTS.
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   PXPK     I    A    PARTIALS OF CARTESIAN ORBIT PARAMETERS
!                      W.R.T. KEPLERIAN ORBIT PARAMETERS.
!   DIAGNL   I    A    KEPLER ORBIT PARAMETER A PRIORI VARIANCES
!                      TO BE USED IN LEAST SQUARES ADJUSTMENT.
!   PMPA     I    A    PARTIALS OF MEASUREMENTS W.R.T. ADJUSTED
!                      PARAMETERS.
!   RESID    I    A    OBSERVATION RESIDUALS (O-C).
!   EDTSIG   I    A    OBSERVATION EDITING SIGMAS.
!   OBSSIG   I    A    OBSERVATION WEIGHTING SIGMAS.
!   RATIO    O    A    OBSERVATION FITTED RESIDUALS.
!   EDFLAG   O    A    ALPHANUMERIC FLAG INDICATING WHICH DATA
!                      HAVE BEEN EDITED.
!                      In this subroutine, EDFLAG is used to store the
!                      absolute value of the RATIO, but is restored
!                      to an alphanumeric flag in the 9600 loop
!   IXPARM   I    A    INDICES SPECIFYING ORDER IN WHICH ORBIT
!                      PARAMETERS ARE TO BE ELIMINATED TO
!                      PERMIT SOLUTION.
!   LEDIT   I/O   A    LOGICAL SWITCHES INDICATING WHICH POINTS
!                      HAVE BEEN PREVIOUSLY EDITED AS INPUT.
!                      LOGICAL SWITCHES INDICATING WHICH POINTS
!                      HAVE BEEN EDITED AS OUTPUT.
!   LEDIT1   O    A    LOGICAL SWITCHES USED TO MAINTAIN STATUS
!                      OF THE EDITING PROCESS.
!   LEDIT2   O    A    LOGICAL SWITCHES USED TO MAINTAIN STATUS
!                      OF THE EDITING PROCESS.
!   NM       I    S    NUMBER OF OBSERVATIONS IN DATA BLOCK.
!   ISAT     I    S    INDEX OF ORBIT ADJUSTMENT SATELLITE.
!   KNTBLK   I    S    OBSERVATION BLOCK COUNT.
!   SEGMNT   I    S    OBSERVATION BLOCK SEGMENT LABEL.
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      PARAMETER ( ZERO = 0.0D0 )
      PARAMETER ( ONE  = 1.0D0 )
!
      COMMON/CEDIT /EDITX ,EDTRMS,EDLEVL,CONVRG,GLBCNV,EBLEVL,EDITSW,   &
     &              ENPX  ,ENPRMS,ENPCNV,EDBOUN,FREEZI,FREEZG,FREEZA,   &
     &              XCEDIT
      COMMON/CESTML/LNPNM ,NXCSTL
      COMMON/CLNORM/LNRMGI,NXNORM
      COMMON/CNORML/LNORM ,LNORMP
      COMMON/COBGLO/MABIAS,MCBIAS,MPVECT,MINTPL,MPARAM,MSTA,MOBBUF,     &
     &       MNPITR,MWIDTH,MSIZE ,MPART ,MBUF  ,NXCOBG
      COMMON/CPMPA /KTMPAR(3)    ,KMBPAR(2)    ,KRFPAR(2)    ,          &
     &              KAEPAR,KFEPAR,KFPPAR,KVLPAR,KETPAR(2,2)  ,          &
     &              KPMPAR,KUTPAR,KSTPAR(3,4)  ,NADJST       ,          &
     &              NDIM1 ,NDIM2 ,NXDIM1,NXDIM2
      COMMON/CVIEW /IOUT6 ,ILINE6,IPAGE6,MLINE6,                        &
     &              IOUT8 ,ILINE8,IPAGE8,MLINE8,                        &
     &              IOUT9 ,ILINE9,IPAGE9,MLINE9,                        &
     &              IOUT10,ILIN10,IPAG10,MLIN10,                        &
     &              IOUT15,ILIN15,IPAG15,MLIN15,                        &
     &              IOUT16,ILIN16,IPAG16,MLIN16,                        &
     &              IOUT7 ,NXCVUE
!
      CHARACTER(8)      :: EDFLAG
      DIMENSION PMPA(NADJST,NM),RESID (NM),EDTSIG(NM),OBSSIG(NM),       &
     &    RATIO (NM),EDFLAG(NM),LEDIT (NM),LEDIT1(NM),LEDIT2(NM),       &
     &    PXPK (6,6),DIAGNL( 6),IXPARM( 6)
      DIMENSION    ATWA  (21),ATWR  ( 6),DELTAK( 6),WORK1(6,6),         &
     &  XPARTL( 6),XTWX  (21),XTWR  ( 6),DELTAX( 6),WORK2(6,6),         &
     &  LADJST( 6),DIFCOR( 6)
      DIMENSION DEIG(6),ZEIG(6,6),WKECP(27),WKAN(6,6),ATWAIN(6,6),      &
     &          DEIGIN(6)
      DIMENSION LAVOID(NM)
!
      DATA IZ/6/,JOBN/2/
!     DATA DIAGNL/1.0D2,1.0D-14,1.0D-12,1.0D-12,1.0D-12,1.0D-12/
!     DATA IXPARM/4,5,2,3,6,1/
      DATA MXPARM/6/,M1PARM/5/,MXSIZE/21/
      CHARACTER(1)      :: EDTFLG,BLANK
      DATA EDTFLG/'E'/
      DATA BLANK /' '/
!
!**********************************************************************
! START OF EXECUTABLE CODE ********************************************
!**********************************************************************
!
      NITER=MNPITR
      ITER=0
      LAST=.FALSE.
!     RMSPRV=EDTRMS ***ORIG***
      RMS=EDTRMS
!     IF(ENPRMS.GT.ZERO) RMSPRV=ENPRMS ***ORIG***
      IF(ENPRMS.GT.ZERO) RMS=ENPRMS
      EDITM =EDITX
      IF(ENPX  .GT.ZERO) EDITM =ENPX
      CNVERG=CONVRG
      IF(ENPCNV.GT.ZERO) CNVERG=ENPCNV
!     EDTLVL=EDITM *RMSPRV ***ORIG***
      EDTLVL=EDITM *RMS
!
! LOAD LEDIT2 FROM LEDIT SO THAT OBSERVATIONS EDITED FOR ELEVATION
!      CUTOFF, ETC. REMAIN EDITED
!      ....re-load LEDIT from LEDIT2 in 9600 loop at exit
!
      DO 1100 N=1,NM
      LEDIT2(N)=LEDIT(N)
 1100 END DO
!
! EDIT OBSERVATION RESIDUALS
!
      CALL RESEDT(EDTLVL,RESID,EDFLAG,EDTSIG,RATIO,LEDIT2,NM)
!
! CLEAR SUMMATION ARRAYS
      CALL CLEARA(XTWX,MXSIZE)
      CALL CLEARA(XTWR,MXPARM)
!
! CLEAR DIFFERENTIAL CORRECTION ARRAYS
      CALL CLEARA(DELTAX,MXPARM)
      CALL CLEARA(DELTAK,MXPARM)
!
! SET PARAMETER ADJUSTMENT FLAG
      NXPARM=0
      DO 1400 I=1,MXPARM
         LADJST(I)=DIAGNL(I).GT.ZERO
         IF(LADJST(I)) NXPARM=NXPARM+1
 1400 END DO
!
! FORM CARTESIAN NORMALS
      INDEX0=(ISAT-1)*MXPARM
      INDEX1=INDEX0+1
      INDEX2=INDEX0+MXPARM
      SUMRSQ=ZERO
      NWTD=0
!
      IF(.NOT.LNPNM) GO TO 2000
!
! PARTIALS DIMENSIONED NP X NM
!
      DO 1500 N=1,NM
         IF(LEDIT2(N)) GO TO 1500
         RATDIF=RESID(N)/EDTSIG(N)
         NWTD=NWTD+1
!........SUM THIS OBSERVATION EQUATION INTO LOCAL NORMALS
         WT=ONE/OBSSIG(N)**2
         CALL SUMBNP(PMPA(INDEX1,N),RESID(N),WT,MXPARM,MXPARM,XTWX,XTWR,&
     &               WORK1 )
         SUMRSQ=SUMRSQ+RATDIF**2
 1500 END DO
      GO TO 3000
!
! PARTIALS DIMENSIONED NM X NP
!
 2000 CONTINUE
!...COMPUTE OBSERVATION WEIGHTS
      DO 2500 N=1,NM
         WT=ZERO
         IF(LEDIT2(N)) GO TO 2200
         NWTD=NWTD+1
         WT=ONE/OBSSIG(N)**2
         RATDIF=RESID(N)/EDTSIG(N)
         SUMRSQ=SUMRSQ+RATDIF**2
 2200    CONTINUE
         RATIO(N)=WT
 2500 END DO
!
!.....SUM INTO NORMALS
      CALL SUMNM(PMPA(1,INDEX1),RESID,RATIO,MXPARM,MXPARM,NM,XTWX,XTWR, &
     &   EDFLAG,LAVOID)
 3000 CONTINUE
!
      IF(NWTD.LE.0) GO TO 9000
!
! COMPUTE NEW RMS
!     DENOM=MAX0(NWTD-NXPARM,1) *** ORIG ***
      DENOM=MAX(NWTD-NXPARM-1,1)
!****
      RMSPRV=RMS
!****
      RMS=SQRT(SUMRSQ/DENOM)
!
! CHECK FOR CONVERGENCE
      RMSCHK=CNVERG*RMS
      RMSDIF=ABS(RMSPRV-RMS)
      EDTLVL=EDITM *RMS
      ITER=ITER+1
      IF(RMSDIF.LE.RMSCHK) NITER=ITER
      LAST=ITER.GE.NITER
!
! TRANSFORM NORMAL MATRIX INTO KEPLER NORMALS: PXPKT * XTWX * PXPK
!
!...LOAD XTWX INTO SQUARE 6X6 MATRIX
      K=0
      DO 3200 I=1,M1PARM
         K=K+1
         WORK1(I,I)=XTWX(K)
         I1=I+1
         DO 3100 J=I1,MXPARM
            K=K+1
            WORK1 (J,I)=XTWX(K)
            WORK1 (I,J)=XTWX(K)
 3100    CONTINUE
 3200 END DO
      WORK1(MXPARM,MXPARM)=XTWX(MXSIZE)
!
!...MULTIPLY PXPKT * XTWX  &  PXPKT * XTWR
      DO 3500 I=1,MXPARM
         ATWR(I)=ZERO
         DO 3400 K=1,MXPARM
            WORK2(I,K)=ZERO
            DO 3300 J=1,MXPARM
               WORK2(I,K)=WORK2(I,K)+PXPK(J,I)*WORK1(J,K)
 3300       CONTINUE
            ATWR(I)=ATWR(I)+PXPK(K,I)*XTWR(K)
 3400    CONTINUE
 3500 END DO
!
!...MULTIPLY (PXPKT * XTWX) *  PXPK
      DO 3800 I=1,MXPARM
         DO 3700 K=1,MXPARM
            WORK1(I,K)=ZERO
            DO 3600 J=1,MXPARM
               WORK1(I,K)=WORK1(I,K)+WORK2(I,J)*PXPK(J,K)
 3600       CONTINUE
 3700    CONTINUE
 3800 END DO
!
      IF(NWTD.GE.NXPARM) GO TO 4000
!
! THERE ARE FEWER WEIGHTED OBSERVATIONS THAN ADJUSTED ORBIT PARAMETERS.
!       ELIMINATE PARAMETERS ACCORDING TO USER SUPPLIED PREFERENCE.
!
      DO 3900 I=1,MXPARM
         J=IXPARM(I)
         IF(.NOT.LADJST(J)) GO TO 3900
         LADJST(J)=.FALSE.
         NXPARM=NXPARM-1
         IF(NWTD.GE.NXPARM) GO TO 4000
 3900 END DO
      GO TO 9000
 4000 CONTINUE
!
      IF(LNRMGI) GO TO 4450
!
! ZERO OUT ROWS AND COLUMNS OF UNADJUSTED ORBIT ELEMENTS
      DO 4300 K=1,MXPARM
         IF(LADJST(K)) GO TO 4300
         DO 4100 I=1,MXPARM
            WORK1(I,K)=ZERO
 4100    CONTINUE
         DO 4200 J=1,MXPARM
            WORK1(K,J)=ZERO
 4200    CONTINUE
         ATWR(K)=ZERO
 4300 END DO
!
! SET UNADJUSTED DIAGONALS = TO ONE
! SET ADJUSTED DIAGONALS = ITSELF + (1/DIAGNL(M))
! SET ADJUSTED RIGHT HAND SIDE = ITSELF + DELTAK(M)/DIAGNL(M)
!
      DO 4400 M=1,MXPARM
         IF(LADJST(M)) GO TO 4350
         WORK1(M,M)=ONE
         GO TO 4400
 4350    CONTINUE
         WORK1(M,M) = WORK1(M,M) + 1/DIAGNL(M)
         ATWR(M) = ATWR(M) - DELTAK(M)/DIAGNL(M)
 4400 END DO
 4450 CONTINUE
!
!...LOAD ATWA FROM SQUARE 6X6 MATRIX
      K=0
      IF(LNRMGI) GO TO 4575
      DO 4500 I=1,MXPARM
         DO 4500 J=I,MXPARM
            K=K+1
            ATWA(K)=WORK1(I,J)
 4500 CONTINUE
      GO TO 4625
 4575 CONTINUE
      DO 4600 I=1,MXPARM
         DO 4600 J=1,I
            K=K+1
            ATWA(K)=WORK1(I,J)
 4600 CONTINUE
 4625 CONTINUE
!
      IF(LNRMGI) GO TO 4650
!
! INVERT NORMAL MATRIX
      CALL DSINV(ATWA  ,MXPARM,MXPARM,WORK1 )
!
! SOLVE FOR LOCAL ORBIT DIFFERENTIAL CORRECTIONS
      CALL SOLVE(ATWA  ,ATWR  ,MXPARM,MXPARM,DIFCOR)
!
      GO TO 4750
 4650 CONTINUE
!
! INVERT NORMAL MATRIX
      CALL PSEUDO(ATWA,DEIG,ZEIG,WKECP,MXPARM,IZ,JOBN,MXSIZE,WKAN,      &
     &            DEIGIN,ATWAIN)
!
! SOLVE FOR LOCAL ORBIT DIFFERENTIAL CORRECTIONS
      DO 4700 I=1,MXPARM
         DIFCOR(I)=ZERO
         DO 4700 J=1,MXPARM
            DIFCOR(I)=DIFCOR(I)+ATWAIN(I,J)*ATWR(J)
 4700 CONTINUE
 4750 CONTINUE
!
! UPDATE LOCAL ORBIT CORRECTION SUMS
      DO 4800 I=1,MXPARM
         DELTAK(I)=DELTAK(I)+DIFCOR(I)
 4800 END DO
!
! TRANSFORM ORBIT CORRECTION TO CARTESIAN
!
!...MULTIPLY PXPKT * DELTAK
      DO 5000 I=1,MXPARM
         PREVDX=DELTAX(I)
         DELTAX(I)=ZERO
         DO 4900 J=1,MXPARM
!           DELTAX(I)=DELTAX(I)+PXPK(J,I)*DELTAK(J) **** ORIG
!                                                (CHANGE HELPS)***
            DELTAX(I)=DELTAX(I)+PXPK(I,J)*DELTAK(J)
 4900    CONTINUE
         DIFCOR(I)=DELTAX(I)-PREVDX
 5000 END DO
!
      IF(LAST) GO TO 5600
!
! LINEARLY REMOVE DIFFERENTIAL CORRECTION FROM R.H.S.
      K0=0
      DO 5400 I=1,MXPARM
         DO 5100 J=I,MXPARM
            K=K0+J
            XTWR(I)=XTWR(I)-XTWX(K)*DIFCOR(J)
 5100    CONTINUE
         IF(I.LE.1) GO TO 5300
         I1=I-1
         K=I
         DO 5200 J=1,I1
            XTWR(I)=XTWR(I)-XTWX(K)*DIFCOR(J)
            K=K+MXPARM-J
 5200    CONTINUE
 5300    CONTINUE
         K0=K0+MXPARM-I
 5400 END DO
!
! SAVE FLAGS THAT INDICATE WHICH OBSERVATIONS PRESENTLY IN LOCAL NORMALS
!
      DO 5500 N=1,NM
         LEDIT1(N)=LEDIT2(N)
 5500 END DO
!
 5600 CONTINUE
!
! LOOP THRU EACH OBSERVATION RE-EDITING AND CORRECTING LOCAL NORMALS
      SUMRSQ=ZERO
      DO 7000 N=1,NM
         LEDIT2(N)=LEDIT(N)
         IF(LEDIT(N)) GO TO 7000
         RESDIF=RESID(N)
         IF(LNPNM) GO TO 6200
!
!........PARTIALS DIMENSIONED NM X NP
!........STORE PARTIALS INTO LOCAL ARRAY
         CALL PMPE(XPARTL,PMPA,NM,NADJST,N,INDEX1,INDEX2,LNPNM)
!........SUBTRACT PARTIALS*DIFFERENTIAL CORR. FROM RESIDUAL
         DO 6100 I=1,MXPARM
            RESDIF=RESDIF-DELTAX(I)*XPARTL(I)
 6100    CONTINUE
         GO TO 6400
!
!........PARTIALS DIMENSIONED NP X NM
 6200    CONTINUE
!........SUBTRACT PARTIALS*DIFFERENTIAL CORR. FROM RESIDUAL
         I=0
         DO 6300 J=INDEX1,INDEX2
            I=I+1
            RESDIF=RESDIF-DELTAX(I)*PMPA(J,N)
 6300    CONTINUE
!
!........COMPUTE RATIO TO EDITING SIGMA AND EDIT
 6400    CONTINUE
!
         IF(LAST) RATIO(N)=RESDIF
         RATDIF=RESDIF/EDTSIG(N)
         LNGOOD=ABS(RATDIF).GT.EDTLVL
         IF(LNGOOD) GO TO 6500
         SUMRSQ=SUMRSQ+RATDIF**2
         IF(.NOT.LEDIT1(N)) GO TO 7000
!
!........SUM THIS OBSERVATION EQUATION INTO LOCAL NORMALS
         LEDIT2(N)=.FALSE.
         NWTD=NWTD+1
         IF(LAST) GO TO 7000
         WT=ONE/OBSSIG(N)**2
         GO TO 6600
 6500    CONTINUE
!        **** MOVED FROM BELOW
         LEDIT2(N)=.TRUE.
!        **** MOVED FROM BELOW
         IF(LEDIT1(N)) GO TO 7000
!
!........SUBTRACT THIS OBSERVATION EQUATION FROM LOCAL NORMALS
!        LEDIT2(N)=.TRUE.    **** ORIG HERE *****
         NWTD=NWTD-1
         IF(LAST) GO TO 7000
         WT=-ONE/OBSSIG(N)**2
 6600    CONTINUE
         IF(     LNPNM) CALL SUMBNP(PMPA(INDEX1,N),RESDIF  ,WT,MXPARM,  &
     &                       MXPARM,XTWX,XTWR,WORK1 )
         IF(.NOT.LNPNM) CALL SUMBNP(XPARTL        ,RESDIF  ,WT,MXPARM,  &
     &                       MXPARM,XTWX,XTWR,WORK1 )
 7000 END DO
!
      IF(LAST) GO TO 9100
      GO TO 3000
!
! NO WEIGHTED OBSERVATIONS REMAIN
!
 9000 CONTINUE
      IF(.NOT.LNORMP) WRITE(IOUT6,90000) ITER,KNTBLK,SEGMNT,NM,EDTLVL
!
! FLAG EDITED DATA POINTS
!     ....restore edit flags saved in LEDIT2
!
 9100 CONTINUE
      DO 9600 N=1,NM
         LEDIT(N)=LEDIT2(N)
         EDFLAG(N)=BLANK
         IF(LEDIT2(N)) EDFLAG(N)=EDTFLG
 9600 END DO
      RETURN
!
90000 FORMAT(//' INSUFFICIENT WEIGHTED OBSERVATIONS REMAIN ',           &
     &   'AFTER NORMAL',                                                &
     &   ' POINT EDITING ITERATION ',I2/'0TOTAL NUMBER OF ',            &
     &   'OBSERVATIONS IN BLOCK ',I6,A1,' IS :',I6,'.   EDIT LEVEL =',  &
     &   G12.4/' ')
      END