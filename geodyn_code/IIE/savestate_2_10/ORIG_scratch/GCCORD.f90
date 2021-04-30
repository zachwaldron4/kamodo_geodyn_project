!$GCCORD
      SUBROUTINE GCCORD(MJDSN,FSECN,XTN,XTK,VTN,VTK,XMN,XMK,NMP,        &
     &   INDSTA,INDP,RPOLE,PXPOLE,NINTPL,MINTPL,S,S1,XTP,NM,LPOLAD,     &
     &   PXSPXP,PXSPLV,COSTHG,SINTHG,MTYPE,PMPXE,PMPXI,XDPOLE,          &
     &   AA,II,LL,PXSPXD,UTDT)
!**********************************************************************
!    2   RNM,RKM,RKJ,RIJ,RRNM,RRKM,RRKJ,RRIJ,URNM,URKM,URKJ,URIJ,
!    3   PRRPNM,PRRPKM,PRRPKJ,PRRPIJ,NMP,INDSTA,INDP,RPOLE,PXPOLE,
!    4   NINTPL,MINTPL,S,S1,XTP,RELV,PXSPXP,PXSPLV,COSTHG,SINTHG,
!    5   INDSAT,SIGNL,NM,LPOLAD,LIGHT,LRANGE,LSKIP1,IEXIT,LTDRSS,
!    6   GRELT1,GRELT2,GRELT3,GRELT4,DELCTN,DELCTK,DELCTI,PSTAT,
!    7   RSUNST,CHEMR,CHMOR,EPOSR,CHEMT,CHMOT,EPOST,CHCBS,CPOSS,SCRTM,
!    8   XSTT,XSTR,XSS,MTYPE,INDSET,AA,II,LL)
!***********************************************************************
!
! VERSION           - 9101.0  DATE- 02.05.91      LUCIA TSAOUSSI
!
! FUNCTION          - COMPUTE J2000.0 STATE VECTORS FOR THE SITES
!                     IN THE VLBI MEASUREMENT MODELLING
!
! INPUT PARAMETERS  - MJDSN=MODIFIED JULIAN DAY SECONDS OF THE FINAL
!                           RECEIVED TIME OF THE FIRST OBSERVATION IN
!                           THE BLOCK
!                     FSECN=ELAPSED SECONDS FROM MJDSN OF THE TIME
!                           TAG ASSOCIATED WITH STATION 1
!                     XMN=MEAN POLE COORDINATES OF TRACKING STATION 1
!                     XMK=MEAN POLE COORDINATES OF TRACKING STATION 2
!                     NM=NUMBER OF MEASUREMENTS
!                     LPOLAD=SWITCH INDICATING IF POLAR MOTION ADJUST.
!                            PARTIALS ARE REQUIRED FOR EACH INTERP.
!                            INTERVAL
!
! OUTPUT PARAMETERS - XTN=J2000.0 POSITION OF SITE 1
!                   - XTK=J2000.0 POSITION OF SITE 2
!                   - VTN=J2000.0 VELOCITY OF SITE 1
!                   - VTK=J2000.0 VELOCITY OF SITE 2
!                   - NMP=INDEX OF THE LAST MEASUREMENT ASSOCIATED WITH
!                         EACH INTERPOLATION INTERVAL
!                   - INDSTA=POINTER TO INTERNAL STATION NUMBER
!                   - INDP=POINTER TO ADJUSTED POLAR MOTION VALUES
!                          ASSOCIATED WITH EACH INTERPOLATION INTERVAL
!                   - PXSPXP=PARTIALS OF TRUE POLE STATION COORDINATES
!                            W.R.T. POLAR MOTION FOR EACH OF "NM"
!                            MEASUREMENT TIMES
!                   - COSTHG=COSINES OF RIGHT ASCENSION OF GREENWICH
!                   - SINTHG= SINES  OF RIGHT ASCENSION OF GREENWICH
!                     MTYPE =MEASUREMENT TYPE
!
! WORKING ARRAYS    - RPOLE=POLAR MOTION ROTATION MATRICES AT EACH END
!                           OF EACH INTERPOLATION INTERVAL
!                     PXPOLE=PARTIALS OF THE TRUE POLE STATION LOCATION
!                            W.R.T. THE POLAR MOTION X & Y PARAMETERS AT
!                            EACH END OF EACH INTERPOLATION INTERVAL
!                     MINTPL=MAXIMUM NUMBER OF INTERPOLATION INTERVALS
!                     S=INTERPOLATION FRACTIONS
!                     S1=1.0-S
!                     XTP=TRUE POLE COORDINATES OF A TRACKING STATION
!                     XDPOLE=PARTIALS OF THE TRUE POLE STATION RATE
!                            W.R.T. THE POLAR MOTION X & Y PARAMETERS AT
!                            EACH END OF EACH INTERPOLATION INTERVAL
!
!***********************************************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      COMMON/CBINRL/LBINR,LLOCR,LODR,LBNCR,LBINRI,LLOCRI,LODRI,LBNCRI,  &
     &              NXCBIN
      COMMON/CBLOKV/QUANO(3),EHAT(3),DEDA(3),DEDD(3),EFLG
      COMMON/CEGREL/LGRELE,LRLCLK,LGRELR,LXPCLK,LBPCLK,NXEGRL
      COMMON/CHCOEF/ COEFM(3,15),COEFJ(3,15),COEFSA(3,15),COEFS(3,15),  &
     &               COEFEM(3,15),COEFMO(3,15),COEF(3,15)
      COMMON/CIMDST/IDRLTM(200),ITRLTM(200),IRELON,IRLONA,NRLTMC,       &
     & IDRCK4(200),IRKONA,NROCK4,IRKRAD,NXIRTM
      COMMON/CITERL/LSTGLB,LSTARC,LSTINR,LNADJ ,LITER1,LSTITR,          &
     &              LOBORB,LRESID,LFREEZ,LSAVEF,LHALT,LADJPI,LADJCI
      COMMON/CLIGHT/VLIGHT,ERRLIM,XCLITE
      COMMON/CNIGLO/MINTIM,MSATG3,MEQNG ,MEQNG3,MSATG ,MSATOB,MSATA ,   &
     &              MSATA3,MSETA ,MINTVL,MSORDR,MSORDV,NMXORD,          &
     &       MCIPV ,MXBACK,MXI   ,MPXPF ,MAXAB ,MSETDG,MXSATD,          &
     &       MXDEGS,MXDRP ,MXDRPA,MXSRP ,MXSRPA,MXGAP ,MSATDR,          &
     &       MSATSR,MSATGA,MXDRPD,MXSRPD,MXGAPD,MXBCKP,MXTPMS,          &
     &       NSTAIN,NXCNIG
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
      COMMON/CORA02/KFSCTB,KFSCTC,KFSCTE,KDSECT,                        &
     &              KFSECT,KS    ,KCIP  ,KCIV  ,                        &
     &       KXTN  ,KXSM  ,KXTK  ,KXSJ  ,KXTI  ,KXTKP ,                 &
     &       KVTN  ,KVSM  ,KVTK  ,KVSJ  ,KVTI  ,KVTKP ,                 &
     &       KSATLT,KSATLN,KSATH ,KCOSTH,KSINTH,                        &
     &       KPXPFM,KPXPFK,KPXPFJ,KTRBF ,KFSTRC,                        &
     &       KFSTRE,KDSCTR,KFSCVS,KXSMBF,KXSKBF,KXSJBF,                 &
     &       KRSSV1,KRSSV2,KRSSV3,KTPMES,KACOEF,KACTIM,                 &
     &       KXTNPC,KXSMPC,KXTKPC,KXSJPC,KXTIPC,KXTKPP,                 &
     &       KRLRNG,KASTO,KASTP,NXCA02
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
      COMMON/CORI02/KNTIME,KMJSTB,KMJSTC,KMJSTE,KISECT,                 &
     &              KINDH ,KNMH  ,KIVSAT,KIPXPF,KNTRTM,KMSTRC,          &
     &              KMSTRE,KISCTR,KISATR,KITRUN,KTRTMB,KTRTMC,          &
     &              KMJDVS,KNTMVM,NXCI02
      COMMON/CORI03/KICRD ,KICON ,KISTNO,KINDPI,KMJDPL,KIPOLC,          &
     &              KNDOLA,KIOLPA,KKIOLA,KIP0OL,KNDOLM,KIOLPM,          &
     &              KKIOLM,KIPVOL,KICNL2,KICNH2,                        &
     &              KSTMJD, KNUMST, KITAST, KSTNRD, KICNV,              &
     &              KTIDES,KFODEG,KFOORD,KRDEGR,KRORDR,                 &
     &              KPHINC,KDOODS,KOTFLG,KJDN  ,KPTDN ,                 &
     &              KATIND,KPRESP,KMP2RS,KSITE,KPTOLS,NXCI03
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
      COMMON/CORL01/KLORBT,KLORBV,KLNDRG,KLBAKW,KLSETS,KLAFRC,KLSTSN,   &
     &              KLSNLT,KLAJDP,KLAJSP,KLAJGP,KLTPAT,KEALQT,KLRDGA,   &
     &              KLRDDR,KLRDSR,KFHIRT,KLSURF,KHRFON,KLTPXH,KSETDN,   &
     &              KTALTA,NXCL01
      COMMON/CPARFL/LPARFI,LPFEOF,LARCNU,LRORR
      COMMON/CRDDIM/NDCRD2,NDCRD3,NDCRD4,NDCRD5,NDCRD6,NDCRD7,          &
     &              NDCRD8,NDCRD9,NXCRDM
      COMMON/CREFMT/REFMT(9)
      COMMON/CSBSAT/KR,KRT,KZT,KXY2,KUZ,KUZSQ,KTEMP,KC3,KTHETG
      COMMON/IBODPT/IBDCF(999),IBDSF(999),IBDGM(999),IBDAE(999),    &
     &              IBDPF(999),                                     &
     &              ICBDCF,ICBDSF,ICBDGM,ICBDAE,ICBDPF,             &
     &              ITBDCF,ITBDSF,ITBDGM,ITBDAE,ITBDPF,NXBDPT
      COMMON/IORCHB/ IORM,IORJ,IORSA,IORSUN,IOREM,IORMO,IORCB,IORTB,    &
     &               IGRP,ICHBOG(2,14),IORSCB(988),NXORCH
      COMMON/LOLOAD/LOLMD,LOLAJ,L2FOLT,LAPLOD
      COMMON/OCCLTL/LOCCLT(200),LMSHD(200)
      COMMON/OLDADJ/NPV0OL(3,3),JPV0OL(3,3),NYZ0OL(3,3),JYZ0OL(3,3),    &
     &              NEO0OL(3,3),JEO0OL(3,3)
      COMMON/OLDMOD/NTOLFR,NTOLF2,NTOLMD,NSTAOL,NSITOL,NTOLAJ,MXOLSA,   &
     &              NPOLSH,                                             &
     &              NXOLMD
      COMMON/OLOADA/LXYZCO,LEOPTO
      COMMON/POLESW/LDNPOL,NXPOLS
      COMMON/STATN /NSTA,NSTAE,NMSTA,NCSTA,NSTAV,NSTLV,NSTEL2,          &
     &              NSTEH2,                                             &
     &              NPH2L2,                                             &
     &              NSTNUM, NSTIME, NALLST,KCONAD, NXSTAT
      COMMON/UNITS/IUNT11,IUNT12,IUNT13,IUNT19,IUNT30,IUNT71,IUNT72,    &
     &             IUNT73,IUNT05,IUNT14,IUNT65,IUNT88,IUNT21,IUNT22,    &
     &             IUNT23,IUNT24,IUNT25,IUNT26
      COMMON/VMATFL/LVMTF,LVMTFO
