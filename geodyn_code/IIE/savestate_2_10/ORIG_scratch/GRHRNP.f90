!$GRHRNP
      SUBROUTINE GRHRNP(MJDSEC,FSEC,EQN,SCRTCH,THETAG,COSTHG,           &
     &                  SINTHG,NM,AA,UTDT)
!********1*********2*********3*********4*********5*********6*********7**
! GRHRN2           83/03/25            0000.0    PGMR - TOM MARTIN
!                  89/06/06            0000.0    PGMR - A. MARSHALL
!
! FUNCTION:  COMPUTE THE RIGHT ASCENSION OF GREENWICH FOR
!            A VECTOR OF TIMES OF LENGTH "NM".
!            COMPUTE THE COSINES AND SINES OF THE RIGHT
!            ASCENSION OF GREENWICH VECTOR.
!
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   MJDSEC   I    S    MODIFIED JULIAN DAY SECONDS OF THE VECTOR
!                      OF TIMES OF INTEREST (EPHEMERIS TIME)
!   FSEC     I    A    THE FRACTION OF SECONDS OF THE VECTOR OF
!                      TIMES OF INTEREST (EPHEMERIS TIME)
!   EQN     I/O   A    EQUATION OF THE EQUINOX
!                      EQN OF THE EQUINOX
!   SCRTCH  I/O   A    SCRATCH 5*NM
!   THETAG   O    A    VECTOR OF VALUES OF RIGHT ASCENSION OF
!                      GREENWICH
!   COSTHG   O    A    COSINES OF THETAG
!   SINTHG   O    A    SINES OF THETAG
!   NM       I    S    NUMBER OF TIMES OF INTEREST
!   AA       I    A    REAL DYNAMIC ARRAY
!
! COMMENTS:
!           THIS ROUTINE IS CALLED IF THE EQUINOX EQN HAS ALREADY BEEN
!           CALCULATED (I.E. ANALAGOUS TO GRHRAN, WITHOUT CALLS FOR
!           EQUINOX EQUATION COMPUTATION)
!
!*********1*********2*********3*********4*********5*********6*********7*
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
!
      DIMENSION FSEC(NM),THETAG(NM),COSTHG(NM),SINTHG(NM),EQN(NM),      &
     &          SCRTCH(NM,5),AA(1)
      DIMENSION UTDT(NM)
      COMMON/CONSTR/PI,TWOPI,DEGRAD,SECRAD,SECDAY
      COMMON/CORA03/KRFMT ,KROTMT,KSRTCH,KCFSC ,KTHG  ,KCOSTG,KSINTG,   &
     &              KDPSI ,KEPST ,KEPSM ,KETA  ,KZTA  ,KTHTA ,KEQN  ,   &
     &              KDPSR ,KSL   ,KH2   ,KL2   ,KXPUT ,KYPUT ,KUT   ,   &
     &              KSPCRD,KSPSIG,KSTAIN,KSXYZ ,KSPWT ,KDXSDP,KDPSDP,   &
     &              KXLOCV,KSTNAM,KA1UT ,KPLTIN,KPLTVL,KPLTDV,KPUTBH,   &
     &              KABCOF,KSPEED,KANGFC,KSCROL,KSTVEL,KSTVDV,KTIMVL,   &
     &              KSTEL2,KSTEH2,KSL2DV,KSH2DV,                        &
     &              KAPRES, KASCAL, KASOFF,KXDOTP,KSAVST,               &
     &              KANGT , KSPDT , KCONAM,KGRDAN,KUANG ,KFAMP ,        &
     &              KOFACT, KOTSGN,KWRKRS,KANFSD,KSPDSD,KPRMFS,KSCRFR,  &
     &              KCOSAS,KSINAS,KDXTID,KALCOF,KSTANF,KNUTIN,KNUTMD,   &
     &              KPDPSI,KPEPST,KDXDNU,KDPSIE,KEPSTE,NXCA03
      COMMON/CORA04/KABIAS,KABSTR,KABSTP,KCBIAS,KCBSTR,KCBSTP,          &
     &       KRNM  ,KRKM  ,KRKJ  ,KRIJ  ,KRKPM ,                        &
     &       KRRNM ,KRRKM ,KRRKJ ,KRRIJ ,KRRKPM,                        &
     &       KURNM ,KURKM ,KURKJ ,KURIJ ,KURKPM,                        &
     &       KPRRNM,KPRRKM,KPRRKJ,KPRRIJ,KPRRKP,                        &
     &       KPMPXI,KPMPXE,KRA   ,KRELV ,KUHAT ,KWORK ,KTMPCR,KU    ,   &
     &       KS0   ,KS1   ,KXTP  ,KPXSXP,KPXDXP,KXUTDT,KRPOLE,KPXPOL,   &
     &       KXDPOL,KOBBUF,KOBSC ,KRESID,KSIGMA,KRATIO,KELEVS,          &
     &       KPMPA ,KPXSLV,KTPRTL,                                      &
     &       KFRQOF,KXYZOF,KFRQST,KFRQSA,KSTDLY,KSADLY,KXYZCG,KSCMRA,   &
     &       KEBVAL,KEBSIG,KEBNAM,KBTWB ,KTBTWA,KBTWD ,KPMPE ,          &
     &       KFSEB1,KFSEB2,KSTAMT,KPXSPA,KDIAGN,KOBOUT,KGRLT1,KGRLT2,   &
     &       KGRLT3,KGRLT4,KGRLT5,KPSTAT,KRSUNS,KCHEMR,KCHMOR,KEPOSR,   &
     &       KCHEMT,KCHMOT,KEPOST,KCHCBS,KCPOSS,KSCRTM,KXSTT ,KXSTR ,   &
     &       KXSS  ,KRANGT,KRANGR,KCHB1 ,KCHB2 ,KCHBV1,KCHBV2,KCHEB ,   &
     &       KSSTFQ,KSSTCC,KSSTSS,KSSTWT,KRLCOR,KWVLBI,KQUINF,KBRTS ,   &
     &       KBRTSV,KLRARC,KXEPBF,KXEPBR,KPRCBD,KPRTBD,KXPMPA,KXL,      &
     &       KXSIG ,KXEDTS,KXALO1,KXALO2,KXYOF2,KDLATF,KDLATS,KDLONF,   &
     &       KDLONS,KPF   ,KPS   ,                                      &
     &       KXOBSV,KXOBSW,KXEDSW,                                      &
     &       KXSIGW,KPSF  ,KDNUM ,KCNUM ,KFCOR ,KCOSAR,KSINAR,KSABIA,   &
     &       KSBTM1,KSBTM2,KYAWBS,KVLOUV,KACMAG,KOBSTR,                 &
     &       KPRL1 ,KPRL2, KRL1  ,KT1SE ,KTCP  ,                        &
     &       KRATDR,KFQT1S,KFQT1E,KT1STR,KFTTSE,KFRSTR,KFRRAT,KSV1  ,   &
     &       KSV2  ,KTSLOV,                                             &
     &       KGLGR1,KGLGR2,KGLFR1,KGLFR2,                               &
     &       KARGR1,KARGR2,KARFR1,KARFR2,                               &
     &       KRDS1L,KFT1AV,KDFQP ,KFREQ1,KFREQ3,KSAVD1,KSAVD2,          &
     &       KANTOU,KFM3CF,KF2CF,KTMG,KLTMG,KX2TIM,KX2OBS,KXRNDX,KX2SCR,&
     &       KALTWV,KXXBM ,KX2PAR,KATIME,KPMPAT,KPMATT,KX2PAT,          &
     &       KPXEXI,KPXEPA,KPV,KPXEP2,KX2COF,KACOF2,KACOF3,KBCOF,KBCOF2,&
     &       KDDDA ,KX2AUX,KX2VPR,KX2VPA,KEXTRA,KVARAY,KATROT,KATPER,   &
     &       KLTAR ,KXHOLD,KANTBL,KPHC  ,KOFDRV,KGNAME,KGRSIZ,KGRCNT,   &
     &       KGRDAT,KACCDT,KCTBTI,KCTBWE,KCTCTM,KANTUV,KANTOR,KW1PU ,   &
     &       KPYSQH,KSIGSP,KXYOF3,KXVTM1,KXDIST,KXDST0,KTMSE ,KDSDP ,   &
     &       KEXCST,KEXCDT,KEXCGX,KEXCGY,KEXCGZ,KIMNDX,KIMOBS,KIMTIM,   &
     &       KIMSAT,KM2VPA,KDCDD ,KDWNWT,KDPOR ,KC2PAR,KBOUNC,KBPART,   &
     &       NXCA04
      COMMON/CRDDIM/NDCRD2,NDCRD3,NDCRD4,NDCRD5,NDCRD6,NDCRD7,          &
     &              NDCRD8,NDCRD9,NXCRDM
      COMMON/CTHDOT/THDOT
      COMMON/CTHETG/DJ1900,TG1900,TDOT00,TGDDOT, DCENT,DAYEAR
      COMMON/DTMGDN/TGTYMD,TMGDN1,TMGDN2,REPDIF,XTMGN
      COMMON/EOPRAT/ETAG,THTAG,ZTAG,EPSMG,DPSIG,EPSTG,TETAG,XPOLE,   &
     &     YPOLE,ETAR,THTAR,ZTAR,EPSMR,DPSIR,EPSTR,THETAGR,XPOLER,   &
     &     YPOLER,SP2,DSP2
      COMMON/OLOADA/LXYZCO,LEOPTO
      COMMON/THETGC/THTGC(4)
      DATA TWO/2.0D0/,THREE/3.D0/,ADDON/.7272205216643040D-04/
