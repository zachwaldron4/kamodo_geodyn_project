      SUBROUTINE DUMPCOL (ISTA,TQ0,MJDSBL,OBSTIM,RESID,PMPA,NM,NP,IPT,  &
     &                    KPT)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z), LOGICAL(L)
      DIMENSION PMPA(NP,NM),RESID(*),OBSTIM(NM)
      DO J=1,NM
         TQ=DBLE(MJDSBL)+OBSTIM(J)-TQ0
         WRITE(65,9987) ISTA,TQ,RESID(J),(PMPA(IPT+I-1,J),I=1,6),       &
     &                  (PMPA(KPT+I-1,J),I=1,6)
      END DO
      RETURN
 9987 FORMAT(1X,I10,14(1X,E22.15))
      END
