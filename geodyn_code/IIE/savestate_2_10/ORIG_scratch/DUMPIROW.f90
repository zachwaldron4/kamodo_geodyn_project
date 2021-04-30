      SUBROUTINE DUMPIROW (NM,RESID,PMPA,NDIM1,NDIM2,IPT,KPT)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z), LOGICAL(L)
      DIMENSION PMPA(NDIM1,NDIM2),RESID(*)
      IZER=0
      FZER=0.D0
      DO J=1,NM
         WRITE(66,9987) IZER,FZER,RESID(J),(PMPA(J,IPT+I-1),I=1,6),     &
     &                  (PMPA(J,KPT+I-1),I=1,6)
      END DO
      RETURN
 9987 FORMAT(1X,I10,14(1X,E22.15))
      END