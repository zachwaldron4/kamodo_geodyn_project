!$RESPAR
      SUBROUTINE RESPAR(EXPART,GPNORM,ICPNT,ISPNT,ICPNTW,ISPNTW,        &
     &                  LTP,VRARAY,CORPAR,EXPRFL,                       &
     &                  WORK,NEQN,NSTART,NST,NADJCC,NADJSS,NC,NS,XM,    &
     &                  XNP1,P,COSLAM,SINLAM,AORN)
!********1*********2*********3*********4*********5*********6*********7**
! RESPAR           83/05/11            8305.0    PGMR - D. ROWLANDS
!
!   FUNCTION:  COMPUTE THE EXPLICIT PARTIALS OF ACCELERATION (IN
!              THE TRUE OF REFERENCE SYSTEM) WRT C&S COEFFCIENTS
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   EXPART   O    A    ARRAY OF EXPLICIT PARTIALS FILLED WITH C&S
!                      PARTIALS
!   GPNORM   I    A    FACTORS FOR NORMALIZING PARTIALS
!   ICPNT    I    A    POINTER TO ADJUSTED C COEFFCIENTS
!   ISPNT    I    A    POINTER TO ADJUSTED S COEFFCIENTS
!   VRARAY   I    A    ACCELERATIONS (IN RFL) DUE TO GEOPOTENTIAL,
!                      R,RSQ,XYSQ,RTXYSQ,GM/R (BODY FIXED)
!   CORPAR        A    TRANSFORMATION MATRIX FOR BODY FIXED R,PHI,LAMBDA
!   EXPRFL   I    A    EXPLICIT PARTIALS OF ACCELERATION (IN RFL)
!                      WRT C&S COEFFCIENTS;THE PARTIALS OF R ARE
!                      TOO LARGE BY A FACTOR OF R
!   WORK    I/O   A    MUST BE DIMENSIONED TO BE 3 TIMES THE
!                      MAX OF (#ADJ C'S,#ADJ S'S)
!   NEQN     I    S    NUMBER OF FORCE MODEL EQUATIONS
!   NSTART   I    I    STARTING LOCATION OF C&S COEFFCIENTS IN
!                      EXPART ARRAY (Could be time period in which case
!                      NST is needed)
!   NST      I    I    STARTING LOCATION OF C&S COEFFCIENTS IN
!                      EXPART ARRAY
!   NADJCC   I    S    NUMBER OF ADJUSTED C COEFFICIENTS
!   NADJSS   I    S    NUMBER OF ADJUSTED S COEFFICIENTS
!   XM       I    A    ARRAY OF PRECOMPUTED ORDERS TO MATCH C AND S
!                      ARRAYS
!   XNP1     I    A    ARRAY OF PRECOMPUTED DEGREES PLUS 1 TO MATCH C
!                      AND S ARRAYS
!   P        I    A    LEGENDRE POLYNOMIAL ARRAY
!   COSLAM   I    A    COSINE M*L ARRAY
!   SINLAM   I    A    SINE M*L ARRAY
!   AORN     I    A    (AE/R)**N ARRAY
!
! COMMENTS:
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      COMMON/CRMB/RMB(9), rmb0(9)
      COMMON/GEODEG/NMAX,NMAXP1,NP,NTOLD,NTOLO,NADJC,NADJS,NADJCS,      &
     &              NPMAX,NXGDEG
!
      DIMENSION EXPART(NEQN,3),ISPNT(1),ICPNT(1),VRARAY(8),CORPAR(9),   &
     &   ISPNTW(1),ICPNTW(1),                                           &
     &   EXPRFL(NP,6),WORK(NADJCS,3),GPNORM(1)
      DIMENSION BFRTTR(9)
      DIMENSION XM(NP),XNP1(NP),P(NP),COSLAM(NMAXP1),                   &
     &          SINLAM(NMAXP1),AORN(NMAX)
!
      DATA EPSP1/1.0001D0/,EPSM1/-.9999D0/
!
!
!**********************************************************************
!* START OF EXECUTABLE CODE *******************************************
!**********************************************************************
!
!   GET MATRIX TO GO FROM R,PSI,LAMDA TO TRUE OF REFERENCE
!
      BFRTTR(1)=RMB(1)*CORPAR(1)+RMB(2)*CORPAR(4)+RMB(3)*CORPAR(7)
      BFRTTR(2)=RMB(4)*CORPAR(1)+RMB(5)*CORPAR(4)+RMB(6)*CORPAR(7)
      BFRTTR(3)=RMB(7)*CORPAR(1)+RMB(8)*CORPAR(4)+RMB(9)*CORPAR(7)
      BFRTTR(4)=RMB(1)*CORPAR(2)+RMB(2)*CORPAR(5)+RMB(3)*CORPAR(8)
      BFRTTR(5)=RMB(4)*CORPAR(2)+RMB(5)*CORPAR(5)+RMB(6)*CORPAR(8)
      BFRTTR(6)=RMB(7)*CORPAR(2)+RMB(8)*CORPAR(5)+RMB(9)*CORPAR(8)
      BFRTTR(7)=RMB(1)*CORPAR(3)+RMB(2)*CORPAR(6)+RMB(3)*CORPAR(9)
      BFRTTR(8)=RMB(4)*CORPAR(3)+RMB(5)*CORPAR(6)+RMB(6)*CORPAR(9)
      BFRTTR(9)=RMB(7)*CORPAR(3)+RMB(8)*CORPAR(6)+RMB(9)*CORPAR(9)
!
!   DIVIDE FIRST COLUMN BY R TO ACCOUNT FOR THE FACT THAT
!   R PARTIALS ARE TOO LARGE BY R
!
      T1=BFRTTR(1)/VRARAY(4)
      T2=BFRTTR(2)/VRARAY(4)
      T3=BFRTTR(3)/VRARAY(4)
      LRET=.FALSE.
!
!   PUT PARTIALS WRT C INTO WORK
!
      IF(NADJCC.LE.0) GO TO 400
      N=NADJCC
      IPT=NSTART
      DO 300 I=1,NADJCC
      ICPX=ICPNT(I)
      IF(LTP)THEN
      DO 310 IJ=1,NC
      IF(ICPX.EQ.ICPNTW(IJ)) THEN
      I1=IJ
      IPTT=NST+I1-2
      EXPART(IPTT+I,1)=0.D0
      EXPART(IPTT+I,2)=0.D0
      EXPART(IPTT+I,3)=0.D0
      ENDIF
  310 END DO
      ENDIF
      XORDP1=XM(ICPX)+EPSP1
      IORDP1=XORDP1
      XDEG=XNP1(ICPX)+EPSM1
      IDEG=XDEG
      WORK(I,1)=-AORN(IDEG)*XNP1(ICPX)*COSLAM(IORDP1)*P(ICPX)
      WORK(I,2)=AORN(IDEG)*COSLAM(IORDP1)*EXPRFL(ICPX,2)
      WORK(I,3)=-AORN(IDEG)*XM(ICPX)*SINLAM(IORDP1)*P(ICPX)
  300 END DO
      GO TO 600
  400 CONTINUE
      LRET=.TRUE.
!
!   PUT PARTIALS WRT S INTO WORK
!
      IF(NADJSS.LE.0) GO TO 1000
      N=NADJSS
      IPT=NSTART+NADJCC
      DO 500 I=1,NADJSS
      ISPX=ISPNT(I)
      IF(LTP)THEN
      DO 510 IJ=1,NS
      IF(ISPX.EQ.ISPNTW(IJ)) THEN
      I1=IJ
      IPTT=NST+NC+I1-2
      EXPART(IPTT+I,1)=0.D0
      EXPART(IPTT+I,2)=0.D0
      EXPART(IPTT+I,3)=0.D0
      ENDIF
  510 END DO
      ENDIF
      XORDP1=XM(ISPX)+EPSP1
      IORDP1=XORDP1
      XDEG=XNP1(ISPX)+EPSM1
      IDEG=XDEG
      WORK(I,1)=-AORN(IDEG)*XNP1(ISPX)*SINLAM(IORDP1)*P(ISPX)
      WORK(I,2)=AORN(IDEG)*SINLAM(IORDP1)*EXPRFL(ISPX,2)
      WORK(I,3)=AORN(IDEG)*XM(ISPX)*COSLAM(IORDP1)*P(ISPX)
  500 END DO
  600 CONTINUE
!
!   TRANSFORM PARTIALS;  PUT INTO PROPER LOCATION
!
      IPTT=IPT-1
      DO 700 I=1,N
      EXPART(IPTT+I,1)=T1*WORK(I,1)+BFRTTR(4)*WORK(I,2)+BFRTTR(7)*      &
     &                 WORK(I,3)
  700 END DO
      DO 800 I=1,N
      EXPART(IPTT+I,2)=T2*WORK(I,1)+BFRTTR(5)*WORK(I,2)+BFRTTR(8)*      &
     &                 WORK(I,3)
  800 END DO
      DO 900 I=1,N
      EXPART(IPTT+I,3)=T3*WORK(I,1)+BFRTTR(6)*WORK(I,2)+BFRTTR(9)*      &
     &                 WORK(I,3)
!     iptt1=iptt+i
!     write(6,*)' dbg 800 ',iptt1,i,expart(iptt1,1),expart(iptt1,2),
!    .expart(iptt1,3)
  900 END DO
      IF(.NOT.LRET) GO TO 400
 1000 CONTINUE
      RETURN
      END
