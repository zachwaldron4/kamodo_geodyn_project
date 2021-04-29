      SUBROUTINE PSS(NRAT1,CPPNC,IORDER,IOL1,IOL2,H,H2,SUMX,XDDOT,NSAT, &
     &               N3,XLSASS,IBCKNC,XPNC,XNC,CPP,CPV,CCP,CCV,HS,HS2,  &
     &               SUMXNC,XDDTNC,MJDSEC,FSEC,IDSMXN,IDXDDN,           &
     &               ISATID,XDDTAC,LFHIRT,LSURFF,NTCRD,NEQN,XDDOTL,     &
     &               PXDDTL,XDDTMC,TOPXAT,LTPXAT,PXDDAC,NEQNA,IPTFBS,   &
     &               NPRMAC,DYNTIM,NPERDY,EXACCT,EXACIN,EXACOB,LACCELS, &
     &               ACCTIM,ACCPER,NPERAC,IACCP,PACCL,NXSTAT,TXSTAT,    &
     &               DELXST,SUMRNC,IPXST,HREMAL,LXSTAT,JPXST,XPNC2,     &
     &               XP,DSROT,XDDRC,LSBURN,IPSBRN,LFBURN,XDDBRN,AA,II,  &
     &               LL)
!********1*********2*********3*********4*********5*********6*********7**
! PSS
!
! FUNCTION:  NUMERICAL INTEGRATION OF SMALL STEP STATE AT "INBETWEEN"
!            STEPS AND PREDICTION OF SMALL STEP STATE AT LARGE STEP
!
! I/O PARAMETERS:
!
!   NRAT1    I    S    NRAT-1 WHERE NRAT=RATIO OF LARGE STEP SIZE TO
!                      SMALL STEP SZ (NRAT=1 => SINGLE RATE INTEGRATION)
!   CPPNC    I    A    COEFFICIENTS FOR PRDICTING LARGE STEP STATE
!                      AT SMALL STEP TIMES
!   IORDER   I    S    ORDER OF COWELL INTEGRATION FOR ORBIT
!   IOL1     I    S    IORDER-1
!   IOL2     I    S    IORDER-2
!   H        I    S    INTEGRATION LARGE STEP SIZE IN SECONDS
!   H2       I    S    H*H
!   SUMX     I    A    INTEGRATION SUMS FOR ORBIT (LARGE STEP)
!   XDDOT    I    A    ORBIT ACCELERATIONS (LARGE STEP)
!   NSAT     I    A    NUMBER OF SATELLITES BEING INTEGRATED IN THIS
!                      CALL
!   N3       I    S    NSAT*3
!   XLSASS   I    A    COEFFICIENTS FOR PRDICTING LARGE STEP STATE
!   IBCKNC  I/O   S    COUNTER INDICATING WHERE CURRENT INTEGRATION
!                      IS IN THE SUMXNC ARRAY
!   XPNC     O    A    PREDICTED S/C POS. AND VEL. SMALL STEP
!   XNC      O    A    CORRECTED SC POS. AND VEL. SMALL STEP
!   CPP      I    S    COWELL COEFFICIENTS FOR PREDICTING POSITION
!   CPV      I    S    COWELL COEFFICIENTS FOR PREDICTING VELOCITY
!   CCP      I    A    COWELL COEFFICIENTS FOR CORRECTING POSITION
!   CCV      I    A    COWELL COEFFICIENTS FOR CORRECTING VELOCITY
!   HS       I    S    INTEGRATION SMALL STEP SIZE IN SECONDS
!   HS2      I    S    HS*HS
!   MJDSEC   I    S    CURRENT DATE AND INTEGRAL SECONDS OF TIME
!                      OF LARGE STEP ORBIT INTEGRATION
!   FSEC     I    S    CURRENT FRACTIONAL SECONDS FROM MJDSEC
!   SUMXNC  I/O   A    SMALL STEP INTEGRATION SUMS
!   XDDTNC  I/O   A    SMALL STEP ACCELERATIONS
!   IDSMXN   I    S    NUMBER OF STEPS COVERED BY (LAST DIMENSION OF)
!                      THE SUMXNC ARRAY
!   IDXDDN   I    S    NUMBER OF STEPS COVERED BY (LAST DIMENSION OF)
!                      THE XDDTNC ARRAY
!   ISATID        A    SAT ID ARRAY
!   XDDTAC  I/O   A    COMPUTED ACCELERATIONS CORRESPONDING TO
!                      ACCELEROMTER
!   LFHIRT   I    A    ARRAY OF LOGICAL FLAGS. EACH ELEMENT
!                      CORRESPONDS TO A FORCE MODEL COMPONENT.
!                      THE ARRAY DESCRIBES WHICH COMPONENTS ARE
!                      INTEGRATED AT A HIGH RATE.
!   LSURFF   I    A    ARRAY OF LOGICAL FLAGS. EACH ELEMENT
!                      CORRESPONDS TO A FORCE MODEL COMPONENT.
!                      THE ARRAY DESCRIBES WHICH COMPONENTS ARE
!                      INTEGRATED AT A HIGH RATE.
!   NTCRD    I    S    COORDINATE SYSTEM STEP NUMBER (COORDINATE
!                      SYSTEM CALLS ARE MADE IN ADVANCE BY SUBROUTINE
!                      COWELL FOR INTEGRATION STEPS) AT THE NEXT
!                      LARGE STEP
!   NEQN     I    S    NUMBER OF ADJUSTING FORCE MODEL PARAMETERS
!   XDDOTL   O    A    ARRAY USED TO HOLD LARGE STEP ACCELERATIONS
!                      COMPUTED (AND NOT USED) AT SMALL STEPS
!   PXDDTL   O    A    ARRAY USED TO HOLD EXPLICT FORCE MODEL PARTIALS
!   XDDTMC   O    A    ARRAY USED TO HOLD COMPLETE ACCELERATIONS
!                      EXCEPT PT MASS ACCELERATION
!   TOPXAT   O    A    ARRAY USED TO HOLD TOPEX ATTITUDE INFORMATION
!   LTPXAT   O    A    ARRAY USED TO HOLD TOPEX APTITUDE INFORMATION
!   PXDDAC   O    A    PARTIAL DERIVATIVES OF XDDTAC
!   NEQNA    I    S    NUMBER OF ADJUSTING ACCELEROMTER PARTIALS
!   IPTFBS   I    A    MAPPING ARRAY ; EXPLICIT PARTIAL ARRAY TO
!                      COMPUTED ACCELERATION PARTIAL ARRAY
!   NPRMAC   I    A    NUMBER OF PARMETERS IN EACH FORCE MODEL
!                      GROUP CATEGORY YO BE MAPPED BY IPTFBS
!   DYNTIM   I    A    USER REQUESTED START AND STOP TIMES FOR
!                      DYNAMIC ACCELERATION ACCELEROMETER PERIODS
!   NPERDY   I    A    NUMBER OF USER REQUESTED
!                      DYNAMIC ACCELERATION ACCELEROMETER PERIODS
!   NXSTAT   I    S    NUMBER OF DSTATE EPOCHS
!   TXSTAT   I    A    DSTATE EPOCHS IN ELAPSED TIME SECONDS SINCE
!                      JD 2430000.5
!   DELXST   I&O  A    ARRAY OF DELSTATE VALUES.ID YJESE ARE INPUT
!                      IN LOCAL ORBIT PLANE, THEY ARE ROTATED TO
!                      TRUE OF REFERENCE. THIS ARRAY IS REINITIALIZED
!                      IN INITI EVERY ITERATION.
!   IPXST    I    S    STARTING LOCATION IN THE FORCE MODEL EXPLICIT
!                      PARTIAL AEEAY FOR DELTA STATES
!   HREMAL   O    S    FRACTION BASED ON WHERE DELTA STATE FALL WRT
!                      CLOSEST STEP SIZE )ZERO FOR THIS ROUTINE)
!   LXSTAT   O    S    SET TO FALSE, THEN TO TRUE IF A DSTATE OCCURS
!                      AT CURRENT STEP
!   JPXST    O    S    SET TO ZERO, IF THERE IS A DELTA STATE AT
!                      CURRENT STEP SET TO LOCATION OF THAT PARAMETER
!                      IN THE EXPLICIT PARTIAL ARRAY
!   DSROT   I&O   A    ON INPUT THE IDENITY MATRIX. IF THERE IS A
!                      DSTATE AT THE CURRENT STEP AND IF THAT DSTATE
!                      IS IN THE LOCAL ORBIT COORDINTE SYSTEM, A ROTATION
!                      MATRIX TO GO TO TRUE OF REFERENCE IS OUTPUT
!  LSBURN     O    S   TRUE IFF THIS CALL INITIATES A BURN (IN ONE
!                      OF THE SMALK STEPS OF THIS CALL)
!  IPSBRN     O    S   POINTER IN THE FORCE MODEL EXPLICIT PARTIAL
!                      ARRAY TO THE FIRST PARAMTER IN THE ACTIVE BURN
!  LFBURN     O    S   TRUE IFF THIS CALL INITIATES A BURN (IN ONE
!                      OF THE SMALL STEPS OF THIS CALL)
!  XDDBRN     O    A   BURN ACCELERATION AT THE STEP OF INITIATION
!   AA      I/O   A    REAL DYNAMIC ARRAY
!   II      I/O   A    INTEGER DYNAMIC ARRAY
!   LL      I/O   A    LOGICAL DYNAMIC ARRAY
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      COMMON/ACCEL9/MXACC9,ITOTGA,NUMGA,ITYPGA,MACC,NXACC9
      COMMON/ACCLRM/MDYNPD,MBAPPD,MACOBS,IDYNSC(200),MDYNST,IACCSC(200),&
     &              MACCSC,NACPRM(200),NATPRM(200),NXCLRM
      COMMON/NFORCE/NHRATE,NSURF,MPXHDT,MXHRG,MXFMG,NFSCAC,NXFORC
      COMMON/CONTRL/LSIMDT,LOBS  ,LORB  ,LNOADJ,LNADJL,LORFST,LORLST,   &
     &              LORALL,LORBOB,LOBFST,LOBLST,LOBALL,LPREPO,LORBVX,   &
     &              LORBVK,LACC3D,LSDATA,LCUTOT,LACCEL,LDYNAC,LFRCAT,   &
     &              LNIAU, NXCONT
      COMMON/CORA01/KFSEC0,KFSECB,KFSEC ,KFSECV,KH    ,KHV   ,KCTOL ,   &
     &              KRSQ  ,KVMATX,KCPP  ,KCPV  ,KCCP  ,KCCV  ,KCCPV ,   &
     &              KCCVV ,KXPPPP,KX    ,KPX   ,KSUMX ,KXDDOT,KSUMPX,   &
     &              KPXDDT,KAB   ,KPN   ,KAORN ,KSINLM,KCOSLM,KTANPS,   &
     &              KCRPAR,KVRARY,KXM   ,KXNP1 ,KXPRFL,KXM2  ,KXNNP1,   &
     &              KWRK  ,KFI   ,KGE   ,KB0DRG,KBDRAG,KAPGM ,KAPLM ,   &
     &              KCN   ,KSN   ,KSTID ,KTIDE ,KSTDRG,KSTSRD,KSTACC,   &
     &              KLGRAV,KGM   ,KAE   ,KFPL  ,KFEQ  ,KPLNPO,KPLNVL,   &
     &              KXEPOC,KCD   ,KCDDOT,KCR   ,KGENAC,KACN  ,KASN  ,   &
     &              KTHDRG,KCKEP ,KCKEPN,KXNRMZ,KXNRMC,KFSCEP,KFSCND,   &
     &              KAREA ,KXMASS,KRMSPO,KTCOEF,KTXQQ ,KTIEXP,KTXMM ,   &
     &              KTXLL1,KTXSN1,KTS2QQ,KT2M2H,KT2MHJ,KTXKK ,KTSCRH,   &
     &              KPXPK ,KAESHD,KCSAVE,KSSAVE,KCGRVT,KSGRVT,KXDTMC,   &
     &              KDNLT ,KTXSN2,KTNORM,KTWRK1,KTWRK2,KUNORM,KAERLG,   &
     &              KSINCO,KPARLG,KCONST,KBFNRM,KTDNRM,KCSTHT,KTPSTR,   &
     &              KTPSTP,KTPFYW,KPLMGM,KTPXAT,KEAQAT,KEAFSS,KEAINS,   &
     &              KACS  ,KECS  ,KSOLNA,KSOLNE,KSVECT,KSFLUX,KFACTX,   &
     &              KFACTY,KADIST,KGEOAN,KPALB ,KALBCO,KEMMCO,KCNAUX,   &
     &              KSNAUX,KPPER ,KACOSW,KBSINW,KACOFW,KBCOFW,KANGWT,   &
     &              KWT   ,KPLNDX,KPLANC,KTGACC,KTGDRG,KTGSLR,KWTACC,   &
     &              KWTDRG,KWTSLR,KTMACC,KTMDRG,KTMSLR,KATTUD,KDYACT,   &
     &              KACCBT,KACPER,KXDDNC,KXDDAO,KXNC  ,KXPPNC,KSMXNC,   &
     &              KXDDTH,KPDDTH,KXSSBS,KCPPNC,KEXACT,KXACIN,KXACOB,   &
     &              KPXHDT,KTPXTH,KPACCL,KTXSTA,KDELXS,KSMRNC,KPRX  ,   &
     &              KSMRNP,KDSROT,KXUGRD,KYUGRD,KZUGRD,KSUMRC,KXDDRC,   &
     &              KTMOS0,KTMOS, KTMOSP,KSMXOS,KSGTM1,KSGTM2,KSMPNS,   &
     &              KXGGRD,KYGGRD,KZGGRD,KXEGRD,KYEGRD,KZEGRD,KSSDST,   &
     &              KSDINS,KSDIND,KSSDSR,KSSDDG,KTATHM,KTAINS,KTAFSS,   &
     &              KSRAT ,KTRAT ,KHLDV ,KHLDA1,KHLDA4,KHLDA7,KQAST1,   &
     &              KQAST2,KQAST3,KQAST4,KQAST5,KQAST6,NXCA01
      COMMON/CORA06/KPRMV ,KPNAME,KPRMV0,KPRMVC,KPRMVP,KPRMSG,KPARVR,   &
     &              KPRML0,KPDLTA,KSATCV,KSTACV,KPOLCV,KTIDCV,KSUM1 ,   &
     &              KSUM2 ,KGPNRA,KGPNRM,KPRSG0,KCONDN,KVELCV,          &
     &              KSL2CV,KSH2CV,KTIEOU,KPRMDF,NXCA06
      COMMON/CORI01/KMJDS0,KMJDSB,KMJDSC,KMJDSV,KIBACK,KIBAKV,KIORDR,   &
     &              KIORDV,KNOSTP,KNOCOR,KNSAT ,KN3   ,KNEQN ,KNEQN3,   &
     &              KNH   ,KNHV  ,KNSTPS,KNSTPV,KICPP ,KICPV ,KICCP ,   &
     &              KICCV ,KICCPV,KICCVV,KISUMX,KIXDDT,KISMPX,KIPXDD,   &
     &              KNMAX ,KNTOLD,KNTOLO,KICNT ,KISNT ,KMM   ,KKK   ,   &
     &              KJJ   ,KHH   ,KIBDY ,KSIGN1,KSIGN2,KLL   ,KQQ   ,   &
     &              KIORFR,KIPDFR,KITACC,KJSAFR,KJSPFR,KMJDEP,KMJDND,   &
     &              KNVSTP,KNSTRN,KNDARK,KTIPPT,KTJBDY,                 &
     &              KICNTA,KISNTA,KISHDP,KIPTC ,KIPTS ,KIGTSR,KIXTMC,   &
     &              KTIPTT,KTNOSD,KTQNDX,KTLL1 ,KTJJBD,KTITDE,KTCNTR,   &
     &              KTNN  ,KITACX,KNMOVE,KPANEL,KPLPTR,KNADAR,KNADSP,   &
     &              KNADDF,KNADEM,KNADTA,KNADTC,KNADTD,KNADTF,KNADTX,   &
     &              KITPMD,KSCATT,KITPAT,KILTPX,KEASBJ,KEANMP,KEANAN,   &
     &              KEAPMP,KEAPAN,KEAMJS,KEAPPP,KEAAAA,KICNTT,KISNTT,   &
     &              KTPGRC,KTPGRS,KTPC  ,KTPS  ,KALCAP,KEMCAP,KNSEG ,   &
     &              KICNTP,KISNTP,KNRDGA,KNRDDR,KNRDSR,KIRDGA,KIRDRG,   &
     &              KIRSLR,KSTRTA,KSTRTD,KSTRTS,KDYNPE,KACCPE,KIBCKN,   &
     &              KNRAT ,KIXDDN,KISMXN,KDXDDN,KDSMXN,KICPPN,KACSID,   &
     &              KNEQNH,KHRFRC,KPTFBS,KPTFSB,KIPXDA,KIACCP,KXSTAT,   &
     &              KPXST ,KSALST,KMAPLG,KNMBUF,KSTEPS,KSGMNT,KSATIN,   &
     &              KMEMST,KNEQNI,KBUFIN,KWEMGA,KWEMDR,KTPATS,KTANMP,   &
     &              KTAPPP,KTAMJS,KTASID,KGPSID,KNSSVA,KPNALB,KBRAX1,   &
     &              KBRAX2,KBRAX3,NXCI01
      COMMON/IDELTX/MXSTAT,NEVENTS,NDSTAT,IDSYST,NDELTX
      DIMENSION SUMX(N3,2),                                             &
     &   XDDOT(N3,IOL1)
      DIMENSION CPP(IORDER),CPV(IORDER),                                &
     &    CCP(IORDER),CCV(IORDER)
      DIMENSION AA(1),II(1),LL(1)
      DIMENSION ISATID(NSAT)
      DIMENSION XDDTNC(N3,IDXDDN),SUMXNC(N3,2,IDSMXN)
