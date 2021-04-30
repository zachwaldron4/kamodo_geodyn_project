!$EBSOLV
      SUBROUTINE EBSOLV(BTWB  ,TBTWA ,BTWD  ,PDELTA,DELTA ,EBSIG ,      &
     &           SUM1  ,SUM2  ,NAPARM,NEPARM,LWHOLE)
!********1*********2*********3*********4*********5*********6*********7**
! EBSOLV           85/03/19            8503.0    PGMR - TOM MARTIN
!                  86/02/10            8602.0    PGMR - TOM MARTIN
!
! FUNCTION:  SOLVE FOR A SET OF ELECTRONIC BIASES AND
!            BACK-SUBSTITUTE THEM OUT OF THE NORMAL EQUATIONS
!
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   BTWB     I         NORMAL MATRIX OF E-BIAS PARAMETERS
!   TBTWA    I         TRANSPOSE MATRIX OF CROSS TERMS BETWEEN
!                      E-BIAS AND OTHER PARAMETERS
!   BTWD     I         R.H. SIDE OF E-BIAS SOLUTION
!   PDELTA        A
!   DELTA    O         E-BIAS DIFFERENTIAL CORRECTION ARRAY
!   EBSIG    O         STD. DEV. OF ADJUSTED E-BIASES
!   SUM1    I/O        NORMAL MATRIX
!   SUM2    I/O        R.H. SIDE OF NORMAL EQUATIONS
!   NAPARM   I         NUMBER OF PARAMETERS IN NORMAL MATRIX
!   NEPARM   I         ACTUAL NUMBER OF E-BIAS PARAMETERS IN SET
!   LWHOLE   I         .TRUE. IF THIS DATA BLOCK AN ENTIRE PASS
!
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      COMMON/CEBGLB/MEPARM,MEDIM ,MEBIAS,MBIASE,NEBGRP,IEBGRP(4),NXCEBG
      COMMON/CESTIM/MPARM,MAPARM,MAXDIM,MAXFMG,ICLINK,IPROCS,NXCEST
      COMMON/CPARTI/MAXLP ,KORSIZ,MAXWRK,                               &
     &              IUNTP1,IUNTP2,IUNTPF,ISIZPF,IRECPF,NRECPF,          &
     &              NPDONE,NP1   ,NP2   ,NRECND,NPDIM ,NXPARI
      COMMON/CPARTL/LPART ,LPARTI,NXPARL
!
      DIMENSION BTWB  (MEDIM ),TBTWA (MAPARM,MEPARM),BTWD  (MEPARM),    &
     &          DELTA (MEPARM),EBSIG(MEPARM)
      DIMENSION SUM1  (MAXDIM),SUM2  (MAPARM),PDELTA(MAPARM)
!
      DATA ZERO/0.0D0/
!
!     ....APESIG IS THE INVERSE OF THE  A PRIORI EBIAS SIGMA
      DATA APESIG/1.0D-14/
!
!**********************************************************************
! START OF EXECUTABLE CODE ********************************************
!**********************************************************************
!
!
!     ....ADD APRIORI EBIAS SIGMAS TO EBIAS NORMAL MATRIX
!
!     PRINT *,'EBSOLV: MEPARM, MEDIM ', MEPARM, MEDIM
!     PRINT *,'EBSOLV: BTWB BEFORE A PRIORI ', BTWB
      IK = 1
      DO 10 I = 1, MEPARM
         BTWB(IK) = BTWB(IK) + APESIG
         IK = IK + MEPARM + 1 - I
   10 END DO
!     PRINT *,'EBSOLV: BTWB AFTER A PRIORI ', BTWB
!
! INVERT NORMAL MATRIX
      CALL DSINV(BTWB  ,MEPARM  ,NEPARM  ,DELTA )
!     PRINT *,'EBSOLV: BTWB AFTER INVERSION ', BTWB
!
! BACK-SUBSTITUTE E-BIASES FROM NORMAL MATRIX
!
      I1=0
      DO 6000 I=1,NAPARM
      M1=0
      DO 5000 M=1,NEPARM
      DELTA(M)=ZERO
      IST=0
      DO 1000 J=1,M
      J1=IST+M
      DELTA(M)=DELTA(M)+BTWB(J1)*TBTWA(I,J)
 1000 IST=IST+MEPARM-J
      IF(M.EQ.NEPARM) GO TO 3000
      MP1=M+1
      DO 2000 J=MP1,NEPARM
      J1=M1+J
      DELTA(M)=DELTA(M)+BTWB(J1)*TBTWA(I,J)
 2000 END DO
 3000 CONTINUE
!
      IF(LPARTI.AND.I.GT.NP2) GO TO 4000
      DO 3800 K=I,NAPARM
      K1=I1+K
      SUM1(K1)=SUM1(K1)-DELTA(M)*TBTWA(K,M)
 3800 END DO
 4000 CONTINUE
!
      IF(LWHOLE) GO TO 5000
      SUM2(I)=SUM2(I)-BTWD(M)*DELTA(M)
 5000 M1=M1+MEPARM-M
 6000 I1=I1+MAPARM-I
!
      IF(.NOT.LPARTI) GO TO 9000
      IF(NAPARM.LT.NP2) GO TO 9000
!
! IF NORMAL MATRIX IS BEING FORMED IN PARTS, OUTPUT THE NECESSARY
!    QUANTITIES TO OPERATE ON THE MATRIX PARTITIONS AT THE APPROPRIATE
!    TIME TO AVOID EXCESSIVE PAGING.
!
!    SET THE FIRST ELEMENT THAT IS TO BE OUTPUT TO THE PARTIAL FILE VIA
!    SUBROUTINE PARWRT TO A NEGATIVE VALUE SO THAT SMPART WILL KNOW THAT
!    THIS IS EBIAS INFORMATION AND NOT PARTIALS.
!
      PDELTA(NP2   )=-NEPARM
      DO 7000 I=1,MEDIM
      PDELTA(NP2 +I)=BTWB(I)
 7000 END DO
      CALL PARWRT(PDELTA(NP2))
      DO 8000 I=1,NEPARM
      TBTWA(NP2,I)=-I
      CALL PARWRT(TBTWA(NP2,I))
 8000 END DO
 9000 CONTINUE
!
! SOLVE FOR ELECTRONIC BIAS DIFFERENTIAL CORRECTIONS
!
      CALL SOLVE(BTWB  ,BTWD  ,NEPARM,MEPARM,DELTA )
!
! COMPUTE ADJUSTED E-BIAS SIGMA
!
      I0=0
      DO 9200 I=1,NEPARM
      IJ=I0+I
      EBSIG (I) = SQRT(BTWB(IJ))
 9200 I0=I0+MEPARM-I
!
! CLEAR E-BIAS SOLUTION ARRAYS
!
      NCLEAR=MEPARM*MAPARM
      CALL CLEARA(TBTWA,NCLEAR)
      DO 9500 I=1,MEPARM
      BTWD(I)=ZERO
 9500 END DO
      DO 9600 I=1,MEDIM
      BTWB(I)=ZERO
 9600 END DO
      RETURN
      END