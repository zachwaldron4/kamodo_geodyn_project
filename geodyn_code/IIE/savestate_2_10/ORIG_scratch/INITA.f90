!$INITA
      SUBROUTINE INITA(AA,II,LL,PARMV,IGPCA,IGPSA,LHRFON,JPTFSB,JPTFBS, &
     &                 JSALST)
!*******1**********2*********3*********4*********5*********6*********7**
! INITA            04/26/84            0000.0    PGMR - B. EDDY
!
! FUNCTION:        INITIALIZE ARC PARAMETERS AT THE BEGINNING OF EACH
!                  ARC. THE FOLLOWING FUNCTIONS ARE PERFORMED:
!                  . RELOADING OF ARC COMMON BLOCK INFORMATION FROM
!                    EXTENDED VIRTUAL TO DYNAMIC MEMORY
!                  . RELOADING OF ARC DYNAMIC ARRAY INFORMATION FROM
!                    EXTENDED VURTUAL TO DYNAMIC MEMORY
!                  . SETTING OF POINTERS TO ARC FORCE MODEL ARRAYS
!                  . COMPUTATION OF TRUE OF REFERENCE TO MEAN OF 50
!                    ROTATION MATRIX
!                  . LOADING OF GEOPOTENTIAL ARRAY FROM PARMV ARRAY
!                    TO FORCE MODEL ARRAY. COEFFICIENTS ARE
!                    DENORMALIZED WHEN THEY ARE LOADED INTO THE
!                    FORCE MODEL ARRAYS.
!                  . COMPUTE ARC GEOPOTENTIAL DENORMALIZATION FACTOR
!                    FOR ADJUSTED C,S COEFFICIENTS
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   AA      I/O   A    DYANMIC ARRAY FOR REAL    DATA
!   II      I/O   A    DYNAMIC ARRAY FOR INTEGER DATA
!   LL       I    A    DYNAMIC ARRAY FOR LOGICAL DATA
!   PARMV    I    A    PARAMETER VALUES ARRAY
!   IGPCA    I    A    DEG AND ORDER OF ARC GEOPOTENTIAL C COEF.
!   IGPSA    I    A    DEG AND ORDER OF ARC GEOPOTENTIAL S COEF.
!
! COMMENTS:
!
!
!*******1**********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      COMMON/ACCLRM/MDYNPD,MBAPPD,MACOBS,IDYNSC(200),MDYNST,IACCSC(200),&
     &              MACCSC,NACPRM(200),NATPRM(200),NXCLRM
      COMMON/ATTCNT/KATUD,KATBL,KATID,KATAD
      COMMON/ARCPAR/MAXSEL,NSEL,MAXDEL,NDEL,MAXMET,NMETDT,NSATID,       &
     &              IATDEN,ISATEQ,ITRMAX,ITRMIN,ITRMX2,                 &
     &              MJDSRF,MREFSY,NTDDR,NBTOTL,IDRAGM,IMRNUT,           &
     &              NXARCP
      COMMON/ARCPR /FSECRF,XARCPR
      COMMON/BINBUF/NBUFIN,NLENI ,MAXBUF,MAXOBS,NBUFOT,NLENO ,NMAXOT,   &
     &              KBUFOT,MXBLEN,MAXTDD,NLENDR,MOBSBK,MXTIMB,          &
     &              MXOBSB,IIOBDR,IPSMAX,ILIMBK,NPASS ,MVERSN,NXBINB
      COMMON/CASPER/NFGGLB,NFFGLB,NFGARC,NFFARC,NGGA,NGFA,NAGA,NAFA,    &
     &              NFANEP,NFDIR(4),NSATFA(2,200),NFANTM,NXCASP
      COMMON/CEDIT /EDITX ,EDTRMS,EDLEVL,CONVRG,GLBCNV,EBLEVL,EDITSW,   &
     &              ENPX  ,ENPRMS,ENPCNV,EDBOUN,FREEZI,FREEZG,FREEZA,   &
     &              XCEDIT
      COMMON/CGRAV/GM,AE,AESQ,FE,FFSQ32,FSQ32,XK2,XK3,XLAM,SIGXK2,      &
     &      SIGXK3,SIGLAM,RATIOM(2),AU,RPRESS
      COMMON/CGVTMI/NCDT,NSDT,NCPD,NSPD,NCDTA,NSDTA,NCPDA,NSPDA,NGRVTM, &
     &       KCDT,KCPDA,KCPDB,KSDT,KSPDA,KSPDB,KOMGC,KOMGS,KCOMGC,      &
     &       KSOMGC,KCOMGS,KSOMGS,NXGVTI
      COMMON/CESTIM/MPARM,MAPARM,MAXDIM,MAXFMG,ICLINK,IPROCS,NXCEST
      COMMON/CITER /NINNER,NARC,NGLOBL
      COMMON/CITERL/LSTGLB,LSTARC,LSTINR,LNADJ ,LITER1,LSTITR,          &
     &              LOBORB,LRESID,LFREEZ,LSAVEF,LHALT,LADJPI,LADJCI
      COMMON/CITERG/MARC,MGLOBL,MGLOBM,                                 &
     &              MGLOCV,NXITRG
      COMMON/CITERM/MAXINR,MININR,MAXLST,IHYPSW,NXITER
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
      COMMON/CORA06/KPRMV ,KPNAME,KPRMV0,KPRMVC,KPRMVP,KPRMSG,KPARVR,   &
     &              KPRML0,KPDLTA,KSATCV,KSTACV,KPOLCV,KTIDCV,KSUM1 ,   &
     &              KSUM2 ,KGPNRA,KGPNRM,KPRSG0,KCONDN,KVELCV,          &
     &              KSL2CV,KSH2CV,KTIEOU,KPRMDF,NXCA06
      COMMON/CORA07/KELEVT,KSRFEL,KTINT,KFSCSD,KXTIM,KFSDM,             &
     & KSGM1,KSGM2,KNOISE,KEPHMS,NXCA07
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
      COMMON/CORI06/KPTRAU,KPTRUA,KNFMG ,KIPTFM,KILNFM,KIGPC ,          &
     &              KIGPS ,KIGPCA,KIGPSA,KIELMT,KMFMG ,KTPGPC,          &
     &              KTPGPS,KTPUC ,KTPUS,                                &
     &              KLINK,KPTFAU,KPTFUA,NXCI06
      COMMON/CORI07/KSMSA1,KSMSA2,KSMSA3,KSMST1,KSMST2,KSMST3,KSMTYP,   &
     &              KSMT1,KSMT2,KMSDM,KIOUT,KISUPE,NXCI07
      COMMON/CORL01/KLORBT,KLORBV,KLNDRG,KLBAKW,KLSETS,KLAFRC,KLSTSN,   &
     &              KLSNLT,KLAJDP,KLAJSP,KLAJGP,KLTPAT,KEALQT,KLRDGA,   &
     &              KLRDDR,KLRDSR,KFHIRT,KLSURF,KHRFON,KLTPXH,KSETDN,   &
     &              KTALTA,NXCL01
      COMMON/CORL02/KLNDTT,KLWSTR,KLNDTR,KLEVMF,KLTPMS,NXCL02
      COMMON/CORL04/KLEDIT,KLBEDT,KLEDT1,KLEDT2,KNSCID,KEXTOF,KLSDAT,   &
     &              KLRDED,KLAVOI,KLFEDT,KLANTC,NXCL04
      COMMON/CNIARC/NSATA,NSATG,NSETA,NEQNG,NMORDR,NMORDV,NSORDR,       &
     &              NSORDV,NSUMX,NXDDOT,NSUMPX,NPXDDT,NXBACK,NXI,       &
     &              NXILIM,NPXPF,NINTIM,NSATOB,NXBCKP,NXTIMB,           &
     &              NOBSBK,NXTPMS,NXCNIA
      COMMON/CREFMT/REFMT(9)
      COMMON/CRESPR/LRESPA,LRESPG,LRESPD,LRESPP,LRESPT
      COMMON/CTIDES/NTIDE,NSTADJ,NET,NETADJ,NETUN,NOT,NOTADJ,           &
     &   NOTUN ,NETUNU,NETADU,NOTUNU,NOTADU,NBSTEP,KTIDA(3),            &
     &   ILLMAX,NUNPLY,NNMPLY,NDOODN,MXTMRT,NRESP ,NXCTID
      COMMON/DYNPOL/DPMEP ,DPMXP ,DPMYP ,DPMXDT,DPMYDT,DPMOPT,DPMXPC,   &
     &              DPMYPC,DPMKF ,DPMC21,DPMS21,DPMPD ,DPMUDK,DPMVDK,   &
     &              DPMOCP,DPMNLD,DPMERS,XDYNPL
      COMMON/EPHSET/EMFACT,DTENPD,DTINPD,FSC1EN,FSCENP(2),FSCINP(4),    &
     &   FSDINP(4),XEPHST
      COMMON/FANTOM/LFGLB,LFARC,LFTARC,LFTGLB,LENDGL,LPHNTM(4),LPHTIM(4)&
     &             ,LXTRAF,LSATFA(4,3),NXFANT
      COMMON/GEODEG/NMAX,NMAXP1,NP,NTOLD,NTOLO,NADJC,NADJS,NADJCS,      &
     &              NPMAX,NXGDEG
      COMMON/IBODPT/IBDCF(999),IBDSF(999),IBDGM(999),IBDAE(999),    &
     &              IBDPF(999),                                     &
     &              ICBDCF,ICBDSF,ICBDGM,ICBDAE,ICBDPF,             &
     &              ITBDCF,ITBDSF,ITBDGM,ITBDAE,ITBDPF,NXBDPT
      COMMON/ITHRMP/ITHPAR
      COMMON/IEPHM2/ISUPL,ICBODY,ISEQB(2),MAXDEG,ITOTSE,IREPL(988), &
     &              NXEPH2
      COMMON/LEPHM2/LXEPHM
      COMMON/LCBODY/LEARTH,LMOON,LMARS
      COMMON/LDATOR/LDQAT,LDVCT
      COMMON/LICASE/LINT(2),LCASE(18),NXLCAS
      COMMON/NFORCE/NHRATE,NSURF,MPXHDT,MXHRG,MXFMG,NFSCAC,NXFORC
      COMMON/NPCOM /NPNAME,NPVAL(92),NPVAL0(92),IPVAL(92),IPVAL0(92),   &
     &              MPVAL(28),MPVAL0(28),NXNPCM
      COMMON/NPCOMX/IXARC ,IXSATP,IXDRAG,IXSLRD,IXACCL,IXGPCA,IXGPSA,   &
     &              IXAREA,IXSPRF,IXDFRF,IXEMIS,IXTMPA,IXTMPC,IXTIMD,   &
     &              IXTIMF,IXTHTX,IXTHDR,IXOFFS,IXBISA,IXFAGM,IXFAFM,   &
     &              IXATUD,IXRSEP,IXACCB,IXDXYZ,IXGPSBW,IXCAME,IXBURN,  &
     &              IXGLBL,IXGPC ,IXGPS, IXTGPC,IXTGPS,IXGPCT,IXGPST,   &
     &              IXTIDE,IXETDE,IXOTDE,IXOTPC,IXOTPS,IXLOCG,IXKF  ,   &
     &              IXGM  ,IXSMA ,IXFLTP,IXFLTE,IXPLTP,IXPLTV,IXPMGM,   &
     &              IXPMJ2,IXVLIT,IXEPHC,IXEPHT,IXH2LV,IXL2LV,IXOLOD,   &
     &              IXPOLX,IXPOLY,IXUT1 ,IXPXDT,IXPYDT,IXUTDT,IXVLBI,   &
     &              IXVLBV,IXXTRO,IXBISG,IXSSTF,IXFGGM,IXFGFM,IXLNTM,   &
     &              IXLNTA,IX2CCO,IX2SCO,IX2GM ,IX2BDA,IXRELP,IXJ2SN,   &
     &              IXGMSN,IXPLNF,IXPSRF,IXANTD,IXTARG,                 &
     &              IXSTAP,IXSSTC,IXSSTS,IXSTAV,IXSTL2,                 &
     &              IXSTH2,IXDPSI,IXEPST,IXCOFF,IXTOTL,NXNPCX
      COMMON/REFDRV/DREFDA(9),DREFDB(9),DR3TDW(9),RDATR(9),RDBTR(9),    &
     &              DDA(9,2,50),DDB(9,2,50),DDR(9,50)
      COMMON/SNAPXL/LXRSET
      COMMON/LFVLBI/L1STV
      COMMON/ SPLINC/ INDSP,INDTSP,INDTNO,INDTEA
      COMMON/SAV_VLB/VARC(10000),VGLB(10000),EST_VEC(10000)
      COMMON/TPGRAV/NTPGCU,NTPGCA,NTPGSU,NTPGSA,ITPGRV,NTIMEC,NTIMES,   &
     &              NXTPGR
