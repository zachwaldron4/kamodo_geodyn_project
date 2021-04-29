!$PLANPO
      SUBROUTINE PLANPO(MJDSEC,FSEC,LVELP,LBARYC,AA,II)
!********1*********2*********3*********4*********5*********6*********7**
! PLANPO           83/07/39            8308.0    PGMR - D. ROWLANDS
!
! FUNCTION:  CALCULATE MEAN OF 1950 PLANET STATE AT TIME
!            MJDSEC,FSEC
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   MJDSEC   I    S    EPHEMERIS SECONDS SINCE GEODYN REFERENCE TIME
!   FSEC     I    S    FRACTIONAL REMAINING SECONDS FROM MJDSEC
!   LVELP    I    S    .TRUE. IF VELOCITIES ARE REQUESTED
!   LBARYC   I    S    .TRUE. IF OUTPUT DESIRED IN SS BARYCENTRIC.
!                      IF SO, THE EARTH -MOON BARYCENTER WILL BE
!                      OUTPUT IN SLOT 11 OF BDSTAT
!                      .FALSE. IF OUTPUT DESIRED IN CENTER OF INTEGRATIO
!                      IF SO, THE EARTH'S MOON  WILL BE OUTPUT IN SLOT 1
!                      OF BDSTAT
!
! COMMENTS:  OUTPUT THROUGH COMMON BLOCK BDSTAT & CBARYC
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE

      COMMON/CHCFFX/COEFFX1(3,25,11),COEFFXX(3,25,988),TIMBCHEB
      COMMON/ASTSUN/BDAST(6),GMSAT,GEOPTS(3)
      COMMON/CBARYC/CBODY(6),TBODY(6),SUNRF(6)
      COMMON/CBDSTA/BDSTAT(7,999),XBDSTA
      COMMON/CBDACC/BD_ACCEL(10,999)
      COMMON/CENACC/DGCEN,TCEN,BMACEN,CCHEBV(50),EPCEN(50,3),           &
     &              DGEAR,TEAR,BMAEAR,ECHEBV(50),EPEAR(50,3),           &
     &              DGMON,TMON,BMAMON,SCHEBV(50),EPMON(50,3)
      COMMON/CGRAV/GM,AE,AESQ,FE,FFSQ32,FSQ32,XK2,XK3,XLAM,SIGXK2,      &
     &      SIGXK3,SIGLAM,RATIOM(2),AU,RPRESS
      COMMON/CORA07/KELEVT,KSRFEL,KTINT,KFSCSD,KXTIM,KFSDM,             &
     & KSGM1,KSGM2,KNOISE,KEPHMS,NXCA07
      COMMON/CORI07/KSMSA1,KSMSA2,KSMSA3,KSMST1,KSMST2,KSMST3,KSMTYP,   &
     &              KSMT1,KSMT2,KMSDM,KIOUT,KISUPE,NXCI07
      COMMON/CREFMT/REFMT(9)
      COMMON/EPHM/FSECXY(1),XP(261),YP(261),A1UT(261),EP(261),EC(261),  &
     &            FSCFLX(1),FLUXS(36),AVGFLX(36),FLUXM(288),FSECEP(1),  &
     &            EPHP(816),EPHN(96),ELIB(120),BUFT(2700),FSECNP(4)
      COMMON/EPHMPT/NTOT,NTOTS,NNPDPR,NUTORD,IBODDG(8),IGRPDG(4),       &
     &              NENPD,INRCD(2),KPLAN(11),NINEP,NEPHMR,NEPHEM,       &
     &              IBHINT,NINTBH,NXEPHP
      COMMON/EPHSET/EMFACT,DTENPD,DTINPD,FSC1EN,FSCENP(2),FSCINP(4),    &
     &   FSDINP(4),XEPHST
      COMMON/IBODPT/IBDCF(999),IBDSF(999),IBDGM(999),IBDAE(999),    &
     &              IBDPF(999),                                     &
     &              ICBDCF,ICBDSF,ICBDGM,ICBDAE,ICBDPF,             &
     &              ITBDCF,ITBDSF,ITBDGM,ITBDAE,ITBDPF,NXBDPT
      COMMON/IDUAL/IASTSN
      COMMON/IEPHM2/ISUPL,ICBODY,ISEQB(2),MAXDEG,ITOTSE,IREPL(988), &
     &              NXEPH2
      COMMON/IORCHB/ IORM,IORJ,IORSA,IORSUN,IOREM,IORMO,IORCB,IORTB,    &
     &               IGRP,ICHBOG(2,14),IORSCB(988),NXORCH
      COMMON/LCBODY/LEARTH,LMOON,LMARS
      COMMON/LDUAL/LASTSN,LSTSNX,LSTSNY
      COMMON/LEPHM2/LXEPHM
      COMMON/PLNETI/IPLNET(999),IPLNIN(999),MPLNGD(999),MPLNGO(999),   &
     &              IPLNZ(999),NXPLNI
      DIMENSION FNSEC(4),IGRPPT(4),DT(4),CHB(15),CHBV(15),CHBA(15)
      DIMENSION BMA(4),ITEST(4),CB(9),CBM(9),TB(9)
      DIMENSION IMAP(11)
      DIMENSION XSTAT(7,10)
      DIMENSION AA(1),II(1)
      DATA ZERO/0.D0/,ONE/1.D0/,TWO/2.D0/
      DATA FNSEC/2764800.D0,1382400.D0,691200.D0,345600.D0/
      DATA CHB(1)/1.D0/,CHBV(1)/0.D0/,CHBV(2)/1.D0/
      DATA ITEST/1,2,4,8/
      DATA IMAP/2,4,5,6,7,8,9,11,3,1,10/
      EQUIVALENCE(XSTAT(1,1),BDSTAT(1,13))
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
      LACCIN=LVELP.AND.LBARYC
      TTEST=MJDSEC+FSEC-FSECEP(1)
      ITOT=0
      IF(TTEST.LE.FNSEC(1)) GO TO 10
      ITOT=NTOT
      TTEST=TTEST-FNSEC(1)
   10 CONTINUE
