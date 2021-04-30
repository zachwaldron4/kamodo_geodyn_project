!$NORMBN
      SUBROUTINE NORMBN(AA,II,LL,MJDSBL,OBSTIM,IYMD  ,IHM   ,SEC   ,    &
     &      FRESID,OBS   ,LEDIT ,NM    ,MJDSB1,NDBIN ,NWTDBN,BINTIM,    &
     &      AVGFR ,OBSCAL,RESCAL,DSCRPT,TIMSYS,KNTBLK,SEGMNT,MTYPE,     &
     &      SUMCOR,LAVOID)
!********1*********2*********3*********4*********5*********6*********7**
! NORMBN           86/06/03            8606.0    PGMR - TOM MARTIN
!
! FUNCTION:  CREATE NORMAL POINT OUTPUT FOR ONE BLOCK OF OBSERVATIONS.
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   AA      I/O   A    REAL DYNAMIC ARRAY.
!   II      I/O   A    INTEGER DYNAMIC ARRAY.
!   LL      I/O   A    LOGICAL DYNAMIC ARRAY.
!   MJDSBL   I    S    Time of the start of the block in seconds after
!                      GEODYN REFERENCE TIME
!   OBSTIM   I    A    ELAPSED SECONDS ET FROM BLOCK START TIME
!                      FOR ALL OBSERVATIONS IN BLOCK.
!   IYMD     I    A    CALENDAR DATES OF OBSERVATIONS IN BLOCK.
!   IHM      I    A    HOURS AND MINUTES OBS. UTC TIMES.
!   SEC      I    A    UTC SECONDS OF OBSERVATION TIMES.
!   FRESID   I    A    RESIDUALS ABOUT THE ORBIT FITTING PROCESS
!                      PERFORMED BY NORMED.
!   OBS      I    A    OBSERVATION VALUES.
!   LEDIT    I    A    LOGICAL SWITCHES INDICATING WHICH OBS.
!                      HAVE BEEN EDITED.
!   NM       I    S    NUMBER OF OBSERVATIONS IN THE BLOCK.
!   MJDSB1   I    A    MODIFIED JULIAN DATE SECONDS (ET) OF START
!                      OF EACH NORMAL POINT BIN.
!   NDBIN    I    A    INDEX OF LAST POINT APPLICABLE TO EACH BIN
!   NWTDBN   I    A    NUMBER OF WEIGHTED POINTS IN EACH BIN.
!   BINTIM   I    A    AVERAGE OBSERVATION EPOCH WITHIN EACH BIN
!                      IN ELAPSED SECONDS (ET) FROM BIN START MJDS
!   AVGFR    I    A    AVERAGE FITTED RESIDUAL WITHIN EACH BIN.
!   OBSCAL   I    S    SCALING FACTOR FOR OBSERVATION PRINTOUT.
!   RESCAL   I    S    SCALING FACTOR FOR RESIDUAL PRINTOUT.
!   DSCRPT   I    A    ALPHANUMERIC TRACKING CONFIG. DESCRIPTION.
!   TIMSYS   I    S    ALPHANUMERIC OBS. TIME SYS. INDICATOR.
!   KNTBLK   I    S    OBSERVATION BLOCK COUNT.
!   SEGMNT   I    S    ALPHANUMERIC BLOCK SEGMENT LABEL.
!   MTYPE    I    S    MEASUREMENT TYPE
!   SUMCOR   I    A    SUM OF OBS CORR ARRAY
!
! COMMENTS:
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      COMMON/CITER /NINNER,NARC,NGLOBL
      COMMON/CNORMA/BWIDTH,TCHECK
      COMMON/CNORML/LNORM ,LNORMP
      COMMON/COBGLO/MABIAS,MCBIAS,MPVECT,MINTPL,MPARAM,MSTA,MOBBUF,     &
     &       MNPITR,MWIDTH,MSIZE ,MPART ,MBUF  ,NXCOBG
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
      COMMON/CORI04/KNMP  ,KINDP ,KNDPAR,KNPVCT,KISATN,KISET ,KIANTO,   &
     &              KISATO,KIANTD,KISATD,KISTAD,KISATC,KMJDCG,KISTAT,   &
     &              KMJDEB,KMJDBN,KNDBIN,KNWTDB,KIXPAR,KNDBUF,KSSTNM,   &
     &              KSSTNA,KMBSAT,KMBSTA,KXKEY ,KXVKEY,KXFLAG,KIPNTF,   &
     &              KIPNTS,KNCON ,KKF   ,KIDATB,KNSTLV,KSLVID,KLLBIA,   &
     &              KTMRA1,KTMRA2,KIND1 ,KTARID,KATARD,KYAWID,KXOBLK,   &
     &              KDSCWV,KATRSQ,KATSAT,KKVLAS,KPARTP,KLTMSC,KLTASC,   &
     &              KCTBST,KSTBST,KANCUT,KANGPS,KANTYP,                 &
     &              KANTOF,                                             &
     &              KYSAT, KMBDEG,                                      &
     &              KMBNOD,KMBSST,KBSPLN,KSSPLN,KXIOBS,KIDLAS,KIAVP ,   &
     &              KXNAVP,KNEXCG,KIDEXC,KNREXC,KTELEO,KIKEY ,KIMKEY,   &
     &              KIMBLK,KIMPRT,KCN110,KCN111,KC110,KC111,KTDSAT,     &
     &              KTDANT,NXCI04
      COMMON/CVIEW /IOUT6 ,ILINE6,IPAGE6,MLINE6,                        &
     &              IOUT8 ,ILINE8,IPAGE8,MLINE8,                        &
     &              IOUT9 ,ILINE9,IPAGE9,MLINE9,                        &
     &              IOUT10,ILIN10,IPAG10,MLIN10,                        &
     &              IOUT15,ILIN15,IPAG15,MLIN15,                        &
     &              IOUT16,ILIN16,IPAG16,MLIN16,                        &
     &              IOUT7 ,NXCVUE