!
      DIMENSION AA(1),II(1),LL(1),FSECR(1),EF(1),ZF(1),TF(1)
      DIMENSION DPSI(1),EPST(1),EPSM(1),JSP(9),JSA(MXFMG),JSH(MXHRG)
      DIMENSION DUM(1),DUMN(3),DUM2(3,2,1)
      DIMENSION JPTFSB(MXHRG,MSETA),JPTFBS(MXFMG,MSETA)
      DIMENSION IPTFSB(100),IPTFBS(100)
      DIMENSION PARMV(1),IGPCA(2,1),IGPSA(2,1)
      DATA VSMALL/-99.D0/
      DIMENSION LHRFON(MXFMG,MSETA)
      DIMENSION JSALST(MSETA)
      DATA ZERO/0.0D0/,ONE/1.0D0/
!
!**********************************************************************
! START OF EXECUTABLE CODE
!**********************************************************************
!
      LXRSET=.FALSE.
      L1STV=.TRUE.
      INDSP=1
      INDTSP=1
      INDTNO=1
      INDTEA=1
      IF(LITER1) THEN
      DO I=1,1000
      VARC(I)=0.D0
      VGLB(I)=0.D0
      EST_VEC(I)=0.D0
      ENDDO
      ENDIF
      LDQAT=.FALSE.
      LDVCT=.FALSE.
      CALL CLEARL(LL(KLAVOI),MAPARM)
      CALL CLEARL(LL(KLANTC),MOBSBK)
      CALL CLEARI(JSH,16)
      KATUD=0
      KATBL=-1
      KATAD=0
      LTOP=.FALSE.
      DO 11 I=2,18
      IF(LINT(1).AND.LCASE(I)) THEN
      LTOP=.TRUE.
      ENDIF
   11 END DO
      NARC=NARC+1
      LSTARC=NARC.GE.MARC
      NINNER=0
      LSTINR=.FALSE.
