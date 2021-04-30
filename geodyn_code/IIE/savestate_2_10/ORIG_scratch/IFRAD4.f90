!$IFRAD4
      SUBROUTINE IFRAD4(AA,II,LL,IARCNO,LRDIFF,LOAD,IFFHDR,FFBUF)
!********1*********2*********3*********4*********5*********6*********7**
!
! NAME IFRAD4      DATE 01/24/84        PGMR - B. EDDY
!
! FUNCTION         CONTROLS MOVEMENT OF ARC DYNAMIC ARRAY INFORMATION
!                  FOR GROUP #4 - MEASUREMENT MODELING ARRAYS
!                  AS FOLLOWS:
!                  1. FROM INTERFACE FILE TO EXTENDED VIRTUAL MEMORY(VM)
!                  2. FROM EXTENDED VIRTUAL MEMORY TO ARC DYNAMIC ARRAYS
!                  3. FROM ARC DYNAMIC ARRAYS TO EXTENDED VITUAL MEMORY
!
!
! INPUT PARAMETERS
!                  AA     - DYNAMIC ARRAY USED FOR REAL DATA
!                  II     - DYNAMIC ARRAY USED FOR INTEGER DATA
!                  LL     - DYNAMIC ARRAY USED FOR LOGICAL DATA
!                  IARCNO - CURRENT ARC NUMBER
!                  LRDIFF  - FLAG USED TO CONTROL READING/LOADING
!                            = T READ IFF & STORE IN VIRTUAL MEMORY
!                            = F MOVE FROM EXTENDED VIRTUAL MEMORY TO
!                                ARC DYNAMIC ARRAYS OR VICE VERSA AS
!                                INDICATED BY "LOAD"
!                  LOAD    - CONTROLS LOADING/UNLOADING OF INFORMATION
!                            =T LOAD FROM EXT. VM TO ARC DYNAMIC ARRAYS
!                            =F UNLOAD FROM DYNAMIC ARRAYS TO EXT. VM
!                  IFFHDR - SCRATCH ARRAY USED FOR HEADER INFORMATION
!
!
!                  FFBUF  - SCRATCH ARRAY USED TO HOLD REAL DATA PRIOR
!                           TO CONVERSION TO PROPER IIE REPRESENTATION
!
!
!
! COMMENTS:     INTERFACE FORMAT #2 USED:
!
! INTEGER  HEADER RECORD  - WITH IFFHDR(5)=0 INDICATING LENGTHS RECORDS
!                           FOLLOWS
! INTEGER LENGTHS RECORD  - CONTAINING IFFHDR(4) WORDS. THE FIRST
!                           IFFHDR(4)-1 WORDS ARE LENGTHS OF DATA
!                           RECORDS. THE LAST WORD IS THE SUM OF LENGTHS
!            DATA RECORDS - IFFHDR(4)-1  DATA RECORDS. DATA RECORDS ARE
!                           OF THE TYPE INDICATED IN IFFHDR(3)
!
! COMMENTS:   TO OUTPUT ADDITIONAL RECORDS IN THIS ROUTINE
!             1. INCREMENT NRECS AND CALCULATE LENGTH OF RECORD TO BE
!                OUTPUT
!             2. ADD WRITE STATEMENT FOR OUTPUTTING DATA RECORDS
!                (IF LENGTH IS ZERO A  RECORD CONTAINING A ZERO MUST
!                BE OUTPUT)
!             3. FOR INTEGER AND LOGICAL DATA SUBROUTINE CYBINT MUST
!                BE CALLED TO CONVERT INTEGERS (AND LOGICALS) TO THE
!                CORRECT REPRESENTATION FOR THE COMPUTER IIE WILL
!                BE RUNNING ON
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      COMMON/CEBGLB/MEPARM,MEDIM ,MEBIAS,MBIASE,NEBGRP,IEBGRP(4),NXCEBG
      COMMON/CIFF  /IFHEAD,IFLNTH,IFBUFL,IFBUFR,KDYNHD,KDYNLN,          &
     &              KDYNIF,KDYNFF,NXCIFF
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
      COMMON/CORL04/KLEDIT,KLBEDT,KLEDT1,KLEDT2,KNSCID,KEXTOF,KLSDAT,   &
     &              KLRDED,KLAVOI,KLFEDT,KLANTC,NXCL04
      COMMON/CVIEW /IOUT6 ,ILINE6,IPAGE6,MLINE6,                        &
     &              IOUT8 ,ILINE8,IPAGE8,MLINE8,                        &
     &              IOUT9 ,ILINE9,IPAGE9,MLINE9,                        &
     &              IOUT10,ILIN10,IPAG10,MLIN10,                        &
     &              IOUT15,ILIN15,IPAG15,MLIN15,                        &
     &              IOUT16,ILIN16,IPAG16,MLIN16,                        &
     &              IOUT7 ,NXCVUE
      COMMON/DYNPTR/KDEPHM,KDEPH2,KDAHDR(3,9),KDYNAP(3,9,2),KDNEXT(3),  &
     &NXDYNP
      COMMON/IONO2E/IONNDX(12),IONRZ(12),IONOYM(12),IONYMS,IONYME,IURSI,&
     &              INTERP,NXIONO
      COMMON/UNITS/IUNT11,IUNT12,IUNT13,IUNT19,IUNT30,IUNT71,IUNT72,    &
     &             IUNT73,IUNT05,IUNT14,IUNT65,IUNT88,IUNT21,IUNT22,    &
     &             IUNT23,IUNT24,IUNT25,IUNT26
      COMMON/TOPOVR/NMTPAT,MXTPAT,NOVRID,NGCATT,NTPBIA,NSTLVS,          &
     &              NISLV, NYWBIA,MSATYW,MAXYWB,NSATTP,NXTOPO
