!$TIDALR
      SUBROUTINE TIDALR(TIDESS,IMP2RS,RESP,EXPART,NEQN,ACCT)
!********1*********2*********3*********4*********5*********6*********7**
! TIDALR           00/00/00            8604.0    PGMR - ?
!
! FUNCTION:  COMPUTES FREQUENCY INDEPENDENT EARTH TIDES OF DEGREE
!            TWO AND THREE
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   TIDESS   I    A    CURRENT VALUES OF THE FREQUENCY INDEPENDENT
!                      EARTH TIDES. THESE AREA AND B COEFFICIENTS.
!   IMP2RS   I    A    MAP FROM THE TIDE PAIRS TO THE NRESP UNIQUE
!                      RESPONSE DEGREE AND ORDERS THAT ARE CONTAINED
!                      IN THE RESP ARRAY
!   RESP     I    A    ARRAY WHICH HOLDS RESPONSE EFFECT INFORMATION
!                      (FILLED IN TIDCNR). THIS ARRAY IS EQUIVALENT
!                      TO THE EXPLICIT PARTIALS OF ACCELERATION WITH
!                      RESPECT TO GEOPOTENTIAL COEFFICIENTS
!   EXPART   O    A    ARRAY OF EXPLICIT PARTIALS OF ACCELERATION
!                      WRT FORCE MODEL PARAMETERS
!   NEQN     I    S    NUMBER OF ADJUSTING FORCE MODEL PARAMETERS
!                      ASSOCIATED WITH CURRENT SATELLLITE
!   ACCT    I/O   A    UPON INPUT ACCERATIONS DUE TO FREQUENCY
!                      DEPENDENT TIDES. UPON OUTPUT THE FREQUENCY
!                      INDEPEDENT EARTH TIDES OF DEGREE 2 & 3
!                      HAVE BEEN ADDED IN
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      COMMON/LCBODY/LEARTH,LMOON,LMARS
      COMMON/CGRAV/GM,AE,AESQ,FE,FFSQ32,FSQ32,XK2,XK3,XLAM,SIGXK2,      &
     &      SIGXK3,SIGLAM,RATIOM(2),AU,RPRESS
      COMMON/CTIDES/NTIDE,NSTADJ,NET,NETADJ,NETUN,NOT,NOTADJ,           &
     &   NOTUN ,NETUNU,NETADU,NOTUNU,NOTADU,NBSTEP,KTIDA(3),            &
     &   ILLMAX,NUNPLY,NNMPLY,NDOODN,MXTMRT,NRESP ,NXCTID
      COMMON/CEFMAT/EFMAT(9)
      COMMON/MNSNSP/XMNSNS(7,2)
      COMMON/SETADJ/LSADRG(4),LSASRD(4),LSAGA(4),LSAGP,LSATID,LSAGM,    &
     &              LSADPM,LSAKF,LSADNX,LSADJ2,LSAPGM
      COMMON/SETAPT/                                                    &
     &       JSADRG(1),JSASRD(1),JSAGA(1),JFAADJ,JTHDRG,JACBIA,JATITD,  &
     &       JDSTAT,JDTUM ,                                             &
     &       JSACS, JSATID,JSALG,JSAGM,JSAKF,JSAXYP,JSADJ2,JSAPGM,      &
     &       JFGADJ,JLTPMU,JLTPAL,JL2CCO,JL2SCO,JL2GM,JLRELT,           &
     &       JLJ2SN,JLGMSN,JLPLFM,JL2AE,JSAXTO,JSABRN
      DIMENSION TIDESS(2,10)
      DIMENSION IMP2RS(10),RESP(NRESP,6)
      DIMENSION EXPART(NEQN,3)
      DIMENSION RNM(7)
      DIMENSION ACC(3,10,2,2)
      DIMENSION ACCT(3)
      DIMENSION XATIOM(2)

!
!
!
!**********************************************************************
!* START OF EXECUTABLE CODE *******************************************
!**********************************************************************
!
!
!
      XATIOM(1)=RATIOM(1)
      XATIOM(2)=RATIOM(2)
      IF(LMOON) THEN
       XATIOM(1)=1.D0/RATIOM(1)
       XATIOM(2)=XATIOM(1)*RATIOM(2)
      ENDIF

      DO 200 IBOD=1,2
! GET BODY FIXED COORDINATES OF FORCING BODY (1 MOON : 2 SUN)
      XBODY=EFMAT(1)*XMNSNS(1,IBOD)+EFMAT(4)*XMNSNS(2,IBOD)             &
     &     +EFMAT(7)*XMNSNS(3,IBOD)
      YBODY=EFMAT(2)*XMNSNS(1,IBOD)+EFMAT(5)*XMNSNS(2,IBOD)             &
     &     +EFMAT(8)*XMNSNS(3,IBOD)
      ZBODY=EFMAT(3)*XMNSNS(1,IBOD)+EFMAT(6)*XMNSNS(2,IBOD)             &
     &     +EFMAT(9)*XMNSNS(3,IBOD)
      RBODY=XMNSNS(4,IBOD)
      RBXY=SQRT(XBODY*XBODY+YBODY*YBODY)
      COSL=XBODY/RBXY
      SINL=YBODY/RBXY
      CSTHET=ZBODY
      SNTHET=SQRT(1.D0-CSTHET*CSTHET)
      CALL LGN33(CSTHET,SNTHET,COSL,SINL,RNM,COS2L,COS3L,SIN2L,SIN3L)
      AER=AE/RBODY