!
! LOAD ARC COMMON BLOCKS AND DYNAMIC ARRAYS FROM EXTENDED
! VIRTUAL MEMORY TO DYNAMIC MEMORY
!
      CALL ARCLOD(AA,II,LL,NARC,.TRUE.,.TRUE.,.TRUE.)
      CALL UPDLG(II(KMAPLG),AA(KPRMVC),AA(KPARLG),AA(KSINCO))
      LRESPA=(NPVAL0(IXGPCA).GT.0.OR.NPVAL0(IXGPSA).GT.0)
      IF(NGLOBL.GT.1) MAXINR=MAXLST
      IF(NGLOBL.GT.1) MININR=1
!
!     DO 21212 J=1,MSETA
!     DO 21212 I=1,MXFMG
!21212 CONTINUE
! COMPUTE STARTING EDIT LEVEL
!
      EDLEVL=EDITX*EDTRMS
!
! COMPUTE ARCWISE DEPENDENT POINTERS
!
! POINTERS FOR INTEGRATION BACK VALUE ACCELERATIONS AND SUMS
      KXDDOT=KSUMX+NSUMX
      KSUMPX=KXDDOT+NXDDOT
      KPXDDT=KSUMPX+NSUMPX
!
! COMPUTE DYNAMIC ARRAY POINTERS FOR ARC PARAMETERS
!
! DRAG,SOLAR RADIATION AND GENERAL ACCELERATION POINTERS MUST BE
! COMPUTED FROM THE START OF THE DRAG VALUES. THE POINTERS IN COMMON
! CORA01 ARE INCORRECT DUE TO THE MULTIPLE SET AND SAT OPTIONS. THE
! ORDER SHOWN BELOW IS REPEATED FOR EACH SET OF SATELLITES:
!  Cd (order 1,2,3)             - for all satellites in the set
!  Cd with times (highest order) -for all satellites in the set
!  Cr (order 1,2,3)             - for all satellites in the set
!  Cr with times (highest order) -for all satellites in the set
!  Ga (order 1,2,3)             - for all satellites in the set
!  Ga with times (highest order) -for all satellites in the set
      KCD=KXEPOC+NPVAL(IXSATP)
      KCR=0
      KGENAC=0
! ARC GEOPOTENTIAL C COEFFICIENTS
      KACN=KCD+NPVAL(IXDRAG)+NPVAL(IXSLRD)+NPVAL(IXACCL)
! ARC GEOPOTENTIAL S COEFFICIENTS
      KASN=KACN+NPVAL(IXGPCA)
! ATTITUDE PARAMETERS
      KATTUD=KASN+NPVAL(IXGPSA)
! NEXT PARAMETER TO BE ADDED
!     KNXTA =KATTUD+NPVAL(IXTHDR) ** NEXT FLOATING POINT ARRAY MEMBER
!
!
! INITIALIZE SOME OF THE TIMES IN COMMON/EPHSET/ SO THAT EPHEMERIS
! CALCULATIONS WILL BE RECALCULATED FOR THIS ARC
      FSCENP(1)=VSMALL
      FSCENP(2)=VSMALL
      FSCINP(1)=VSMALL
      FSCINP(4)=VSMALL
      FSDINP(1)=VSMALL
      FSDINP(4)=VSMALL