!
!********1*********2*********3*********4*********5*********6*********7**
! START OF EXECUTABLE CODE
!********1*********2*********3*********4*********5*********6*********7**
!
! GET UT TIMES FROM ET TIMES;PUTIT INTO SCRTCH( ,3)
      IF(LEOPTO) THEN
         CALL ETUTP(MJDSEC,FSEC,AA(KDPSR),AA(KXPUT),SCRTCH(1,3), &
     &              SCRTCH(1,5),AA(KA1UT),NM,AA(KXDOTP),UTDT)
      ELSE
         CALL ETUT (MJDSEC,FSEC,AA(KDPSR),AA(KXPUT),SCRTCH(1,3), &
     &              SCRTCH(1,5),AA(KA1UT),NM,AA(KXDOTP),UTDT)
      ENDIF
!   CALCULATE TIME AT START OF DAY
      MJDSC0=MOD(MJDSEC,86400)
      MJDSC0=MJDSEC-MJDSC0
      XJDSC0=DBLE(MJDSC0)
      XJDSC0=XJDSC0+(TMGDN2-30000.D0)*86400.D0
! EVALUATE RIGHT ASCENSION OF GREENWICH FOR START OF DAY
      THETG0=((THTGC(4)*XJDSC0+THTGC(3))*XJDSC0+THTGC(2))*XJDSC0 &
     &      +THTGC(1)