!   MAP MJDSEC,FSEC INTO INTERVAL  -1,1  FOR EACH PERIOD GROUP
!   FIGURE POINTER WHITHIN 32 DAY RECORD FOR EACH PERIOD GROUP
      DO 100 I=1,4
      IGRPPT(I)=TTEST/FNSEC(I)
      IF(IGRPPT(I).GE.ITEST(I)) IGRPPT(I)=ITEST(I)-1
      FSECC=FSECEP(1+ITOT)+IGRPPT(I)*FNSEC(I)
      DT(I)=((MJDSEC-FSECC)+FSEC)/FNSEC(I)
      DT(I)=DT(I)*TWO-ONE
      BMA(I)=TWO/FNSEC(I)
  100 END DO
      DO 250 IGROUP=1,4
      IF (LVELP) THEN
          ! ALSO GET ACCELERATIONS IF VELOCITIES ARE REQUESTED
          CALL CHEBPL2(CHB, CHBV, CHBA, DT(IGROUP), 15)
      ELSE
          CALL CHEBPL(CHB,CHBV,DT(IGROUP),15,LVELP)
      END IF
      DO 200 I=1,11
      IF(ICHBOG(2,IMAP(I)).NE.IGROUP) GO TO 200
      IB=ICHBOG(1,IMAP(I))
      IBPT=KPLAN(I)+3*IGRPPT(IGROUP)*IB+ITOT
      BDSTAT(1,I)=ZERO
      BDSTAT(2,I)=ZERO
      BDSTAT(3,I)=ZERO
      DO 120 K=1,IB
      IBK2=IB+1-K
      IBK11=IBPT+IBK2-1
      IBK12=(IBPT+IB)+IBK2-1
      IBK13=(IBPT+2*IB)+IBK2-1
      BDSTAT(1,I)=BDSTAT(1,I)+EPHP(IBK11)*CHB(IBK2)
      BDSTAT(2,I)=BDSTAT(2,I)+EPHP(IBK12)*CHB(IBK2)
      BDSTAT(3,I)=BDSTAT(3,I)+EPHP(IBK13)*CHB(IBK2)
  120 END DO
      BD_ACCEL(1:3,I) = BDSTAT(1:3,I)
      IF(LACCIN.AND.(I.EQ.9)) THEN
        TEAR=DT(IGROUP)
        DGEAR=DBLE(IB)
        BMAEAR=BMA(IGROUP)
        DO K=1,IB
          ECHEBV(K)=CHBV(K)
          EPEAR(K,1)=EPHP(IBK11-1+K)
          EPEAR(K,2)=EPHP(IBK12-1+K)
          EPEAR(K,3)=EPHP(IBK13-1+K)
        ENDDO
      ENDIF
      IF(LACCIN.AND.(I.EQ.11)) THEN
        TMON=DT(IGROUP)
        DGMON=DBLE(IB)
        BMAMON=BMA(IGROUP)
        DO K=1,IB
          SCHEBV(K)=CHBV(K)
          EPMON(K,1)=EPHP(IBK11-1+K)
          EPMON(K,2)=EPHP(IBK12-1+K)
          EPMON(K,3)=EPHP(IBK13-1+K)
        ENDDO
      ENDIF
      IF(LACCIN.AND.IPLNIN(ICBDGM).EQ.I) THEN
         TCEN=DT(IGROUP)
         DGCEN=DBLE(IB)
         BMACEN=BMA(IGROUP)
         DO 130 K=1,IB
         CCHEBV(K)=CHBV(K)
         EPCEN(K,1)=EPHP(IBK11-1+K)
         EPCEN(K,2)=EPHP(IBK12-1+K)
         EPCEN(K,3)=EPHP(IBK13-1+K)
  130    CONTINUE
      ENDIF
      IF(.NOT.LVELP) GO TO 200
      IBM1=IB-1
      BDSTAT(4,I)=ZERO
      BDSTAT(5,I)=ZERO
      BDSTAT(6,I)=ZERO
      BD_ACCEL(7:9,I) = ZERO
      DO 140 K=1,IBM1
      IBK2=IB+1-K
      IBK11=IBPT+IBK2-1
      IBK12=(IBPT+IB)+IBK2-1
      IBK13=(IBPT+2*IB)+IBK2-1
      BDSTAT(4,I)=BDSTAT(4,I)+EPHP(IBK11)*CHBV(IBK2)
      BDSTAT(5,I)=BDSTAT(5,I)+EPHP(IBK12)*CHBV(IBK2)
      BDSTAT(6,I)=BDSTAT(6,I)+EPHP(IBK13)*CHBV(IBK2)
      BD_ACCEL(7,I) = BD_ACCEL(7,I) + EPHP(IBK11)*CHBA(IBK2)
      BD_ACCEL(8,I) = BD_ACCEL(8,I) + EPHP(IBK12)*CHBA(IBK2)
      BD_ACCEL(9,I) = BD_ACCEL(9,I) + EPHP(IBK13)*CHBA(IBK2)
  140 END DO
      BDSTAT(4,I)=BDSTAT(4,I)*BMA(IGROUP)
      BDSTAT(5,I)=BDSTAT(5,I)*BMA(IGROUP)
      BDSTAT(6,I)=BDSTAT(6,I)*BMA(IGROUP)
      BD_ACCEL(4:6,I) = BDSTAT(4:6,I)
      BD_ACCEL(7:9,I) = BD_ACCEL(7:9,I) * BMA(IGROUP)**2
  200 END DO
  250 END DO
