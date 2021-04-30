      SUBROUTINE RMPLOD(NRAMPS,NRR,HOLD,TIME1,TIME2,FRAMP,FDRAMP)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      DIMENSION HOLD(NRR,8),TIME1(NRAMPS),TIME2(NRAMPS)
      DIMENSION FRAMP(NRAMPS),FDRAMP(NRAMPS)
      DO 10 I=1,NRAMPS
      ILINE=1+(I-1)/2
      I12=MOD(I+1,2)*4
      TIME1(I)=HOLD(ILINE,1+I12)
      TIME2(I)=HOLD(ILINE,2+I12)
      FRAMP(I)=HOLD(ILINE,3+I12)
      FDRAMP(I)=HOLD(ILINE,4+I12)
   10 END DO
      RETURN
      END