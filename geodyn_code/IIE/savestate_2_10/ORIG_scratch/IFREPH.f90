!$IFREPH
      SUBROUTINE IFREPH(AA,IFFHDR,FFBUF)
!********1*********2*********3*********4*********5*********6*********7**
! IFREPH           00/00/00            0000.0    PGMR - B. EDDY
!
! FUNCTION:  READ EPHEMERIS,POLAR MOTION AND FLUX DATA FROM THE
!            INTERFACE FILE AND STORE IN VIRTUAL MEMORY
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   AA      I/O   A    DYNAMIC ARRAY IN VIRTUAL MEMORY WHERE
!                      EPHEMERIS,POLAR MOTION,AND FLUX DATA RECORDS
!                      WILL BE STORED
!   IFFHDR   I    A    SCRATCH ARRAY USED FOR HEADER INFORMATION
!   FFBUF    I    A    SCRATCH ARRAY USED FOR STORING DATA PRIOR
!                      TO CONVERSION TO IIE FLOATING POINT
!                      REPRESENTATION
! COMMENTS:
!
!   INTERFACE FORMAT #1 USED:     HEADER -  WITH NON ZERO RECORD LENGTH
!                                 DATA
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      COMMON/CIFF  /IFHEAD,IFLNTH,IFBUFL,IFBUFR,KDYNHD,KDYNLN,          &
     &              KDYNIF,KDYNFF,NXCIFF
      COMMON/CLASCI/LASCII,LIFCYB,LARECL,NXLASC
      COMMON/CVIEW /IOUT6 ,ILINE6,IPAGE6,MLINE6,                        &
     &              IOUT8 ,ILINE8,IPAGE8,MLINE8,                        &
     &              IOUT9 ,ILINE9,IPAGE9,MLINE9,                        &
     &              IOUT10,ILIN10,IPAG10,MLIN10,                        &
     &              IOUT15,ILIN15,IPAG15,MLIN15,                        &
     &              IOUT16,ILIN16,IPAG16,MLIN16,                        &
     &              IOUT7 ,NXCVUE
      COMMON/DYNPTR/KDEPHM,KDEPH2,KDAHDR(3,9),KDYNAP(3,9,2),KDNEXT(3),  &
     &NXDYNP
      COMMON/UNITS/IUNT11,IUNT12,IUNT13,IUNT19,IUNT30,IUNT71,IUNT72,    &
     &             IUNT73,IUNT05,IUNT14,IUNT65,IUNT88,IUNT21,IUNT22,    &
     &             IUNT23,IUNT24,IUNT25,IUNT26
!
      DIMENSION AA(1)
      DIMENSION FFBUF(IFBUFR),IFFHDR(IFHEAD)
!
      DATA IBLOCK/30/
!**********************************************************************
! START OF EXECUTABLE CODE ********************************************
!**********************************************************************
!
!**********************************************************************
! READ HEADER RECORD FROM INTERFACE FILE
!**********************************************************************
      ITYPE=1
      IF(LASCII) THEN
       IF(LARECL) THEN
       READ(IUNT11,17000,END=60000) IFFHDR
       ELSE
       READ(IUNT11,18000,END=60000) IFFHDR
       ENDIF
      ELSE
       CALL BINRD(IUNT11,IFFHDR,IFHEAD)
      ENDIF
! TEST FOR CORECT BLOCK NUMBER AND DATA TYPE
      IF(IFFHDR(1).NE.IBLOCK .OR. IFFHDR(3).NE.ITYPE) GO TO 60100
! SET NUMBER OF RECORDS AND RECORD LENGTH
      NRECS =IFFHDR(4)
      IRECL =IFFHDR(5)
!**********************************************************************
! READ AND STORE EPHEMERIS DATA RECORDS
!**********************************************************************
      IF(IRECL.GT.IFBUFR) GO TO 60300
      IPTR=KDEPHM
      DO 500 I=1,NRECS
      CALL BINRD2(IUNT11,FFBUF ,IRECL)
! CONVERT TO PROPER FLOATING POINT REPRESENTATION FOR IIE COMPUTER
      CALL Q9ICLA(FFBUF,AA(IPTR),IRECL,ISTAT)
      IF(ISTAT.NE.0) GO TO 60200
      IPTR=IPTR+IRECL
  500 END DO
      RETURN
!**********************************************************************
! ERROR MESSAGES
!**********************************************************************
! UNEXPECTED END OF FILE
60000 WRITE(IOUT6,80000) ITYPE
      WRITE(IOUT6,89999)
      STOP
! INCORRECT BLOCK NUMBER OR DATA TYPE FOR EPHEMERIS DATA
60100 WRITE(IOUT6,80100) IBLOCK,ITYPE,IFFHDR
      WRITE(IOUT6,89999)
      STOP
! PROBLEM CONVERTING FROM IBM TO CYBER FLOATING POINT REPRESENTATION
60200 WRITE(IOUT6,80200) ISTAT
      WRITE(IOUT6,89999)
      STOP
! EPHEMERIS RECORD LENGTH EXCEEDS ALLOCATED SCRATCH SPACE
60300 WRITE(IOUT6,80300) IRECL,IFBUFR
      WRITE(IOUT6,89999)
      STOP
17000 FORMAT(BZ,3I25)
18000 FORMAT(BZ,5I25)
80000 FORMAT(1X,'UNEXPECTED END OF FILE WHILE READING TYPE (',I2,       &
     & ') DATA ' )
80100 FORMAT(1X,'INCORRECT BLOCK TYPE FOR EPHEMERIS DATA. IBLOCK AND ', &
     & 'HEADER RECORD FOLLOW'/1X,21I5)
80200 FORMAT(1X,'PROBLEM CONVERTING FROM IBM TO CYBER FLOATING POINT.', &
     &' IO STATUS FLAG = ',I5)
80300 FORMAT(1X,'EPHEMERIS RECORD LENGTH (',I5,') EXCEEDS ALLOCATED', &
     &'BUFFER SPACE',I6)
89999 FORMAT(1X,' EXECUTION TERMINATING IN SUBROUTINE IFREPH ')
      END