!
      DIMENSION AA(*),II(*),LL(*)
      DIMENSION FSECN(NM),XTN(MINTIM,3),XTK(MINTIM,3),                  &
     &   VTN(MINTIM,3),VTK(MINTIM,3),XMN(3),XMK(3),                     &
     &   NMP(MINTPL,4),NINTPL(4),                                       &
     &   INDSTA(3),INDP(MINTPL,4),RPOLE(3,3,MINTPL),PXPOLE(3,2,MINTPL), &
     &   S(NM),S1(NM),XTP(NM,3),PXSPXP(NM,3,2,4),PMPXI(NM,3),           &
     &   PXSPLV(NM,3,2,4),PMPXE(NM,3),COSTHG(NM,4),SINTHG(NM,4),        &
     &   XDPOLE(3,2,MINTPL),PXSPXD(NM,3,2,4),UTDT(NM,4)
      DIMENSION XENV(3,3)
!
!
      DATA J1,J2,J3,J4/1,2,3,4/
      DATA TWO/2.0D0/
!
!********1*********2*********3*********4*********5*********6*********7**
! START OF EXECUTABLE CODE
!********1*********2*********3*********4*********5*********6*********7**
!
!
!
!***** START HERE TO COMPUTE J2000.0 STATION #1 POSITION & VELOCITY ****
!
      ISTA1=INDSTA(1)
      ISTA2=INDSTA(2)
      CALL GRHRAN(MJDSN,FSECN,.TRUE.,.FALSE.,AA(KEQN),AA(KSRTCH),       &
     &   AA(KTHETG),COSTHG(1,J1),SINTHG(1,J1),NM,AA,II,UTDT(1,J1))