! DEGREE TWO FORCING TERMS
      FACT=XATIOM(IBOD)*AER*AER*AER
      RNM(1)=RNM(1)*FACT
      RNM(2)=RNM(2)*FACT
      RNM(3)=RNM(3)*FACT
! DEGREE THREE FORCING TERMS
      FACT=FACT*AER
      RNM(4)=RNM(4)*FACT
      RNM(5)=RNM(5)*FACT
      RNM(6)=RNM(6)*FACT
      RNM(7)=RNM(7)*FACT
!
      DO 100 ITERM=1,10
      IF(ITERM.EQ.1.OR.ITERM.EQ.4) THEN
        FORCEC=RNM(1)
        FORCES=0.D0
      ENDIF
      IF(ITERM.EQ.2.OR.ITERM.EQ.5) THEN
        FORCEC=RNM(2)*COSL
        FORCES=RNM(2)*SINL
      ENDIF
      IF(ITERM.EQ.3.OR.ITERM.EQ.6) THEN
        FORCEC=RNM(3)*COS2L
        FORCES=RNM(3)*SIN2L
      ENDIF
      IF(ITERM.EQ.7) THEN
        FORCEC=RNM(4)
        FORCES=0.D0
      ENDIF
      IF(ITERM.EQ.8) THEN
        FORCEC=RNM(5)*COSL
        FORCES=RNM(5)*SINL
      ENDIF
      IF(ITERM.EQ.9) THEN
        FORCEC=RNM(6)*COS2L
        FORCES=RNM(6)*SIN2L
      ENDIF
      IF(ITERM.EQ.10) THEN
        FORCEC=RNM(7)*COS3L
        FORCES=RNM(7)*SIN3L
      ENDIF
!
      ACC(1,ITERM,1,IBOD)=FORCEC*RESP(IMP2RS(ITERM),1)                  &
     &                   +FORCES*RESP(IMP2RS(ITERM),4)
      ACC(1,ITERM,2,IBOD)=FORCES*RESP(IMP2RS(ITERM),1)                  &
     &                   -FORCEC*RESP(IMP2RS(ITERM),4)
      ACC(2,ITERM,1,IBOD)=FORCEC*RESP(IMP2RS(ITERM),2)                  &
     &                   +FORCES*RESP(IMP2RS(ITERM),5)
      ACC(2,ITERM,2,IBOD)=FORCES*RESP(IMP2RS(ITERM),2)                  &
     &                   -FORCEC*RESP(IMP2RS(ITERM),5)
      ACC(3,ITERM,1,IBOD)=FORCEC*RESP(IMP2RS(ITERM),3)                  &
     &                   +FORCES*RESP(IMP2RS(ITERM),6)
      ACC(3,ITERM,2,IBOD)=FORCES*RESP(IMP2RS(ITERM),3)                  &
     &                   -FORCEC*RESP(IMP2RS(ITERM),6)
!
      ACCT(1)=ACCT(1)+TIDESS(1,ITERM)*ACC(1,ITERM,1,IBOD)               &
     &               +TIDESS(2,ITERM)*ACC(1,ITERM,2,IBOD)
      ACCT(2)=ACCT(2)+TIDESS(1,ITERM)*ACC(2,ITERM,1,IBOD)               &
     &               +TIDESS(2,ITERM)*ACC(2,ITERM,2,IBOD)
      ACCT(3)=ACCT(3)+TIDESS(1,ITERM)*ACC(3,ITERM,1,IBOD)               &
     &               +TIDESS(2,ITERM)*ACC(3,ITERM,2,IBOD)
  100 END DO
  200 END DO
!
      IF(NSTADJ.LE.0.OR..NOT.LSATID) RETURN
!
!  WRITE OUT PARTIALS ; WITH STANDARD TIDES ALL 10 TERMS
!  (20 PARAMETERS) ARE ADJUSTED, EVEN IF 1 IS ADJUSTED
      DO 300 ITERM=1,10
      IP1=JSATID+(ITERM-1)
      IP2=IP1+10
      EXPART(IP1,1)=ACC(1,ITERM,1,1)+ACC(1,ITERM,1,2)
      EXPART(IP1,2)=ACC(2,ITERM,1,1)+ACC(2,ITERM,1,2)
      EXPART(IP1,3)=ACC(3,ITERM,1,1)+ACC(3,ITERM,1,2)
      EXPART(IP2,1)=ACC(1,ITERM,2,1)+ACC(1,ITERM,2,2)
      EXPART(IP2,2)=ACC(2,ITERM,2,1)+ACC(2,ITERM,2,2)
      EXPART(IP2,3)=ACC(3,ITERM,2,1)+ACC(3,ITERM,2,2)
  300 END DO
      RETURN
      END