!$AVGRR
      SUBROUTINE AVGRR (AA,PMPA,NDIM1,NDIM2,OBSC,TPARTL,DTIME,NM,NADJST,&
     &   NT,LNPNM)
!********1*********2*********3*********4*********5*********6*********7**
! AVGRR            00/00/00            0000.0    PGMR - ?
!
!
! FUNCTION: DIVIDES MEASUREMENT, PARTIAL DERIVATIVE, AND CORRECTION
!           DIFFERENCES BY TIME INTERVAL
!
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   AA      I/O   A    REAL ARRAY
!   PMPA    I/O   A    PARTIAL OF MEASUREMENT WRT TO PARAMETERS
!   NDIM1    I    S    FIRST DIMENSION OF PMPA ARRAY
!   NDIM2    I    S    SECOND DIMENSION OF PMPA ARRAY
!   OBSC    I/O   A    COMPUTED OBSERVATION
!   TPARTL  I/O   A    PARTIAL OF OBSERVATION WRT TIME (OBS RATES)
!   DTIME    I    A    DOPPLER COUNTING INTERVAL
!   NM       I    S    NUMBER OF MEASUREMENTS
!   NADJST   I    S    NUMBER OF ADJUSTED PARAMETERS
!   NT       I    S    NUMBER OF PARTIAL OF OBSERVATION WRT TIME
!   LNPNM    I    S    .TRUE. IF NADJST IS THE FIRST DIMENSION IN THE
!                      PMPA ARRAY
!
! COMMENTS:
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      PARAMETER ( ONE = 1.0D0 )
      PARAMETER ( TENM5 = 1.0D-5 )
      PARAMETER ( TENM6 = 1.0D-6 )
!
      COMMON/CITERL/LSTGLB,LSTARC,LSTINR,LNADJ ,LITER1,LSTITR,          &
     &              LOBORB,LRESID,LFREEZ,LSAVEF,LHALT,LADJPI,LADJCI
      COMMON/COBBUF/IOBSBF,IBUF1 ,IBUF2 ,IWORD1,NHEADR,NWORDM
      COMMON/COBLOC/KXMN  (3,4)  ,KENVN (3,4)  ,KSTINF(3,4)  ,          &
     &       KOBS  ,KDTIME,KSMCOR,KSMCR2,KTMCOR,KOBTIM,KOBSIG,KOBSG2,   &
     &       KIAUNO,KOBCOR(9,7)  ,KFSECS(6,8)  ,KOBSUM(8)    ,          &
     &       KEDSIG,KEDSG2
      COMMON/CPRESW/LPRE9 (24),LPRE  (24,3),LSWTCH(10,8),LOBSIN,LPREPW, &
     &              LFS   (40)
!
      DIMENSION AA(1),PMPA(NDIM1,NDIM2),OBSC(NM),TPARTL(NM,NT),DTIME(NM)
!
!**********************************************************************
!* START OF EXECUTABLE CODE *******************************************
!**********************************************************************
!
      DO 500 M=1,NM
         IF( ABS(DTIME(M)) .GT. TENM6 ) GO TO 500
         WRITE(6,*) 'AVGRR: BAD DOPPLER COUNT INTERVAL -- SET TO 10**-5'
         WRITE(6,*) 'AVGRR: M, DTIME(M) ', M, DTIME(M)
         DTIME(M) = TENM5
  500 END DO
!
!
! DIVIDE MEASUREMENTS AND TIME DERIVATIVES BY DOPPLER COUNTING INTERVAL
      DO 1000 M=1,NM
      OBSC(M)  =-OBSC(M)  /DTIME(M)
      TPARTL(M,1)=-TPARTL(M,1)/DTIME(M)
 1000 END DO
      IF(NT.LT.2) GO TO 1200
      DO 1100 M=1,NM
      TPARTL(M,2)=-TPARTL(M,2)/DTIME(M)
 1100 END DO
 1200 CONTINUE
!
      IF(LNADJ) GO TO 6000
!
! DIVIDE PARTIALS BY DOPPLER COUNTING INTERVAL
!
      IF(LNPNM) GO TO 4000
!.....PARTIALS DIMENSIONED (NM,NADJST)
      DO 3000 N=1,NADJST
      DO 2400 M=1,NM
      PMPA(M,N)=-PMPA(M,N)/DTIME(M)
 2400 END DO
 3000 END DO
      GO TO 6000
 4000 CONTINUE
!
!.....PARTIALS DIMENSIONED (NADJST,NM)
      DO 5000 M=1,NM
      DTINV=ONE/DTIME(M)
      DO 4400 N=1,NADJST
      PMPA(N,M)=-PMPA(N,M)*DTINV
 4400 END DO
 5000 END DO
 6000 CONTINUE
!
      IF(.NOT.LITER1) RETURN
!
! DIVIDE MEASUREMENT CORRECTIONS BY DOPPLER COUNTING INTERVAL
!
      DO 9000 IHEADR=2,NHEADR
      JHEADR=IHEADR-1
      DO 8000 IWORD =2,8
      IF(LPRE  (IWORD ,JHEADR)) GO TO 8000
      IF(.NOT.LSWTCH(IWORD ,IHEADR)) GO TO 8000
      JOBCOR=KOBCOR(IWORD ,JHEADR)
      DO 7000 M=1,NM
      AA(JOBCOR)=-AA(JOBCOR)/DTIME(M)
      JOBCOR=JOBCOR+1
 7000 END DO
 8000 END DO
 9000 END DO
      RETURN
      END