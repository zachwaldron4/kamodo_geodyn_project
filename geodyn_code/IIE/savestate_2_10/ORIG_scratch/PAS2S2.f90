      SUBROUTINE PAS2S2(NM,NEQN,PXPF,PAPF)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      DIMENSION PXPF(NM,NEQN,3),PAPF(NM,NEQN,3)
      DO 200 J=1,NM
      DO 100 I=1,NEQN
      PXPF(J,I,1)=PAPF(J,I,1)
      PXPF(J,I,2)=PAPF(J,I,2)
      PXPF(J,I,3)=PAPF(J,I,3)
 100  CONTINUE
 200  CONTINUE
      RETURN
      END