! ***** DEBUG  ********
      THG=AA(KTHETG)
      SINT=SINTHG(1,J1)
      COST=COSTHG(1,J1)
!     WRITE(6,*) '  GCCORD : THETA G, SIN COS  ',THG,SINT,COST
!
!  ******  REPLACE THETA G!!!!!!!!!!!
!     AA(KTHETG)=3.1652938363700876
!     SINTHG(1,J1)=SIN(AA(KTHETG))
!     COSTHG(1,J1)=COS(AA(KTHETG))
! ***** DEBUG  ********
!     THG=AA(KTHETG)
!     SINT=SINTHG(1,J1)
!C    COST=COSTHG(1,J1)
!     WRITE(6,*) '  GCCORD : 1ST SITE THETA G, SIN COS  ',THG,SINT,COST
!
!  ROTATE THE QUASAR VECTOR BY NP TO BE USED FOR THE ANT. CORR.
!
!     WRITE(6,*) ' GCCORD : EHAT  ',(EHAT(J),J=1,3)
!     WRITE(6,*) '  GCCORD : CALL TO TDORT3 FOR CF QUASAR*** '
      CALL TDORT3(MJDSN,FSECN,EHAT,PMPXE,AA,NM,.FALSE.,II)
! ****  ROTATION DEBUG ********
!     WRITE(6,*) 'NP MATRIX ', KROTMT,(KROTMT+NDCRD2),(KROTMT+NDCRD3)
!     WRITE(6,*) AA(KROTMT),AA(KROTMT+NDCRD2),AA(KROTMT+NDCRD3)
!     WRITE(6,*) (KROTMT+NDCRD4),(KROTMT+NDCRD5),(KROTMT+NDCRD6)
!     WRITE(6,*) AA(KROTMT+NDCRD4),AA(KROTMT+NDCRD5),AA(KROTMT+NDCRD6)
!     WRITE(6,*) (KROTMT+NDCRD7),(KROTMT+NDCRD8),(KROTMT+NDCRD9)
!     WRITE(6,*) AA(KROTMT+NDCRD7),AA(KROTMT+NDCRD8),AA(KROTMT+NDCRD9)
!     WRITE(6,*) ' GCCORD : E ROTATION BY NP PMPXE ',(PMPXE(1,J),J=1,3)
!
!  ROTATE ROT2T BY THETA G TO BE USED FOR THE ANT. CORR.
      CALL ECFIXP(PMPXE,COSTHG(1,J1),SINTHG(1,J1),PMPXI,NM,NM,NM)
