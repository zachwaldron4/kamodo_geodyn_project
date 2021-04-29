      SUBROUTINE ODRSR1(AA,II,LL,NDIR)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!  ODRSR1
!
!  PURPOSE: COUNT THE # OF TRACKING DATA DIRECTORY RECORDS
!
!     AA    GEODYN's DYNAMIC  ARRAY FOR FLOATING POINTS
!     II    GEODYN's DYNAMIC  ARRAY FOR INTEGERS
!     LL    GEODYN's DYNAMIC  ARRAY FOR LOGICALS
!     NDIR  NUMBER OF TRACKING DATA DIRECTORY RECORDS (OUTPUT)
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
!
      DIMENSION AA(1),II(1),LL(1)
!
!
      NDIR=0
  10  CONTINUE
      CALL OBSDIR(AA,II,LL,LEOF)
      IF(LEOF) RETURN
      NDIR=NDIR+1
      GO TO 10
      END
