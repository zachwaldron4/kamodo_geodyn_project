!$
      SUBROUTINE MENDEZ(COSEL,SINEL,EDOT,RNM,CDRY,CWET,CION,NM,         &
     &   MODELT,LNDRYT,LNWETT,LNIONO,BLKMET,OBSMET,LOBMET,LALTON,       &
     &   RLATA,COSLTA,SINLTA,HTA,MTYPE,MJDSBL,FSEC,IWPR,NSTA0)
!********1*********2*********3*********4*********5*********6*********7**
! MENDEZ           00/00/00            0000.0    PGMR - ?
!
!
! FUNCTION:  TROP REFRACTION CORRECTION USING MENDEZ MODEL
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   COSEL    I    A    COSINE OF ELEVATION
!   SINEL    I    A    SINE OF ELEVATION
!   EDOT     I    A    TIME RATE OF CHANGE OF ELEVATION
!   RNM      I    A    RANGE FROM STATION TO S/C
!   CDRY     O    A    DRY TROPOSPHERIC REFRACTION CORRECTION
!   CWET     O    A    WET TROPOSPHERIC REFRACTION CORRECTION
!   CION     O    A    IONOSPHERIC REFRACTION CORRECTION
!   NM       I    S    NUMBER OF OBSERVATION IN THIS LOGICAL BLOCK
!   MODELT   I    S    REFRACTION MODEL INDICATOR
!   LNDRYT   I    S    LOGICAL FLAG TO THE DRY TROPOSPHERIC REFRACTION
!                      CORRECTION
!   LNWETT   I    S    LOGICAL FLAG TO THE WET TROPOSPHERIC REFRACTION
!                      CORRECTION
!   LNIONO   I    S    LOGICAL FLAG TO THE IONOSHPERIC REFRACTION
!                      CORRECTION
!   BLKMET   I    S    METEOROLOGICAL DATA FROM THE BLOCK HEADER RECORDS
!   OBSMET   I    A    METEOROLOGICAL DATA FOR EACH OBSERVATION IN THE
!                      BLOCK
!   LOBMET   I    S    LOGICAL FLAG FOR METEOROLOGICAL DATA
!
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      COMMON/CBLOKL/LIGHT ,LNRATE,LNREFR,LPOLAD,LTDRIV,LNANT ,LNTRAK,   &
     &       LASER ,LGPART,LGEOID,LETIDE,LOTIDE,LNTIME,LAVGRR,LRANGE,   &
     &       LSSTMD,LSSTAJ,LNTDRS,LPSBL,LACC,LAPP,LTARG,LTIEOU,LEOTRM,  &
     &       LSURFM,LGEOI2,LSSTM2,LOTID2,LOTRM2,LETID2,LNUTAD
      COMMON/CITERL/LSTGLB,LSTARC,LSTINR,LNADJ ,LITER1,LSTITR,          &
     &              LOBORB,LRESID,LFREEZ,LSAVEF,LHALT,LADJPI,LADJCI
      COMMON/CMET/P0,T0,RELHUM,E0,WAVLEN
      COMMON/CMETI /MODEL(999),MWET(999),MDRY(999),MODESC(999),        &
     &              MAPWET(999),MAPDRY(999),METP(999),IRFRC,           &
     &              IRFPRT(10),NXCMTI
      COMMON/CBLOKA/FSECBL,SIGNL ,VLITEC,SECEND,BLKDAT(6,4),DOPSCL(5,4)
      COMMON/CONSTR/PI,TWOPI,DEGRAD,SECRAD,SECDAY
      COMMON/CSTA/RLAT,COSLAT,SINLAT,RLON,COSLON,SINLON,HEIGHT,         &
     &   TMOUNT,DISP,WAVREC,WAVXMT,ELCUT,PLATNO,SITNOL,SDTLRA,ANTTNO
      COMMON/GPSBLK/LGPS,LNOARC,LSPL85,NXGPS
      DIMENSION COSEL(NM),SINEL(NM),EDOT(NM),RNM(NM),CDRY(NM),CION(NM)
      DIMENSION OBSMET(NM),CWET(NM),FSEC(NM),JYMD(1),JHM(1),FSEC1(1)
      DIMENSION RLATA(NM),COSLTA(NM),SINLTA(NM),HTA(NM)
      DIMENSION HMF(2),WMF(2),IOROGRAPHY_ARRAY(91,145)
      DATA ZERO/0.0D0/,ONE/1.0D0/,HUNDRD/100.0D0/,C1500/1.5D3/
      DATA CFLAM0/0.965D0/,CFLAM2/0.0164D-12/,CFLAM4/0.228D-27/
      DATA CFPOSL/-2.6D-3/,CFPOSH/-3.1D-7/,DPDH/-1.1138D-4/
      DATA P1ATM/1013.5D0/,STDTMP/293.16D0/,VAPOR0/9.35D0/
      DATA kentry/0/

      PARAMETER( HALF = 0.5D0 )
      PARAMETER( C1D2 = 1.0D2 )
      PARAMETER( C1D6 = 1.0D6 )

      INTEGER :: IWPR
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!      write(6,*) 'jtw I am in MENDEZ'
!
      kentry = kentry + 1

      IF(LNDRYT) GO TO 5000
      IF(.NOT.LALTON) THEN
         CALL METDAT(BLKMET)
         IF(P0.GT.HUNDRD.AND.P0.LT.C1500) GO TO 1000