!     WRITE(6,*) ' GCCORD : ADD ROT BY TH G : PMPXI ',(PMPXI(1,J),J=1,3)
!
! OBTAIN POLAR MOTION ROTATION MATRICES AND PARTIAL DERIVATIVE MATRICES
!        FROM WHICH TO INTERPOLATE ACROSS THE ENTIRE BLOCK OF DATA
      CALL INPOLE(AA(KA1UT),AA(KDPSR),AA(KXPUT),AA(KYPUT),.TRUE.,LDNPOL,&
     &   LPOLAD,MJDSN,FSECN,NM,XMN,II(KINDPI),NINTPL(J1),NMP(1,J1),     &
     &   INDP(1,J1),PXPOLE,RPOLE,S,XDPOLE,AA(KXDOTP))
! COMPUTE TRUE POLE STATION COORDINATES AND INTERPOLATE PARTIAL DERIV.
!         MATRICES FOR ENTIRE BLOCK OF DATA
      NINTP2=NINTPL(J1)*2
!     WRITE(6,*) '  GCCORD : XMN  ',XMN
      lyara = .false.
      isnumb = 0
      CALL TRUEPV(S,S1,NMP(1,J1),INDP(1,J1),RPOLE,PXPOLE,LPOLAD,XMN,XTP,&
     &   PXSPXP(1,1,1,J1),PXSPLV(1,1,1,J1),NM,NINTPL(J1),NINTP2,MJDSN,  &
     &   FSECN,COSTHG(1,J1),SINTHG(1,J1),.TRUE.,AA(KWVLBI),AA(KSTAIN),  &
     &   AA(KPLTDV),AA(KPLTVL),INDSTA(J1),AA(KSTVEL),AA(KTIMVL),        &
     &   PMPXE,PMPXI,II(KICNL2),II(KICNH2),.TRUE.,AA,                   &
     &   LYARA, ISNUMB, II ,XDPOLE,PXSPXD(1,1,1,J1))
