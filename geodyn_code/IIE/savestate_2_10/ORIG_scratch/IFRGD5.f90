!$IFRGD5
      SUBROUTINE IFRGD5(AA,II,LL,IFFHDR,IFFLEN,FFBUF)
!********1*********2*********3*********4*********5*********6*********7**
! IFRGD5           00/00/00            0000.0    PGMR - B. EDDY/SEVITSKI
!
! FUNCTION:  READ GLOBAL DYNAMIC ARRAYS FROM THE INTERFACE FILE
!            FOR ALLOCATION GROUP #1 - INTEGRATION AND FORCE MODEL
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   AA      I/O   A    REAL DYNAMIC ARRAY
!   II      I/O   A    INTEGER DYNAMIC ARRAY
!   LL      I/O   A    LOGICAL DYNAMIC ARRAY
!   IFFHDR   I    A    SCRATCH ARRAY USED FOR HEADER INFORMATION
!   IFFLEN   I    A    SCRATCH ARRAY USED FOR LENGTHS OF DATA
!   FFBUF    I    A    SCRATCH ARRAY USED FOR CONVERTING IBM
!                      FLOATING POINT NUMBERS TO CYBER F.P.
!
! COMMENTS:     INTERFACE FORMAT #2 USED:
!
! INTEGER  HEADER RECORD  - WITH IFFHDR(5)=0 INDICATING LENGTHS RECORDS
!                           FOLLOWS
! INTEGER LENGTHS RECORD  - CONTAINING IFFHDR(4)-1 LENGTHS
!            DATA RECORDS - IFFHDR(4)-1  DATA RECORDS. DATA RECORDS ARE
!                           OF THE TYPE INDICATED IN IFFHDR(3)
!
! COMMENTS:   TO READ ADDITIONAL RECORDS IN THIS ROUTINE
!             1. INCREMENT IRECS IN PROPER GROUP-REAL,INTEGER OR LOGICAL
!             2. ADD CALL TO BINRD2 (REAL) OR BINRD (INTEGER,LOGICAL)
!                IN PROPER GROUP
!             3. FOR FLOATING POINT DATA CALL SUBROUTINE Q9ICLA TO
!                CONVERT REAL WORDS TO THE CORRECT REPRESENTATION
!                FOR THE COMPUTER IIE IS RUNNING ON
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      COMMON/CIFF  /IFHEAD,IFLNTH,IFBUFL,IFBUFR,KDYNHD,KDYNLN,          &
     &              KDYNIF,KDYNFF,NXCIFF
      COMMON/CORA05/KOBTYP,KDSCRP,KGMEAN,KGLRMS,KWGMEA,KWGRMS,KTYMEA,   &
     &       KTYRMS,KWTMTY,KWTYRM,KTMEAN,KTRMS ,KWMEAN,KWTRMS,KWTRND,   &
     &       KPRVRT,KEBSTT,KVLOPT,NXCA05
      COMMON/CORI05/KNOBGL,KNOBWG,KNOBTY,KNOBWY,KNOBST,KNOBWT,KNEBOB,   &
     &              KJSTAT,NXCI05
      COMMON/CORL05/KLGPRV,NXCL05
      COMMON/CSTATS/MSTATS,MTYPES,NXCSTT
      COMMON/CVIEW /IOUT6 ,ILINE6,IPAGE6,MLINE6,                        &
     &              IOUT8 ,ILINE8,IPAGE8,MLINE8,                        &
     &              IOUT9 ,ILINE9,IPAGE9,MLINE9,                        &
     &              IOUT10,ILIN10,IPAG10,MLIN10,                        &
     &              IOUT15,ILIN15,IPAG15,MLIN15,                        &
     &              IOUT16,ILIN16,IPAG16,MLIN16,                        &
     &              IOUT7 ,NXCVUE
      COMMON/UNITS/IUNT11,IUNT12,IUNT13,IUNT19,IUNT30,IUNT71,IUNT72,    &
     &             IUNT73,IUNT05,IUNT14,IUNT65,IUNT88,IUNT21,IUNT22,    &
     &             IUNT23,IUNT24,IUNT25,IUNT26
