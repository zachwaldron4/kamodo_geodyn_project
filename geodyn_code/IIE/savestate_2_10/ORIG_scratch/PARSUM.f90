!$PARSUM
      SUBROUTINE PARSUM(NG,NL,AINV,AG,G,SUM2A,SUM2G)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      PARAMETER (MAXDIM=20000)
      DIMENSION AG(NG),G(1),SUM2G(NG)
      DIMENSION HOLD(MAXDIM)
!
      IF(NG.GT.MAXDIM) THEN
       WRITE(6,6000)
       WRITE(6,6001)
       WRITE(6,6002) NG
       WRITE(6,6003) MAXDIM
        STOP
      ENDIF
!
      SUM2A=SUM2A*AINV
      DO 100 I=1,NG
      HOLD(I)=AG(I)
      AG(I)=AG(I)*AINV
      SUM2G(I)=SUM2G(I)-HOLD(I)*SUM2A
  100 END DO
!
      IL=NG
      ISROW=0
      ISP=0
      DO 500 I=1,NG
      DO 200 II=1,IL
      G(ISROW+II)=G(ISROW+II)-AG(I)*HOLD(ISP+II)
  200 END DO
      ISROW=ISROW+NL+IL
      ISP=ISP+1
      IL=IL-1
  500 END DO
      RETURN
 6000 FORMAT(' EXECUTION TERMINATING IN PARSUM')
 6001 FORMAT(' NUMBER OF ARC PARAMETERS MINUS')
 6002 FORMAT(' AMBIGUITY PARAMETRS: ',I5)
 6003 FORMAT(' IS GREATER THAN ',I5)
      END