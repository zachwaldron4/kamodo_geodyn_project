!$INIVLB
      SUBROUTINE INIVLB(PARMV,QUAINF)
!********1*********2*********3*********4*********5*********6*********7**
! INIVLB           90/12/26            0000.0    PGMR - LUCIA TSAOUSSI
!
! FUNCTION:        INITIALIZATION OF THE QUASAR INFORMATION ARRAY
!                  AND UPDATING AFTER EACH GLOBAL ITERATION
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS IN ALPHABETICAL ORDER
!   ------  ---  ---   ------------------------------------------------
!   PARMV    I    A    PARAMETER ARRAY / POINTER IPVAL(IXVLBI)
!   QUAINF   O    A    QUASAR INFORMATION ARRAY AS FOLLOWS:
!                      QUAINF(1)=ALPHANUMERIC NAME
!                      QUAINF(2)=INTEGER ID
!                      QUAINF(3)=RIGHT ASCENSION AS GIVEN IN QUAPOS CARD
!                      QUAINF(4)=DECLINATION AS GIVEN IN QUAPOS CARDS
!                      QUAINF(5)=SINE OF RIGHT ASCENSION
!                      QUAINF(6)=COSINE OF RIGHT ASCENSION
!                      QUAINF(7)=SINE OF DECLINATION
!                      QUAINF(8)=COSINE OF DECLINATION
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      DOUBLE PRECISION, DIMENSION(:), ALLOCATABLE :: ALPHA,DELTA_L
      CHARACTER*8, ALLOCATABLE :: QID(:)
      SAVE
!
      INCLUDE 'COMMON_DECL.inc'
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
      COMMON/VLBI/NQUA,NADJQ,NADJQV,NQUAB,IYMDV,NVOPT,NXVLBI
      DIMENSION QUAINF(12,NQUAB),PARMV(*)
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
      IF(NVSRC.EQ.1) THEN
      ALLOCATE(ALPHA(4000),DELTA_L(4000),QID(4000))
! THIS IS THE CASE WHERE THE SOURCE COORDINATES ARE READ FROM AN EXTERNAL
! FILE
      CALL SOUCOO(ALPHA,DELTA_L,QID,NBUF)
!     do J=1,NBUF
!     write(6,7777) ALPHA(J),DELTA_L(J),QID(J),J
!7777  format(2F20.10,2X,A8,I5)
!     enddo
      DO I=1,NQUAB
      CALL FNDCHR(QUAINF(1,I), QID, NBUF, IRET)
      IF(IRET.GT.0) THEN
!     write(6,*)' DBG ALPHA DELTA_L ', ALPHA(IRET),DELTA_L(IRET),IRET
      QUAINF(3,I)=ALPHA(IRET)
      QUAINF(4,I)=DELTA_L(IRET)
      ENDIF
      ENDDO
      WRITE(6,*)' HERE WE WILL READ THE SOURCE COORDINATES '
      WRITE(6,*)' FROM AN EXTERNAL FILE '

      DEALLOCATE (ALPHA,DELTA_L,QID)
      ENDIF
!  ************  START EXECUTABLE CODE  **********
      KPVLBI=IPVAL(IXVLBI)-1
      DO 50 I=1,NQUAB
      IF(NVSRC.EQ.1) GOTO 100
      RASCIN= QUAINF(3,I)
      DECLIN= QUAINF(4,I)
      CALL RADOUT(RASCIN,RASCOT,2)
      CALL RADOUT(DECLIN,DECOUT,1)
      QUAINF(3,I)=RASCOT
      QUAINF(4,I)=DECOUT
!     write(6,*)' dbg COORDINATES FROM QUAINF ',RASCOT,DECOUT,I
100   CONTINUE
      QUAINF(5,I)=SIN(QUAINF(3,I))
      QUAINF(6,I)=COS(QUAINF(3,I))
      QUAINF(7,I)=SIN(QUAINF(4,I))
      QUAINF(8,I)=COS(QUAINF(4,I))
!     QUAINF(5,I)=DSIN(RASCOT)
!     QUAINF(6,I)=DCOS(RASCOT)
!     QUAINF(7,I)=DSIN(DECOUT)
!     QUAINF(8,I)=DCOS(DECOUT)
!     QUAINF(5,I)=DSIN(PARMV(KPVLBI+(2*I-1)))
!     QUAINF(6,I)=DCOS(PARMV(KPVLBI+(2*I-1)))
!     QUAINF(7,I)=DSIN(PARMV(KPVLBI+2*I))
!     QUAINF(8,I)=DCOS(PARMV(KPVLBI+2*I))
!LT   WRITE(6,*) I,(QUAINF(J,I),J=1,12)
   50 END DO
      RETURN
      END