! TIME DERIVATIVE OF RIGHT ASCENSION OF GREENWICH FOR START OF DAY
      THDOT=(THREE*THTGC(4)*XJDSC0+TWO*THTGC(3))*XJDSC0+THTGC(2)+ADDON
      THETAGR=THDOT

! COMPUTE ELAPSED SECONDS WITHIN DAY FOR EACH TIME POINT
      FLT=DBLE(MJDSEC-MJDSC0)
      DO 1000 N=1,NM
      THETAG(N)=FLT+SCRTCH(N,3)
 1000 CONTINUE
! EVALUATE RIGHT ASCENSION OF GREENWICH FOR EACH TIME POINT AS VALUE
!          AT START OF DATE PLUS ELAPSED SECONDS WITHIN DAY TIMES
!          LINEAR RATE OF CHANGE OF RIGHT ASCENSION OF GREENWICH
      DO 2000 N=1,NM
      THETAG(N)=THETAG(N)*THDOT+THETG0
 2000 CONTINUE
! KEEP VALUE WITHIN RANGE ZERO TO 2*PI,THEN ADD IN EQ OF EQUINOX
      DO 3000 N=1,NM
      THETAG(N)=MOD(THETAG(N)+TWOPI,TWOPI)
      THETAG(N)=THETAG(N)+EQN(N)
      TETAG=THETAG(N)
 3000 CONTINUE
! EVALUATE COSINES OF THETAG
      DO 4000 N=1,NM
      COSTHG(N)=COS(THETAG(N))
 4000 CONTINUE
! EVALUATE SINES OF THETAG
      DO 5000 N=1,NM
      SINTHG(N)=SIN(THETAG(N))
 5000 CONTINUE
      RETURN
      END