!
!  SETUP THE TRUE OF REFERENCE TO MEAN OF 50 MATRX or J2000
!  TIMES AT REF ARE:MJDSRF&FSECRF
!
!
      CALL MCRCON(FSC1EN)
      IF(MREFSY.NE.1) THEN
!
      FSECR(1)=FSECRF
!
      IF(ICBDGM.EQ.3) THEN
      CALL BUFEAR(MJDSRF,FSECRF,MJDSRF,FSECRF,1,IDUM1,DUM1,LDUM1,AA,II)
!
      CALL PRECSS(MJDSRF,FSECR,EF,ZF,TF,AA(KSRTCH),1)
      CALL NUVECT(MJDSRF,FSECR,DPSI,EPST,EPSM,1,AA(KSRTCH))
      CALL NPVECT(MJDSRF,FSECR,DPSI,EPST,EPSM,EF,TF,ZF,1,AA(KSRTCH),    &
     &            REFMT,DUM,1,.FALSE.,                                  &
     &            AA(KPDPSI),AA(KPEPST),AA(KNUTIN),AA(KNUTMD),.FALSE.,  &
     &            AA(KDXDNU),AA(KDPSIE),AA(KEPSTE),DUMN,DUM2)
      ELSE
      CALL BUFXTR(MJDSRF,FSECRF,MJDSRF,FSECRF,1,IDUM1,DUM1,LDUM1,AA)
!
      IF(LXEPHM) THEN
      DO IJ=1,ICBODY
      CALL BUFSUP(AA,MJDSRF,FSECRF,MJDSRF,FSECRF,II(KISUPE),            &
     &AA(KEPHMS),IJ,1)
      ENDDO
      ENDIF
!
! NEW SUBROUTINE FOR NUTATION CALCULATION ONLY FOR MARS
         IF(LMARS.AND.IMRNUT.EQ.1) THEN
      CALL PRMCSS(MJDSRF,FSECR,EF,ZF,TF,AA(KSRTCH),1)
      CALL NUVMCT(MJDSRF,FSECR,DPSI,EPST,EPSM,1,AA(KSRTCH))
      CALL NPVMCT(MJDSRF,FSECR,DPSI,EPST,EPSM,EF,TF,ZF,1,AA(KSRTCH),    &
     &            REFMT,DUM,1,.FALSE.)
      CALL MM2EJ2(MJDSRF,FSECR,REFMT,1,AA(KSRTCH),.FALSE.)
!
         ELSE
      CALL PRXCSS(MJDSRF,FSECR,EF,ZF,TF,AA(KSRTCH),1,AA(KDPSI),         &
     &            AA(KEPST),AA(KEPSM),AA,1)
      CALL NUVXCT(MJDSRF,FSECR,DPSI,EPST,EPSM,1,AA(KSRTCH))
      CALL NPVXCT(MJDSRF,FSECR,DPSI,EPST,EPSM,EF,TF,ZF,1,AA(KSRTCH),    &
     &            REFMT,DUM,1,.FALSE.)
      ENDIF
      ENDIF
!
      COSA=REFMT(4)
      SINA=-REFMT(1)
      COSB=REFMT(8)
      SINB=REFMT(9)
!
!   TRANSPOSE MATRIX
!
      REFMT4=REFMT(2)
      REFMT(2)=REFMT(4)
      REFMT(4)=REFMT4
      REFMT7=REFMT(3)
      REFMT(3)=REFMT(7)
      REFMT(7)=REFMT7
      REFMT8=REFMT(6)
      REFMT(6)=REFMT(8)
      REFMT(8)=REFMT8
!
! else for mrefsy check
!
      ELSE
!
! IF MREFSY IS 1 THEN SET UP FOR J2000 REFERENCE SYSTEM BY SETTING
! REFMT EQUAL TO THE IDENTITY MATRIX, THIS SHOULD ONLY BE DONE IF
! USING THE DE200 EPHEMERIS
      REFMT(1)=ONE
      REFMT(2)=ZERO
      REFMT(3)=ZERO
      REFMT(4)=ZERO
      REFMT(5)=ONE
      REFMT(6)=ZERO
      REFMT(7)=ZERO
      REFMT(8)=ZERO
      REFMT(9)=ONE
!
!
!
      COSA=REFMT(4)
      SINA=-REFMT(1)
      COSB=REFMT(8)
      SINB=REFMT(9)
!
! endif for mrefsy check
!
      ENDIF
!
      IF(NPVAL0(IXXTRO).GT.0) THEN
            DREFDA(1)=-COSA
            DREFDA(2)=-SINA
            DREFDA(3)=ZERO
            DREFDA(4)=SINA*SINB
            DREFDA(5)=-COSA*SINB
            DREFDA(6)=ZERO
            DREFDA(7)=-SINA*COSB
            DREFDA(8)=COSA*COSB
            DREFDA(9)=ZERO
!
            DREFDB(1)=ZERO
            DREFDB(2)=ZERO
            DREFDB(3)=ZERO
            DREFDB(4)=-COSA*COSB
            DREFDB(5)=-SINA*COSB
            DREFDB(6)=-SINB
            DREFDB(7)=-COSA*SINB
            DREFDB(8)=-SINA*SINB
            DREFDB(9)=COSB
