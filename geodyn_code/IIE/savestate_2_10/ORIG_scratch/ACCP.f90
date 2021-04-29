!$ACCP
      SUBROUTINE ACCP(NDIM,PARMVC,PRMLBL)
!********1*********2*********3*********4*********5*********6*********7**
!  ACCP            00/00/00         0000.0      PGMR - ?
!
! FUNCTION: DETERMINES IF ACCEL9 HAS ADJUSTED PARAMETERS. IF IT DOES
!           WRITE OUT ACCEL9 WITH ADJUSTED VALUES TO UNIT 7. IF IT DOES
!           NOT JUST WRITE OUT THE CARD WITH NO ADJUSTMENTS TO UNIT 7.
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   NDIM     I    S    ARRAY DIMENSIONS
!   PARMVC   I    A    CORRECTED PARAMETER VALUES ARRAY
!   PRMLBL   I    A    PARAMETER LABEL ARRAY
!
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**

      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      CHARACTER*80 CARD
      CHARACTER*24 WARN
      CHARACTER*13 B13
      CHARACTER*9 DIG
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
      DIMENSION PARMVC(NDIM)
      DIMENSION PRMLBL(3,NDIM)
      DATA DIG/'123456789'/
!
      DO 1 I=1,13
    1 B13(I:I)=' '
      BACKSPACE 14
      NA9=0
   10 CONTINUE
      READ(14,5000) CARD
      IF(CARD(1:6).NE.'ACCEL9') GO TO 500
!
! DETERMINE IF CARD BELONGS TO AN ADJUSTED PARAMETER
      IF(CARD(60:72).EQ.B13) GO TO 400
      DO 100 I=60,72
      IF(CARD(I:I).EQ.'E') GO TO 110
      IF(CARD(I:I).EQ.'D') GO TO 110
  100 END DO
      IE=72
      GO TO 120
  110 CONTINUE
      IE=I-1
  120 CONTINUE
      LSIG=.FALSE.
      DO 200 I=60,IE
      DO 190 J=1,9
      IF(CARD(I:I).EQ.DIG(J:J)) THEN
        LSIG=.TRUE.
        GO TO 200
      ENDIF
  190 END DO
  200 END DO
  210 CONTINUE
      IF(.NOT.LSIG) GO TO 400
      NA9=NA9+1
      IPT=IPVAL0(IXDRAG)+NA9-1
      JPT=NPVAL0(IXARC)-NPVAL0(IXBISA)
      IF(IPT.GT.JPT) GO TO 600
      XTEST=MOD(PRMLBL(1,IPT),1000000000.D0)
      ITEST=XTEST+.001D0
      ITEST=ITEST/100000000
      IF(ITEST.NE.8) GO TO 210
      VAL=PARMVC(IPT)
      WRITE(7,5001) CARD(1:24),VAL,CARD(45:80)
      GO TO 10
  400 CONTINUE
      WRITE(7,5000) CARD
      GO TO 10
  500 CONTINUE
      BACKSPACE 14
      RETURN
  600 CONTINUE
      BACKSPACE 14
      WARN='PROBLEM WITH ACCEL PUNCH'
      WRITE(7,5002) WARN
      RETURN
 5000 FORMAT(BZ,A80)
 5001 FORMAT(BZ,A24,D20.8,A36)
 5002 FORMAT(BZ,A24)
      END