!  XPNC AND XPNC2 ARE THE SAME ARRAY PASSED IN TO PSS FROM COWELL
      DIMENSION XPNC(N3,2),XPNC2(3,NSAT,2),XNC(N3,2)
      DIMENSION CPPNC(NRAT1,IORDER,2),XLSASS(N3,2,NRAT1)
      DIMENSION XDDTAC(3,NFSCAC,NSAT,IDXDDN),PXDDAC(NEQNA,N3,IDXDDN)
!     DIMENSION XDDTAC(N3,IDXDDN),PXDDAC(NEQNA,N3,IDXDDN)
      DIMENSION LFHIRT(NHRATE),LSURFF(NSURF),IPTFBS(MXFMG)
      DIMENSION NPRMAC(MXHRG)
      DIMENSION XDDOTL(N3),PXDDT3(NEQN,N3),XDDTMC(N3)
      DIMENSION XDDRC(NSAT)
      DIMENSION TOPXAT(2,NSAT),LTPXAT(3,NSAT)
      DIMENSION DYNTIM(MDYNPD,2,NSAT),NPERDY(NSAT)
      DIMENSION EXACCT(2,NSAT),EXACIN(NSAT),EXACOB(MACOBS,NSAT)
      DIMENSION ACCTIM(MBAPPD,2,NSAT),ACCPER(MBAPPD,NSAT),NPERAC(NSAT)
      DIMENSION IACCP(2,NSAT),PACCL(MACC,3,NSAT)
      DIMENSION PXDDTL(NEQN,3,NSAT)
      DIMENSION SUMRNC(N3,2)
      DIMENSION CPPNCS(1,11,2)
      DIMENSION SFRACS(1),B(1)