!
         RDATR(1)=DREFDA(1)*REFMT(1)+DREFDA(2)*REFMT(2)                 &
     &           +DREFDA(3)*REFMT(3)
         RDATR(2)=DREFDA(4)*REFMT(1)+DREFDA(5)*REFMT(2)                 &
     &           +DREFDA(6)*REFMT(3)
         RDATR(3)=DREFDA(7)*REFMT(1)+DREFDA(8)*REFMT(2)                 &
     &           +DREFDA(9)*REFMT(3)
         RDATR(4)=DREFDA(1)*REFMT(4)+DREFDA(2)*REFMT(5)                 &
     &           +DREFDA(3)*REFMT(6)
         RDATR(5)=DREFDA(4)*REFMT(4)+DREFDA(5)*REFMT(5)                 &
     &           +DREFDA(6)*REFMT(6)
         RDATR(6)=DREFDA(7)*REFMT(4)+DREFDA(8)*REFMT(5)                 &
     &           +DREFDA(9)*REFMT(6)
         RDATR(7)=DREFDA(1)*REFMT(7)+DREFDA(2)*REFMT(8)                 &
     &           +DREFDA(3)*REFMT(9)
         RDATR(8)=DREFDA(4)*REFMT(7)+DREFDA(5)*REFMT(8)                 &
     &           +DREFDA(6)*REFMT(9)
         RDATR(9)=DREFDA(7)*REFMT(7)+DREFDA(8)*REFMT(8)                 &
     &           +DREFDA(9)*REFMT(9)
         RDBTR(1)=DREFDB(1)*REFMT(1)+DREFDB(2)*REFMT(2)                 &
     &           +DREFDB(3)*REFMT(3)
         RDBTR(2)=DREFDB(4)*REFMT(1)+DREFDB(5)*REFMT(2)                 &
     &           +DREFDB(6)*REFMT(3)
         RDBTR(3)=DREFDB(7)*REFMT(1)+DREFDB(8)*REFMT(2)                 &
     &           +DREFDB(9)*REFMT(3)
         RDBTR(4)=DREFDB(1)*REFMT(4)+DREFDB(2)*REFMT(5)                 &
     &           +DREFDB(3)*REFMT(6)
         RDBTR(5)=DREFDB(4)*REFMT(4)+DREFDB(5)*REFMT(5)                 &
     &           +DREFDB(6)*REFMT(6)
         RDBTR(6)=DREFDB(7)*REFMT(4)+DREFDB(8)*REFMT(5)                 &
     &           +DREFDB(9)*REFMT(6)
         RDBTR(7)=DREFDB(1)*REFMT(7)+DREFDB(2)*REFMT(8)                 &
     &           +DREFDB(3)*REFMT(9)
         RDBTR(8)=DREFDB(4)*REFMT(7)+DREFDB(5)*REFMT(8)                 &
     &           +DREFDB(6)*REFMT(9)
         RDBTR(9)=DREFDB(7)*REFMT(7)+DREFDB(8)*REFMT(8)                 &
     &           +DREFDB(9)*REFMT(9)
      ENDIF
      CALL GETSNM
!  START SATELLITE FORCE MAINTANENCE
!  LOOP THROUGH ALL SATELLITES IN ALL SETS;FILL MULTIPLIER TO
!  SOLAR RADIATION EXPLICIT PARTIAL.
      KPSAT=KAPLM
      DO 100 I=1,NSETA
      LNSOL=II(KIORFR+3*(I-1)+1).LE.0
      IF(LNSOL) GO TO 100
      NSATS=II(KNSAT-1+I)
      DO 50 J=1,NSATS
!
! PLACE THE SOLAR RADIATION PRESSURE AT 1 AU INTO APLM
! THEN SCALE IT UP BY AU**2
! (THE SOLAR  RADIATION  ACCELLERATION  WILL BE DIVIDED  BY THE
! DISTANCE OF THE SATELLITE TO THE SUN SQUARED IN SUBROUTINE SOLRD)
!
      IF(AA(KPSAT).LT.AU) AA(KPSAT)=AA(KPSAT)*RPRESS*AU**2
      KPSAT=KPSAT+1
   50 END DO
  100 END DO
!
!  LOOP THROUGH ALL SETS;GET POINTERS TO SATELITE DEPENDENT PARAMETERS
!   KB0DRG - points to array containing     .5*area/mass
!   KBDRAG - points to array containing  Cd*.5*area/mass
!   KSTDRG - points to array containing time for drag intervals
!   KAPLM  - points to array containing     area/mass*rpress*au**2
!   KAPGM  - points to array containing  Cr*area/mass*rpress*au**2
!   KSTSRD - points to array containing time for sol. rad intervals
!   KGENAC - points to array containing general acceleration values
!   KSTACC - points to array containing time for gen. acc. intervals
!   KITACC - points to array containing type of gen. acceleration
      NSATS=II(KNSAT)
      JSP(1)=KB0DRG
      JSP(2)=KBDRAG
      JSP(3)=KSTDRG
      JSP(4)=KAPLM
      JSP(5)=KAPGM
      JSP(6)=KSTSRD
!     JSP(7)=KGENAC
      JSP(7)=KCD+(II(KIORFR)+II(KIPDFR)+II(KIORFR+1)+II(KIPDFR+1))*NSATS
      JSP(8)=KSTACC
      JSP(9)=KITACC
      DO 200 I=1,NSETA
      NSATS=II(KNSAT-1+I)
      DO 130 J=1,9
      II(KJSPFR+(I-1)*9+J-1)=JSP(J)
  130 END DO
!   DRAG POINTERS
      IF(II(KIORFR+3*(I-1)).LE.0) GO TO 140
      JSP(1)=JSP(1)+NSATS
      JSP(2)=JSP(2)+NSATS*(II(KIORFR+3*(I-1))+II(KIPDFR+3*(I-1)))
      JSP(3)=JSP(3)+NSATS*II(KIPDFR+3*(I-1))
!   SOLRD POINTERS
  140 IF(II(KIORFR+3*(I-1)+1).LE.0) GO TO 150
      JSP(4)=JSP(4)+NSATS
      JSP(5)=JSP(5)+NSATS*(II(KIORFR+3*(I-1)+1)+II(KIPDFR+3*(I-1)+1))
      JSP(6)=JSP(6)+NSATS*II(KIPDFR+3*(I-1)+1)
!   GENERAL ACC POINTERS
  150 IF(II(KIORFR+3*(I-1)+2).LE.0) GO TO 200
      IF(I.LT.NSETA)                                                    &
     & JSP(7)=JSP(7)+NSATS*(II(KIORFR+3*(I-1)+2)+II(KIPDFR+3*(I-1)+2))  &
     &        +II(KNSAT+I)*(II(KIORFR+3*(I  )  )+II(KIPDFR+3*(I  )  ))  &
     &        +II(KNSAT+I)*(II(KIORFR+3*(I  )+1)+II(KIPDFR+3*(I  )+1))
      JSP(8)=JSP(8)+NSATS*II(KIPDFR+3*(I-1)+2)
      JSP(9)=JSP(9)+NSATS
  200 END DO
