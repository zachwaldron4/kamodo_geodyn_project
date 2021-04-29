!$UNFRD
      SUBROUTINE UNFRD(IUNT,IARRAY,ISIZE,LINT)
!********1*********2*********3*********4*********5*********6*********7**
! UNFRD            00/00/00            0000.0    PGMR - SBL
!
!
! FUNCTION:  READ VARIABLE LENGTH SINGLE WORD BINARY RECORDS
!            FROM A SPECIFIED UNIT
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   IUNT     I         UNIT NUMBER TO READ FROM
!   IARRAY   I         ARRAY TO BE READ IN TO
!   ISIZE    I         NUMBER OF WORDS TO BE READ
!   LINT     I         IF .TRUE. THEN THIS CALL IS FOR INTEGERS
!                      IF .FALSE. THEN THIS CALL IS FOR LOGICALS
!
! COMMENTS:
!                  THIS ROUTINE DIFFERS FROM BINRD IN THAT NO TEST
!                  IS MADE FOR ZERO LENGTH RECORDS AND NO DUMMY RECORD
!                  IS READ FOR ZERO LENGTH RECORDS.
! RESTRICTIONS:
!                  ISIZE MUST BE GREATER THAN 0.
!              **  THIS ROUTINE SHOULD ONLY BE USED FOR THE INTERFACE
!                  AND DATA FILES.
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      COMMON/CORE2S/KORE2S(3,2),KSCL2S(3),NGRP2S,MACH2S,KCOM2S,MAXC2E,  &
     &              NXCORS
!
      DIMENSION IARRAY(ISIZE)
!
!**********************************************************************
! START OF EXECUTABLE CODE ********************************************
!**********************************************************************
!       KENTRY = KENTRY + 1
      READ(IUNT) IARRAY
      RETURN
      END
