!$RESMAS
      SUBROUTINE RESMAS(EXPART,ICPNT,ISPNT,CM,SM,                       &
     &                  VRARAY,CORPAR,EXPRFL,NLOCAL,IPTRAU,             &
     &                  IMAPLG,NEQN,NSTART,NADJCC,NADJSS,XM,            &
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
      COMMON/NPCOM /NPNAME,NPVAL(92),NPVAL0(92),IPVAL(92),IPVAL0(92),   &
     &              MPVAL(28),MPVAL0(28),NXNPCM
      COMMON/NPCOMX/IXARC ,IXSATP,IXDRAG,IXSLRD,IXACCL,IXGPCA,IXGPSA,   &
     &              IXAREA,IXSPRF,IXDFRF,IXEMIS,IXTMPA,IXTMPC,IXTIMD,   &
     &              IXTIMF,IXTHTX,IXTHDR,IXOFFS,IXBISA,IXFAGM,IXFAFM,   &
     &              IXATUD,IXRSEP,IXACCB,IXDXYZ,IXGPSBW,IXCAME,IXBURN,  &
     &              IXGLBL,IXGPC ,IXGPS, IXTGPC,IXTGPS,IXGPCT,IXGPST,   &
     &              IXTIDE,IXETDE,IXOTDE,IXOTPC,IXOTPS,IXLOCG,IXKF  ,   &
     &              IXGM  ,IXSMA ,IXFLTP,IXFLTE,IXPLTP,IXPLTV,IXPMGM,   &
     &              IXPMJ2,IXVLIT,IXEPHC,IXEPHT,IXH2LV,IXL2LV,IXOLOD,   &
     &              IXPOLX,IXPOLY,IXUT1 ,IXPXDT,IXPYDT,IXUTDT,IXVLBI,   &
     &              IXVLBV,IXXTRO,IXBISG,IXSSTF,IXFGGM,IXFGFM,IXLNTM,   &
     &              IXLNTA,IX2CCO,IX2SCO,IX2GM ,IX2BDA,IXRELP,IXJ2SN,   &
     &              IXGMSN,IXPLNF,IXPSRF,IXANTD,IXTARG,                 &
     &              IXSTAP,IXSSTC,IXSSTS,IXSTAV,IXSTL2,                 &
     &              IXSTH2,IXDPSI,IXEPST,IXCOFF,IXTOTL,NXNPCX
!
      DIMENSION EXPART(NEQN,3),ISPNT(1),ICPNT(1),VRARAY(8),CORPAR(9),   &
     &   EXPRFL(NP,6),CM(NADJCC,NLOCAL),SM(NADJCC,NLOCAL)
      DIMENSION WORKC(11475,3),WORKS(11325,3)
      DIMENSION XM(NP),XNP1(NP),P(NP),COSLAM(NMAXP1),                   &
     &          SINLAM(NMAXP1),AORN(NMAX)
      DIMENSION IMAPLG(1),IPTRAU(1)
      DIMENSION BFRTTR(9)
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
!
!   PUT PARTIALS WRT C INTO WORK
!
      NAJC=0
      DO 100 I=1,NADJCC
      ICPX=ICPNT(I)
      XORDP1=XM(ICPX)+EPSP1
      IORDP1=XORDP1
      XDEG=XNP1(ICPX)+EPSM1
      IDEG=XDEG
      IF(IDEG.GT.NMAX) GO TO 110
      WORKC(I,1)=-AORN(IDEG)*XNP1(ICPNT(I))*COSLAM(IORDP1)*P(ICPNT(I))
      WORKC(I,2)=AORN(IDEG)*COSLAM(IORDP1)*EXPRFL(ICPNT(I),2)
      WORKC(I,3)=-AORN(IDEG)*XM(ICPNT(I))*SINLAM(IORDP1)*P(ICPNT(I))
      NAJC=NAJC+1
  100 END DO
  110 CONTINUE
      NAJS=0
      DO 200 I=1,NADJSS
      ISPX=ISPNT(I)
      XORDP1=XM(ISPX)+EPSP1
      IORDP1=XORDP1
      XDEG=XNP1(ISPX)+EPSM1
      IDEG=XDEG
      IF(IDEG.GT.NMAX) GO TO 210
      WORKS(I,1)=-AORN(IDEG)*XNP1(ISPNT(I))*SINLAM(IORDP1)*P(ISPNT(I))
      WORKS(I,2)=AORN(IDEG)*SINLAM(IORDP1)*EXPRFL(ISPNT(I),2)
      WORKS(I,3)=AORN(IDEG)*XM(ISPNT(I))*COSLAM(IORDP1)*P(ISPNT(I))
      NAJS=NAJS+1
  200 END DO
  210 CONTINUE
!
!
!
!
      DO 1000 IL=1,NLOCAL
      IQP=1+(IL-1)*NADJCC
      JQP=IMAPLG(IQP)
      IF(JQP.LE.0) GO TO 1000
      ILQ=IPTRAU(JQP)-IPVAL(IXLOCG)+1
      W1=0.D0
      W2=0.D0
      W3=0.D0
      DO 300 I=1,NAJC
      W1=W1+WORKC(I,1)*CM(I,ILQ)
      W2=W2+WORKC(I,2)*CM(I,ILQ)
      W3=W3+WORKC(I,3)*CM(I,ILQ)
  300 END DO
      DO 400 I=1,NAJS
      W1=W1+WORKS(I,1)*SM(I,ILQ)
      W2=W2+WORKS(I,2)*SM(I,ILQ)
      W3=W3+WORKS(I,3)*SM(I,ILQ)
  400 END DO
!
!   TRANSFORM PARTIALS;  PUT INTO PROPER LOCATION
!
      IPTT=NSTART+JQP-IPVAL0(IXLOCG)
      EXPART(IPTT,1)=T1*W1+BFRTTR(4)*W2+BFRTTR(7)*W3
      EXPART(IPTT,2)=T2*W1+BFRTTR(5)*W2+BFRTTR(8)*W3
      EXPART(IPTT,3)=T3*W1+BFRTTR(6)*W2+BFRTTR(9)*W3
 1000 END DO
      RETURN
      END