!     DIMENSION XLSAS2(N3,2,1)
      DIMENSION XLSAS2(3,2,1)
      DIMENSION TXSTAT(MXSTAT),DELXST(6,MXSTAT,NSAT)
      DIMENSION XP(N3,2),DSROT(3,3,NSAT)
      DIMENSION ARY(3,2)
      DIMENSION DUM(3)
      DIMENSION XDDBRN(3),XBT(3)
!
!
      LSBURN=.FALSE.
      LFBURN=.FALSE.
      JPXST=0
      LXSTAT=.FALSE.
      NZ=3*MACC*NSAT
      IF(NZ.GT.0) THEN
        DO IQP=1,NZ
           PACCL(IQP,1,1)=0.D0
        ENDDO
      ENDIF
      NRAT=NRAT1+1
      N6=N3*2
!
      LHIRAT=.TRUE.
      LALL=.FALSE.
!
! PREDICT THE LARGE STEP STATE AT ALL "INBETWEEN" SMALL STEPS
!
      CALL PREDLS(NRAT1,CPPNC,IORDER,IOL1,IOL2,H,H2,                    &
     &            SUMX,XDDOT,N3,XLSASS)
!
! PREDICT POSITION AT LARGE STEP
      DO 2100 J=1,N3
      SUM=SUMX(J,1)
      DO 2000 I=1,IOL2
      K=IORDER-I
      SUM=SUM+CPP(I)*XDDOT(J,K)
 2000 END DO
      XP(J,1)=SUM*H2
 2100 END DO

