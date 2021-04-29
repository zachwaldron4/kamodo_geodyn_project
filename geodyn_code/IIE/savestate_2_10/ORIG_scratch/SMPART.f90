!$SMPART
      SUBROUTINE SMPART(AA,PMPP,NRMTOT,ATPA,SCRTCH,TBTWA,LPRTD,NRECS,   &
     & IUNTMT)
!********1*********2*********3*********4*********5*********6*********7**
! SMPART           85/10/08            0000.0    PGMR - TOM MARTIN
!                  84/02/27            0000.0    PGMR - D. ROWLANDS
!                  90/04/10                      PGMR - SBL
!
! FUNCTION:  ACCUMULATE PARTIALS & RESIDUALS INTO PARTITIONS OF
!            NORMAL MATRIX.
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   AA      I/O   A    DYNAMIC ARRAY FOR REAL    DATA
!   PMPP     I    A    FULL ARRAY OF PARTIALS(INCLUDING ZEROS WHERE
!                      NECCESSARY) FOR EACH MEASUREMENT.
!   NRMTOT   I    S    MAXIMUM DIMENSION OF NORMAL MATRIX
!   ATPA     O    A    NORMAL MATRIX
!   SCRTCH   I    A    SCRATCH ARRAY
!   TBTWA
!   LPRTD
!   NRECS
!   IUNTMT
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
! THE SIZE OF MEPARX MUST BE CONSISTENT WITH THE BTWB & DELTA ARRAYS
      PARAMETER ( MEPARX = 4 )
      PARAMETER ( ZERO   = 0.0D0 )
!
      COMMON/CEBGLB/MEPARM,MEDIM ,MEBIAS,MBIASE,NEBGRP,IEBGRP(4),NXCEBG
      COMMON/CLVIEW/LNPRNT(18),NXCLVI
      COMMON/CPARTI/MAXLP ,KORSIZ,MAXWRK,                               &
     &              IUNTP1,IUNTP2,IUNTPF,ISIZPF,IRECPF,NRECPF,          &
     &              NPDONE,NP1   ,NP2   ,NRECND,NPDIM ,NXPARI
      COMMON/CPARTL/LPART ,LPARTI,NXPARL
      COMMON/CORA06/KPRMV ,KPNAME,KPRMV0,KPRMVC,KPRMVP,KPRMSG,KPARVR,   &
     &              KPRML0,KPDLTA,KSATCV,KSTACV,KPOLCV,KTIDCV,KSUM1 ,   &
     &              KSUM2 ,KGPNRA,KGPNRM,KPRSG0,KCONDN,KVELCV,          &
     &              KSL2CV,KSH2CV,KTIEOU,KPRMDF,NXCA06
      COMMON/CVIEW /IOUT6 ,ILINE6,IPAGE6,MLINE6,                        &
     &              IOUT8 ,ILINE8,IPAGE8,MLINE8,                        &
     &              IOUT9 ,ILINE9,IPAGE9,MLINE9,                        &
     &              IOUT10,ILIN10,IPAG10,MLIN10,                        &
     &              IOUT15,ILIN15,IPAG15,MLIN15,                        &
     &              IOUT16,ILIN16,IPAG16,MLIN16,                        &
     &              IOUT7 ,NXCVUE
      COMMON/EMAT  /EMTNUM,EMTPRT,EMTCNT,VMATRT,VMATS,VMATFR,FSCVMA,    &
     &              XEMAT
      DIMENSION AA(1),PMPP(NRMTOT),ATPA(1),SCRTCH(NRMTOT)
! BTWB AND DELTA ARE LOCAL ARRAYS IN THIS ROUTINE
! DIMENSION     BTWB(MEDIM),DELTA(MEPARM),TBTWA(NRMTOT,MEPARM)
      DIMENSION BTWB(10)   ,DELTA(4)     ,TBTWA(NRMTOT,MEPARM)
!
!**********************************************************************
! START OF EXECUTABLE CODE ********************************************
!**********************************************************************
!
      NRECSV=NRECPF
      IF(IUNTPF.EQ.IUNTP1) NRECSV=IRECPF
      NRECND=IRECPF
      IUNTP2=IUNTPF
      NPAR0=NP2
      LFIRST=.FALSE.
      LAST=NPDONE.GE.NRMTOT
      ENDFILE IUNTPF
      REWIND IUNTPF
 1000 CONTINUE
! A MEMORY PARTITION IS COMPLETE - OUTPUT THIS PARTITION TO THE EMATRX
! FILE THIS WILL BE ROWS NP1 TO NP2
      CALL EMTPDT(ATPA(1),AA(KSUM2),LPRTD,AA(KPRML0),NRECS,IUNTMT)
