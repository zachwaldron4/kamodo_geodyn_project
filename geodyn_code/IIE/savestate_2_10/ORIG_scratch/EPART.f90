!$EPART
      SUBROUTINE EPART(NRMTOT,LFIRST,LAST)
!********1*********2*********3*********4*********5*********6*********7**
! EPART            90/04/02            0000.0    PGMR: TVM, SBL
!
! FUNCTION: INITIALIZES AND CALCULATES INFORMATION NEEDED FOR THE
!           E-MATRIX PARTITIONING. ON FIRST CALL SETS UP FIRST PARTITION
!           AND SCRATCH FILES TO HOLD PARTIALS AND EBISES ON SUBSEQUENT
!           CALLS SETS UP THE FOLLOWING PARTITION INFORMATION
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   NRMTOT  I/O   S    MAXIMUM ORDER OF THE ATWA MATRIX
!   LFIRST  I/O        .TRUE. = FIRST CALL TO THIS ROUTINE FROM INITI
!                      .FALSE.= OTHER THAN FIRST CALL FROM SMPART
!   LAST    I/O        .TRUE. = THEN LAST PARTITION
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      CHARACTER*5   FILNAM
!
      COMMON/CPARTI/MAXLP ,KORSIZ,MAXWRK,                               &
     &              IUNTP1,IUNTP2,IUNTPF,ISIZPF,IRECPF,NRECPF,          &
     &              NPDONE,NP1   ,NP2   ,NRECND,NPDIM ,NXPARI
      COMMON/CPARTL/LPART ,LPARTI,NXPARL
      COMMON/CVIEW /IOUT6 ,ILINE6,IPAGE6,MLINE6,                        &
     &              IOUT8 ,ILINE8,IPAGE8,MLINE8,                        &
     &              IOUT9 ,ILINE9,IPAGE9,MLINE9,                        &
     &              IOUT10,ILIN10,IPAG10,MLIN10,                        &
     &              IOUT15,ILIN15,IPAG15,MLIN15,                        &
     &              IOUT16,ILIN16,IPAG16,MLIN16,                        &
     &              IOUT7 ,NXCVUE
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
! THE NUMBER OF PARAMETERS ALREADY SUMMED IS NPDONE
      IF(LFIRST) NPDONE=0
      IF(.NOT.LFIRST) NPDONE=NP2
! LENGTH OF THE CURRENT NEXT ROW TO BE SUMMED
      KURSIZ=NRMTOT-NPDONE
! APPROXIMATE NUMBER OF ROWS IN CURRENT PARTITION
      NRWORK=MAXWRK/KURSIZ
! IF WORK SPACE .GE. NUMBER OF ROWS REMAINING THEN SEARCH NO MORE
      IF(NRWORK.GE.KURSIZ) GO TO 200
  100 CONTINUE
! APPLY A CORRECTION TO THE ABOVE APPROXIMATION
      NWORDX=MAXWRK-(KURSIZ*NRWORK-NRWORK*(NRWORK-1)/2)
! IF INSUFFICIENT SPACE FOR ONE MORE ROW THEN SEARCH NO MORE
      NEWROW=KURSIZ-NRWORK
      IF(NWORDX.LT.NEWROW) GO TO 200
      NROWAD=NWORDX/NEWROW
      IF(NROWAD.GE.NEWROW) GO TO 150
      NRWORK=NRWORK+NROWAD
      GO TO 100
  150 CONTINUE
      NRWORK=KURSIZ
  200 CONTINUE
! FORCE NUMBER OF ROWS TO BE PROCESSED TO BE .LE. NUMBER REMAINING
      NRWORK=MIN(NRWORK,KURSIZ)
! BEGIN PROCESSING WITH NP1
      NP1=NPDONE+1
! STOP WITH NP2
      NP2=NPDONE+NRWORK
! SET LAST PARTITION INDICATOR
      LAST=NP2.GE.NRMTOT
      IF(LAST) NP2=NRMTOT
! INITIALIZE WORKING UNIT NUMBER
      IUNTPF=IUNTP1
! SET RECORD COUNT TO ZERO
      IRECPF=0
      IF(.NOT.LFIRST) WRITE(IOUT6,50000) NP1,NP2,MAXWRK
      IF(LAST.AND..NOT.LFIRST) WRITE(IOUT6,60000)
      IF(.NOT.LFIRST) RETURN
! DEFINE RECORD SIZE IN NUMBER OF 64-BIT WORDS:
!        NUMBER OF PARTIALS + 1 FOR OBSWT
      NPDIM =NRMTOT-NP2+1
! NUMBER OF RECORDS PER FILE IS: FILE SIZE / (RECORD SIZE + 1)
!        FILE SIZE IS NUMBER OF BLOCKS TIMES 512 64-BIT WORDS PER BLOCK
      NRECPF=(ISIZPF*512)/(NPDIM+1)
      IU1=IUNTPF/10
      IU2=IUNTPF-IU1*10
      WRITE(FILNAM,FMT='(A3,I1,I1)')'ftn',IU1,IU2
      OPEN(IUNTPF,FILE=FILNAM,ACCESS='SEQUENTIAL',FORM='UNFORMATTED')
      WRITE(IOUT6,80000) IUNTPF
      IF(LAST) WRITE(IOUT6,10000)
      IF(.NOT.LAST) WRITE(IOUT6,20000) NP2
      WRITE(IOUT6,30000) MAXWRK,NRMTOT
      IF(LAST) RETURN
      WRITE(IOUT6,40000) IUNTP1,IUNTP2,NRECPF,NPDIM
      RETURN
10000 FORMAT('0','NORMAL MATRIX PARTITIONING HAS BEEN REQUESTED, BUT ', &
     &   'WILL NOT BE PERFORMED BECAUSE UNNECESSARY.')
20000 FORMAT('0','NORMAL MATRIX PARTITIONING HAS BEEN REQUESTED, AND ', &
     &   'WILL BE PERFORMED. PARTITION ONE WILL CONTAIN',I6,' ROWS.')
30000 FORMAT('0','WORKING MEMORY SIZE =',I10,' 64-BIT WORDS.'/          &
     &   ' NUMBER OF ADJUSTED PARAMETERS =',I6,/,1X)
40000 FORMAT(' SCRATCH UNITS',I3,' THRU',I3,' WILL EACH HOLD',I10,      &
     &   ' RECORDS OF',I6,' 64-BIT WORDS.'/1X )
50000 FORMAT(' SUMMING INTO MATRIX PARTITION WHICH OCCUPIES ROWS',      &
     &   I6,' THRU',I6/' WORKING MEMORY SIZE =',I10)
60000 FORMAT(' CURRENT PARTITION WILL BE LAST')
80000 FORMAT(' UNIT ',I3,' OPENED FOR PARTITIONING PARTIAL FILE')
      END