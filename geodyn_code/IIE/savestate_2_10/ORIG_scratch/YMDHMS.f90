!

!$YMDHMS
      SUBROUTINE YMDHMS(MJDS,FSEC,IYMD,IHM,SEC,NPTS)
!********1*********2*********3*********4*********5*********6*********7**
! YMDHMS           00/00/00            0000.0    PGMR - ?
!
!
! FUNCTION:
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   MJDS
!   FSEC
!   IYMD
!   IHM
!   SEC
!   NPTS
!
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      COMMON/CONSTR/PI,TWOPI,DEGRAD,SECRAD,SECDAY
      COMMON/DTMGDN/TGTYMD,TMGDN1,TMGDN2,REPDIF,XTMGN
      DIMENSION FSEC(NPTS),IYMD(NPTS),IHM(NPTS),SEC(NPTS)
!     DATA IYMDRF/410106/
      DATA SECMIN/6.0D1/
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
! COMPUTE MODIFIED JULIAN DAY = JULIAN DAY - GEODYN REFERENCE TIME IN JD
      MJD=(DBLE(MJDS)+FSEC(1))/SECDAY
! ADD ELAPSED DAYS SINCE GEODYN TIME TO REFERENCE CALENDAR DATE
      IYMDRF=INT(TGTYMD+0.001)
      IYMD0=IYMDRF
      CALL ADDYMD(IYMD0,MJD)
! COMPUTE START TIME ELAPSED SECONDS WITHIN DAY
      ISEC0=MJDS-MJD*86400
      SEC0=DBLE(ISEC0)
! ADD TO ELAPSED SECONDS SINCE START TIME
      DO 1000 N=1,NPTS
      SEC(N)=SEC0+FSEC(N)
 1000 END DO
! COMPUTE INTEGRAL ELAPSED DAYS FROM START DATE
      DO 2000 N=1,NPTS
      IYMD(N)=SEC(N)/SECDAY
 2000 END DO
! SUBTRACT INTEGRAL DAYS FROM ELAPSED SECONDS
      DO 3000 N=1,NPTS
      SEC(N)=SEC(N)-DBLE(IYMD(N)*86400)
 3000 END DO
! COMPUTE INTEGRAL ELAPSED MINUTES WITHIN DAY
      DO 4000 N=1,NPTS
      IHM(N)=SEC(N)/SECMIN
 4000 END DO
! SUBTRACT INTEGRAL MINUTES FROM ELAPSED SECONDS
      DO 5000 N=1,NPTS
      SEC(N)=SEC(N)-DBLE(IHM(N)*60)
 5000 END DO
! CONVERT INTEGRAL MINUTES TO HOURS AND MINUTES
      DO 6000 N=1,NPTS
!     IH=IHM(N)/60
!     IHM(N)=IHM(N)-IH*60
!     IHM(N)=IHM(N)+IH*100
      IHM(N)=(IHM(N)/60)*40+IHM(N)
 6000 END DO
! REPLACE INTEGRAL DAYS SINCE START DATE WITH CALENDAR DATE
      IDAYS=0
      IYMDAY=IYMD0
      DO 8000 N=1,NPTS
      IF(IYMD(N).EQ.IDAYS) GO TO 7000
      IDAYS=IYMD(N)
      IYMDAY=IYMD0
      CALL ADDYMD(IYMDAY,IDAYS)
 7000 CONTINUE
      IYMD(N)=IYMDAY
 8000 END DO
      RETURN
      END