! PREDICT  VELOCITY AT LARGE STEP
      DO 2300 J=1,N3
      SUM=SUMX(J,2)
      DO 2200 I=1,IOL1
      K=IORDER-I
      SUM=SUM+CPV(I)*XDDOT(J,K)
 2200 END DO
      XP(J,2)=SUM*H
 2300 END DO
 2400 CONTINUE
!
!
! INTEGRATE SMALL STEP STATE AT ALL "INBETWEEN" SMALL STEPS
!
      DO 1950 ISTEP=1,NRAT
      SFRAC=DBLE(ISTEP)/DBLE(NRAT1+1)
      IBACK1=IBCKNC+1
      IORBAK=IORDER+IBCKNC
      IPTA=IORBAK-IOL1
      CALL PCSSS(XPNC,N3,IORDER,IOL1,IOL2,CPP,CPV,HS,HS2,               &
     &           SUMXNC(1,1,IBACK1),XDDTNC(1,IPTA))
      FSECX=FSEC+DBLE(ISTEP)*HS
      DO IQP=1,N6
       SUMRNC(IQP,1)=SUMXNC(IQP,1,IBACK1)
      ENDDO

      IF(ISTEP.EQ.NRAT)  THEN
! UPDATE LARGE STEP STATE
        DO IQP=1,N6
        XP(IQP,1)=XP(IQP,1)+XPNC(IQP,1)
        ENDDO
      ELSE
        DO IQP=1,N6
        XLSASS(IQP,1,ISTEP)=XLSASS(IQP,1,ISTEP)+XPNC(IQP,1)
        ENDDO
      ENDIF

      IF(IDSYST.EQ.2) THEN