! CLEAR MEMORY USED FOR ATWA MATRIX
      CALL CLEARA(ATPA(1),MAXWRK)
      IF(LAST) GO TO 9100
      NRECPF=NRECSV
      CALL EPART(NRMTOT,LFIRST,LAST)
      ISP0=NP1-1
      IL0=NRMTOT-ISP0
 2000 CONTINUE
      CALL PARTRD(PMPP(NPAR0),LEOF)
      IF(LEOF) GO TO 1000
      WT=PMPP(NPAR0)
      IF(WT.LE.ZERO) GO TO 6000
!     SCRATCH IS ATP (IN ATPA)
      DO 3000 I=NP1,NRMTOT
      SCRTCH(I)=WT*PMPP(I)
 3000 END DO
!$OMP PARALLEL DO DEFAULT (SHARED) PRIVATE(ISROW)
      DO 5000 I=NP1,NP2
      ISROW=(I-NP1)*IL0-((I-NP1)*(I-NP1-1))/2
!!!!!!!!!!!!!!!!!!DIR$ IVDEP
      DO 4000 II=1,IL0-(I-NP1)
      ATPA(ISROW+II)=ATPA(ISROW+II)+SCRTCH(I)*PMPP(ISP0+I-NP1+II)
 4000 END DO
 5000 END DO
!$OMP END PARALLEL DO
      GO TO 2000
! THE DATA JUST READ FROM THE PARTIAL FILE IS AN E-BIAS CORRECTION
!     RECORD. ABS(WT) PROVIDES THE NUMBER OF E-BIAS PARAMETERS
!     ASSOCIATED WITH THIS RECORD.
 6000 CONTINUE
      NEPARM=ABS(WT)
      IF(MEPARM.GT.MEPARX) GO TO 9800
      DO 6100 I=1,MEDIM
      BTWB(I)=PMPP(NPAR0+I)
 6100 END DO
      DO 6200 I=1,NEPARM
      CALL PARTRD(TBTWA(NPAR0,I),LEOF)
      IF(LEOF) GO TO 9900
 6200 END DO
! BACK-SUBSTITUTE E-BIASES FROM NORMAL MATRIX PARTITION
      I1=0
      K2=0
      DO 9000 I=NP1,NP2
      M1=0
      DO 8500 M=1,NEPARM
      DELTA(M)=ZERO
      IST=0
      DO 6500 J=1,M
      J1=IST+M
      DELTA(M)=DELTA(M)+BTWB(J1)*TBTWA(I,J)
 6500 IST=IST+MEPARM-J
      IF(M.EQ.NEPARM) GO TO 7500
      MP1=M+1
      DO 7000 J=MP1,NEPARM
      J1=M1+J
      DELTA(M)=DELTA(M)+BTWB(J1)*TBTWA(I,J)
 7000 END DO
 7500 CONTINUE
      KL=NRMTOT-I+1
      KB=I
      DO 8000 K=1,KL
      K1=K2+K
      ATPA(K1)=ATPA(K1)-DELTA(M)*TBTWA(KB,M)
      KB=KB+1
 8000 END DO
 8500 M1=M1+MEPARM-M
! SET THE ROW ON IN THE MEMORY PARTITION (THIS IS DIFF THEN ROW OF ATWA)
      I1=I-NPDONE
! NRMTOT-NPDONE IS THE TOTAL # OF ROWS LEFT
      K2=(NRMTOT-NPDONE)*I1-(I1*(I1-1))/2
 9000 END DO
      GO TO 2000
 9100 CONTINUE
! WRITE OUT E-MATRIX LABELS IF REQUESTED ON PRNTVU CARD
      IF(.NOT.LNPRNT(12)) CALL SMPLBL(AA(KPRML0))
!     ....f90 on Sun did not like IUNTPF as loop index
!     ....and also in common block         ! jjm 9/98
                                     ! jjm 9/98
      DO 9200 IUNTPFX=IUNTP1,IUNTP2
                        ! jjm 9/98
      CLOSE(IUNTPFX)
 9200 CONTINUE
! END AND REWIND EMAT FILE
      ENDFILE IUNTMT
      REWIND IUNTMT
      WRITE(IOUT6,80100) NRECS,IUNTMT,EMTNUM
      RETURN
!
 9800 CONTINUE
      WRITE(IOUT6,98000) MEPARM,MEPARX
      STOP 16
!
 9900 CONTINUE
      WRITE(IOUT6,99000)
      STOP 16
!
80100 FORMAT('0',9X,I5,' RECORDS OUTPUT ON UNIT ',I2,                   &
     &   ' FOR E-MATRIX NUMBER  ',F16.0)
98000 FORMAT(' **SMPART**  MEPARM(',I11,') FROM E-BIAS CORRECTIONS ',   &
     &   'RECORD IS INCONSISTENT WITH LOCAL DIMENSION(',I2,')')
99000 FORMAT(' **SMPART**  UNEXPECTED E.O.F. ENCOUNTERED WHILE READING',&
     &   ' E-BIAS PARTIALS IN PARTRD.')
      END
