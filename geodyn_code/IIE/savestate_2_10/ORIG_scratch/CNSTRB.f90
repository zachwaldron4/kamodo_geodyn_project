!$CONSTR
!********1*********2*********3*********4*********5*********6*********7**
! CONSTR           00/00/00            0000.0    PGMR - ?
!
!
! FUNCTION:  INITIALIZE THE COMMON BLOCK CONSTR
!
! COMMENTS:  TRIGONOMETRIC CONVERSION CONSTANTS
!
!********1*********2*********3*********4*********5*********6*********7**
       BLOCK DATA CNSTRB
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      COMMON/CONSTR/PI,TWOPI,DEGRAD,SECRAD,SECDAY
      DATA PI/3.141592653589793D0/
      DATA TWOPI/6.2831853071795864D0/
      DATA DEGRAD/1.7453292519943296D-2/
      DATA SECRAD/.4848136811095365D-5/
      DATA SECDAY/86400.D0/
      END