!
      DIMENSION AA(1)
      DIMENSION FFBUF(IFBUFR)
      DIMENSION IFFHDR(IFHEAD)
      DIMENSION II(1)
      DIMENSION LL(1)
!
      DATA IBLOCK/60/,IGROUP/4/
!
!**********************************************************************
! START OF EXECUTABLE CODE ********************************************
!**********************************************************************
      IGP1=IGROUP+1
! DETERMINE IF READING DATA FROM INTERFACE FILE
      IF(.NOT.LRDIFF) GO TO 5000
!**********************************************************************
! READ HEADER RECORD FOR REAL DATA
!**********************************************************************
      ISTAT =0
      ITYPE =1
      CALL BINRD(IUNT11,IFFHDR,IFHEAD)
! VERIFY BLOCK NO.,GROUP NUMBER AND DATA TYPE
      IF(IFFHDR(1).NE.IBLOCK .OR. IFFHDR(2).NE.IGROUP .OR.              &
     &   IFFHDR(3).NE.ITYPE) GO TO 60150
      NRECS1=IFFHDR(4)
      NRECS =NRECS1-1
! STORE NRECS1 IN VIRTUAL MEMORY
      IPTHDR=KDAHDR(ITYPE,IGP1)
      II(IPTHDR)=NRECS1
!**********************************************************************
! READ LENGTHS RECORD FOR REAL DATA-STORE IN VIRTUAL MEMORY
!**********************************************************************
      CALL BINRD(IUNT11,II(IPTHDR+1),NRECS1)
! LAST WORD READ IS SUM OF THE LENGTHS OF THE DATA RECORDS
      NWORDS=II(IPTHDR+NRECS1)
!**********************************************************************
! READ REAL DATA RECORDS AND STORE IN VIRTUAL MEMORY
!**********************************************************************
      IF(NRECS.EQ.0) GO TO 1000
      IPTR=KDYNAP(ITYPE,IGP1,1)+(IARCNO-1)*KDYNAP(ITYPE,IGP1,2)
      IPTSTR=IPTR
      DO 200 IREC=1,NRECS
      NX    =II(IPTHDR+IREC)
      NXABS =ABS(NX)
      IF(NXABS.GT.IFBUFR) GO TO 60300
      IF(NX.GE.0) THEN
      CALL BINRD2(IUNT11,FFBUF,NXABS)
      IF(NX.GT.0) CALL Q9ICLA(FFBUF,AA(IPTR),NXABS,ISTAT)
      ELSE
      CALL BINRDC(IUNT11,FFBUF,NXABS)
      CALL MOVER(FFBUF,AA(IPTR),NXABS,.TRUE.)
      ENDIF