!
!  LOOP THROUGH ALL SETS;GET POINTERS TO SATELITE DEPENDENT PARTIALS
!  IF A NEW POINTER GROUP IS ADDED TO KJSAFR ARRAY THEN YOU MUST REMEMBE
!  TO MODIFY ALL CALCULATIONS BASED ON THE NUMBER OF POINTER GROUPS IN
!  COWLIN, ORBIT, SUMCMP, VMATHD (SEARCH FOR KJSAFR)
!
!  LOOP THROUGH ALL SETS;GET POINTERS TO SATELITE DEPENDENT PARTIALS
      JLAJDP=KLAJDP-1
      JLAJSP=KLAJSP-1
      JLAJGP=KLAJGP-1
!
      NDELM=0
      DO 300 I=1,NSETA
      NSATS=II(KNSAT-1+I)

! DRAG STARTS AFTER ALL SATELLITES IN THE SET
      JSA(1) = NSATS*6 + 1
      JSA(2) = JSA(1)

      LRD = .FALSE.
      LTD = .FALSE.
      JC = 0

! DRAG OFFSET; SOLRD PARTIAL POINTER
      DO J = 1, 3 ! 210
          IF (LL(KLAFRC+12*(I-1)+J-1)) THEN
              JSA(2) = JSA(2) + 1
          END IF
      END DO
!     IF(LL(KLAFRC+12*(I-1)+3)) JSA(2)=JSA(2)+II(KIPDFR+3*(I-1))
      IPDLP = II(KIPDFR+3*(I-1))
      IF (LL(KLAFRC+12*(I-1)+3)) THEN
          DO J = 1, IPDLP ! 212
              IF (LL(JLAJDP+J)) THEN
                  JSA(2) = JSA(2) + 1
              END IF
          END DO
      END IF
      JLAJDP = JLAJDP + NSATS*IPDLP
      JSA(3) = JSA(2)

! SOLRD OFFSET; GENERAL ACCEL PARTIAL POINTER
      DO J = 1, 3 ! 220
          IF (LL(KLAFRC+12*(I-1)+J+3)) THEN
              JSA(3) = JSA(3) + 1
          END IF
      END DO
!     IF(LL(KLAFRC+12*(I-1)+7)) JSA(3)=JSA(3)+II(KIPDFR+3*(I-1)+1)
      IPDLP = II(KIPDFR+3*(I-1)+1)
      IF (LL(KLAFRC+12*(I-1)+7)) THEN
          DO J = 1, IPDLP ! 222
              IF (LL(JLAJSP+J)) THEN
                  JSA(3) = JSA(3) + 1
              END IF
          END DO
      END IF
      JLAJSP = JLAJSP + NSATS*IPDLP
      JSA(4) = JSA(3)

! GENERAL ACCEL OFFSET; BOX WING PLATE AREA POINTER
      DO J = 1, 3 ! 230
          IF (LL(KLAFRC+12*(I-1)+J+7)) THEN
              JSA(4) = JSA(4) + 1
          END IF
      END DO
!     IF(LL(KLAFRC+12*(I-1)+11)) JSA(4)=JSA(4)+II(KIPDFR+3*(I-1)+2)
      IPDLP = II(KIPDFR+3*(I-1)+2)
      IF (LL(KLAFRC+12*(I-1)+11)) THEN
         DO J = 1, IPDLP ! 232
             IF (LL(JLAJGP+J)) THEN
                 JSA(4) = JSA(4) + 1
             END IF
         END DO
      END IF
      JLAJGP = JLAJGP + NSATS*IPDLP
      JSA(5) = JSA(4)

! BOX-WING PARAMETER POINTER CONTROL
!*************************************************************
!  THIS CODE ASSUMES ONLY ONE SATELLITE PER SET!!!!!!!
!*************************************************************
! PLATE AREA OFFSET; PLATE SPECULAR RELATIVITY POINTER
      JH1 = JSA(5)
      JSA(5) = JSA(5) + II(KNADAR+I-1)
      JSA(6) = JSA(5)
! PLATE SPECULAR REFLECTIVITY OFFSET; PLATE DIFFUSE REFLECTIVITY POINTER
      JSA(6) = JSA(6) + II(KNADSP+I-1)
      JSA(7) = JSA(6)
! PLATE DIFFUSE REFLECTIVITY OFFSET; PLATE EMISSIVITY POINTER
      JSA(7) = JSA(7) + II(KNADDF+I-1)
      JSA(8) = JSA(7)
! PLATE EMISSIVITY OFFSET; PLATE TEMPERATURE A POINTER
      JSA(8) = JSA(8) + II(KNADEM+I-1)
      JSA(9) = JSA(8)
! PLATE TEMPERATURE A OFFSET; PLATE TEMPERATURE C POINTER
      JSA(9) = JSA(9) + II(KNADTA+I-1)
      JSA(10) = JSA(9)
! PLATE TEMPERATURE C OFFSET; PLATE TIME D POINTER
      JSA(10) = JSA(10) + II(KNADTC+I-1)
      JSA(11) = JSA(10)
! PLATE TIME D OFFSET; PLATE TIME F POINTER
      JSA(11) = JSA(11) + II(KNADTD+I-1)
      JSA(12) = JSA(11)
! PLATE TIME F OFFSET; PLATE THETAX POINTER
      JSA(12) = JSA(12) + II(KNADTF+I-1)
      ITHPAR = JSA(12)

! PLATE THETAX OFFSET; LAGEOS THERMAL DRAG SPIN AXIS POINTER
      ITHPAR = ITHPAR + II(KNADTX+I-1)
      JSA(13) = ITHPAR
      JSA(14) = JSA(13)

      JH2 = JSA(13)
      JHDIF = JH2 - JH1

! LAGEOS SPIN AXIS OFFSET. (DOES NOT WORK WHEN SPIN AXIS IS ADJUSTED
! IN A MULTI SAT RUN);
! FANTOM ARC FORCE PARAMETERS POINTER
      JSA(14) = JSA(14) + NPVAL0(IXTHDR)
      JSA(15) = JSA(14)