!
      DIMENSION AA(1),II(1),LL(1)
      DIMENSION NDBIN (NM),MJDSB1(NM),BINTIM(NM),NWTDBN(NM),            &
     &          AVGFR (NM),DSCRPT(7)
      DIMENSION OBSTIM(NM),IYMD  (NM),IHM   (NM),SEC   (NM),FRESID(NM), &
     &          OBS   (NM),LEDIT (NM),SUMCOR(NM)
      DIMENSION DUM(1)
      DIMENSION DUMMY(3)
      DIMENSION LAVOID(NM)
!
!
      CHARACTER(8)      :: BLKNEW, BLKOLD
      DATA BLKNEW/'(*NEW*)'/,BLKOLD/'(CONT.)'/
      DATA ZERO/0.0D0/,ONE/1.0D0/
!
!**********************************************************************
! START OF EXECUTABLE CODE ********************************************
!**********************************************************************
!
! SUBTRACT OFF OBS CORR CALCULATED BY GEODYN from sumcor
!     ....and zero  out the correction values
!
      DO I=1,3
      DUMMY(I)=0.D0
      ENDDO

      DO 100 I=1,NM
      CALL PRESUB(MTYPE,SUMCOR(I),AA,I,DUMMY)
  100 END DO
!
! DETERMINE BIN LOCATIONS, START TIMES AND MEAN EPOCHS
!
!...BIN START TIME IN UTC SECONDS PAST MIDNIGHT (MJDSBN)
      MJDSBN=MJDSBL+OBSTIM(1)
      MJDSBN=(MJDSBN/MWIDTH)*MWIDTH
!...OFFSET FROM BLOCK START TIME
      FSECBN=MJDSBL-MJDSBN
!...INITIALIZE FIRST BIN
      NBINS =1
      MJDSB1(1)=MJDSBN
      NWBINS=0
      NWTD=0
      MWTD=0
      AVEPOC=ZERO
      AVGRES=ZERO
!
!...LOOP THRU ALL OBSERVATIONS
      DO 3000 N=1,NM
      TEST  =OBSTIM(N)+FSECBN
      IF(TEST.LT.BWIDTH) GO TO 2000
