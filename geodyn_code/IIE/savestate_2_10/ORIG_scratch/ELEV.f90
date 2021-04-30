!$ELEV
      SUBROUTINE ELEV(UHAT,RNM,RDOT,VSM,COSTHG,SINTHG,ENV,COSZEN,COSEL, &
     &   RCOSEL,RELV,ELEVSC,ELRATE,NM,LNCOSZ,LNCOSE,LNELEV,LRAD,LNRATE, &
     &   LNRELV,LNRDOT)
!********1*********2*********3*********4*********5*********6*********7**
! ELEV             83/06/13            8306.0    PGMR - TOM MARTIN
!
! FUNCTION:  COMPUTE ELEVATION OF S/C W.R.T. STATION
!            AND OPTIONALLLY TIME RATE OF CHANGE OF ELEVATION
!            AND COSINES OF ZENITH AND ELEVATION.
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   UHAT     I    A    E.C.F. UNIT VECTOR FROM STATION TO S/C
!   RNM      I    A    RANGE FROM STATION TO S/C
!   RDOT     I    A    RANGE RATE FROM STATION TO S/C
!   VSM      I    A    INERTIAL S/C VELOCITY
!   COSTHG   I    A    COSINES OF RIGHT ASCENSION OF GREENWICH
!   SINTHG   I    A    SINES  OF RIGHT ASCENSION OF GREENWICH
!   ENV      I    A    STATION EAST,NORTH,VERTICAL VECTORS IN E.C.F.
!   COSZEN  I/O   A    S/C ZENITH DIRECTION COSINES.
!   COSEL   I/O   A    COSINES OF ELEVATION
!   RCOSEL        A    RANGE TIMES COSINE OF ELEVATION
!   RELV     O    A    S/C E.C.F. RELATIVE VELOCITY
!   ELEVSC   O    A    ELEVATION OF S/C W.R.T. STATION
!   ELRATE   O    A    TIME RATE OF CHANGE OF ELEVATION
!   NM       I    S    NUMBER OF TIMES FOR WHICH ELEV. TO BE COMPUTED
!   LNCOSZ   I    S    .T.-ZENITH COSINE ALREADY COMPUTED
!                      .F.-COMPUTE ZENITH COSINE
!   LNCOSE   I    S    .T.-ELEVATION COSINE ALREADY COMPUTED
!                      .F.-COMPUTE ELEVATION COSINE
!   LNELEV   I    S    .T.-ELEVATION ANGLE NOT REQUIRED
!                      .F.-COMPUTE ELEVATION ANGLE
!   LRAD     I    S    .T.-COMPUTE ELEVATION IN RADIANS
!                      .F.-CONVERT ELEVATION TO DEGREES
!   LNRATE   I    S    .T.-ELEVATION RATE NOT REQUIRED
!                      .F.-COMPUTATION OF ELEV. RATE REQUIRED
!   LNRELV   I    S    .T.-RELATIVE VELOCITY PRECOMPUTED
!                      .F.-COMPUTATION OF REL. VEL. REQUIRED
!   LNRDOT   I    S    .T.-RANGE RATE PRECOMPUTED
!                      .F.-COMPUTATION OF RANGE RATE REQUIRED
!
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      COMMON/CONSTR/PI,TWOPI,DEGRAD,SECRAD,SECDAY
      COMMON/CNIGLO/MINTIM,MSATG3,MEQNG ,MEQNG3,MSATG ,MSATOB,MSATA ,   &
     &              MSATA3,MSETA ,MINTVL,MSORDR,MSORDV,NMXORD,          &
     &       MCIPV ,MXBACK,MXI   ,MPXPF ,MAXAB ,MSETDG,MXSATD,          &
     &       MXDEGS,MXDRP ,MXDRPA,MXSRP ,MXSRPA,MXGAP ,MSATDR,          &
     &       MSATSR,MSATGA,MXDRPD,MXSRPD,MXGAPD,MXBCKP,MXTPMS,          &
     &       NSTAIN,NXCNIG
      DIMENSION UHAT(NM,3),RNM(NM),RDOT(NM),VSM(MINTIM,3),COSTHG(NM),   &
     &   SINTHG(NM),ENV(3,3),COSZEN(NM),COSEL(NM),RCOSEL(NM),RELV(NM,3),&
     &   ELEVSC(NM),ELRATE(NM)
      DATA ONE/1.0D0/
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
!
! BYPASS COMPUTATION OF ZENITH COSINE UNLESS REQUIRED
      IF(LNCOSZ) GO TO 3000
! COMPUTE ZENITH COSINES
      CALL MATPRD(UHAT,ENV(1,3),COSZEN,NM,3,1)
 3000 CONTINUE
! BYPASS COMPUTATION OF ELEVATION COSINES UNLESS REQUIRED
      IF(LNCOSE) GO TO 5000
! COMPUTE COSINES SQUARED OF ELEVATION
      DO 3800 N=1,NM
      COSEL (N)=ONE-COSZEN(N)*COSZEN(N)
 3800 END DO
! COMPUTE COSINES OF ELEVATION
      DO 4800 N=1,NM
      COSEL(N)=SQRT(COSEL (N))
 4800 END DO
 5000 CONTINUE
      IF(LNELEV) GO TO 8000
! COMPUTE TANGENT OF ELEVATIONS = (ZENITH COSINES / ELEVATION COSINES)
      DO 5800 N=1,NM
      ELEVSC(N)=COSZEN(N)/COSEL(N)
 5800 END DO
! COMPUTE ELEVATIONS = ARCTAN OF (ZENITH COSINES / ELEVATION COSINES)
      DO 6800 N=1,NM
      ELEVSC(N)=ATAN(ELEVSC(N))
 6800 END DO
! LEAVE ELEVATION IN RADIANS UNLESS DEGREES REQUESTED
      IF(LRAD) GO TO 8000
! CONVERT ELEVATION FROM RADIANS TO DEGREES
      DO 7800 N=1,NM
      ELEVSC(N)=ELEVSC(N)/DEGRAD
 7800 END DO
 8000 CONTINUE
! RETURN IF ELEVATION RATE NOT REQUIRED
      IF(LNRATE) RETURN
! COMPUTE THE RELATIVE VELOCITY AND THE RANGE RATE
      IF(.NOT.(LNRELV.AND.LNRDOT)) CALL RELVEL(VSM,COSTHG,SINTHG,UHAT,  &
     &   RNM,ELRATE,RELV,RDOT,NM,LNRELV,LNRDOT)
! COMPUTE RANGE TIMES COSINE OF ELEVATION
      DO 13800 N=1,NM
      RCOSEL(N)=RNM(N)* COSEL(N)
13800 END DO
! COMPUTE DOT PRODUCT OF RELATIVE VEL. AND LOCAL VERTICAL DIRECTION
      CALL MATPRD(RELV,ENV(1,3),ELRATE,NM,3,1)
! SUBTRACT RANGE RATE TIMES THE ZENITH DIRECTION COSINE
      DO 16800 N=1,NM
      ELRATE(N)=ELRATE(N)-RDOT(N)*COSZEN(N)
16800 END DO
! DIVIDE BY RANGE TIMES THE COSINE OF ELEVATION
      DO 17800 N=1,NM
      ELRATE(N)=ELRATE(N)/RCOSEL(N)
17800 END DO
      RETURN
      END