! FANTOM ARC FORCE OFFSET ; ACCELEROMETER BIAS POINTER
! FORCE MODEL ONLY IF DYNSEL PRESENT
      JSA(15) = JSA(15) + NSATFA(2,I)
      JSA(16) = JSA(15)

! ACCELEROMETER BIAS OFFSET; ARC FORCE ATTITUDE POINTER
! FORCE MODEL ONLY IF DYNSEL PRESENT
!     IF(LDYNAC) THEN
      IF (IDYNSC(I) == II(KISATN-1+I)) THEN
!         JSA(16) = JSA(16) + NPVAL0(IXACCB)
          JSA(16) = JSA(16) + 60
      ELSE
          JSA(16) = JSA(16)
      ENDIF
      JSA(17) = JSA(16)

! ARC FORCE ATTITUDE OFFSET; DELTA STATE POINTER
      IF (LFRCAT) THEN
          JSA(17) = JSA(17) + NPVAL0(IXATUD)
      ELSE
          JSA(17) = JSA(17)
      ENDIF
      JSA(18) = JSA(17)

! DELTA STATE OFFSET; TUM SOLAR RADIATION POINTER
      NDELTS = II(KXSTAT-1+I)
      NDELA = 0
      IQ1 = KPTRUA + IPVAL(IXDXYZ) + NDELM - 1
      IQ2 = IQ1 + NDELTS - 1
      IF (IQ2 >= IQ1) THEN
          DO IQP = IQ1, IQ2
              IF (II(IQP) > 0) THEN
                  NDELA=NDELA+6
              END IF
          ENDDO
      ENDIF
      NDELM = NDELM + NDELTS

      JSA(18) = JSA(18) + NDELA
      JSA(39) = JSA(18)

! TUM SOLAR RADIATION OFFSET; FINITE BURN MODEL POINTER
      JSA(39) = JSA(39) + NPVAL0(IXGPSBW)

      ! ... FIGURE OUT THE NUMBER OF BURN PARAMETERS FOR THIS SATELLITE
      NUM_PARAM_PER_BURN = 25
      NUM_BURNS = NPVAL0(IXBURN) / NUM_PARAM_PER_BURN
      NUM_BURN_PARAMS = 0
      DO J = 1, NUM_BURNS
          ! CHECK THAT THE SATELLITE ID MATCHES
          IF (II(KBRAX1+J-1) == II(KISATN+I-1)) THEN
              NUM_BURN_PARAMS = NUM_BURN_PARAMS + NUM_PARAM_PER_BURN
          END IF
      END DO
      JSA(19) = JSA(39)

! FINITE BURN OFFSET; C&S  GLOBAL GEOPOTENTIAL POINTER
      JSA(19) = JSA(19) + NUM_BURN_PARAMS
      JSA(20) = JSA(19)

! POINTER TO C20 IN PXDDOT ARRAY (IN CASE C20 ADJUSTED IN
! PRESENCE OF DYNAMIC POLAR MOTION).  NO OFFSET FOR THIS BECAUSE IT JUST
! POINTS TO C20 INSIDE OF THE ALREADY-ALLOCATED C&S COEFFICIENT ARRAY.
      JSA(26) = JSA(19)
      IPC = IPVAL(IXGPC)
! C10 OFFSET
      IF (II(KPTRUA-1+IPC) > 0) THEN
          JSA(26) = JSA(26) + 1
      END IF
! C11 OFFSET
      IF (II(KPTRUA-1+IPC+1) > 0) THEN
          JSA(26) = JSA(26) + 1
      END IF

! C&S + TIME DEP C&S COEFFICIENT OFFSET; DYNAMIC TIDE POINTER
      JSA(20) = JSA(20) + II(KNEQN+2*MSETA+I-1) + II(KNEQN+3*MSETA+I-1) &
     &                  + II(KNEQN+4*MSETA+I-1) + II(KNEQN+5*MSETA+I-1) &
     &                  + NPVAL0(IXTGPC) + NPVAL0(IXTGPS)               &
     &                  + NPVAL0(IXGPCT) + NPVAL0(IXGPST)
      JSA(21) = JSA(20)

! DYNAMIC TIDE OFFSET; LOCAL GRAVITY ANOMALIES POINTER
      JSA(21) = JSA(21) + NSTADJ + 2*(NETADJ+NOTADJ)
      JSA(22) = JSA(21)

! LOCAL GRAVITY ANOMALIES OFFSET; DYNAMIC POLAR MOTION SCALE FACTOR
! POINTER
      JSA(22) = JSA(22) + NPVAL0(IXLOCG)
      JSA(23) = JSA(22)

! DYNAMIC POLAR MOTION SCALE FACTOR OFFSET; GM POINTER
      JSA(23) = JSA(23) + NPVAL0(IXKF)
      JSA(24) = JSA(23)

! GM OFFSET; PLANETARY MOON GM POINTER
      JSA(24) = JSA(24) + NPVAL0(IXGM)
      JSA(25) = JSA(24)

! PLANETARY MOON GM OFFSET; DYNAMIC POLAR MOTION XP & YP POINTER
      JSA(25) = JSA(25) + NPVAL0(IXPMGM)

! JSA(26) IS COMPUTED ABOVE, AFTER JSA(19)

! DYNAMIC POLAR MOTION XP,YP OFFSET; PLANETARY ORIENTATION POINTER
! DOES NOT FOLLOW C20 (JSA(26))
      JSA(38) = JSA(25) + 3*NPVAL0(IXPOLX)
!
! GLOBAL FANTOM FORCE (OFFSET) FOLLOWS PLANETARY ORIENTATION
      JSA(27) = JSA(38) + NPVAL0(IXXTRO)

! LENSE THIRRING MU POINTER: FANTOM GLOBAL FORCE MODEL OFFSET;
      JSA(28) = JSA(27) + NPVAL0(IXFGFM)

! LENSE THIRRING ALPHA POINTER; LENSE THIRRING MU OFFSET;
      JSA(29) = JSA(28) + NPVAL0(IXLNTM)

