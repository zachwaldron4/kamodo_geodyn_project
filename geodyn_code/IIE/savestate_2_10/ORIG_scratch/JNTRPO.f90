!$JNTRPO
      SUBROUTINE JNTRPO(S,B,NM,CIPV,CIVV,IORDER,H,INDH,NMH,NINTVL,      &
     &    SUMX,XDDOT,N3,NH,NSTEPS,XI,MAXM,M3,I3,RNPPN,SCRTCH,DNLT,      &
     &    TOPXAT,LTPXAT,TPMEAS,LTPMES,SUMXOS,XDDTOS,KNSTEPS,ISAT,ISATID)
!********1*********2*********3*********4*********5*********6*********7**
! INTRPO           82/08/27            8208.0    PGMR - TOM MARTIN
!
! FUNCTION:  INTERPOLATE FOR THE S/C ORBIT AT MULTIPLE TIMES
!
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   S        I    A    VECTOR OF INTERPOLATION FRACTIONS
!   B       I/O   A    SCRATCH USED FOR INTERMEDIATE SUMS
!   NM       I    S    NUMBER OF TIMES FOR WHICH INTERPOLATION NEEDED
!   CIPV     I    A    COWELL COEFFICIENTS FOR INTERPOLATING A
!                      VECTOR OF POSITIONS
!   CIVV     I    A    COWELL COEFFICIENTS FOR INTERPOLATING A
!                      VECTOR OF VELOCITIES
!   IORDER   I    S    ORDER OF COWELL INTEGRATION
!   H        I    S    INTEGRATION STEPSIZE
!   INDH     I    A    INDICES OF THE BACK VALUES USED FOR
!                      INTERPOLATING A GROUP OF TIMES
!   NMH      I    A    NUMBER OF THE LAST MEASUREMENT IN EACH
!                      INTERPOLATION GROUP
!   NINTVL   I    S    NUMBER OF INTERPOLATION GROUPS
!   SUMX     I    A    INTEGRATION SUMS
!   XDDOT    I    A    ACCELERATION BACK VALUES
!   N3       I    S    NUMBER OF SATELLITES TIMES 3
!   NH       I    S    NUMBER OF ACCELERATION BACK VALUES
!   NSTEPS   I    S    NUMBER OF COWELL SUM BACK VALUES
!   XI       O    A    INTERPOLATED ORBIT POSITIONS AND VELOCITIES
!   MAXM     I    S    MAX # OF SAT. TO BE INTERPOLATED TIMES 3
!   M3       I    S    NUMBER OF SATELLITES TIMES 3 TO BE STORED
!                      IN THE OUTPUT ARRAY
!   I3       I    S    NUMBER OF SATELLITES TIMES 3 TO BE INTERPOLATED
!                      ON THIS CALL
!   RNPPN   I/O   A    SCRATCH SPACE FOR TEMPORARY STORAGE
!   SCRTCH  I/O   A    SCRATCH SPACE FOR TEMPORARY STORAGE
!   DNLT     I    A    ACCUMULATED NODE DIFFERENCE DUE TO
!                      LENSE-THIRRING
!   TOPXAT   I    A    TOPEX ATT. BACK VALUES (BETAPRIME & ORBIT ANGLE)
!   LTPXAT   I    A    TOPEX ATT. BACK VALUES (RAMPING LOGICALS)
!   TPMEAS   O    A    TOPEX ATT VALUES FOR USE IN MEAS. MODEL
!   LTPMES   O    A    TOPEX ATT VALUES FOR USE IN MEAS. MODEL
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      COMMON/CEGREL/LGRELE,LRLCLK,LGRELR,LXPCLK,LBPCLK,NXEGRL
      COMMON/HOLDQ/SUMXO(3,2,200,3),SUMXX(8000,3,2,200,3),QINTQ
      COMMON/IOS/ISTOS1,ISTOS2,ISTOS3,ISTLST,INTSUB(3),JNTSUB(3),      &
     &        ILSTSG(80),INTOSP,MAPSAT(3,4)
      DIMENSION S(NM),B(NM),CIPV(NM,IORDER),CIVV(NM,IORDER),            &
     &          INDH(NINTVL),NMH(NINTVL),SUMX(N3,2,NH),                 &
     &          XDDOT(N3,NSTEPS),XI(MAXM,M3,2),DNLT(I3)
      DIMENSION RNPPN(NM,3,3),SCRTCH(NM,3)
      DIMENSION TPMEAS(MAXM,2),LTPMES(MAXM,3)
      DIMENSION TOPXAT(2*N3/3,NSTEPS),LTPXAT(N3,NSTEPS)
      DIMENSION SUMXOS(3,2,1),XDDTOS(3,KNSTEPS,1)
