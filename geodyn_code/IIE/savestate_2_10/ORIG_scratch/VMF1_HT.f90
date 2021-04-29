      SUBROUTINE VMF1_HT( AH, AW, DMJD, DLAT, HT, ZD, VMF1H, VMF1W )

!  - - - - - - - - -
!   V M F 1 _ H T
!  - - - - - - - - -

!  This routine is part of the International Earth Rotation and
!  Reference Systems Service (IERS) Conventions software collection.

!  This subroutine determines the Vienna Mapping Function 1 (VMF1)
!                                        (Boehm et al. 2006).

!     :------------------------------------------:
!     :                                          :
!     :                 IMPORTANT                :
!     :                                          :
!     :  This version uses height correction!    :
!     :  It has to be used with the VMF Grid     :
!     :  located at the website mentioned in     :
!     :  the Notes.                              :
!     :__________________________________________:

!  In general, Class 1, 2, and 3 models represent physical effects that
!  act on geodetic parameters while canonical models provide lower-level
!  representations or basic computations that are used by Class 1, 2, or
!  3 models.

!  Status: Class 1 model

!     Class 1 models are those recommended to be used a priori in the
!     reduction of raw space geodetic data in order to determine
!     geodetic parameter estimates.

!     Class 2 models are those that eliminate an observational
!     singularity and are purely conventional in nature.

!     Class 3 models are those that are not required as either Class
!     1 or 2.

!     Canonical models are accepted as is and cannot be classified as a
!     Class 1, 2, or 3 model.

!  Given:
!     AH             d      Hydrostatic coefficient a (Note 1)
!     AW             d      Wet coefficient         a (Note 1)
!     DMJD           d      Modified Julian Date
!     DLAT           d      Latitude given in radians (North Latitude)
!     HT             d      Ellipsoidal height given in meters
!     ZD             d      Zenith distance in radians

!  Returned:
!     VMF1H          d      Hydrostatic mapping function (Note 2)
!     VMF1W          d      Wet mapping function         (Note 2)

!  Notes:

!  1) The coefficients can be obtained from the primary website
!     http://ggosatm.hg.tuwien.ac.at/DELAY/ or the back-up website
!     http://www.hg.tuwien.ac.at/~ecmwf1/.

!  2) The mapping functions are dimensionless scale factors.

!  Test case:
!     given input: AH   = 0.00127683D0
!                  AW   = 0.00060955D0
!                  DMJD = 55055D0
!                  DLAT = 0.6708665767D0 radians (NRAO, Green Bank, WV)
!                  HT   = 824.17D0 meters
!                  ZD   = 1.278564131D0 radians

!     expected output: VMF1H = 3.423513691014495652D0
!                      VMF1W = 3.449100942061193553D0

!  References:

!     Boehm, J., Werl, B., and Schuh, H., (2006),
!     "Troposphere mapping functions for GPS and very long baseline
!     interferometry from European Centre for Medium-Range Weather
!     Forecasts operational analysis data," J. Geophy. Res., Vol. 111,
!     B02406, doi:10.1029/2005JB003629

!     Petit, G. and Luzum, B. (eds.), IERS Conventions (2010),
!     IERS Technical Note No. 36, BKG (2010)

!  Revisions:
!  2005 October 02 J. Boehm     Original code
!  2009 August 17 B.E. Stetzler Added header and copyright
!  2009 August 17 B.E. Stetzler More modifications and defined twopi
!  2009 August 17 B.E. Stetzler Provided test case
!  2009 August 17 B.E. Stetzler Capitalized all variables for FORTRAN 77
!                               compatibility
!  2010 September 08 B.E. Stetzler   Provided new primary website to obtain
!                                    VMF coefficients

!-----------------------------------------------------------------------

      IMPLICIT NONE

      double precision AH, AW, DMJD, DLAT, HT, ZD, VMF1H, VMF1W

      double precision DOY,  C11H, C10H, PHH, CH, SINE, BETA,     &
     &           GAMMA, TOPCON, &
     &           HS_KM, HT_CORR_COEF, HT_CORR

      double precision, PARAMETER :: PI  =3.1415926535897932384626433D0
      double precision, PARAMETER :: TWOPI=6.283185307179586476925287D0
      double precision, PARAMETER :: half_PI    = PI / 2.0D0

      double precision, parameter :: inv_day_per_year =  1.0D0/365.25D0

      double precision, parameter :: BH  = 0.0029D0
      double precision, parameter :: C0H = 0.062D0

      double precision, parameter :: A_HT = 2.53D-5
      double precision, parameter :: B_HT = 5.49D-3
      double precision, parameter :: C_HT = 1.14D-3

      double precision, parameter :: BW = 0.00146D0
      double precision, parameter :: CW = 0.04391D0


      double precision :: arg1


!--------------------------------------------------------------------------


!+-------------------------------------------------
!  Reference day is 28 January 1980
!  This is taken from Niell (1996) to be consistent
!--------------------------------------------------

!!The Julian date for 1980 January 28 00:00:00.0 UT is:
!  JD 2444266.500
! MJD = 44266.0

!!The Julian date for 1980 January  1 00:00:00.0 UT is:
!  JD 2444239.500
! MJD = 44239.0


! DOY is not day of year but days since the reference MJD 44239

!      write(6,*) "VMF1HT: DMJD is :", DMJD

      DOY = DMJD  - 44239.0D0 + REAL( 1 - 28 , kind=8 )

!      write(6,*) "VMF1HT: DOY is :", DOY

!write(6,'(/A,2(1x,F20.2)/)') 'vmf1ht: dmjd, doy ', dmjd, doy