! RESET LENGTH TO POSITIVE NUMBER (NEGATIVE INDICATES CHARACTER DATA)
      II(IPTHDR+IREC)=NXABS
      IF(ISTAT.NE.0) GO TO 60350
      IPTR=IPTR+NXABS
  200 END DO
!
! TEST IF CORRECT NUMBER OF WORDS READ
!
      IF(NWORDS.NE. IPTR-IPTSTR) GO TO 60220
!**********************************************************************
! READ HEADER RECORD FOR INTEGER DATA
!**********************************************************************
 1000 ITYPE=2
      CALL BINRD(IUNT11,IFFHDR,IFHEAD)
! VERIFY BLOCK NO.,GROUP NUMBER AND DATA TYPE
      IF(IFFHDR(1).NE.IBLOCK .OR. IFFHDR(2).NE.IGROUP .OR.              &
     &   IFFHDR(3).NE.ITYPE) GO TO 60150
      NRECS1=IFFHDR(4)
      NRECS = NRECS1-1
! STORE NRECS1 IN VIRTUAL MEMORY
      IPTHDR=KDAHDR(ITYPE,IGP1)
      II(IPTHDR)=NRECS1
!**********************************************************************
! READ LENGTHS RECORD FOR INTEGER DATA-STORE IN VIRTUAL MEMORY
!**********************************************************************
      CALL BINRD(IUNT11,II(IPTHDR+1),NRECS1)
      NWORDS=II(IPTHDR+NRECS1)
!**********************************************************************
! READ INTEGER DATA RECORDS AND STORE IN VIRTUAL MEMORY
!**********************************************************************
      IF(NRECS.EQ.0) GO TO 2000
      IPTR=KDYNAP(ITYPE,IGP1,1)+(IARCNO-1)*KDYNAP(ITYPE,IGP1,2)
      IPTSTR=IPTR
      DO 1200 IREC=1,NRECS
      NX=II(IPTHDR+IREC)
      CALL BINRD(IUNT11,II(IPTR),NX)
      IPTR=IPTR+NX
 1200 END DO
!
! TEST IF CORRECT NUMBER OF WORDS READ
!
      IF(NWORDS.NE.IPTR-IPTSTR) GO TO 60220
!**********************************************************************
! READ HEADER RECORD FOR LOGICAL DATA
!**********************************************************************
 2000 ITYPE=3
      CALL BINRD(IUNT11,IFFHDR,IFHEAD)
! VERIFY BLOCK NO.,GROUP NUMBER AND DATA TYPE
      IF(IFFHDR(1).NE.IBLOCK .OR. IFFHDR(2).NE.IGROUP .OR.              &
     &   IFFHDR(3).NE.ITYPE) GO TO 60150
      NRECS1=IFFHDR(4)
      NRECS = NRECS1-1
! STORE NRECS1 IN VIRTUAL MEMORY
      IPTHDR=KDAHDR(ITYPE,IGP1)
      II(IPTHDR)=NRECS1
!**********************************************************************
! READ LENGTHS RECORD FOR LOGICAL DATA-STORE IN VIRTUAL MEMORY
!**********************************************************************
      CALL BINRD(IUNT11,II(IPTHDR+1),NRECS1)
      NWORDS=II(IPTHDR+NRECS1)
!**********************************************************************
! READ LOGICAL DATA RECORDS AND STORE IN VIRTUAL MEMORY
!**********************************************************************
      IF(NRECS.EQ.0) GO TO 3000
      IPTR=KDYNAP(ITYPE,IGP1,1)+(IARCNO-1)*KDYNAP(ITYPE,IGP1,2)
      IPTSTR=IPTR
      DO 2200 IREC=1,NRECS
      NX=II(IPTHDR+IREC)
      CALL BINRDL(IUNT11,LL(IPTR),NX)
      IPTR=IPTR+NX
 2200 END DO
! TEST IF CORRECT NUMBER OF WORDS READ
      IF(NWORDS.NE. IPTR-IPTSTR) GO TO 60220
 3000 CONTINUE
!**********************************************************************
      RETURN