!     WRITE(6,*) ' GCCORD : CR FIX QUASAR PMPXI ',(PMPXI(1,J),J=1,3)
!     WRITE(6,*) ' GCCORD : CR FIX QUASAR PMPXE ',(PMPXE(1,J),J=1,3)
!     WRITE(6,*) ' GCCORD : XTP AFTER TRUEPV  ',(XTP(1,J),J=1,3)
      LESTA=ISTA1.LE.NSTAE.OR.ISTA2.LE.NSTAE
      IF(.NOT.LOLMD) GO TO 500
!     WRITE(6,*) ' GCCORD : CALL TO OLDSET  '
      CALL OLDSET(J1,INDSTA(J1),NM,AA(KSTAIN),II(KIP0OL),II(KNDOLA),    &
     &          II(KKIOLA),LOLAJ,LOLMDS,JABCOF,JPXSPA,JOLPAE,JOLPAN,    &
     &          JOLPAV,JXLOCV,                                          &
     &          JABCCM,JPXSP1,JOLPXC,JOLPYC,JOLPZC,                     &
     &          JABCEO,JPXSP2,JOLPXP,JOLPYP,JOLPUP,LALOAD,ISITA,XENV)
!     WRITE(6,*) ' GCCORD : XTP AFTER OLDSET  ',(XTP(1,J),J=1,3)
      IF(.NOT.LOLMDS) GO TO 500
!     IF(LEOPTO.OR.LOLMDS.OR.LXYZCO) THEN
         CALL OLTIME(MJDSN,FSECN,NM,AA(KANGFC),AA(KSPEED),AA(KSCROL),   &
     &               AA(KSCROL+4*NTOLFR),II(KPTOLS),AA(KANGT),          &
     &               AA(KCONAM),AA(KTWRK1),AA(KGRDAN),AA(KUANG),        &
     &               AA(KFAMP),II(KJDN))