!
!
! NOTE THAT SUMXX IS A LOCAL ARRAY THAT REALLY WOULD HAVE TO BE DYNAMICALLY
! ALLOCATED FOR THIS ROUTINE TO WOTK IN GENERAL. I BELIEVE THAT SUMX
! COULD BE USED (SUMX ALREADY PASSES IN AND DYNAMICALLY ALLOCATED) INSTEAD
! OF SUMXX (THE INDEXING OF SUMXX WOULD STILL BE USED)
!
!
!
!
!
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
      CALL COEFV(S,B,NM,IORDER,CIPV,CIVV)
      IOL1=IORDER-1
      IF(QINTQ.GT.0.D0) THEN
        CALL OGRATE(IOL1,NINTVL,INDH,SUMXO(1,1,1,INTOSP),SUMXOS,XDDTOS, &
     &              KNSTEPS,ISAT)
        INTSUB(INTOSP)=INDH(1)
      ENDIF
      IADD=INDH(1)-INTSUB(INTOSP)
!
      H2=H**2
      IOL2=IORDER-2
      NM1=1
      DO 1000 INTVL=1,NINTVL
      NM2=NMH(INTVL)
      INDEX=INDH(INTVL)

!
! FILL TOPEX ATT. ARRAYS FOR EACH MEASUREMENT
! (IOL1-1+INDEX) is the most advanced integration time associated with
!  this measurement.  Subtract 3 from this and you have the integration
!  step which preceeds the measurment.
      IF(ISATID.eq.9205201.or.ISATID.eq.8032001.or.ISATID.eq.1055001)   &
     &  THEN
      DO  70 IJ=NM1,NM2
         TPMEAS(IJ,1) = TOPXAT(1,IOL1-1+INDEX-3)
         TPMEAS(IJ,2) = TOPXAT(2,IOL1-1+INDEX-3)
         LTPMES(IJ,1) = LTPXAT(1,IOL1-1+INDEX-3)
         LTPMES(IJ,2) = LTPXAT(2,IOL1-1+INDEX-3)
         LTPMES(IJ,3) = LTPXAT(3,IOL1-1+INDEX-3)
   70 END DO
      ENDIF
   71 CONTINUE
!
      DO 900 N=1,I3
!
      DO 100 NMI=NM1,NM2
!     B(NMI)=SUMX(N,2,INDEX)
      B(NMI)=SUMXO(N,2,INTVL+IADD,INTOSP)
  100 END DO
!
!
      DO 300 K=1,IOL1
!     KK=IOL1-K+INDEX+IADD
      KK=IOL1-K+INDEX
!
      DO 200 NMI=NM1,NM2
!     B(NMI)=B(NMI)+CIVV(NMI,K)*XDDOT(N,KK)
      B(NMI)=B(NMI)+CIVV(NMI,K)*XDDTOS(N,KK,1)
  200 END DO
!
!
  300 END DO
!
      DO 400 NMI=NM1,NM2
      XI(NMI,N,2)=B(NMI)*H
  400 END DO
!
!
      DO 500 NMI=NM1,NM2
!     B(NMI)=SUMX(N,1,INDEX)-SUMX(N,2,INDEX)                            &
!    &      +S(NMI)*SUMX(N,2,INDEX)
      B(NMI)=SUMXO(N,1,INTVL+IADD,INTOSP)-SUMXO(N,2,INTVL+IADD,INTOSP)  &
     &      +S(NMI)*SUMXO(N,2,INTVL+IADD,INTOSP)
  500 END DO
!
!
      DO 700 K=1,IOL2
!     KK=IOL1-K+INDEX+IADD
      KK=IOL1-K+INDEX
!
      DO 600 NMI=NM1,NM2
!     B(NMI)=B(NMI)+CIPV(NMI,K)*XDDOT(N,KK)
      B(NMI)=B(NMI)+CIPV(NMI,K)*XDDTOS(N,KK,1)
  600 END DO
!
!
  700 END DO
!
      DO 800 NMI=NM1,NM2
      XI(NMI,N,1)=B(NMI)*H**2
  800 END DO
!
!
  900 END DO
      NM1=NM2+1
 1000 END DO
!     IF(.NOT.LGRELE) RETURN
! ADD IN LENSE-THIRRING EFFECT
!     NSAT=I3/3
!     DO 2000 ISAT=1,NSAT
!     IPTX=(ISAT-1)*3+1
!     CALL NODELT(NM,XI(1,IPTX,1),MAXM,M3,DNLT(ISAT),RNPPN)
!2000 CONTINUE
      RETURN
      END