!**********************************************************************
!**********************************************************************
! LOAD INFORMATION FROM EXTENDED VIRTUAL MEM. TO ARC DYNAMIC ARRAYS OR
! UNLOAD INFORMATION FROM DYNAMIC ARRAYS TO EXTENDED VIRTUAL MEMORY
!**********************************************************************
!**********************************************************************
!
!**********************************************************************
! LOAD/UNLOAD REAL DATA
!**********************************************************************
 5000 ITYPE=1
      IPTHDR=KDAHDR(ITYPE,IGP1)
      NRECS1=II(IPTHDR)
      NRECS =NRECS1-1
      IF(NRECS.EQ.0) GO TO 7000
      NWORDS=II(IPTHDR+NRECS1)
      IPTR=KDYNAP(ITYPE,IGP1,1)+(IARCNO-1)*KDYNAP(ITYPE,IGP1,2)
      IPTSTR=IPTR
      IREC=0
! KEBVAL
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KEBVAL),NX,LOAD)
      IPTR=IPTR+NX
! KEBSIG
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KEBSIG),NX,LOAD)
      IPTR=IPTR+NX
! KEBNAM
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KEBNAM),NX,LOAD)
      IPTR=IPTR+NX
! KDIAGN/DIAGNL
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KDIAGN),NX,LOAD)
      IPTR=IPTR+NX
! KSABIA
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KSABIA),NX,LOAD)
      IPTR=IPTR+NX
! KSBTM1
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KSBTM1),NX,LOAD)
      IPTR=IPTR+NX
! KSBTM2
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KSBTM2),NX,LOAD)
      IPTR=IPTR+NX
!>>>>>
! KYAWBS
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KYAWBS),NX,LOAD)
      IPTR=IPTR+NX
! KVLOUV
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KVLOUV),NX,LOAD)
      IPTR=IPTR+NX
! KACMAG
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KACMAG),NX,LOAD)
      IPTR=IPTR+NX
! KTSLOV
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KTSLOV),NX,LOAD)
      IPTR=IPTR+NX
! GLBGR1
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KGLGR1),NX,LOAD)
      IPTR=IPTR+NX
! GLBGR2
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KGLGR2),NX,LOAD)
      IPTR=IPTR+NX
! GLBFR1
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KGLFR1),NX,LOAD)
      IPTR=IPTR+NX
! GLBFR2
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KGLFR2),NX,LOAD)
      IPTR=IPTR+NX
! ARCGR1
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KARGR1),NX,LOAD)
      IPTR=IPTR+NX
! ARCGR2
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KARGR2),NX,LOAD)
      IPTR=IPTR+NX
! ARCFR1
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KARFR1),NX,LOAD)
      IPTR=IPTR+NX
! ARCFR2
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KARFR2),NX,LOAD)
      IPTR=IPTR+NX
! FM3CF
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KFM3CF),NX,LOAD)
      IPTR=IPTR+NX
! F2CF
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KF2CF),NX,LOAD)
      IPTR=IPTR+NX
! KALTWV
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KALTWV),NX,LOAD)
      IPTR=IPTR+NX
! KATIME
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KATIME),NX,LOAD)
      IPTR=IPTR+NX
! KATPER
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KATPER),NX,LOAD)
      IPTR=IPTR+NX
! KCTBTI
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KCTBTI),NX,LOAD)
      IPTR=IPTR+NX
! KCTBWE
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KCTBWE),NX,LOAD)
      IPTR=IPTR+NX
! KCTCTM
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KCTCTM),NX,LOAD)
      IPTR=IPTR+NX
! KANTUV
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KANTUV),NX,LOAD)
      IPTR=IPTR+NX
! KANTOR
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KANTOR),NX,LOAD)
      IPTR=IPTR+NX
! KSIGSP
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVER(AA(IPTR),AA(KSIGSP),NX,LOAD)
      IPTR=IPTR+NX
!
! TEST IF CORRECT NUMBER OF DATA RECORDS RELOADED
!
      IF(IREC.NE.NRECS) GO TO 60200
! TEST IF CORRECT NUMBER OF WORDS RELOADED
      IF(NWORDS.NE.IPTR-IPTSTR) GO TO 60220