!     ENDIF
!     WRITE(6,*) ' GCCORD : CALL TO OLOAD  '
      isnumb = 0
      CALL OLOAD(MJDSN,FSECN,NM,AA(JABCOF),AA(KANGFC),AA(KSPEED),       &
     &           AA(JXLOCV),XTP,AA(KSCROL),AA(KWVLBI),LOLAJ,            &
     &           AA(JPXSPA),NPV0OL(1,J1),NPV0OL(2,J1),NPV0OL(3,J1),     &
     &           II(JOLPAE),II(JOLPAN),II(JOLPAV),AA(JABCCM),           &
     &           AA(JPXSP1),NYZ0OL(1,J1),NYZ0OL(2,J1),NYZ0OL(3,J1),     &
     &           II(JOLPXC),II(JOLPYC),II(JOLPZC),AA(JABCEO),           &
     &           AA(JPXSP2),NEO0OL(1,J1),NEO0OL(2,J1),NEO0OL(3,J1),     &
     &           II(JOLPXP),II(JOLPYP),II(JOLPUP),LOLMDS,LXYZCO,LEOPTO, &
     &           isnumb ,.FALSE.,NM,LALOAD,AA(KALCOF),II(KSITE),ISITA,  &
     &           XENV)
!     WRITE(6,*) ' GCCORD : XTP AFTER OLOAD  ',(XTP(1,J),J=1,3)
  500 CONTINUE
! ROTATE TRUE POLE STATION COORDINATES TO TRUE OF DATE ACROSS ENTIRE
!        BLOCK OF DATA
! ***** DEBUG  ********
      THG=AA(KTHETG)
      SINT=SINTHG(1,J1)
      COST=COSTHG(1,J1)
!     WRITE(6,*) '  GCCORD : THETA G, SIN COS  ',THG,SINT,COST
      CALL INERTP(XTP,COSTHG(1,J1),SINTHG(1,J1),XTN,NM,MINTIM,NM)
! COMPUTE INERTIAL STATION VELOCITIES
      CALL INRTSV(COSTHG(1,J1),SINTHG(1,J1),XTN,VTN,NM,MINTIM)
! ROTATE TO J2000.0 REFERENCE SYSTEM
!     WRITE(6,*) '  GCCORD : CALL TO TDORTR *** '
!     CALL TDORTR(MJDSN,FSECN,XTN,XTN,AA,NM,MINTIM,.TRUE.,.TRUE.,II)
! ****  ROTATION DEBUG ********
!
      CALL RTNP(AA(KROTMT),AA(KROTMT+NDCRD2),AA(KROTMT+NDCRD3),         &
     &    AA(KROTMT+NDCRD4),AA(KROTMT+NDCRD5),AA(KROTMT+NDCRD6),        &
     &    AA(KROTMT+NDCRD7),AA(KROTMT+NDCRD8),AA(KROTMT+NDCRD9),        &
     &    XTN,XTN,NM,MINTIM,.TRUE.)
! ****  ROTATION DEBUG ********
!     WRITE(6,*) 'NP MATRIX ', KROTMT,(KROTMT+NDCRD2),(KROTMT+NDCRD3)
!     WRITE(6,*) AA(KROTMT),AA(KROTMT+NDCRD2),AA(KROTMT+NDCRD3)
!     WRITE(6,*) (KROTMT+NDCRD4),(KROTMT+NDCRD5),(KROTMT+NDCRD6)
!     WRITE(6,*) AA(KROTMT+NDCRD4),AA(KROTMT+NDCRD5),AA(KROTMT+NDCRD6)
!     WRITE(6,*) (KROTMT+NDCRD7),(KROTMT+NDCRD8),(KROTMT+NDCRD9)
!     WRITE(6,*) AA(KROTMT+NDCRD7),AA(KROTMT+NDCRD8),AA(KROTMT+NDCRD9)
!     WRITE(6,*) ' GCCORD : FINAL STATION PARTIAL VECTOR ROTATION'
!     WRITE(6,*) ' GCCORD : PMPXE ',(PMPXE(1,J),J=1,3)
!
  200 CONTINUE
!     CALL TDORTR(MJDSN,FSECN,VTN,VTN,AA,NM,MINTIM,.FALSE.,.TRUE.,II)
      CALL RTNP(AA(KROTMT),AA(KROTMT+NDCRD2),AA(KROTMT+NDCRD3),         &
     &    AA(KROTMT+NDCRD4),AA(KROTMT+NDCRD5),AA(KROTMT+NDCRD6),        &
     &    AA(KROTMT+NDCRD7),AA(KROTMT+NDCRD8),AA(KROTMT+NDCRD9),        &
     &    VTN,VTN,NM,MINTIM,.TRUE.)