!
       IF(LASTSN) THEN
         DO K=1,6
          BDSTAT(K,12)=BDAST(K)+BDSTAT(K,8)
          BD_ACCEL(K,12) = BDSTAT(K,12)
         ENDDO
         BDSTAT(7,12)=GM
       ENDIF
       IF(LXEPHM) THEN
!      CALL PLANPX(MJDSEC,FSEC,XSTAT,II(KISUPE),AA(KEPHMS),LVELP,AA,II)
       CALL PLANPX(MJDSEC,FSEC,BDSTAT(1,12+IASTSN),II(KISUPE),          &
     &             AA(KEPHMS),LVELP,AA,II)
       ENDIF
      NUL=3
      NULA=3
      IF(LVELP) THEN
          NUL=6
          NULA=9
      END IF
!
!   NOW GET EARTH & EARTH'S MOON & EARTH-MOON BARYCENTER
!!!!!MODIFIED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!      WRITE(6,87652) 11, BDSTAT(1:3,11)
!      WRITE(6,87653) 11, BD_ACCEL(1:3,11)
!      WRITE(6,87652) 9, BDSTAT(1:3,9)
!      WRITE(6,87653) 9, BD_ACCEL(1:3,9)
!87652    FORMAT("PLANPO BDSTAT ",I2,3D25.11)
!87653    FORMAT("PLANPO BD_ACCEL ",I2,3D25.11)

      DO 600 I=1,NUL
      CB(I)=-EMFACT*BDSTAT(I,11)+BDSTAT(I,9)
  600 END DO
      IK=11
      DO 610 I=1,NUL
      TB(I)=BDSTAT(I,IK)+CB(I)
      BDSTAT(I,IK)=BDSTAT(I,9)
      BDSTAT(I,9)=CB(I)
  610 END DO
      DO I = 1, NULA
          CB(I) = -EMFACT*BD_ACCEL(I,11) + BD_ACCEL(I,9)
          !!!! MODIFIED TO GET ACCELERATION OF THE MOON WRT SSB !!!!
          CBM(I) = (1.0D0-EMFACT)*BD_ACCEL(I,11) + BD_ACCEL(I,9)
      END DO
      IK=11
      DO I = 1, NULA
          TB(I) = BD_ACCEL(I,IK)+CB(I)
          BD_ACCEL(I,IK) = CBM(I)