!**********************************************************************
! LOAD/UNLOAD INTEGER DATA
!**********************************************************************
 7000 ITYPE=2
      IPTHDR=KDAHDR(ITYPE,IGP1)
      NRECS1=II(IPTHDR)
      NRECS =NRECS1-1
      IF(NRECS.LE.0) GO TO 9000
      NWORDS=II(IPTHDR+NRECS1)
      IPTR=KDYNAP(ITYPE,IGP1,1)+(IARCNO-1)*KDYNAP(ITYPE,IGP1,2)
      IPTSTR=IPTR
      IREC=0
! KISATN/ISATN
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KISATN),NX,LOAD)
      IPTR=IPTR+NX
! KISET/ISETN
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KISET),NX,LOAD)
      IPTR=IPTR+NX
! KIXPAR/IXPARM
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KIXPAR),NX,LOAD)
      IPTR=IPTR+NX
! KMBSAT/IMBSAT
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KMBSAT),NX,LOAD)
      IPTR=IPTR+NX
! KMBSTA/IMBSTA
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KMBSTA),NX,LOAD)
      IPTR=IPTR+NX
!>>>>>
! KIDATB/IDATTB
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KIDATB),NX,LOAD)
      IPTR=IPTR+NX
! KNSTLV/NSTLOV
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KNSTLV),NX,LOAD)
      IPTR=IPTR+NX
! KSLVID/ISLVID
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KSLVID),NX,LOAD)
      IPTR=IPTR+NX
! KYAWID/IYAWID
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KYAWID),NX,LOAD)
      IPTR=IPTR+NX
! KDSCWV/IDSCWV
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KDSCWV),NX,LOAD)
      IPTR=IPTR+NX
! KATRSQ/ISEQ
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KATRSQ),NX,LOAD)
      IPTR=IPTR+NX
! KATSAT/IATSAT
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KATSAT),NX,LOAD)
      IPTR=IPTR+NX
! KKVLAS/KVLAS
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KKVLAS),NX,LOAD)
      IPTR=IPTR+NX
!
! KLTMSC/ILTMSC
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KLTMSC),NX,LOAD)
      IPTR=IPTR+NX
!
! KLTASC/ILTASC
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KLTASC),NX,LOAD)
      IPTR=IPTR+NX
!
! KSTBST/ISTBST
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KSTBST),NX,LOAD)
      IPTR=IPTR+NX
!
! KANCUT/IANTSC
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KANCUT),NX,LOAD)
      IPTR=IPTR+NX
!
! KANGPS/IANGPS
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KANGPS),NX,LOAD)
      IPTR=IPTR+NX
!
! KANTYP/IANTYP
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KANTYP),NX,LOAD)
      IPTR=IPTR+NX
!
! KANTOF/IANTOF2
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KANTOF),NX,LOAD)
      IPTR=IPTR+NX
!
! KYSAT/ISATYA
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KYSAT),NX,LOAD)
      IPTR=IPTR+NX
!
! KMBDEG/
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KMBDEG),NX,LOAD)
      IPTR=IPTR+NX
!
! KMBNOD/
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KMBNOD),NX,LOAD)
      IPTR=IPTR+NX
!
! KMBSST/
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KMBSST),NX,LOAD)
      IPTR=IPTR+NX
! KBSPLN/
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KBSPLN),NX,LOAD)
      IPTR=IPTR+NX
!
! KSSPLN/
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KSSPLN),NX,LOAD)
      IPTR=IPTR+NX
! KNEXCG
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KNEXCG),NX,LOAD)
      IPTR=IPTR+NX
! KIDEXC
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KIDEXC),NX,LOAD)
      IPTR=IPTR+NX
! KNREXC
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KNREXC),NX,LOAD)
      IPTR=IPTR+NX
! KTELEO
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KTELEO),NX,LOAD)
      IPTR=IPTR+NX
! KTDSAT
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KTDSAT),NX,LOAD)
      IPTR=IPTR+NX
! KTDANT
      IREC=IREC+1
      NX=II(IPTHDR+IREC)
      CALL MOVEI(II(IPTR),II(KTDANT),NX,LOAD)
      IPTR=IPTR+NX
