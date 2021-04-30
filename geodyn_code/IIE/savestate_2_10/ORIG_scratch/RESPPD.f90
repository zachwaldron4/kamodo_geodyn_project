!$RESPPD
      SUBROUTINE RESPPD(EXPART,VRARAY,CORPAR,EXPRFL,WORK,NEQN,NSTART,   &
     &              IPCPDA,IPSPDA,COSOMC,SINOMC,COSOMS,SINOMS,          &
     &              XM,XNP1,P,COSLAM,SINLAM,AORN)
!********1*********2*********3*********4*********5*********6*********7**
! RESPPD           83/05/11            8305.0    PGMR - D. ROWLANDS
!
! FUNCTION:  COMPUTE THE EXPLICIT PARTIALS OF ACCELERATION (IN
!            THE TRUE OF REFERENCE SYSTEM) WRT
!            TIME DEPENDENT PERIODIC C AND S COEFFCIENTS
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   EXPART   O    A    ARRAY OF EXPLICIT PARTIALS FILLED WITH C&S
!                      PARTIALS
!   VRARAY   I    A    ACCELERATIONS (IN RFL) DUE TO GEOPOTENTIAL,
!***                   R,RSQ,XYSQ,RTXYSQ,GM/R (BODY FIXED)
!   CORPAR   I    A    TRANSFORMATION ON MATRIX FOR BODY FIXED R, PHI,
!                      LAMBDA
!   EXPRFL   I    A    EXPLICIT PARTIALS OF ACCELERATION (IN RFL)
!                      WRT C&S COEFFCIENTS;THE PARTIALS OF R ARE
!                      TOO LARGE BY A FACTOR OF R
!   WORK    I/O   A    MUST BE DIMENSIONED TO BE 3 TIMES THE
!                      MAX OF (#ADJ C'S,#ADJ S'S)
!   NEQN     I    S    NUMBER OF FORCE MODEL EQUATIONS
!   NSTART   I    S    STARTING LOCATION OF C&S PERIODIC TIME
!                      DEPENDENT COEFFICIENTS IN THE EXPART ARRAY
!                      (FORCE MODEL ADJUST ARRAY)
!   IPCPDA   I    A    POINTER ARRAY FROM ADJUSTED C A PERIODIC
!                      ARRAY TO THE C,S,P ARRAYS.
!   IPSPDA   I    A    POINTER ARRAY FROM ADJUSTED S A PERIODIC
!                      ARRAY TO THE C,S,P ARRAYS.
!   COSOMC   I    A    ARRAY CONTAINING COSINES FOR THE C A
!                      COEFFICIENTS. THIS IS TIGHTLY PACKED
!                      WITH THE ADJUSTED COEEFICIENTS UP
!                      FRONT.
!   SINOMC   I    A    ARRAY CONTAINING SINES FOR THE C B
!                      COEFFICIENTS. THIS IS TIGHTLY PACKED
!                      WITH THE ADJUSTED COEEFICIENTS UP
!                      FRONT.
!   COSOMS   I    A    ARRAY CONTAINING COSINES FOR THE S A
!                      COEFFICIENTS. THIS IS TIGHTLY PACKED
!                      WITH THE ADJUSTED COEEFICIENTS UP
!                      FRONT.
!   SINOMS   I    A    ARRAY CONTAINING SINES FOR THE S B
!                      COEFFICIENTS. THIS IS TIGHTLY PACKED
!                      WITH THE ADJUSTED COEEFICIENTS UP
!                      FRONT.
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
     &          WORK(NADJCS,3),IPCPDA(1),IPSPDA(1),COSOMC(1),SINOMC(1), &
     &          COSOMS(1),SINOMS(1)
      DIMENSION BFRTTR(9)
      DIMENSION XM(NP),XNP1(NP),P(NP),COSLAM(NMAXP1),                   &
     &          SINLAM(NMAXP1),AORN(NMAX)
!
      DATA EPSP1/1.0001D0/,EPSM1/-.9999D0/
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
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
      IF(NCPDA.LE.0) GO TO 500
!
!   PUT PARTIALS WRT C INTO WORK
!
      N=NCPDA
      IPT=NSTART
      DO 100 I=1,NCPDA
      ICPX=IPCPDA(I)
      XORDP1=XM(ICPX)+EPSP1
      IORDP1=XORDP1
      XDEG=XNP1(ICPX)+EPSM1
      IDEG=XDEG
      WORK(I,1)=-AORN(IDEG)*XNP1(ICPX)*COSLAM(IORDP1)*P(ICPX)
      WORK(I,2)=AORN(IDEG)*COSLAM(IORDP1)*EXPRFL(ICPX,2)
      WORK(I,3)=-AORN(IDEG)*XM(ICPX)*SINLAM(IORDP1)*P(ICPX)
  100 END DO
!
!   TRANSFORM PARTIALS;PUT INTO PROPER LOCATION
!
      IPTT=IPT-1
      IPT2=IPTT+N
      DO 200 I=1,N
      EXPART(IPTT+I,1)=T1*WORK(I,1)+BFRTTR(4)*WORK(I,2)                 &
     &                +BFRTTR(7)*WORK(I,3)
      EXPART(IPT2+I,1)=EXPART(IPTT+I,1)*SINOMC(I)
      EXPART(IPTT+I,1)=EXPART(IPTT+I,1)*COSOMC(I)
  200 END DO
      DO 300 I=1,N
      EXPART(IPTT+I,2)=T2*WORK(I,1)+BFRTTR(5)*WORK(I,2)                 &
     &                +BFRTTR(8)*WORK(I,3)
      EXPART(IPT2+I,2)=EXPART(IPTT+I,2)*SINOMC(I)
      EXPART(IPTT+I,2)=EXPART(IPTT+I,2)*COSOMC(I)
  300 END DO
      DO 400 I=1,N
      EXPART(IPTT+I,3)=T3*WORK(I,1)+BFRTTR(6)*WORK(I,2)                 &
     &                +BFRTTR(9)*WORK(I,3)
      EXPART(IPT2+I,3)=EXPART(IPTT+I,3)*SINOMC(I)
      EXPART(IPTT+I,3)=EXPART(IPTT+I,3)*COSOMC(I)
  400 END DO
  500 CONTINUE
!
!   PUT PARTIALS WRT S INTO WORK
!
      IF(NSPDA.LE.0) RETURN
      N=NSPDA
      IPT=NSTART+2*NCPDA+NSDTA
      DO 600 I=1,NSPDA
      ISPX=IPSPDA(I)
      XORDP1=XM(ISPX)+EPSP1
      IORDP1=XORDP1
      XDEG=XNP1(ISPX)+EPSM1
      IDEG=XDEG
      WORK(I,1)=-AORN(IDEG)*XNP1(ISPX)*SINLAM(IORDP1)*P(ISPX)
      WORK(I,2)=AORN(IDEG)*SINLAM(IORDP1)*EXPRFL(ISPX,2)
      WORK(I,3)=AORN(IDEG)*XM(ISPX)*COSLAM(IORDP1)*P(ISPX)
  600 END DO
!
!   TRANSFORM PARTIALS;PUT INTO PROPER LOCATION
!
      IPTT=IPT-1
      IPT2=IPTT+N
      DO 700 I=1,N
      EXPART(IPTT+I,1)=T1*WORK(I,1)+BFRTTR(4)*WORK(I,2)                 &
     &                +BFRTTR(7)*WORK(I,3)
      EXPART(IPT2+I,1)=EXPART(IPTT+I,1)*SINOMS(I)
      EXPART(IPTT+I,1)=EXPART(IPTT+I,1)*COSOMS(I)
  700 END DO
      DO 800 I=1,N
      EXPART(IPTT+I,2)=T2*WORK(I,1)+BFRTTR(5)*WORK(I,2)                 &
     &                +BFRTTR(8)*WORK(I,3)
      EXPART(IPT2+I,2)=EXPART(IPTT+I,2)*SINOMS(I)
      EXPART(IPTT+I,2)=EXPART(IPTT+I,2)*COSOMS(I)
  800 END DO
      DO 900 I=1,N
      EXPART(IPTT+I,3)=T3*WORK(I,1)+BFRTTR(6)*WORK(I,2)                 &
     &                +BFRTTR(9)*WORK(I,3)
      EXPART(IPT2+I,3)=EXPART(IPTT+I,3)*SINOMS(I)
      EXPART(IPTT+I,3)=EXPART(IPTT+I,3)*COSOMS(I)
  900 END DO
      RETURN
      END