!     WRITE(6,*) ' GCCORD:XTN  ',(XTN(1,J),J=1,3)
!     WRITE(6,*) ' GCCORD:VTN  ',(VTN(1,J),J=1,3)
!
!
!
!***** START HERE TO COMPUTE J2000.0 STATION #2 POSITION & VELOCITY ****
!
      CALL GRHRAN(MJDSN,FSECN,.TRUE.,.TRUE.,AA(KEQN),AA(KSRTCH),        &
     &   AA(KTHETG),COSTHG(1,J2),SINTHG(1,J2),NM,AA,II,UTDT(1,J2))
!
!  ******  REPLACE THETA G!!!!!!!!!!!
!     AA(KTHETG)=3.1652938363700876
!     SINTHG(1,J2)=SIN(AA(KTHETG))
!     COSTHG(1,J2)=COS(AA(KTHETG))
! ***** DEBUG  ********
!     THG=AA(KTHETG)
!     SINT=SINTHG(1,J2)
!     COST=COSTHG(1,J2)
!     WRITE(6,*) '  GCCORD : 2ND SITE THETA G, SIN COS  ',THG,SINT,COST
! OBTAIN POLAR MOTION ROTATION MATRICES AND PARTIAL DERIVATIVE MATRICES
!        FROM WHICH TO INTERPOLATE ACROSS THE ENTIRE BLOCK OF DATA
      CALL INPOLE(AA(KA1UT),AA(KDPSR),AA(KXPUT),AA(KYPUT),.TRUE.,LDNPOL,&
     &   LPOLAD,MJDSN,FSECN,NM,XMK,II(KINDPI),NINTPL(J2),NMP(1,J2),     &
     &   INDP(1,J2),PXPOLE,RPOLE,S,XDPOLE,AA(KXDOTP))
! COMPUTE TRUE POLE STATION COORDINATES AND INTERPOLATE PARTIAL DERIV.
!         MATRICES FOR ENTIRE BLOCK OF DATA
      NINTP2=NINTPL(J2)*2
      lyara = .false.
      isnumb = 0
      CALL TRUEPV(S,S1,NMP(1,J2),INDP(1,J2),RPOLE,PXPOLE,LPOLAD,XMK,XTP,&
     &   PXSPXP(1,1,1,J2),PXSPLV(1,1,1,J2),NM,NINTPL(J2),NINTP2,MJDSN,  &
     &   FSECN,COSTHG(1,J2),SINTHG(1,J2),.TRUE.,AA(KWVLBI),AA(KSTAIN),  &
     &   AA(KPLTDV),AA(KPLTVL),INDSTA(J2),AA(KSTVEL),AA(KTIMVL),        &
     &   PMPXE,PMPXI,II(KICNL2),II(KICNH2),.FALSE.,AA,                  &
     &   LYARA, ISNUMB, II ,XDPOLE,PXSPXD(1,1,1,J2))
!     WRITE(6,*) ' GCCORD : 2 CR FIX QUASAR PMPXI ',(PMPXI(1,J),J=1,3)
!     WRITE(6,*) ' GCCORD : SHOULD NOT CHANGE PMPXE ',(PMPXE(1,J),J=1,3)
      IF(.NOT.LOLMD) GO TO 700
      CALL OLDSET(J2,INDSTA(J2),NM,AA(KSTAIN),II(KIP0OL),II(KNDOLA),    &
     &          II(KKIOLA),LOLAJ,LOLMDS,JABCOF,JPXSPA,JOLPAE,JOLPAN,    &
     &          JOLPAV,JXLOCV,                                          &
     &          JABCCM,JPXSP1,JOLPXC,JOLPYC,JOLPZC,                     &
     &          JABCEO,JPXSP2,JOLPXP,JOLPYP,JOLPUP,LALOAD,ISITA,XENV)
      IF(.NOT.LOLMDS) GO TO 700