!
! TEST IF CORRECT NUMBER OF DATA RECORDS RELOADED
!
      IF(IREC.NE.NRECS) GO TO 60200
! TEST IF CORRECT NUMBER OF WORDS RELOADED
      IF(NWORDS .NE. IPTR-IPTSTR) GO TO 60220
!**********************************************************************
! LOAD/UNLOAD LOGICAL DATA RECORDS
!**********************************************************************
 9000 ITYPE=3
      IPTHDR=KDAHDR(ITYPE,IGP1)
      NRECS1=II(IPTHDR)
      NRECS =NRECS1-1
      IF(NRECS.LE.0) GO TO 60000
      NWORDS=II(IPTHDR+NRECS1)
      IPTR=KDYNAP(ITYPE,IGP1,1)+(IARCNO-1)*KDYNAP(ITYPE,IGP1,2)
      IPTSTR=IPTR
      IREC=0
! EXAMPLE
! KLNDTT
!     IREC=IREC+1
!     NX=II(IPTHDR+IREC)
!     CALL MOVEL(LL(IPTR),LL(KLNDTT),NX,LOAD)
!     IPTR=IPTR+NX
!
! TEST IF CORRECT NUMBER OF DATA RECORDS RELOADED
!
      IF(IREC.NE.NRECS) GO TO 60200
! TEST IF CORRECT NUMBER OF WORDS RELOADED
      IF(NWORDS.NE. IPTR-IPTSTR ) GO TO 60220
!**********************************************************************
! NORMAL END OF ROUTINE
!**********************************************************************
60000 RETURN
!**********************************************************************
! ERROR PROCESSING
!**********************************************************************
! NUMBER OF OUTPUT RECORDS EXCEEDS LENGTHS RECORD
60150 WRITE(IOUT6,80150) IBLOCK,IGROUP,ITYPE,(IFFHDR(J),J=1,10)
      WRITE(IOUT6,89999)
      STOP
! NUMBER OF RECORDS READ/RELOADED DISAGREES WITH NUMBER EXPECTED
60200 WRITE(IOUT6,80200) IARCNO,ITYPE,IREC,NRECS
      WRITE(IOUT6,89999)
      STOP
! NUMBER OF WORDS READ/RELOADED DISAGREES WITH NUMBER OF WORDS EXPECTED
60220 WRITE(IOUT6,80220) IARCNO,ITYPE,NWORDS,IPTR,IPTSTR
      WRITE(IOUT6,89999)
      STOP
! INTEGER OR LOGICAL RECORD EXCEEDS BUFFER SPACE AVAILABLE
60300 WRITE(IOUT6,80300) IARCNO,ITYPE,IREC,NX,IFBUFR
      WRITE(IOUT6,89999)
      STOP
! FLOATING POINT CONVERSION PROBLEM
60350 WRITE(IOUT6,80350) ISTAT
      WRITE(IOUT6,89999)
      STOP
80150 FORMAT(1X,'BLOCK NUMBER,GROUP NUMBER OR TYPE IS INCORRECT ',      &
     & 13I5)
80200 FORMAT(1X,'NUMBER OF RECORDS READ/RELOADED DISAGREES WITH NUMBER',&
     &'EXPECTED. ARC NO.,RECORD TYPE,RECORD NUMBER, AND NO. OF RECORDS',&
     &'FOLLOWS'/5X,4I8)
80220 FORMAT(1X,'NUMBER OF WORDS READ/RELOADED DISAGREES WITH NUMBER',&
     &'EXPECTED. '/1X,'ARC NUMBER,RECORD TYPE,NUMBER OF WORDS,STARTING',&
     &'POINTER,AND ENDING POINTER FOLLOW'/1X,6I8)
80300 FORMAT(1X,'INPUT RECORD EXCEEDS BUFFER SPACE - (ARC NO.,RECORD',&
     &'TYPE,RECORD NUMBER,NO. OF WORDS,BUFFER SPACE )'/10X,5I8)
80350 FORMAT(1X,'FLOATING POINT CONVERSION PROBLEM - ISTAT = ',I5)
89999 FORMAT(1X,'EXECUTION TERMINATING IN SUBROUTINE IFRAD4 ')
      END