!!BH  = 0.0029D0
!!C0H = 0.062D0

      if( DLAT < 0.0D0 ) then   ! southern hemisphere

      PHH  = PI
      C11H = 0.007D0
      C10H = 0.002D0

      else                    ! northern hemisphere

      PHH  = 0.0D0
      C11H = 0.005D0
      C10H = 0.001D0

      endif

!arg1 =  DOY/365.25D0 * TWOPI + PHH
      arg1 =  DOY * inv_day_per_year * TWOPI + PHH

!      write(6,*) "VMF1HT: arg1 is :", arg1

      CH = C0H + &
     &(  ( COS(arg1) + 1.0D0 ) * C11H / 2.0D0 + C10H   ) *      &
     &                                  ( 1.0D0 - COS(DLAT) )


!      write(6,*) "VMF1HT: CH is:", CH

!SINE    = SIN( PI / 2.0D0 - ZD )
      SINE    = SIN( half_PI - ZD )

      BETA    = BH / ( SINE + CH   )
      GAMMA   = AH / ( SINE + BETA )

!----------------------------------------------------
! below is from the USNO version of vmf1_ht
! BW should be BH and CW should be CH
! as in the tuwien version of vmf1_ht

! at this point, BW and CW are undefined in the original version

!TOPCON  = ( 1.0D0 + AW / &
!                    ( 1.0D0 + BW / &
!                             ( 1.0D0 + CW )  )  )
!----------------------------------------------------

! correct version ( in tuwien vmf1_ht )

      TOPCON  = ( 1.0D0 + AH / &
     &              ( 1.0D0 + BH / &
     &                       ( 1.0D0 + CH )  )  )

!----------------------------------------------------

      VMF1H   = TOPCON / ( SINE + GAMMA )



!  Compute the height correction (Niell, 1996)

!!A_HT = 2.53D-5
!!B_HT = 5.49D-3
!!C_HT = 1.14D-3

!HS_KM  = HT / 1000.0D0
      HS_KM  = HT * 1.0D-3

      BETA         = B_HT / ( SINE + C_HT )
      GAMMA        = A_HT / ( SINE + BETA )

      TOPCON       = ( 1.0D0 + A_HT / &
     &                   ( 1.0D0 + B_HT / &
     &                             ( 1.0D0 + C_HT) ) )

      HT_CORR_COEF = 1.0D0 / SINE - TOPCON / ( SINE + GAMMA )
      HT_CORR      = HT_CORR_COEF * HS_KM

      VMF1H        = VMF1H + HT_CORR

!!BW = 0.00146D0
!!CW = 0.04391D0

      BETA   = BW / ( SINE + CW   )
      GAMMA  = AW / ( SINE + BETA )

      TOPCON = ( 1.0D0 + AW / &
     &             ( 1.0D0 + BW / &
     &                       ( 1.0D0 + CW ) ) )

      VMF1W  = TOPCON / ( SINE + GAMMA )


!write(6,'(A,2(1x,E20.10)/)') 'vmf1ht: vmf1h, vmf1w ', vmf1h, vmf1w

! Finished.

      return

!+----------------------------------------------------------------------

!  Copyright (C) 2008
!  IERS Conventions Center

!  ==================================
!  IERS Conventions Software License
!  ==================================

!  NOTICE TO USER:

!  BY USING THIS SOFTWARE YOU ACCEPT THE FOLLOWING TERMS AND CONDITIONS
!  WHICH APPLY TO ITS USE.

!  1. The Software is provided by the IERS Conventions Center ("the
!     Center").

!  2. Permission is granted to anyone to use the Software for any
!     purpose, including commercial applications, free of charge,
!     subject to the conditions and restrictions listed below.

!  3. You (the user) may adapt the Software and its algorithms for your
!     own purposes and you may distribute the resulting "derived work"
!     to others, provided that the derived work complies with the
!     following requirements:

!     a) Your work shall be clearly identified so that it cannot be
!        mistaken for IERS Conventions software and that it has been
!        neither distributed by nor endorsed by the Center.

!     b) Your work (including source code) must contain descriptions of
!        how the derived work is based upon and/or differs from the
!        original Software.

!     c) The name(s) of all modified routine(s) that you distribute
!        shall be changed.

!     d) The origin of the IERS Conventions components of your derived
!        work must not be misrepresented; you must not claim that you
!        wrote the original Software.

!     e) The source code must be included for all routine(s) that you
!        distribute.  This notice must be reproduced intact in any
!        source distribution.

!  4. In any published work produced by the user and which includes
!     results achieved by using the Software, you shall acknowledge
!     that the Software was used in obtaining those results.

!  5. The Software is provided to the user "as is" and the Center makes
!     no warranty as to its use or performance.   The Center does not
!     and cannot warrant the performance or results which the user may
!     obtain by using the Software.  The Center makes no warranties,
!     express or implied, as to non-infringement of third party rights,
!     merchantability, or fitness for any particular purpose.  In no
!     event will the Center be liable to the user for any consequential,
!     incidental, or special damages, including any lost profits or lost
!     savings, even if a Center representative has been advised of such
!     damages, or for any claim by any third party.

!  Correspondence concerning IERS Conventions software should be
!  addressed as follows:

!                     Gerard Petit
!     Internet email: gpetit[at]bipm.org
!     Postal address: IERS Conventions Center
!                     Time, frequency and gravimetry section, BIPM
!                     Pavillon de Breteuil
!                     92312 Sevres  FRANCE

!     or

!                     Brian Luzum
!     Internet email: brian.luzum[at]usno.navy.mil
!     Postal address: IERS Conventions Center
!                     Earth Orientation Department
!                     3450 Massachusetts Ave, NW
!                     Washington, DC 20392


!-----------------------------------------------------------------------
       END SUBROUTINE VMF1_HT
