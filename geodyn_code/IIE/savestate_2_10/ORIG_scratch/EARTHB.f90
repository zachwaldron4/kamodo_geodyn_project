!$CEARTH
!********1*********2*********3*********4*********5*********6*********7**
! CEARTH           00/00/00            0000.0    PGMR - ?
!
!
! FUNCTION:  BLOCK DATA SUBROUTINE FOR COMMON CEARTH CONTAINING EARTH
!            RELATED CONSTANTS.
!
! COMMENTS:
!
!********1*********2*********3*********4*********5*********6*********7**
       BLOCK DATA EARTHB
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      COMMON/CEARTH/AEG,AEGSQ,FGINV,FG,EGSQ,EGSQP1,C1,C2,FOURC1,TWOC2,  &
     &              XH2,XL2,WREF,RMEAN,REFC20,REFC40,REFC60,BEG,CBLTC,  &
     &              WAE2,GAMMAA,FSTAR,F4
! 1978 IUGG ADOPTED REFERENCE ELLIPSOID
      DATA AEG/6378137.0D0/,FGINV/298.257D0/,WREF/.72921151D-4/
      END