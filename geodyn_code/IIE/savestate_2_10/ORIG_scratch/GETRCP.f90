      SUBROUTINE GETRCP(NM,FREQO,FREQ,SF2,VLIGHT,RSCALX)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      DIMENSION FREQ(NM),RSCALX(NM)
!
      DO 100 I=1,NM
      RSCALX(I)=(FREQO+FREQ(I))*SF2/VLIGHT
  100 END DO
      RETURN
      END