! CALL ORBTOR TO GET THE ROTATION MATRIX BASED ON PREDICTED SAT POSITION
        IF(ISTEP.EQ.NRAT)  THEN
        CALL ORBTOR(XP(1,1),XP(1,2),DSROT,NSAT)
        ELSE
        CALL ORBTOR(XLSASS(1,1,ISTEP),XLSASS(1,2,ISTEP),DSROT,NSAT)
        ENDIF
      ENDIF
!
!  CODE FOR DELTA STATE
!
      TIME1=DBLE(MJDSEC)+FSEC+DBLE(ISTEP-1)*HS
      TIME2=TIME1+HS
      LAT2=.FALSE.
      LBTW=.FALSE.
      DO 100 IQP=1,NXSTAT
         IPDXST=IQP
         TDIF=ABS(TIME2-TXSTAT(IQP))
         IF(TDIF.LT..001D0) THEN
           LAT2=.TRUE.
           NXSTEP=NRAT-ISTEP
           HREMAL=DBLE(NXSTEP)*HS
           GO TO 110
         ENDIF
         IF(TXSTAT(IQP).GT.TIME1.AND.TXSTAT(IQP).LT.TIME2) THEN
           LBTW=.TRUE.
           HREMA=TIME2-TXSTAT(IPDXST)
           NXSTEP=NRAT-ISTEP
           HREMAL=HREMA+DBLE(NXSTEP)*HS
           GO TO 110
         ENDIF
  100 END DO
  110 CONTINUE
      IF(LAT2.AND..NOT.LXSTAT) THEN
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
!         WRITE(6,78787) TIME2
78787    FORMAT(' DELTA V AT STEP TIME ',F15.3)
!         V1=XLSASS(1,2,ISTEP)
!         V2=XLSASS(2,2,ISTEP)
!         V3=XLSASS(3,2,ISTEP)
!         VM=DSQRT(V1*V1+V2*V2+V3*V3)
!         V1=V1*.01D0/VM
!         V2=V2*.01D0/VM
!         V3=V3*.01D0/VM
!         DELXST(1,1)=0.D0
!         DELXST(2,1)=0.D0
!         DELXST(3,1)=0.D0
!         DELXST(4,1)=V1
!         DELXST(5,1)=V2
!         DELXST(6,1)=V3
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                  IF(IDSYST.EQ.2) THEN
!  ROTATE DELXST TO TOR BEFORE CORRECTING XPNC2 IF IDSYST=2
         DO IQP=1,NSAT
         ARY(1,1)=DSROT(1,1,IQP)*DELXST(1,IPDXST,IQP)+                  &
     &            DSROT(1,2,IQP)*DELXST(2,IPDXST,IQP)+                  &
     &            DSROT(1,3,IQP)*DELXST(3,IPDXST,IQP)
         ARY(2,1)=DSROT(2,1,IQP)*DELXST(1,IPDXST,IQP)+                  &
     &            DSROT(2,2,IQP)*DELXST(2,IPDXST,IQP)+                  &
     &            DSROT(2,3,IQP)*DELXST(3,IPDXST,IQP)
         ARY(3,1)=DSROT(3,1,IQP)*DELXST(1,IPDXST,IQP)+                  &
     &            DSROT(3,2,IQP)*DELXST(2,IPDXST,IQP)+                  &
     &            DSROT(3,3,IQP)*DELXST(3,IPDXST,IQP)
         ARY(1,2)=DSROT(1,1,IQP)*DELXST(4,IPDXST,IQP)+                  &
     &            DSROT(1,2,IQP)*DELXST(5,IPDXST,IQP)+                  &
     &            DSROT(1,3,IQP)*DELXST(6,IPDXST,IQP)
         ARY(2,2)=DSROT(2,1,IQP)*DELXST(4,IPDXST,IQP)+                  &
     &            DSROT(2,2,IQP)*DELXST(5,IPDXST,IQP)+                  &
     &            DSROT(2,3,IQP)*DELXST(6,IPDXST,IQP)
         ARY(3,2)=DSROT(3,1,IQP)*DELXST(4,IPDXST,IQP)+                  &
     &            DSROT(3,2,IQP)*DELXST(5,IPDXST,IQP)+                  &
     &            DSROT(3,3,IQP)*DELXST(6,IPDXST,IQP)
         DELXST(1,IPDXST,IQP)=ARY(1,1)
         DELXST(2,IPDXST,IQP)=ARY(2,1)
         DELXST(3,IPDXST,IQP)=ARY(3,1)
         DELXST(4,IPDXST,IQP)=ARY(1,2)
         DELXST(5,IPDXST,IQP)=ARY(2,2)
         DELXST(6,IPDXST,IQP)=ARY(3,2)
         ENDDO
                  ENDIF

         JPXST=IPXST+(IPDXST-1)*6
         DO IQP=1,NSAT
         MQP=0
         DO JQP=1,2
         DO KQP=1,3
           MQP=MQP+1
           XPNC2(KQP,IQP,JQP)=XPNC2(KQP,IQP,JQP)+DELXST(MQP,IPDXST,IQP)
         ENDDO
         ENDDO
         ENDDO
         CALL UCSSS(XPNC,N3,IORDER,IOL1,IOL2,CPP,CPV,HS,HS2,            &
     &              SUMRNC(1,1),XDDTNC(1,IPTA))
      ENDIF
