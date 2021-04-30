!$GPMDAE
      SUBROUTINE GPMDAE(ATPAA,ARIARG,ATPAG,SCRTCH,IAPARM,IGPARM,        &
     &                  NRMTOT)
!********1*********2*********3*********4*********5*********6*********7**
! GPMDAE           00/00/00            0000.0    PGMR - ?
!
! FUNCTION:  MODIFY THE ARC INVERTED NORMAL MATRIX (ADJ. ARC
!            PARAMETER VARIANCES) AFTER A GLOBAL ITERATION HAS
!            TAKEN PLACE.
!
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   ATPAA   I/O   A    ARC INVERTED  NORMAL MATRIX FOR INPUT
!                      ARC ADJUSTED PARAMETER VARIANC-COVARIANCE MATRIX
!                      FOR OUTPUT
!   ARIARG   I    A    ARC INVERSE NORMAL MATRIX TIMES ARC-GLOBAL CROSS
!                      BLOCK
!   ATPAG    I    A    GLOBAL INVERTED NORMAL MATRIX
!   SCRTCH  I/O   A    SCRATCH VECTOR IAPARM IN LENGTH
!   IAPARM   O    S    NUMBER OF ARC PARAMETERS
!   IGPARM   O    S    NUMBER OF GLOBAL PARAMETERS
!   NRMTOT   O    S    LENGTH OF FIRST ROW OF ENTIRE NORMAL MATRIX
!
! COMMENTS:
!
! NOTE:  THE VECTORIZATION OF THIS ROUTINE IS SOMEWHAT LIMITED
!        BY THE FACT THAT IT IS PROGRAMMED TO USE SCRATCH SPACE
!        ONLY IAPARM IN LENGTH
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      DIMENSION ATPAA(1),ARIARG(1),ATPAG(1),SCRTCH(1)
      DATA ZERO/0.D0/
!
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
! GET THE PRODUCT ARIARG*ATPAG ONE COLUMN AT A TIME
! STORE THIS INTO SCRTCH.THEN ACCUMULATE THIS COLUMNS EFFECT INTO
! THE FINAL CHANGE
!
      ISV2=0
      INV2=IGPARM
      DO 200 ICOL=1,IGPARM
!  DO VECTOR OPERATIONS ON THE PORTION OF THE COLUMNS OF ATPAG
!  WHICH ARE DIAGONAL OR LOWER TIANGULAR
      IVECTL=IGPARM+1-ICOL
      ISV1=ICOL-1
      INV1=NRMTOT-1
      DO 50 IROW=1,IAPARM
      SCRTCH(IROW)=ZERO
      DO 10 J=1,IVECTL
      SCRTCH(IROW)=SCRTCH(IROW)+ARIARG(ISV1+J)*ATPAG(ISV2+J)
   10 END DO
      ISV1=ISV1+INV1
      INV1=INV1-1
   50 END DO
!
      IF(ICOL.EQ.1) GO TO 170
!  DO SCALER OPERATIONS ON THE STRICTLY UPPER TRIANGULAR PORTION OF
!  ATPAG
      ISCALL=ICOL-1
      ISS1=0
      INS1=NRMTOT-1
      DO 150 IROW=1,IAPARM
      ISS2=ICOL
      INS2=IGPARM-1
      DO 120 J=1,ISCALL
      SCRTCH(IROW)=SCRTCH(IROW)+ARIARG(ISS1+J)*ATPAG(ISS2)
      ISS2=ISS2+INS2
      INS2=INS2-1
  120 END DO
      ISS1=ISS1+INS1
      INS1=INS1-1
  150 END DO
  170 CONTINUE
!  AT THIS POINT SCRATCH CONTAINS THE ICOL COLUMN OF ARIARG*ATPAG.
!
!
      ISATPA=0
      INATPA=NRMTOT-1
      ITSFR=ICOL
      ITNFR=NRMTOT-1
      DO 195 IFROW=1,IAPARM
      ITTSFR=ITSFR
      ITTNFR=ITNFR
      DO 190 IFCOL=IFROW,IAPARM
      ATPAA(ISATPA+IFCOL)=ATPAA(ISATPA+IFCOL)+SCRTCH(IFROW)             &
     &                   *ARIARG(ITTSFR)
      ITTSFR=ITTSFR+ITTNFR
      ITTNFR=ITTNFR-1
  190 END DO
      ISATPA=ISATPA+INATPA
      INATPA=INATPA-1
      ITSFR=ITSFR+ITNFR
      ITNFR=ITNFR-1
  195 END DO
      ISV2=ISV2+INV2
      INV2=INV2-1
  200 END DO
      RETURN
      END