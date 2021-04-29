      SUBROUTINE TWELVE(C1,C2,CMID,CBASE,LBAS2S)
!SDOC*******************************************************************
!
!   PURPOSE:    CONVERT CARTESIAN COORDINATES OF TWO STATE VECTORS TO
!               CARTESIAN COORDINATES OF THE MID POINT AND THE BASELINE
!               VICE VERSA
!
!   ARGUMENTS:  C1     - CARTESIAN COORDINATES OF THE FIRST SATELLITE
!               C2     - CARTESIAN COORDINATES OF THE SECOND SATELLITE
!               CMID   - CARTESIAN COORDINATES OF THE MID POINT
!               CBASE  - CARTESIAN COORDINATES OF THE BASELLINE VECTOR
!               LBAS2S - TRUE IF WE ARE GOING FROM STATE COORDINATES TO
!                        BASELINE COORDINETES, OTHERWISE FALSE
!
!EDOC*******************************************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      DIMENSION C1(6),C2(6),CBASE(6),CMID(6)
      DATA TWO/2.D0/
      IF(LBAS2S) THEN

       DO I=1,6
       CBASE(I)=C2(I)-C1(I)
       CMID(I)=(C1(I)+C2(I))/TWO
       ENDDO

      ELSE

       DO I=1,6
       C1(I)=CMID(I)-CBASE(I)/TWO
       C2(I)=CBASE(I)+CMID(I)-CBASE(I)/TWO
       ENDDO

      ENDIF
      RETURN
      END
