!$SUMII
      SUBROUTINE SUMII (II,JJ,N)
!********1*********2*********3*********4*********5*********6*********7**
! SUMII            00/00/00            0000.0    PGMR - ?
!
!
! FUNCTION:
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   II      I/O   A
!   JJ
!   N
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      DIMENSION II(N),JJ(N)
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
      DO 1000 K=1,N
      II(K)=II(K)+JJ(K)
 1000 END DO
      RETURN
      END
