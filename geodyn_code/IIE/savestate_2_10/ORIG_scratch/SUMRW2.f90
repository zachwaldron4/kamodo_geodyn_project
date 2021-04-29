!$SUMRW2
      SUBROUTINE SUMRW2(PMPP,WT,NM,NP,ATPA,SCRTCH,                      &
     &                  ISROWS,NP1,INC,NUMIT,I1ROW,                     &
     &                  IL,ISROW,IOBS,IQPS,IQPSS,                       &
     &                  I,II)
!********1*********2*********3*********4*********5*********6*********7**
! SUMRW2                                         PGMR - TOM MARTI
!                                                PGMR - D.ROWLAND
!
! FUNCTION:  ACCUMULATE PARTIALS & RESIDUALS INTO THE
!            NORMAL MATRIX AND RIGHT HAND SIDE OF THE NORMAL EQ.
!            ON A SINGLE CALL, ONLY  A SUBSET OF ROWS IS SUMMED.
!            EVERY NTH ROW IS SUMMED. THIS ROUTINE IS INTENDED TO BE
!            CALLED SIMULTANEOUSLY BY MULTIPLE PROCESSORS. THIS ROUTTINE
!            IS CALL BY SMPRT3 TO SUM THE THE PARTITIONS OF THE NORMAL
!            MATRIX THAT DO NOT FIT IN MEMORY
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   PMPP     I   A     FULL ARRAY OF PARTIALS(INCLUDING ZEROS WHERE
!                      NECCESSARY) FOR EACH MEASUREMENT.
!   WT       I   A     MEASUREMENT WEIGHT ARRAY
!   NM       I   A     NUMBER OF MEASUREMENTS
!   NP       I   A     NUMPER OF PARAMETERS
!   ATPA     O   A     NORMAL MATRIX
!   SCRTCH   I   A     SCRATCH ARRAY
!   ISROWS   I   S     NUMBER OF ELEMENTS IN THE NORMAL MATRIX BEFORE
!                      THE STARTING ROW OF THIS CALL
!   NP1      I   S     LENGTH OF THE STARTING ROW OF THIS CALL
!   INC      I   S     N AS IN EVERY NTH ROW
!   NUMIT    I   S     NUMBER OF ROWS ACTUALLY BEING SUMMED
!   I1ROW    I   S     1ST ROW NUMBER ACTUALLY BEING SUMMED
!   IL       I   S     SEE COMMENTS
!   ISROW    I   S     SEE COMMENTS
!   IOBS     I   S     SEE COMMENTS
!   IQPS     I   S     SEE COMMENTS
!   IQPSS    I   S     SEE COMMENTS
!   I        I   S     SEE COMMENTS
!   II       I   S     SEE COMMENTS
!                      (BECAUSE THE PARTIAL IS 0) TO SAVE COMPUTATIONS
!
! COMMENTS:    EVERY VARIABLE USED IN THIS ROUTINE IS PASSED AS AN
!              ARGUMENT TO AVOID CONFLICTS DURING SIMULTANEOUS CALLS
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      COMMON/CGLBAR/LGDRAG,NXGLAR
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
      COMMON/CITERL/LSTGLB,LSTARC,LSTINR,LNADJ ,LITER1,LSTITR,          &
     &              LOBORB,LRESID,LFREEZ,LSAVEF,LHALT,LADJPI,LADJCI
      COMMON/EMAT  /EMTNUM,EMTPRT,EMTCNT,VMATRT,VMATS,VMATFR,FSCVMA,    &
     &              XEMAT
!
      DIMENSION PMPP(NP,NM),WT(NM),ATPA(1)
      DIMENSION SCRTCH(NP)
!
      DATA ZERO/0.0D0/
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
!
!
!
      IF(NUMIT.EQ.0) RETURN
!
!
      DO 1000 IOBS=1,NM
      IF(WT(IOBS).LE.ZERO) GO TO 1000
!     SCRATCH IS ATP (IN ATPA)
      DO 100 I=1,NP
      SCRTCH(I)=WT(IOBS)*PMPP(I,IOBS)
  100 END DO
      ISROW=ISROWS
      IQPS=I1ROW
      IQPSS=I1ROW-1
      IL=NP1
      DO 500 I=1,NUMIT
!!!!!!!!!!!!!!!!!!!!DIR$ IVDEP
      DO 200 II=1,IL
      ATPA(ISROW+II)=ATPA(ISROW+II)+SCRTCH(IQPS)*PMPP(IQPSS+II,IOBS)
  200 END DO
  201 CONTINUE
      ISROW=ISROW+INC*IL-INC*(INC-1)/2
      IL=IL-INC
      IQPS=IQPS+INC
      IQPSS=IQPSS+INC
  500 END DO
 1000 END DO
      RETURN
      END
