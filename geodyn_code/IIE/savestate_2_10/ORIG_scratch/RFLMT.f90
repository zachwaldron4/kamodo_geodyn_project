!$RFLMT
      SUBROUTINE RFLMT(EXPART,XNP1,XM,XM2,XNNP1,COSLAM,SINLAM,TANPSI,   &
     &   C,S,P,VRARAY,AORN)
!********1*********2*********3*********4*********5*********6*********7**
! RFLMT            83/05/13            8305.0    PGMR - D. ROWLANDS
!
! FUNCTION:  COMPUTE SECOND ORDER PARTIALS C/S GEOPOTENTIAL
!            WRT R,PSI,LAMDA
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   EXPART   I    A    EXPLICIT PARTIALS OF ACCELERATION
!                      (IN R,PSI,LAMDA) WRT C&S;
!                      NOTE: EXPART IS DESTROYED BY THIS ROUTINE
!   XNP1     I    A    ARRAY CALCULATED BY GEODYNIIS.IT IS A
!                      VECTOR OF THE SAME LENGTH AS C&S
!                      CONTAINING DEGREE+1 IN EACH LOCATION
!   XM       I    A    ARRAY CALCULATED BY GEODYNIIS.IT IS A
!                      VECTOR OF THE SAME LENGTH AS C&S
!                      CONTAINING ORDER IN EACH LOCATION
!   XM2      I    A    ARRAY CALCULATED BY GEODYNIIS.IT IS A
!                      VECTOR OF LENGTH DEGREE+1 CONTAINING
!                      ORDER SQUARED IN EACH LOCATION
!   XNNP1    I    A    ARRAY CALCULATED BY GEODYNIIS.IT IS A
!                      VECTOR OF LENGTH DEGREE+1 CONTAINING
!                      (DEGREE)*(DEGREE+1) IN EACH LOCATION
!   COSLAM   I    A    ARRAY CONTAINING COS((ORDER-1)*LAMDA))
!   SINLAM   I    A    ARRAY CONTAINING SIN((ORDER-1)*LAMDA))
!   TANPSI   I    A    ARRAY CONTAINING M*TAN(PSI)
!   C        I    A    C GEOPOTENTIAL COEFFCIENTS
!   S        I    A    S GEOPOTENTIAL COEFFCIENTS
!   P        I    A    P LGENDRE POLYNOMIALS
!   VRARAY   I    A    ACCELERATIONS DUE TO GEOPOTENTIAL (IN
!                      R,PSI,LAMDA);R,RSQ,XYSQ,RTXYSQ (IN
!                      MEAN EARTH COORDINATES);GM/R
!   AORN     I    A    (AE/R)**N ARRAY
!
! COMMENTS:
!
!  OUTPUT NOTES         (1)INFORMATION FROM EXPART IS USED;THEN THE
!                          ARRAY IS USED AS WORKING SPACE.
!                       (2)SECOND ORDER PARTIALS ARE OUTPUT THROUGH
!                          COMMON BLOCK RFLMAT
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      COMMON/GEODEG/NMAX,NMAXP1,NP,NTOLD,NTOLO,NADJC,NADJS,NADJCS,      &
     &              NPMAX,NXGDEG
      COMMON/RFLMAT/RFLADR(3,3)
      DIMENSION EXPART(NP,6),XNP1(NP),XM(NP),XM2(NMAXP1),XNNP1(NMAX),   &
     &   COSLAM(NMAXP1),SINLAM(NMAXP1),TANPSI(NMAXP1),VRARAY(8),        &
     &   C(NP),S(NP),P(NP),AORN(NMAX)
      DATA ZERO/0.D0/,ONE/1.D0/,TWO/2.D0/
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
      SEC2=ONE+TANPSI(2)*TANPSI(2)
!
      IPTNP1=NTOLD*(NTOLD-1)/2+3*(NTOLD-1)+1
!  RFLADR(1,1)
      RFLADR(1,1)=ZERO
      DO 100 N=1,NTOLD
      RFLADR(1,1)=RFLADR(1,1)+(XM(IPTNP1+N)+TWO)*EXPART(N,4)
  100 END DO
!
!  RFLADR(1,2)
      RFLADR(1,2)=ZERO
      DO 200 N=1,NTOLD
      RFLADR(1,2)=RFLADR(1,2)+(XM(IPTNP1+N)+ONE)*EXPART(N,5)
  200 END DO
!
!  RFLADR(1,3)
      RFLADR(1,3)=ZERO
      DO 300 N=1,NTOLD
      RFLADR(1,3)=RFLADR(1,3)+(XM(IPTNP1+N)+ONE)*EXPART(N,6)
  300 END DO
!
!  RFLADR(2,3) & RFLADR(3,3)
      KRA1=0
      KNL=2
      RFLADR(2,3)=ZERO
      RFLADR(3,3)=ZERO
      DO 2000 N=1,NTOLD
      DEG23=ZERO
      DEG33=ZERO
      DO 1000 KR=1,KNL
      DEG23=DEG23+EXPART(KR+KRA1,2)*EXPART(KR+KRA1,3)
      DEG33=DEG33+EXPART(KR+KRA1,1)*XM2(KR)
 1000 END DO
      RFLADR(2,3)=RFLADR(2,3)+AORN(N)*DEG23
      RFLADR(3,3)=RFLADR(3,3)+AORN(N)*DEG33
      KRA1=KRA1+N+3
      KNL=KNL+1
 2000 END DO
!
!  RFLADR(2,2)
      RFLADR(2,2)=TANPSI(2)*VRARAY(2)+SEC2*RFLADR(3,3)
      DO 3000 N=1,NTOLD
      RFLADR(2,2)=RFLADR(2,2)+XM(IPTNP1+N)*EXPART(N,4)
 3000 END DO
      RFLADR(1,1)=(-RFLADR(1,1)+TWO*VRARAY(8))/VRARAY(5)
      RFLADR(1,2)=-RFLADR(1,2)/VRARAY(4)
      RFLADR(1,3)=-RFLADR(1,3)/VRARAY(4)
      RFLADR(3,3)=-RFLADR(3,3)
      RETURN
      END