! DEFAULT PRESSURE, TEMPERATURE AND WATER VAPOR PRESSURE
         P0=P1ATM*(ONE+DPDH*HEIGHT)
         T0=STDTMP
         E0=VAPOR0
 1000 CONTINUE
      ENDIF

      MODE=1
      IF(LASER) MODE=2
      MODELX=MODELT

      CALL XDOY(DOY)

      RLATD=RLAT*57.295777951D0
! CONVERT WAVELENGTH TO METERS AND LATITUDE IN DEGREES
      W1=WAVLEN*1.D06
      PHI_DEG=RLAT/DEGRAD

! BEGIN DO LOOP
      DO 2800 N=1,NM
      IF(LOBMET.AND..NOT.LALTON) CALL METDAT(OBSMET(N))
      IF(LALTON) THEN
        HEIGHT=HTA(N)
        IF(LOBMET) THEN
           CALL METDAT(OBSMET(N))
        ELSE
           CALL METDAT(BLKMET)
           IF(P0.LT.HUNDRD.OR.P0.GT.C1500) THEN
! DEFAULT PRESSURE, TEMPERATURE AND WATER VAPOR PRESSURE
              P0=P1ATM*(ONE+DPDH*HEIGHT)
              T0=STDTMP
              E0=VAPOR0
            ENDIF
        ENDIF
      ENDIF

!ecp  This is the final, published version of the new ZTD model, broken
!      and WET delay:

      CALL fculzd_hPa(PHI_DEG, HEIGHT, P0, E0, W1, TZD, TZDRY, TZDWET)

      IF(METP(MTYPE).EQ.0)                                              &
     &       CDRY(N)=FCULA(PHI_DEG,HEIGHT,T0,SINEL(N),TZDRY)
      IF(METP(MTYPE).EQ.0)                                              &
     &       CWET(N)=FCULA(PHI_DEG,HEIGHT,T0,SINEL(N),TZDWET)
      IF(METP(MTYPE).EQ.1)                                              &
     &       CDRY(N)=FCULB(PHI_DEG,HEIGHT,DOY,SINEL(N),TZDRY)
      IF(METP(MTYPE).EQ.1)                                              &
     &       CWET(N)=FCULB(PHI_DEG,HEIGHT,DOY,SINEL(N),TZDWET)



          CALL YMDHMS(MJDSBL,FSEC(N),JYMD,JHM,FSEC1,1)
          IF(JYMD(1).GE.1000000)JYMD(1)=JYMD(1)-1000000
          STRTIM=DBLE(JYMD(1))*C1D6 + DBLE(JHM(1))*C1D2+ FSEC1(1)

          IF (LITER1 .AND. IWPR==1) THEN

!           WRITE(6,*)'NSTA0, STRTIM, CDRY, CWET'
!           WRITE(6,*)NSTA0,STRTIM,CDRY(N),CWET(N)
!           WRITE(400,'(I8,1x,G24.16,1X,E,1x,E)') NSTA0,STRTIM,CDRY(N),CWET(N)
           WRITE(400,'(I8,1x,G24.16,1X,E20.10,1x,E20.10)') &
                 NSTA0,STRTIM,CDRY(N),CWET(N)

          ENDIF




 2800 END DO

 5000 CONTINUE
      IF(LNIONO) RETURN
      RETURN
      END