!...CURRENT OBSERVATION TIME EXCEEDS BIN WIDTH
      NDBIN (NBINS)=N-1
      NWTDBN(NBINS)=NWTD
      MWTD=MWTD+NWTD
!...MEAN EPOCH AND RESIDUAL OF WEIGHTED OBSERVATIONS WITHIN CURRENT BIN
      IF(NWTD.LT.1) GO TO 1000
      NWBINS=NWBINS+1
      BINTIM(NBINS)=AVEPOC/DBLE(NWTD)
      AVGFR (NBINS)=AVGRES/DBLE(NWTD)
 1000 CONTINUE
      AVEPOC=ZERO
      AVGRES=ZERO
      NWTD=0
!...INCREMENT BIN COUNT AND START TIME
      NBINS =NBINS +1
      ISECBN=TEST
      ISECBN=(ISECBN/MWIDTH)*MWIDTH
      TEST=TEST-ISECBN
      MJDSBN=MJDSBN+ISECBN
      FSECBN=FSECBN-ISECBN
      MJDSB1(NBINS)=MJDSBN
 2000 CONTINUE
      IF(LEDIT(N)) GO TO 3000
!...SUM TIMES TO COMPUTE AVERAGE BIN TIME
      NWTD=NWTD+1
      AVEPOC=AVEPOC+TEST
      AVGRES=AVGRES+FRESID(N)
 3000 END DO
!
!...MEAN EPOCH AND RESIDUAL OF WEIGHTED OBSERVATIONS WITHIN LAST BIN
      NDBIN (NBINS)=NM
      NWTDBN(NBINS)=NWTD
      BINTIM(NBINS)=-ONE
      IF(NWTD.LT.1) GO TO 4000
      NWBINS=NWBINS+1
      BINTIM(NBINS)=AVEPOC/DBLE(NWTD)
      AVGFR (NBINS)=AVGRES/DBLE(NWTD)
 4000 CONTINUE
      MWTD=MWTD+NWTD
      IF(MWTD.LT.1) GO TO 9400
!
! COMPUTE THE PASS STANDARD ERROR OF SINGLE OBSERVATION
      PASSIG=ZERO
      DO 5000 N=1,NM
      IF(LEDIT(N)) GO TO 5000
      PASSIG=PASSIG+FRESID(N)**2
 5000 END DO
      DENOM=MAX(MWTD-1,1)
      PASSIG=SQRT(PASSIG/DENOM)
!
! INITIALIZE NORMAL POINT OUTPUT FILE BUFFER
      CALL BLKHDR(AA(KOBOUT),II(KNDBUF),AA(KOBBUF),NWBINS)
!
! LOCATE THE WTD RESIDUAL NEAREST THE MEAN WTD EPOCH OF EACH BIN AND
!        COMPUTE THE NORMAL POINT AS THE OBSERVATION MINUS THE RESIDUAL
!        PLUS THE AVERAGE WTD RESIDUAL FOR THE BIN
!
      IF(.NOT.LNORMP) GO TO 5500
!...PRINT REPORT HEADERS
      NLIN15=ILIN15+MIN(9,NBINS+3)
      IF(NLIN15.LE.MLIN15) GO TO 5400
      IPAG15=IPAG15+1
      WRITE(IOUT15,54000) NARC,NINNER,NGLOBL,IPAG15,DSCRPT,BLKNEW,TIMSYS
      ILIN15=4
      GO TO 5500
 5400 CONTINUE
      WRITE(IOUT15,55000) TIMSYS,DSCRPT,KNTBLK,SEGMNT
      ILIN15=ILIN15+2
 5500 CONTINUE
      KOUNT=0
      N1=1
!...LOOP THRU ALL BINS
      DO 8000 I=1,NBINS
      N2=NDBIN (I)
      NWTD=NWTDBN(I)
      IF(NWTD.LT.1) GO TO 8000
      KOUNT=KOUNT+1
      NPOINT=N1
      BEGIN =MJDSBL-MJDSB1(I)
      TIMDIF=BWIDTH
      BINSIG=ZERO
      TCHECK=BINTIM(I)
