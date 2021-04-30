!$NUTDAT
       BLOCK DATA NUTDAT
!********1*********2*********3*********4*********5*********6*********7
!                                               PGMR - S.LUO
!
! PARAMETERS
!   ALPHA = A0 + DA0 * T
!   DELTA = B0 + DB0 * T
!   VI    = V0 + DV0 * D
!
!   ALPHA : THE RIGHT ASCENSION OF MARS NORTH POLE IN ECI
!   DELTA : THE DECLILATION OF MARS NORTH POLE IN ECI
!   VI    : THE ANGLE ON MARS EQUATOR, MEASURED POSITIVE FROM IAU
!           VECTOR(MARS EQUATOR ASCENDING NODE ON ECI EQUATOR) TO
!           MARS MEAN AUTUMNAL EQUINOX OF J2000)
!   T     : TIME INTERVAL IN JULIAN CENTURY FROM J2000.0
!   D     : TIME INTERVAL IN DAY FROM J2000.0
!   T01    : JULIAN DAY OF J2000.0
!
!
! FUNCTION
!     INITIALIZE THE CONSTANS FOR THE CALCULATION OF THE POSITION
!     OF MARS NORTH POLE IN STANDARD REFERENCE FRAME (ECI)
!
! REFERENCE
!     L.BASS AND R.CESARONE,  MARS OBSERVER: PLANETARY CONSTANTS
!                 AND MODELS
!                        JPL D-3444(DRAFT) (NOVEMBER 1990)
!
!*********************************************************************
      IMPLICIT DOUBLE PRECISION    (A-H,O-Z), LOGICAL (L)
      SAVE
!
      COMMON/ASTRO /A0,DA0,B0,DB0,V0,DV0,T01
      DATA A0/317.681D0/,DA0/-0.108D0/,B0/52.886D0/,DB0/-0.061D0/
      DATA V0/37.65100887D0/,DV0/-0.27D-5/
      DATA T01/2451545.D0/
      END