!
!
!
      IF(LBTW.AND..NOT.LXSTAT) THEN
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
!         WRITE(6,78788) TIME2
78788    FORMAT(' DELTA V IN BETWEEN STEP TIME ',F15.3)
!
! GET INTERPOLATION INFORMATION FOR LARGE STEP SIZE
!
!         SFRACS(1)=(TXSTAT(IPDXST)-DBLE(MJDSEC)-FSEC)/H
!
!         CALL COEFV(SFRACS,B,1,IORDER,CPPNCS(1,1,1),CPPNCS(1,1,2))
!
!         CPPNCS(1,IORDER,1)=SFRACS(1)
!         CALL PREDLS(1,CPPNCS,IORDER,IOL1,IOL2,H,H2,
!     1               SUMX,XDDOT,N3,XLSAS2)
!         V1=XLSAS2(1,2,1)
!         V2=XLSAS2(2,2,1)
!         V3=XLSAS2(3,2,1)
!         VM=DSQRT(V1*V1+V2*V2+V3*V3)
!         V1=V1*.01D0/VM
!         V2=V2*.01D0/VM
!         V3=V3*.01D0/VM
!         DELXST(1,1)=0.D0
!         DELXST(2,1)=0.D0
!         DELXST(3,1)=0.D0
!         DELXST(4,1)=V1
!         DELXST(5,1)=V2
!         DELXST(6,1)=V3
!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                  IF(IDSYST.EQ.2) THEN
!  ROTATE DELXST TO TOR BEFORE CORRECTING XPNC2 IF IDSYST=2
         DO IQP=1,NSAT
         ARY(1,1)=DSROT(1,1,IQP)*DELXST(1,IPDXST,IQP)+                  &
     &            DSROT(1,2,IQP)*DELXST(2,IPDXST,IQP)+                  &
     &            DSROT(1,3,IQP)*DELXST(3,IPDXST,IQP)
         ARY(2,1)=DSROT(2,1,IQP)*DELXST(1,IPDXST,IQP)+                  &
     &            DSROT(2,2,IQP)*DELXST(2,IPDXST,IQP)+                  &
     &            DSROT(2,3,IQP)*DELXST(3,IPDXST,IQP)
         ARY(3,1)=DSROT(3,1,IQP)*DELXST(1,IPDXST,IQP)+                  &
     &            DSROT(3,2,IQP)*DELXST(2,IPDXST,IQP)+                  &
     &            DSROT(3,3,IQP)*DELXST(3,IPDXST,IQP)
         ARY(1,2)=DSROT(1,1,IQP)*DELXST(4,IPDXST,IQP)+                  &
     &            DSROT(1,2,IQP)*DELXST(5,IPDXST,IQP)+                  &
     &            DSROT(1,3,IQP)*DELXST(6,IPDXST,IQP)
         ARY(2,2)=DSROT(2,1,IQP)*DELXST(4,IPDXST,IQP)+                  &
     &            DSROT(2,2,IQP)*DELXST(5,IPDXST,IQP)+                  &
     &            DSROT(2,3,IQP)*DELXST(6,IPDXST,IQP)
         ARY(3,2)=DSROT(3,1,IQP)*DELXST(4,IPDXST,IQP)+                  &
     &            DSROT(3,2,IQP)*DELXST(5,IPDXST,IQP)+                  &
     &            DSROT(3,3,IQP)*DELXST(6,IPDXST,IQP)
         DELXST(1,IPDXST,IQP)=ARY(1,1)
         DELXST(2,IPDXST,IQP)=ARY(2,1)
         DELXST(3,IPDXST,IQP)=ARY(3,1)
         DELXST(4,IPDXST,IQP)=ARY(1,2)
         DELXST(5,IPDXST,IQP)=ARY(2,2)
         DELXST(6,IPDXST,IQP)=ARY(3,2)
         ENDDO
                  ENDIF

         JPXST=IPXST+(IPDXST-1)*6
         DO IQP=1,NSAT
         MQP=0
         DO JQP=1,2
         DO KQP=1,3
           MQP=MQP+1
           XPNC2(KQP,IQP,JQP)=XPNC2(KQP,IQP,JQP)+DELXST(MQP,IPDXST,IQP)
           IF(JQP.EQ.1) THEN
               XPNC2(KQP,IQP,1)=XPNC2(KQP,IQP,1)+DELXST(MQP,IPDXST,IQP) &
     &                         +HREMA*DELXST(MQP+3,IPDXST,IQP)
           ENDIF
         ENDDO
         ENDDO
         ENDDO
         CALL UCSSS(XPNC,N3,IORDER,IOL1,IOL2,CPP,CPV,HS,HS2,            &
     &              SUMRNC(1,1),XDDTNC(1,IPTA))