!          BD_ACCEL(I,IK) = BD_ACCEL(I,9)
          BD_ACCEL(I,9) = CB(I)
      END DO

!      WRITE(6,87652) 11, BDSTAT(1:3,11)
!      WRITE(6,87653) 11, BD_ACCEL(1:3,11)
!      WRITE(6,87652) 9, BDSTAT(1:3,9)
!      WRITE(6,87653) 9, BD_ACCEL(1:3,9)

!DEP
!     BD_ACCEL(10,1:21) = BDSTAT(7,1:21)
      BD_ACCEL(10,1:999) = BDSTAT(7,1:999)
      IF(.NOT.LBARYC) GO TO 900
! TRACKING BODY AND CENTER OF INTEGRATION TRUE OF REF COORDINATES
! DESIRED THROUGH COMMON LBARYC IN ADDITION TO MEAN OF 50 (2000)
! COORDINATES THROUGH CBDSTA
      IXPCI=IPLNIN(ICBDGM)
      IXPTK=IPLNIN(ITBDGM)
      IF(LMOON) THEN
      DO 615 I=1,NUL
      CB(I)=TB(I)
  615 END DO
      ELSE
      DO 620 I=1,NUL
      CB(I)=BDSTAT(I,IXPCI)
  620 END DO
      ENDIF
      IF(ITBDGM.EQ.4) GOTO 700
      DO 670 I=1,NUL
      TB(I)=BDSTAT(I,IXPTK)
  670 END DO
  700 CONTINUE
!     ROTATE TRACKING BODY CENTER OF INTEGRATION AND SUN
!     INTO TRUE OF REFERENCE
      DO 800 I=1,3
      IPT1=3*I-2
      IPT2=IPT1+1
      IPT3=IPT2+1
      CBODY(I)=REFMT(IPT1)*CB(1)+REFMT(IPT2)*CB(2)+REFMT(IPT3)*CB(3)
      TBODY(I)=REFMT(IPT1)*TB(1)+REFMT(IPT2)*TB(2)+REFMT(IPT3)*TB(3)
      SUNRF(I)=REFMT(IPT1)*BDSTAT(1,8)+REFMT(IPT2)*BDSTAT(2,8)          &
     &        +REFMT(IPT3)*BDSTAT(3,8)
      IF(NUL.LE.3) GO TO 800
      CBODY(I+3)=REFMT(IPT1)*CB(4)+REFMT(IPT2)*CB(5)+REFMT(IPT3)*CB(6)
      TBODY(I+3)=REFMT(IPT1)*TB(4)+REFMT(IPT2)*TB(5)+REFMT(IPT3)*TB(6)
      SUNRF(I+3)=REFMT(IPT1)*BDSTAT(4,8)+REFMT(IPT2)*BDSTAT(5,8)        &
     &        +REFMT(IPT3)*BDSTAT(6,8)
  800 END DO

      RETURN
  900 CONTINUE
!
!     GET EVERYTHING IN TERMS OF CENTER OF INTEGRATION
! FIRST GET MOON NOT EARTH MOON INTO PROPER LOCATION
      DO 925 I=1,NUL
      BDSTAT(I,IK)=TB(I)
      BD_ACCEL(I,IK)=TB(I)
  925 END DO
      IXPCI=IPLNIN(ICBDGM)
      DO 950 I=1,NUL
      CB(I)=BDSTAT(I,IXPCI)
  950 END DO
!
      IF(LXEPHM) THEN
        IK=IK+ICBODY
      ENDIF

!      WRITE(6,87653) MJDSEC, FSEC

      DO 1000 I=1,IK
      DO 1000 J=1,NUL
      BDSTAT(J,I)=BDSTAT(J,I)-CB(J)
!      WRITE(6,87654) I, BDSTAT(1:3,I)
!      WRITE(6,87655) I, BD_ACCEL(1:3,I)
!      WRITE(6,87656) I, BD_ACCEL(4:6,I)
 1000 CONTINUE


!      WRITE(6,87655) 9, BD_ACCEL(1:3,9)
!      WRITE(6,87654) 11, BDSTAT(1:3,11)
!      WRITE(6,87655) 11, BD_ACCEL(1:3,11)
87653    FORMAT("MJDSEC ",I0,D25.18)
87654    FORMAT("PLANPO BDSTAT ",I2,3D25.18)
87655    FORMAT("PLANPO BD_ACCEL ",I2,3D25.18)
87656    FORMAT("PLANPO BD_ACCEL VEL",I2,3D25.18)

      RETURN
      END
