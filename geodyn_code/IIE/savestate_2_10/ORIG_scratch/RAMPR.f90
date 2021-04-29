      SUBROUTINE RAMPR(OBSC,MJDSBL,TRINT,NDIMTR,MJDRMP,TRAMP,FRAMP,     &
     &                 FDRAMP,NRAMPS,FREQO,BIAS,VLIGHT,SF1,SF2,         &
     &                 DTIME,XINTS,XINTB,XINTS2,LAMB,LAMBV,AMBIG1,      &
     &                 AMBIG2,NM)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      COMMON/RESBIG/AMBIGR(1000)
      COMMON/IBODPT/IBDCF(999),IBDSF(999),IBDGM(999),IBDAE(999),    &
     &              IBDPF(999),                                     &
     &              ICBDCF,ICBDSF,ICBDGM,ICBDAE,ICBDPF,             &
     &              ITBDCF,ITBDSF,ITBDGM,ITBDAE,ITBDPF,NXBDPT
      DIMENSION XINTB(NM),XINTS(NM)
      DIMENSION OBSC(NM),TRINT(NDIMTR,2,2),DTIME(NM)
      DIMENSION TRAMP(1000,2),FRAMP(NRAMPS),FDRAMP(NRAMPS)
      DIMENSION AMBIG2(NM)
!
! LARGE CONSTANT PART OF INTEGRAL WITH PRECISE TDIF OVER ENTIRE SPAN
!
      DO 10 I=1,NM
      XINTB(I)=(TRINT(I,2,1)-TRINT(I,1,1))*FREQO*SF2
   10 END DO
!
! SMALLER PART OF INTEGRAL BASED ON RAMPS
!
      CALL RMPGRL(XINTS,MJDSBL,TRINT(1,1,1),TRINT(1,2,1),MJDRMP,TRAMP,  &
     &            FRAMP,FDRAMP,NRAMPS,NM)
!
      DO 20 I=1,NM
      XINTS(I)=XINTS(I)*SF2
   20 END DO
!
!
      DO 110 I=1,NM
      OBSC(I)=XINTB(I)+XINTS(I)
  110 END DO
!
!
      IF(.NOT.LAMB) RETURN
!
!
      IF(LAMBV) THEN
        DO 120 I=1,NM
        OBSC(I)=MOD(OBSC(I),2.D0*AMBIG2(I))
        IF(ICBDGM.NE.3) AMBIGR(I)=2.D0*AMBIG2(I)
  120   CONTINUE
      ELSE
        DO 130 I=1,NM
        OBSC(I)=MOD(OBSC(I),AMBIG1)
        IF(ICBDGM.NE.3) AMBIGR(I)=AMBIG1
  130   CONTINUE
      ENDIF
      RETURN
      END