!
      ENDIF
      LXSTAT=LXSTAT.OR.LAT2.OR.LBTW
!
      IF(ISTEP.EQ.NRAT) Go TO 1950
!
      DO IQP=1,N6
        XLSASS(IQP,1,ISTEP)=XLSASS(IQP,1,ISTEP)+XPNC(IQP,1)
      ENDDO
!     write(6,*)' dbg call f from PSS ',iorbak,mjdsec,fsecx,LHIRAT

      CALL F(MJDSEC,FSECX,XLSASS(1,1,ISTEP),XDDOTL,PXDDTL,NSAT,NEQN,    &
     &  NTCRD,XDDTMC,TOPXAT,LTPXAT,AA,II,LL,ISATID,LFHIRT,LSURFF,       &
     &  XDDTNC(1,IORBAK),XDDTAC(1,1,1,IORBAK),PXDDAC(1,1,IORBAK),       &
     &  NEQNA,IPTFBS,NPRMAC,LHIRAT,LALL,SFRAC,DYNTIM,NPERDY,LACCELS,    &
     &  EXACCT,EXACIN,EXACOB,ACCTIM,ACCPER,NPERAC,IACCP,PACCL,NRAT,     &
     &  XDDRC,DUM,DUM,LQ1,ISPBRN,LQ2,XBT,HS)
      IF(LQ1) LSBURN=.TRUE.
      IF(LQ2) LFBURN=.TRUE.
      IF(LQ1.OR.LQ2) THEN
        XDDBRN(1)=XBT(1)
        XDDBRN(2)=XBT(2)
        XDDBRN(3)=XBT(3)
      ENDIF