!SECOND ASTEROID C COEF POINTER; LENSE THIRRING ALPHA OFFSET
      JSA(30) = JSA(29) + NPVAL0(IXLNTA)
!SECOND ASTEROID C COEF POINTER; SECOND ASTEROID C COEF OFFSET
      JSA(31)=JSA(30)+NPVAL0(IX2CCO)
!SECOND AST GM POINTER ; SECOND ASTEROID S COEF OFFSET
      JSA(32)=JSA(31)+NPVAL0(IX2SCO)
!SECOND AST AE POINTER ;  SECOND ASTEROID GM OFFSET
      JSA(33)=JSA(32)+NPVAL0(IX2GM)
!RELATIVITY COEF POINTER; SECOND ASTEROID AE OFFSET
      JSA(34)=JSA(33)+NPVAL0(IX2BDA)
!J2 POINTER SUN; RELATIVITY COEF OFFSET
      JSA(35)=JSA(34)+NPVAL0(IXRELP)
!GM POINTER SUN; SUN J2 OFFSET
      JSA(36)=JSA(35)+NPVAL0(IXJ2SN)
!PLANETARY FORCE MODEL POINTER; SUN GM OFFSET
      JSA(37)=JSA(36)+NPVAL0(IXGMSN)
! JSA(38) (PLAN OR)  IS COMPUTED ABOVE, AFTER JSA(25)
! JSA(39) (F BURN) IS COMPUTED ABOVE, AFTER JSA(18)
! NEXT DISPLACEMENT WOULD BE (40) (MXFMG CURRENTLY 39)
! PLANETARY FORCE MODEL PARAMETERS
!!!!! JSA(40)=JSA(37)+NPVAL0(IXPLNF)
! JSALST IS NOT USED ANY MORE; IT WAS THE HIGHEST
! VALUE IN JSA (NOT NECCESSARILY JSA(MXFMG)
      JSALST(I) = JSA(37)
! LOAD THIS SET INTO ARRAY
      DO 240 J=1,MXFMG
      II(KJSAFR+(I-1)*MXFMG+J-1)=JSA(J)
  240 END DO

  300 END DO
!
! LOAD GEOPOTENTIAL FORCE MODEL ARRAY & DENORMALIZE ENTIRE MODEL
!    PARMV IS NORMALIZED - AA(KCN & KSN) ARE DENORMALIZED
!
      ICS=0
      ND=0
      NO=0
      IBEG=IPVAL(IXGPC)
      IEND=IBEG+NPVAL(IXGPC)+NPVAL(IXGPS)-1
      JCNT=0
      DO 400 J=IBEG,IEND
      AA(KCN+JCNT)=PARMV(J)
      AA(KCNAUX+JCNT)=PARMV(J)
      JCNT=JCNT+1
!     CALL INDXNM(JCNT,ICS,ND,NO)
  400 END DO
      IBEG=IPVAL(IXTGPC)
      IEND=IBEG+NPVAL(IXTGPC)+NPVAL(IXTGPS)-1
      DO 401 J=IBEG,IEND
      AACOEF=PARMV(J)
  401 END DO
! DENORMALIZE COMPLETE GEOPOTENTIAL MODEL
!     CALL DNORMA(NMAX,NMAX,AA(KCN),AA(KSN))
!***** BEGIN DEBUG *****
!     PRINT 99830,NMAX,IBEG,IEND,PARMV(IBEG),AA(KCN)
!99830 FORMAT(1X'INITA-NMAX,IBEG,IEND,PARMV(IBEG),AA(KCN)',3I8,2D15.8)
!***** END DEBUG *****
!
! COMPUTE DENORMALIZATION FACTORS FOR ADJUSTED ARC C,S COEFFICIENTS
!
      IF(NPVAL(IXGPCA).LE.0) GO TO 500
      NGP=NPVAL(IXGPCA)
      INDXGP=KGPNRA-1
      DO 450 I=1,NGP
      N=IGPCA(1,I)
      M=IGPCA(2,I)
      AA(INDXGP+I)=DENORM(N,M)
  450 END DO
  500 IF(NPVAL(IXGPSA).LE.0) GO TO 600
      NGP=NPVAL(IXGPSA)
      INDXGP=KGPNRA+NPVAL(IXGPCA)-1
      DO 550 I=1,NGP
      N=IGPSA(1,I)
      M=IGPSA(2,I)
      AA(INDXGP+I)=DENORM(N,M)
  550 END DO
  600 CONTINUE


!-------------------------------------------------------------------------------

!write(6,*)'INITA:  IXFAGM, IPVAL(IXFAGM) ',  IXFAGM, IPVAL(IXFAGM)

!write(6,*)'INITA:  (j, NPVAL0( IPVAL(IXFAGM) -1 + j ),j=1,20 ) ', &

!write(6,*)'INITA: NPVAL(IXFAGM)  ', NPVAL(IXFAGM)
!write(6,*)'INITA: NPVAL0(IXFAGM) ', NPVAL0(IXFAGM)


!write(6,*)'INITA:  (j, aa( kprmv  + IPVAL(IXFAGM) -1 + j ),j=0,NFGARC-1 ) '
!do  j=0, NFGARC-1
!    write(6,'(I3,1x,E20.10)') j, aa( kprmv  + IPVAL(IXFAGM) -1 + j )
!enddo

!write(6,*)'INITA:  (j, aa( kprmv0  + IPVAL0(IXFAGM) -1 + j ),j=0,NAGA-1 ) '
!do  j=0, NAGA -1
!    write(6,'(I3,1x,E20.10)') j, aa( kprmv0  + IPVAL0(IXFAGM) -1 + j )
!enddo


!write(6,*)'INITA:  (j, aa( KPRSG0  + IPVAL0(IXFAGM) -1 + j ),j=0,NAGA-1 ) '
!do  j=0, NAGA -1
!    write(6,'(I3,1x,E20.10)') j, aa( KPRSG0  + IPVAL0(IXFAGM) -1 + j )
!enddo

!-------------------------------------------------------------------------------








      RETURN
      END