!...LOOP THRU ALL OBS IN EACH BIN
      DO 6000 N=N1,N2
      IF(LEDIT(N)) GO TO 6000
      BINSIG=BINSIG+FRESID(N)**2
      BINDIF=ABS(OBSTIM(N)+BEGIN-TCHECK)
      IF(BINDIF.GT.TIMDIF) GO TO 6000
      TIMDIF=BINDIF
      NPOINT=N
 6000 END DO
!...COMPUTE BIN STANDARD ERROR
      DENOM=MAX(NWTD-1,1)
      BINSIG=SQRT(BINSIG/DENOM)
      IF(NWTD.EQ.1) BINSIG=PASSIG
!...COMPUTE NORMAL POINT
      OBSDIF=FRESID(NPOINT)-AVGFR(I)
      OBSNRM=OBS(NPOINT)-OBSDIF
      IF(.NOT.LNORMP) GO TO 7800
!...SEND REPORT TO PRINTER
      IF(MOD(KOUNT,6).NE.1) GO TO 7500
      NLIN15=ILIN15+7
      IF(NLIN15.LE.MLIN15) GO TO 7400
      IPAG15=IPAG15+1
      WRITE(IOUT15,54000) NARC,NINNER,NGLOBL,IPAG15,DSCRPT,BLKOLD,TIMSYS
      ILIN15=4
 7400 CONTINUE
      ILIN15=ILIN15+1
      WRITE(IOUT15,74000)
 7500 CONTINUE
      ILIN15=ILIN15+1
      OBSOUT=OBSNRM*OBSCAL
      DIFOUT=OBSDIF*RESCAL
      AVGOUT=AVGFR(I)*RESCAL
      BSGOUT=BINSIG*RESCAL
      PSGOUT=PASSIG*RESCAL
      WRITE(IOUT15,75000) IYMD(NPOINT),IHM(NPOINT),SEC(NPOINT),OBSOUT,  &
     &    DIFOUT,AVGOUT,BSGOUT,PSGOUT,NWTD,KNTBLK,SEGMNT
 7800 CONTINUE
!...OUTPUT NORMAL POINT TO FILE
      CALL BLKOUT(AA(KOBBUF),AA(KOBOUT),II(KNDBUF),                     &
     &   OBSNRM,DUM,DUM, OBSDIF,BINSIG,NWTD,NPOINT)
 8000 N1=N2+1
      RETURN
!
 9400 CONTINUE
      IF(.NOT.LNORMP) RETURN
      ILIN15=ILIN15+3
      WRITE(IOUT15,94000) KNTBLK,SEGMNT,NM
      RETURN
!
54000 FORMAT('1',15X,'OBSERVATION NORMAL POINTS FOR ARC',               &
     &   I3,' FOR INNER ITERATION',I3,' OF GLOBAL ITERATION',I2,13X,    &
     &   'UNIT 15 PAGE NO.',I6/                                         &
     &   2X,'STATION-SATELLITE CONFIGURATION ',7(1X,A8),10X,            &
     &   A7/2X,'DATE  GREENWICH TIME',6X,'OBSERVATION',8X,              &
     &   'REDUCTION',3X,'BIN RESIDUAL',3X,'BIN STD DEV',3X,             &
     &   'PASS STD DEV',3X,'NO. WTD OBS',                               &
     &    2X,'BLOCK'/1X,'YYMMDD HHMM SEC-UTC-',A1)
55000 FORMAT('0YYMMDD HHMM SEC-UTC-',A1,                                &
     &   ' ** STATION-SAT CONFIG.',7(1X,A8),' ** FOR NEW BLOCK',I6,A1)
74000 FORMAT(1X)
75000 FORMAT(1X,I6,I5,F10.6,F20.9,4F15.6,I9,I8,A1)
94000 FORMAT('0** NORMBN **  OBSERVATION BLOCK',I6,A1,' CONTAINING',I6, &
     &   ' TOTAL OBSERVATIONS HAS NONE WEIGHTED.'/1X )
      END