!
      DIMENSION AA(1)
      DIMENSION FFBUF(IFBUFR)
      DIMENSION IFFHDR(IFHEAD),IFFLEN(IFLNTH)
      DIMENSION II(1)
      DIMENSION LL(1)
!
      DATA IBLOCK/20/
!
!**********************************************************************
! START OF EXECUTABLE CODE ********************************************
!**********************************************************************
!
!**********************************************************************
! READ HEADER RECORD FOR REAL DATA
!**********************************************************************
      CALL BINRD(IUNT11,IFFHDR,IFHEAD)
      ITYPE=IFFHDR(3)
      NRECS1=IFFHDR(4)
      NRECS=NRECS1-1
!**********************************************************************
! READ LENGTHS RECORD FOR REAL DATA
!**********************************************************************
      CALL BINRD(IUNT11,IFFLEN,NRECS1)
! SAVE LAST WORD READ WHICH IS THE SUM OF THE LENGTHS
      NWORDS=IFFLEN(NRECS1)
!**********************************************************************
! READ DATA RECORDS FOR REAL DATA
!**********************************************************************
      IREC=0
      IWORDS=0
! KOBTYP - OBSTYP IN ALPHANUMERIC FORMAT
      IREC=IREC+1
      NX=IFFLEN(IREC)
      IF(NX.GT.IFBUFR) GO TO 60100
      IWORDS=IWORDS+NX
      CALL BINRDC(IUNT11,AA(KOBTYP),NX  )
!      CALL BINRD2(IUNT11,FFBUF,NX  )
!      CALL Q9ICLA(FFBUF,AA(KCN),NX,ISTAT)
! KDSCRP - DSCRPT IN ALPHANUMERIC FORMAT
      IREC=IREC+1
      NX=IFFLEN(IREC)
      IF(NX.GT.IFBUFR) GO TO 60100
      IWORDS=IWORDS+NX
      CALL BINRDC(IUNT11,AA(KDSCRP),NX  )
!      CALL BINRD2(IUNT11,FFBUF,NX  )
!      CALL Q9ICLA(FFBUF,AA(KCN),NX,ISTAT)
! KVLOPT - VLBSTR IN ALPHANUMERIC FORMAT
       IREC=IREC+1
       NX=IFFLEN(IREC)
       IF(NX.GT.IFBUFR) GO TO 60100
       IWORDS=IWORDS+NX
       CALL BINRDC(IUNT11,AA(KVLOPT),NX  )
!      CALL BINRD2(IUNT11,FFBUF,NX  )
!      CALL Q9ICLA(FFBUF,AA(KCN),NX,ISTAT)

! TEST IF CORRECT NUMBER OF DATA RECORDS READ
!
      IF(IREC.NE.NRECS) GO TO 60200
! TEST IF CORRECT NUMBER OF WORDS READ
      IF(NWORDS.NE.IWORDS) GO TO 60300
!**********************************************************************
! READ HEADER RECORD FOR INTEGER DATA
!**********************************************************************
      ITYPE=2
      CALL BINRD(IUNT11,IFFHDR,IFHEAD)
! TEST BLOCK NUMBER AND DATA RECORD TYPE
      IF(IFFHDR(1).NE.IBLOCK .OR. IFFHDR(3).NE.ITYPE) GO TO 60400
      NRECS1=IFFHDR(4)
      NRECS =NRECS1-1
!**********************************************************************
! READ LENGTHS RECORD FOR INTEGER DATA
!**********************************************************************
      CALL BINRD(IUNT11,IFFLEN,NRECS1)
! SAVE SUM OF RECORD LENGTHS
      NWORDS=IFFLEN(NRECS1)
!**********************************************************************
! READ DATA RECORDS FOR INTEGER DATA
!**********************************************************************
      IREC=0
      IWORDS=0