!     WRITE(6,*) ' GCCORD : CALL TO OLOAD  '
!     WRITE(6,*) ' GCCORD : XTP BEFORE OLOAD  ',(XTP(1,J),J=1,3)
      isnumb = 0
!     IF(LEOPTO.OR.LOLMDS.OR.LXYZCO) THEN
         CALL OLTIME(MJDSN,FSECN,NM,AA(KANGFC),AA(KSPEED),AA(KSCROL),   &
     &               AA(KSCROL+4*NTOLFR),II(KPTOLS),AA(KANGT),          &
     &               AA(KCONAM),AA(KTWRK1),AA(KGRDAN),AA(KUANG),        &
     &               AA(KFAMP),II(KJDN))
!     ENDIF
      CALL OLOAD(MJDSN,FSECN,NM,AA(JABCOF),AA(KANGFC),AA(KSPEED),       &
     &           AA(JXLOCV),XTP,AA(KSCROL),AA(KWVLBI),LOLAJ,            &
     &           AA(JPXSPA),NPV0OL(1,J2),NPV0OL(2,J2),NPV0OL(3,J2),     &
     &           II(JOLPAE),II(JOLPAN),II(JOLPAV),AA(JABCCM),           &
     &           AA(JPXSP1),NYZ0OL(1,J1),NYZ0OL(2,J1),NYZ0OL(3,J1),     &
     &           II(JOLPXC),II(JOLPYC),II(JOLPZC),AA(JABCEO),           &
     &           AA(JPXSP2),NEO0OL(1,J1),NEO0OL(2,J1),NEO0OL(3,J1),     &
     &           II(JOLPXP),II(JOLPYP),II(JOLPUP),LOLMDS,LXYZCO,LEOPTO, &
     &           isnumb ,.FALSE.,NM,LALOAD,AA(KALCOF),II(KSITE),ISITA,  &
     &           XENV)
!     WRITE(6,*) ' GCCORD : XTP AFTER OLOAD  ',(XTP(1,J),J=1,3)
  700 CONTINUE
! ROTATE TRUE POLE STATION COORDINATES TO TRUE OF DATE ACROSS ENTIRE
!        BLOCK OF DATA
      CALL INERTP(XTP,COSTHG(1,J2),SINTHG(1,J2),XTK,NM,MINTIM,NM)
! COMPUTE INERTIAL STATION VELOCITIES
      CALL INRTSV(COSTHG(1,J2),SINTHG(1,J2),XTK,VTK,NM,MINTIM)
! ROTATE TO J2000.0 REFERENCE SYSTEM
!     CALL TDORTR(MJDSN,FSECN,XTK,XTK,AA,NM,MINTIM,.TRUE.,.TRUE.,II)
      CALL RTNP(AA(KROTMT),AA(KROTMT+NDCRD2),AA(KROTMT+NDCRD3),         &
     &    AA(KROTMT+NDCRD4),AA(KROTMT+NDCRD5),AA(KROTMT+NDCRD6),        &
     &    AA(KROTMT+NDCRD7),AA(KROTMT+NDCRD8),AA(KROTMT+NDCRD9),        &
     &    XTK,XTK,NM,MINTIM,.TRUE.)
!     CALL TDORTR(MJDSN,FSECN,VTK,VTK,AA,NM,MINTIM,.FALSE.,.TRUE.,II)
      CALL RTNP(AA(KROTMT),AA(KROTMT+NDCRD2),AA(KROTMT+NDCRD3),         &
     &    AA(KROTMT+NDCRD4),AA(KROTMT+NDCRD5),AA(KROTMT+NDCRD6),        &
     &    AA(KROTMT+NDCRD7),AA(KROTMT+NDCRD8),AA(KROTMT+NDCRD9),        &
     &    VTK,VTK,NM,MINTIM,.TRUE.)
!     WRITE(6,*) ' GCCORD:XTK  ',(XTK(1,J),J=1,3)
!     WRITE(6,*) ' GCCORD:VTK  ',(VTK(1,J),J=1,3)
      RETURN
      END