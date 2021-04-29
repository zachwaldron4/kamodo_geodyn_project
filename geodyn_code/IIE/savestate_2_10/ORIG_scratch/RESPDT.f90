!$RESPDT
      SUBROUTINE RESPDT(EXPART,VRARAY,CORPAR,EXPRFL,WORK,NEQN,NSTART,   &
     &              IPCDTA,IPSDTA,XM,XNP1,P,COSLAM,SINLAM,AORN)
!********1*********2*********3*********4*********5*********6*********7**
! RESPDT           83/05/11            8305.0    PGMR - D. ROWLANDS
!
! FUNCTION:  COMPUTE THE EXPLICIT PARTIALS OF ACCELERATION (IN
!            THE TRUE OF REFERENCE SYSTEM) WRT C&S COEFFCIENTS
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   EXPART   O    A    ARRAY OF EXPLICIT PARTIALS FILLED WITH C&S
!                      PARTIALS
!   VRARAY   I    A    ACCELERATIONS (IN RFL) DUE TO GEOPOTENTIAL,
!                      R,RSQ,XYSQ,RTXYSQ,GM/R (BODY FIXED)
!   CORPAR   I    A
!   EXPRFL   I    A    EXPLICIT PARTIALS OF ACCELERATION (IN RFL)
!                      WRT C&S COEFFCIENTS;THE PARTIALS OF R ARE
!                      TOO LARGE BY A FACTOR OF R
!   WORK    I/O   A    MUST BE DIMENSIONED TO BE 3 TIMES THE
!                      MAX OF (#ADJ C'S,#ADJ S'S)
!   NEQN     I    S    NUMBER OF FORCE MODEL EQUATIONS
!   NSTART   I    S    STARTING LOCATION OF C&S LINEAR TIME
!                      DEPENDENT COEFFICIENTS IN EXPART ARRAY
!                      (FORCE MODEL ADJUST ARRAY).
!   IPCDTA   I    A    POINTER ARRAY FROM ADJUSTED C DOT
!                      ARRAY TO THE C,S,P ARRAYS.
!   IPSDTA   I    A    POINTER ARRAY FROM ADJUSTED S DOT
!                      ARRAY TO THE C,S,P ARRAYS.
!   XM       I    A    ARRAY OF PRECOMPUTED ORDERS TO MATCH
!                      C AND S ARRAYS
!   XNP1     I    A    ARRAY OF PRECOMPUTED DEGREES PLUS 1
!                      TO MATCH C AND S ARRAYS
!   P        I    A    LEGENDRE POLYNOMIAL ARRAY
!   COSLAM   I    A    COS M*L ARRAY
!   SINLAM   I    A    SIN M*L ARRAY
!   AORN     I    A    (AE/R)**N ARRAY
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      COMMON/CGVTMI/NCDT,NSDT,NCPD,NSPD,NCDTA,NSDTA,NCPDA,NSPDA,NGRVTM, &
     &       KCDT,KCPDA,KCPDB,KSDT,KSPDA,KSPDB,KOMGC,KOMGS,KCOMGC,      &
     &       KSOMGC,KCOMGS,KSOMGS,NXGVTI
      COMMON/CGVTMR/EPGVTM,ELAPGT,XCGVTR
      COMMON/CRMB/RMB(9), rmb0(9)
      COMMON/GEODEG/NMAX,NMAXP1,NP,NTOLD,NTOLO,NADJC,NADJS,NADJCS,      &
     &              NPMAX,NXGDEG
!
      DIMENSION EXPART(NEQN,3),VRARAY(8),CORPAR(9),EXPRFL(NP,6),        &
     &          WORK(NADJCS,3),IPCDTA(1),IPSDTA(1)
      DIMENSION BFRTTR(9)
      DIMENSION XM(NP),XNP1(NP),P(NP),COSLAM(NMAXP1),                   &
     &          SINLAM(NMAXP1),AORN(NMAX)
!
      DATA EPSP1/1.0001D0/,EPSM1/-.9999D0/
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
      T11=BFRTTR(1)/VRARAY(4)
      T21=BFRTTR(2)/VRARAY(4)
      T31=BFRTTR(3)/VRARAY(4)
!
! GET THE COMMON FACTOR ELAPGT INTO TRANSFORMATION MATRIX
!
      T1=ELAPGT*T11
      T2=ELAPGT*T21
      T3=ELAPGT*T31
      T4=ELAPGT*BFRTTR(4)
      T5=ELAPGT*BFRTTR(5)
      T6=ELAPGT*BFRTTR(6)
      T7=ELAPGT*BFRTTR(7)
      T8=ELAPGT*BFRTTR(8)
      T9=ELAPGT*BFRTTR(9)
!
      LRET=.FALSE.
      IF(NCDTA.LE.0) GO TO 200
      LRET=.TRUE.
!
!   PUT PARTIALS WRT C TIME VARYING INTO WORK
!
      N=NCDTA
      IPT=NSTART
      DO 100 I=1,NCDTA
      ICPX=IPCDTA(I)
      XORDP1=XM(ICPX)+EPSP1
      IORDP1=XORDP1
      XDEG=XNP1(ICPX)+EPSM1
      IDEG=XDEG
      WORK(I,1)=-AORN(IDEG)*XNP1(ICPX)*COSLAM(IORDP1)*P(ICPX)
      WORK(I,2)=AORN(IDEG)*COSLAM(IORDP1)*EXPRFL(ICPX,2)
      WORK(I,3)=-AORN(IDEG)*XM(ICPX)*SINLAM(IORDP1)*P(ICPX)
  100 END DO
      GO TO 6000
  200 CONTINUE
      LRET=.FALSE.
!
!   PUT PARTIALS WRT S INTO WORK
!
      IF(NSDTA.LE.0) RETURN
      N=NSDTA
      IPT=NSTART+NCDTA+2*NCPDA
      DO 300 I=1,NSDTA
      ISPX=IPSDTA(I)
      XORDP1=XM(ISPX)+EPSP1
      IORDP1=XORDP1
      XDEG=XNP1(ISPX)+EPSM1
      IDEG=XDEG
      WORK(I,1)=-AORN(IDEG)*XNP1(ISPX)*SINLAM(IORDP1)*P(ISPX)
      WORK(I,2)=AORN(IDEG)*SINLAM(IORDP1)*EXPRFL(ISPX,2)
      WORK(I,3)=AORN(IDEG)*XM(ISPX)*COSLAM(IORDP1)*P(ISPX)
  300 END DO
 6000 CONTINUE
!
!   TRANSFORM PARTIALS;PUT INTO PROPER LOCATION
!
      IPTT=IPT-1
      DO 7000 I=1,N
      EXPART(IPTT+I,1)=T1*WORK(I,1)+T4*WORK(I,2)+T7*WORK(I,3)
 7000 END DO
      DO 8000 I=1,N
      EXPART(IPTT+I,2)=T2*WORK(I,1)+T5*WORK(I,2)+T8*WORK(I,3)
 8000 END DO
      DO 9000 I=1,N
      EXPART(IPTT+I,3)=T3*WORK(I,1)+T6*WORK(I,2)+T9*WORK(I,3)
 9000 END DO
      IF(LRET) GO TO 200
      RETURN
      END
