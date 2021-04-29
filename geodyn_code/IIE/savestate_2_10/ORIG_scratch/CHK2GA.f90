

      SUBROUTINE CHK2GA(NEQN,NSTART,NADJC,NADJS)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!  CHECK TO MAKE SURE  THATADJUSTING COEFFICIENTS OF 2ND ASTEROID
!  FOLLOW CERTAINE RULES:
!    (1)  START AT DEGREE 2
!    (2)  ALL DEGREES AND ORDERS ADDJUST THROUGH FINAL ADDJUSUNG DEGREE
!
!   FIND STARTING LOCATION IN THE EXPLIT PARTIAL ARRAY FOR ADJUSTING
!   COEFFICIENTS OF 2ND ASTEROID
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
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
      DIMENSION IACPTC(5),IACPTS(5)
      DATA IACPTC/3,7,12,18,25/
      DATA IACPTS/2,5,9,14,20/
!
      DO I=1,5
       IPT=I
       IF(NPVAL0(IX2CCO).EQ.IACPTC(I)) GO TO 10
      ENDDO
      WRITE(6,6000)
      WRITE(6,6001)
      WRITE(6,6002) NPVAL0(IX2CCO)
      WRITE(6,6003) IACPTC
      STOP
  10  CONTINUE
      IF(IACPTS(IPT).NE.NPVAL0(IX2SCO)) THEN
        WRITE(6,6000)
        WRITE(6,6001)
        WRITE(6,6004) IACPTS(IPT)
        WRITE(6,6005) NPVAL0(IX2SCO)
      ENDIF
!
! NOW FIND FIND STARTING LOCATION IN THE EXPLIT PARTIAL ARRAY FOR ADJUSTING
!   COEFFICIENTS OF 2ND ASTEROID

!
      NSTART=1+NEQN-NPVAL0(IX2GM)-NPVAL0(IX2CCO)-NPVAL0(IX2SCO)
      NADJC=NPVAL0(IX2CCO)
      NADJS=NPVAL0(IX2SCO)
      RETURN
 6000 FORMAT(' EXECUTION TERMINATING IN CHK2GA')
 6001 FORMAT(' GEOPOTENTIAL OF 2ND ASTEROID IS ADJUSTING.')
 6002 FORMAT(' NUMBER OF C COEFS ADJUSTING FOR 2ND AST: ',I4)
 6003 FORMAT(' ACCEPTABLE VALUES: ',5I4)
 6004 FORMAT(' C COEFFICIENTS ADJUSTING THROUGH DEGREE: ',I4)
 6005 FORMAT(' DOES NOT MATCH NUMBER OF ADJUSTING S COEFFICENTS: ',I4)
      END