! EXAMPLE OF CODE REQUIRED TO ADD INTEGER ARRAYS
! PLEASE DELETE THIS EXAMPLE ONCE AN INTEGER ARRAYS IS PASSED
!     IREC=IREC+1
!     IWORDS=IWORDS+IFFLEN(IREC)
!     CALL BINRD(IUNT11,II(KICNT),IFFLEN(IREC) )
!
! TEST IF CORRECT NUMBER OF DATA RECORDS READ
!
      IF(IREC.NE.NRECS) GO TO 60200
! TEST IF CORRECT NUMBER OF WORDS READ
      IF(NWORDS.NE.IWORDS) GO TO 60300
!**********************************************************************
! READ HEADER RECORD FOR LOGICAL DATA
!**********************************************************************
      ITYPE=3
      CALL BINRD(IUNT11,IFFHDR,IFHEAD)
! TEST BLOCK NUMBER AND DATA RECORD TYPE
      IF(IFFHDR(1).NE.IBLOCK .OR. IFFHDR(3).NE.ITYPE) GO TO 60400
      NRECS1=IFFHDR(4)
      NRECS =NRECS1-1
!**********************************************************************
! REA@ LENGTHS RECORD FOR LOGICAL DATA
!**********************************************************************
      CALL BINRD(IUNT11,IFFLEN,NRECS1)
! SAVE SUM OF DATA RECORD LENGTHS
      NWORDS=IFFLEN(NRECS1)
!**********************************************************************
! READ DATA RECORDS FOR LOGICAL DATA
!**********************************************************************
      IREC=0
      IWORDS=0
!
! LOGICAL DATA RECORDS GO HERE
!
! TEST IF CORRECT NUMBER OF DATA RECORDS READ
!
      IF(IREC.NE.NRECS) GO TO 60200
! TEST IF CORRECT NUMBER OF WORDS READ
      IF(NWORDS.NE.IWORDS) GO TO 60300
      RETURN
!**********************************************************************
! ERROR PROCESSING
!**********************************************************************
!
! RECORD SIZE EXCEEDS BUFFER SPACE
60100 WRITE(IOUT6,80100) ITYPE,NX,IFBUFR
      WRITE(IOUT6,89999)
      STOP
! NUMBER OF RECORDS READ DISAGREES WITH NUMBER OF LENGTHS EXPECTED
60200 WRITE(IOUT6,80200) ITYPE,IREC,NRECS
      WRITE(IOUT6,89999)
      STOP
! NUMBER OF WORDS SENT DISAGREES WITH NUMBER OF WORDS EXPECTED
60300 WRITE(IOUT6,80300) ITYPE,NWORDS,IWORDS
      WRITE(IOUT6,89999)
      STOP
! BLOCK NUMBER OR DATA TYPE INCORRECT
60400 WRITE(IOUT6,80400) IBLOCK,ITYPE,IFFHDR
      WRITE(IOUT6,89999)
      STOP
80000 FORMAT(1X,'UNEXPECTED END OF FILE ON UNIT ',I2,' FOR DATA TYPE ', &
     & I2)
80100 FORMAT(1X,'RECORD SIZE EXCEEDS BUFFER SPACE AVAILABLE. ITYPE,NX,' &
     &'IFBUFR FOLLOW: '/1X,3I10)
80200 FORMAT(1X,'NUMBER OF TYPE (',I2,') RECORDS READ FROM INTERFACE ',&
     &'FILE DISAGREES WITH NUMBER OF LENGTHS EXPECTED',2I5)
80300 FORMAT(1X,'SUM OF RECORD LENGTHS FROM IFF LENGTHS RECORD DOES ',&
     &'NOT AGREE WITH SUM CALCULATED',3I6)
80400 FORMAT(1X,'BLOCK NUMBER OR DATA TYPE IS INCORRECT',2I5/1X,20I5)
89999 FORMAT(1X,'EXECUTION TERMINATING IN SUBROUTINE IFRGD5 ')
      END