!     write(6,*)' dbg PSS  : XDDTAC(1,',IORBAK,MJDSEC,FSECX
!     write(6,*)'dbg P F ',XDDTAC(1,1,1,IORBAK),XDDTAC(2,1,1,IORBAK),
!    .XDDTAC(3,1,1,IORBAK)
!     write(6,*)'dbg P F ',PXDDAC(1,1,IORBAK),PXDDAC(1,2,IORBAK),
!    .PXDDAC(1,3,IORBAK)
!
! CORECTION STEP
!     CALL PCSSS(XNC,N3,IORDER,IOL1,IOL2,CCP,CCV,HS,HS2,
!    1           SUMXNC(1,1,IBACK1),XDDTNC(1,IPTA+1))
!     DO IQP=1,N6
!       XLSASS(IQP,1,ISTEP)=XLSASS(IQP,1,ISTEP)+XPNC(IQP,1)
!     ENDDO
!     CALL F
!
! UPDATE SUMS
!
      CALL INTSS(IBCKNC,IORBAK,N3,IDSMXN,IDXDDN,XDDTNC,SUMRNC,SUMXNC)
!
 1950 END DO
      IF(LSBURN.AND.LFBURN) THEN
       WRITE(6,6000)
       WRITE(6,6001)
       WRITE(6,6002)
       WRITE(6,6003)
       WRITE(6,6004)
      ENDIF
      RETURN
 6000 FORMAT(' WARNING FROM SUBROUTINE PSS')
 6001 FORMAT(' A BURN WAS INITIATED AND TERMINATED')
 6002 FORMAT(' FROM THE SAME CALL TO PSS')
 6003 FORMAT(' VARIATIONAL EQUATIONS FROM THIS CALL')
 6004 FORMAT(' WILL BE COMPROMISED')
      END
