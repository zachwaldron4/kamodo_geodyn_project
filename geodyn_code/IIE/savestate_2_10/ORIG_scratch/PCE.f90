


!$PCE
      SUBROUTINE PCE   (AA    ,II    ,LL    ,XSM   ,VSM   ,             &
     &    OBS   ,OBSC  ,RESID ,INDSAT,INDSET,INPSAT,LELEVS,             &
     &     NEQN  ,N3    ,IPTFMG,ILNFMG,NFMG  , XTD, VTD,UTDT)
!********1*********2*********3*********4*********5*********6*********7**
! PCE              89/05/23            0000.0    PGMR - ???, SBL
!
! FUNCTION:  CONTROLS PCE MEASUREMENT PROCESSING
!
!  I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   AA      I/O   A    DYNAMIC ARRAY FOR REAL DATA. ACCESSED BY
!                      POINTERS FROM COMMON BLOCKS CORA01-CORA07
!   II      I/O   A    DYNAMIC ARRAY FOR INTEGER DATA. ACCESSED BY
!                      POINTERS FROM COMMON BLOCKS CORI01-CORI07
!   LL      I/O   A    DYNAMIC ARRAY FOR LOGICAL DATA. ACCESSED BY
!                      POINTERS FROM COMMON BLOCKS CORL01-CORL07
!   XSM      O    A    TRUE OF REFERENCE POSTITION CARTESIAN COORDINATES
!   VSM      O    A    TRUE OF REFERENCE VELOSITY CARTESIAN COORDINATES
!   OBS     I/O   A    OBSERVATION - MEASUREMENTS
!   OBSC     O    A    COMPUTED MEASUREMENTS
!   RESID    O    A    RESIDUALS FOR THE PARTICULAR MEASUREMENT BLOCK
!   INDSAT  I/O   A    FOR A GIVEN INTERNAL SAT NO (1,2,3) INDSAT
!                      GIVES THE ACTUAL LOCATION IN THE SATELLITE
!                      RELATED ARRAYS FOR THIS SATELLITE.
!                      (EG.   SAT ID=ISATNO(INDSAT(1,2,OR 3))
!   INDSET  I/O   A    FOR A GIVEN INTERNAL SATELLITE NUMBER INDSET TELL
!                      WHICH SAT SET THAT THE GIVEN SAT BELONGS TO.
!   INPSAT  I/O   A    POINTER ARRAY THAT RELATES THE INTERNAL SATELLITE
!                      NUMBER (1,2,3) TO THE SATELLITES DEFINED IN THE
!                      DATA HEADER RECORDS (N=1,2,3). (EG.
!                      ISATP=INPSAT(1) WOULD TELL WHICH OF THE THREE
!                      POSSIBLE SATELLITES DEFINED IN THE DATA HEADER
!                      RECORDS PERTAINED TO INTERNAL SATELLITE NO. 1)
!   LELEVS  I/O   A    INDICATES WHICH ELEVATION ANGLES NEED TO BE
!                      COMPUTED FOR THE THREE POSSIBLE STATION
!                      SATELLITE CONFIGURATIONS DEFINED IN THE BLOCK
!                      HEADER RECORDS
!   NEQN    I/O   S    NUMBER OF FORCE MODEL PARAMETERS
!   N3      I/O   S    NUMBER OF SATS TIMES 3
!   IPTFMG   I    A    STARTING INDICES OF DESTINATIONS FOR SUBSETS OF
!                      CHAINED PARTIALS
!   ILNFMG   I    A    LENGTH OF SUBSETS
!   NFMG    I/O   A    ARRAY CONTAINING NUMBER OF PARTIAL DERIVITIVE
!                      SUBSETS
!   XTD     I/O   A    SPACE TO STORE TRUE-OF-DATE-CARTESIAN
!                      POSTITION
!   VTD     I/O   A    SPACE TO STORE TRUE-OF-DATE-CARTESIAN
!                      VELOSITY
!
!
!
! COMMENTS:  THIS MEASUREMENT MODEL WORKS FOR TRUE OF REFERENCE, TRUE OF
!            DATE, AND RADIAL PCE DATA.
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      COMMON/CBDSTA/BDSTAT(7,999),XBDSTA
      COMMON/CBLOKA/FSECBL,SIGNL ,VLITEC,SECEND,BLKDAT(6,4),DOPSCL(5,4)
      COMMON/CBLOKI/MJDSBL,MTYPE ,NM    ,JSTATS,NPSEG ,JSATNO(3),ITSYS ,&
     &       NHEADB,NELEVS,ISTAEL(12),INDELV(3,4),JSTANO(3),ITARNO,     &
     &       KTARNO
      COMMON/CBLOKL/LIGHT ,LNRATE,LNREFR,LPOLAD,LTDRIV,LNANT ,LNTRAK,   &
     &       LASER ,LGPART,LGEOID,LETIDE,LOTIDE,LNTIME,LAVGRR,LRANGE,   &
     &       LSSTMD,LSSTAJ,LNTDRS,LPSBL,LACC,LAPP,LTARG,LTIEOU,LEOTRM,  &
     &       LSURFM,LGEOI2,LSSTM2,LOTID2,LOTRM2,LETID2,LNUTAD
      COMMON/CESTIM/MPARM,MAPARM,MAXDIM,MAXFMG,ICLINK,IPROCS,NXCEST
      COMMON/CESTML/LNPNM ,NXCSTL
      COMMON/CGRAV/GM,AE,AESQ,FE,FFSQ32,FSQ32,XK2,XK3,XLAM,SIGXK2,      &
     &      SIGXK3,SIGLAM,RATIOM(2),AU,RPRESS
      COMMON/CITERL/LSTGLB,LSTARC,LSTINR,LNADJ ,LITER1,LSTITR,          &
     &              LOBORB,LRESID,LFREEZ,LSAVEF,LHALT,LADJPI,LADJCI
      COMMON/CLPRNR/LPR9NR(24),LPRNRM(24,3)
      COMMON/CNIGLO/MINTIM,MSATG3,MEQNG ,MEQNG3,MSATG ,MSATOB,MSATA ,   &
     &              MSATA3,MSETA ,MINTVL,MSORDR,MSORDV,NMXORD,          &
     &       MCIPV ,MXBACK,MXI   ,MPXPF ,MAXAB ,MSETDG,MXSATD,          &
     &       MXDEGS,MXDRP ,MXDRPA,MXSRP ,MXSRPA,MXGAP ,MSATDR,          &
     &       MSATSR,MSATGA,MXDRPD,MXSRPD,MXGAPD,MXBCKP,MXTPMS,          &
     &       NSTAIN,NXCNIG
      COMMON/COBLOC/KXMN  (3,4)  ,KENVN (3,4)  ,KSTINF(3,4)  ,          &
     &       KOBS  ,KDTIME,KSMCOR,KSMCR2,KTMCOR,KOBTIM,KOBSIG,KOBSG2,   &
     &       KIAUNO,KOBCOR(9,7)  ,KFSECS(6,8)  ,KOBSUM(8)    ,          &
     &       KEDSIG,KEDSG2
      COMMON/CONSTR/PI,TWOPI,DEGRAD,SECRAD,SECDAY
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
      COMMON/CORA05/KOBTYP,KDSCRP,KGMEAN,KGLRMS,KWGMEA,KWGRMS,KTYMEA,   &
     &       KTYRMS,KWTMTY,KWTYRM,KTMEAN,KTRMS ,KWMEAN,KWTRMS,KWTRND,   &
     &       KPRVRT,KEBSTT,KVLOPT,NXCA05
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
      COMMON/CORL02/KLNDTT,KLWSTR,KLNDTR,KLEVMF,KLTPMS,NXCL02
      COMMON/CORL04/KLEDIT,KLBEDT,KLEDT1,KLEDT2,KNSCID,KEXTOF,KLSDAT,   &
     &              KLRDED,KLAVOI,KLFEDT,KLANTC,NXCL04
      COMMON/CPARFL/LPARFI,LPFEOF,LARCNU,LRORR
      COMMON/CPMPA /KTMPAR(3)    ,KMBPAR(2)    ,KRFPAR(2)    ,          &
     &              KAEPAR,KFEPAR,KFPPAR,KVLPAR,KETPAR(2,2)  ,          &
     &              KPMPAR,KUTPAR,KSTPAR(3,4)  ,NADJST       ,          &
     &              NDIM1 ,NDIM2 ,NXDIM1,NXDIM2
      COMMON/CPRESW/LPRE9 (24),LPRE  (24,3),LSWTCH(10,8),LOBSIN,LPREPW, &
     &              LFS   (40)
      COMMON/CRDDIM/NDCRD2,NDCRD3,NDCRD4,NDCRD5,NDCRD6,NDCRD7,          &
     &              NDCRD8,NDCRD9,NXCRDM
      COMMON/CREFMT/REFMT(9)
      COMMON/CSBSAT/KR,KRT,KZT,KXY2,KUZ,KUZSQ,KTEMP,KC3,KTHETG

      COMMON/CTHDOT/THDOT

      COMMON/GPSBLK/LGPS,LNOARC,LSPL85,NXGPS
      COMMON/IBODPT/IBDCF(999),IBDSF(999),IBDGM(999),IBDAE(999),    &
     &              IBDPF(999),                                     &
     &              ICBDCF,ICBDSF,ICBDGM,ICBDAE,ICBDPF,             &
     &              ITBDCF,ITBDSF,ITBDGM,ITBDAE,ITBDPF,NXBDPT
      COMMON/LDUAL/LASTSN,LSTSNX,LSTSNY
      COMMON/LOLOAD/LOLMD,LOLAJ,L2FOLT,LAPLOD
      COMMON/NEQINT/NINTOT,MEMTOT,NEQNIM,NXNEQS
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
      COMMON/OLDADJ/NPV0OL(3,3),JPV0OL(3,3),NYZ0OL(3,3),JYZ0OL(3,3),    &
     &              NEO0OL(3,3),JEO0OL(3,3)
      COMMON/OLDMOD/NTOLFR,NTOLF2,NTOLMD,NSTAOL,NSITOL,NTOLAJ,MXOLSA,   &
     &              NPOLSH,                                             &
     &              NXOLMD
      COMMON/OLOADA/LXYZCO,LEOPTO
      COMMON/TIDEOP/EOPTID(2,3)
      COMMON/VMATFL/LVMTF,LVMTFO
      COMMON/IOS/ISTOS1,ISTOS2,ISTOS3,ISTLST,INTSUB(3),JNTSUB(3),      &
     &        ILSTSG(80),INTOSP,MAPSAT(3,4)
!
      DIMENSION AA(1),II(1),LL(1),XSM(MINTIM,3),VSM(MINTIM,3),          &
     &   OBS(NM),OBSC(NM),RESID(NM),                                    &
     &   INDSAT(1),INDSET(1),INPSAT(1),LELEVS(1),                       &
     &   NEQN(MSETA),N3(MSETA),IPTFMG(MAXFMG,MSATA),                    &
     &   ILNFMG(MAXFMG,MSATA),NFMG(MSATA)
      DIMENSION XTD(MINTIM,3),VTD(MINTIM,3)
      DIMENSION PKPX(6,6),ELEMNS(3,2)
      DIMENSION INDSTA(3,4)
      DIMENSION ROTS1(9),ROTS2(9),ROTS3(9)
      DIMENSION UTDT(NM,4)
      DIMENSION DUM(3),DUM1(3,2,1)
      DIMENSION XENV(3,3),XYZDUM(1),XNM1(3)
      LOGICAL, DIMENSION(:), ALLOCATABLE :: LEDIT_EXTRA
!
      DATA ZERO/0.0D0/
      DATA J1/1/
!
!********1*********2*********3*********4*********5*********6*********7**
! START OF EXECUTABLE CODE
!********1*********2*********3*********4*********5*********6*********7**
!
      DO I=1,6
        EOPTID(I,1)=0.D0
      ENDDO

      IELEM=1
      IF(LNADJ) GO TO 1000
      IELEM=3
      INDSAH=INDSAT(1)
      IF(LASTSN) INDSAT(1)=2
!
! CLEAR TIME DERIVATIVE ARRAY
      CALL CLEARA(AA(KTPRTL),NM)
!
! CLEAR PARTIAL DERIVATIVE ARRAY
      NCLEAR=NM*NADJST
      CALL CLEARA(AA(KPMPA),NCLEAR)
 1000 CONTINUE
!
! MEASUREMENT SUB-TYPE RANGES 1-6
      NTYPE=(MTYPE-1)/6
      NTYPE=MTYPE-NTYPE*6
!
! SET COORDINATE TRANSFORMATION SWITCH
! IF  LPCETR IS   TRUE   THEN DATA IS IN TRUE OF REFERENCE
      LPCETR=LPRNRM(22,1)
! SET PCE RADIAL DATA SWITCH, IF FALSE THE PCE DATA IS RADIAL
      LRADAL=LPRNRM(23,1)
!
      ISATID=II(KISATN-1+INDSAT(1))
      IF(NINTOT.GT.0) THEN
      CALL FNDNUM(ISATID,II(KSATIN),NINTOT,IRET)
      IF(IRET.GT.0) THEN
      KSUMXOS=MAPSAT(INTOSP,1)
      KSUMPOS=MAPSAT(INTOSP,2)
      KXDDTOS=MAPSAT(INTOSP,3)
      KPDDTOS=MAPSAT(INTOSP,4)
      KNSTEPS=II(KSTEPS-1+IRET)
      NEQNI=II(KNEQNI-1+IRET)
      ENDIF
      ENDIF

! ORBIT PARAMETERS
      IFSECM=KFSECS(1,1)
      CALL ORBSET(II(KNSAT),II(KIVSAT),LL(KLSETS),INDSAT ,              &
     &   KNSTEPS,NEQNI,II(KSGMNT-1+IRET),                               &
     &   AA(KSGTM1-1+IRET),AA(KSGTM2-1+IRET),IRET,MJDSBL,AA(IFSECM),    &
     &   AA(IFSECM-1+NM),NM,AA,II)
!
! OBTAIN SATELLITE POSITION
      CALL ORBIT(MJDSBL,AA(IFSECM),AA(KS),NM,II(KINDH),II(KNMH),        &
     &   II(KMJDSC),AA(KFSEC),II(KMJDSV),AA(KFSECV),LL(KLSETS),         &
     &   II(KIPXPF),II(KIVSAT),1,II(KNMAX),II(KNTOLD),XSM,AA(KPXPFM),   &
     &   LNADJ,.FALSE.,II(KPLPTR),II(KPANEL),II(KNMOVE),                &
     &   AA(KTPMES+4*MINTIM),LL(KLTPMS+6*MINTIM),LL(KSETDN),            &
     &   AA(KTMOS0-1+INTOSP),AA(KTMOS-1+INTOSP),AA(KTMOSP-1+INTOSP),    &
     &   AA(KSMXOS-1+KSUMXOS),AA(KSMXOS-1+KSUMPOS),AA(KSMXOS-1+KXDDTOS),&
     &   AA(KSMXOS-1+KPDDTOS),KNSTEPS,NEQNI,II(KSGMNT-1+IRET),          &
     &   AA(KSGTM1-1+IRET),AA(KSGTM2-1+IRET),AA,II,LL)
!
      INDSAT(1)=INDSAH
      IF(LASTSN.AND.INDSAT(1).EQ.1) THEN
        CALL XAS2SA(NM,MINTIM,AA(KASTO),XSM)
        IF(LNPNM) THEN
           CALL PAS2S1(NM,NEQN(1),AA(KPXPFM),AA(KASTP))
        ELSE
           CALL PAS2S2(NM,NEQN(1),AA(KPXPFM),AA(KASTP))
        ENDIF
      ENDIF
!
      IF(.NOT.LPCETR.OR.LGPS) THEN
      CALL SATUPD(MJDSBL,AA(IFSECM),XSM,XTD,AA,NM,MINTIM,.TRUE.,        &
     &            .FALSE.,II,0,1)
      CALL SATUPD(MJDSBL,AA(IFSECM),VSM,VTD,AA,NM,MINTIM,.FALSE.,       &
     &            .FALSE.,II,0,1)
!C
      IF(LGPS) THEN
!!!!!!!!!!!!!!
      IF(LOLMD) THEN
        CALL OLDSET(1,0,NM,AA(KSTAIN),II(KIP0OL),II(KNDOLA),            &
     &              II(KKIOLA),LOLAJ,LOLMDS,                            &
     &              JABCOF,JPXSPA,JOLPAE,JOLPAN,JOLPAV,JXLOCV,          &
     &              JABCCM,JPXSP1,JOLPXC,JOLPYC,JOLPZC,                 &
     &              JABCEO,JPXSP2,JOLPXP,JOLPYP,JOLPUP,LALOAD,ISITA,    &
     &              XENV)
      ENDIF
      IF(LEOPTO.OR.LOLMDS.OR.LXYZCO) THEN
         CALL OLTIME(MJDSBL,AA(IFSECM),NM,AA(KANGFC),AA(KSPEED),        &
     &               AA(KSCROL),AA(KSCROL+4*NTOLFR),II(KPTOLS),         &
     &               AA(KANGT),AA(KCONAM),AA(KTWRK1),AA(KGRDAN),        &
     &               AA(KUANG),AA(KFAMP),II(KJDN))
      ENDIF
      IF(LEOPTO) THEN
         CALL OLDEOP(MJDSBL,AA(IFSECM),NM,AA(JABCOF),AA(KANGFC),        &
     &              AA(KSPEED),                                         &
     &              AA(JXLOCV),XYZDUM,AA(KSCROL),AA(KROTMT),.FALSE.,    &
     &              AA(JPXSPA),NPV0OL(1,J1),NPV0OL(2,J1),NPV0OL(3,J1),  &
     &              II(JOLPAE),II(JOLPAN),II(JOLPAV),AA(JABCCM),        &
     &              AA(JPXSP1),NYZ0OL(1,J1),NYZ0OL(2,J1),NYZ0OL(3,J1),  &
     &              II(JOLPXC),II(JOLPYC),II(JOLPZC),AA(JABCEO),        &
     &              AA(JPXSP2),NEO0OL(1,J1),NEO0OL(2,J1),NEO0OL(3,J1),  &
     &              II(JOLPXP),II(JOLPYP),II(JOLPUP),LOLMDS,LXYZCO,     &
     &              LEOPTO,XNM1)
      ENDIF
!!!!!!!!!!!!!!
      CALL GRHRAP(MJDSBL,AA(IFSECM),.TRUE.,.TRUE.,AA(KEQN),AA(KSRTCH),  &
     &   AA(KTHETG),AA(KCOSTH),AA(KSINTH),NM,AA,II,UTDT(1,1),.FALSE.,   &
     &   DUM,DUM1)
      ENDIF
!C
      ENDIF
!
      IF(.NOT.(LOBORB.OR.LPARFI)) GO TO 2000
      CALL SATUPD(MJDSBL,AA(IFSECM),XSM,AA(KXTN),AA,NM,MINTIM,.TRUE.,   &
     &            .FALSE.,II,0,1)
      CALL SATUPD(MJDSBL,AA(IFSECM),VSM,AA(KVTN),AA,NM,MINTIM,.FALSE.,  &
     &            .FALSE.,II,0,1)
!
! COMPUTE RIGHT ASCENSION OF GREENWICH ACROSS ENTIRE BLOCK OF DATA
!
      IF(ICBDGM.EQ.3) THEN
      CALL GRHRAP(MJDSBL,AA(IFSECM),.FALSE.,.FALSE.,AA(KEQN),AA(KSRTCH),&
     &   AA(KTHETG),AA(KCOSTH),AA(KSINTH),NM,AA,II,UTDT(1,1),.FALSE.,   &
     &   DUM,DUM1)
      ELSE
      CALL ROTXTR(MJDSBL,AA(IFSECM),.FALSE.,AA(KEQN),AA(KSRTCH),        &
     &   AA(KTHETG),AA(KCOSTH),AA(KSINTH),NM,AA,AA(KACOSW),AA(KBSINW),  &
     &   AA(KANGWT),AA(KWT),AA(KACOFW),AA(KBCOFW),II,1)
      ENDIF
!
! COMPUTE S/C HEIGHT ABOVE ELLIPSOID AND SUB-SATELLITE LAT & LON
      CALL SUBTRK(AA(KXTN),AA(KTHETG),AA(KXY2),AA(KZT),AA(KRT),         &
     &   AA(KSATLT),AA(KSATLN),AA(KSATH),NM)
!
      IF(.NOT.LOBORB) GO TO 2000
!
! PRINT TRAJECTORY
      CALL TRAJCT(AA(KA1UT),MJDSBL,AA(IFSECM),AA(KXTN),AA(KVTN),        &
     &   AA(KSATLT),AA(KSATLN),AA(KSATH),II(KINDH),II(KNMH),AA(KS),     &
     &   AA(KCIP  ),NM,INDSAT(J1),AA,AA(KCOSTH),AA(KSINTH),AA(KDPSR),   &
     &   AA(KXPUT),AA(KYPUT),II)
 2000 CONTINUE
      IF(LVMTFO) CALL VMATO(AA(KA1UT),MJDSBL,AA(IFSECM),XSM,VSM,        &
     &   AA(KPXPFM),II(KINDH),II(KNMH),AA(KS),AA(KCIP  ),NM,INDSAT(J1), &
     &   II)
!
! LOOP THRU EACH MEASUREMENT
!
      TL=AA(IFSECM+NM-1)-AA(IFSECM)
      DO 5000 N=1,NM
!
      IF(LGPS) THEN
      CALL BIH(MJDSBL,AA(IFSECM+N-1),AA(KA1UT),XBIH,YBIH)
!EOPTID(2,3)
      IF(NM.LE.2) THEN
       XBIH=XBIH+EOPTID(N,1)
       YBIH=YBIH+EOPTID(N,2)
      ELSE
       RAT=(AA(IFSECM+N-1)-AA(IFSECM))/TL
       XBIH=XBIH+EOPTID(1,1)+RAT*(EOPTID(2,1)-EOPTID(1,1))
       YBIH=YBIH+EOPTID(1,2)+RAT*(EOPTID(2,2)-EOPTID(1,2))
      ENDIF
      ROTS1(1)=AA(KROTMT+N-1)
      ROTS1(2)=AA(KROTMT+NDCRD2+N-1)
      ROTS1(3)=AA(KROTMT+NDCRD3+N-1)
      ROTS1(4)=AA(KROTMT+NDCRD4+N-1)
      ROTS1(5)=AA(KROTMT+NDCRD5+N-1)
      ROTS1(6)=AA(KROTMT+NDCRD6+N-1)
      ROTS1(7)=AA(KROTMT+NDCRD7+N-1)
      ROTS1(8)=AA(KROTMT+NDCRD8+N-1)
      ROTS1(9)=AA(KROTMT+NDCRD9+N-1)
!
      ROTS2(1)=ROTS1(1)*REFMT(1)+ROTS1(4)*REFMT(2)+ROTS1(7)*REFMT(3)
      ROTS2(2)=ROTS1(2)*REFMT(1)+ROTS1(5)*REFMT(2)+ROTS1(8)*REFMT(3)
      ROTS2(3)=ROTS1(3)*REFMT(1)+ROTS1(6)*REFMT(2)+ROTS1(9)*REFMT(3)
      ROTS2(4)=ROTS1(1)*REFMT(4)+ROTS1(4)*REFMT(5)+ROTS1(7)*REFMT(6)
      ROTS2(5)=ROTS1(2)*REFMT(4)+ROTS1(5)*REFMT(5)+ROTS1(8)*REFMT(6)
      ROTS2(6)=ROTS1(3)*REFMT(4)+ROTS1(6)*REFMT(5)+ROTS1(9)*REFMT(6)
      ROTS2(7)=ROTS1(1)*REFMT(7)+ROTS1(4)*REFMT(8)+ROTS1(7)*REFMT(9)
      ROTS2(8)=ROTS1(2)*REFMT(7)+ROTS1(5)*REFMT(8)+ROTS1(8)*REFMT(9)
      ROTS2(9)=ROTS1(3)*REFMT(7)+ROTS1(6)*REFMT(8)+ROTS1(9)*REFMT(9)
!
      ROTS1(1)=AA(KCOSTH-1+N)
      ROTS1(2)=-AA(KSINTH-1+N)
      ROTS1(3)=0.D0
      ROTS1(4)=AA(KSINTH-1+N)
      ROTS1(5)=AA(KCOSTH-1+N)
      ROTS1(6)=0.D0
      ROTS1(7)=0.D0
      ROTS1(8)=0.D0
      ROTS1(9)=1.D0
!
      ROTS3(1)=ROTS1(1)*ROTS2(1)+ROTS1(4)*ROTS2(2)+ROTS1(7)*ROTS2(3)
      ROTS3(2)=ROTS1(2)*ROTS2(1)+ROTS1(5)*ROTS2(2)+ROTS1(8)*ROTS2(3)
      ROTS3(3)=ROTS1(3)*ROTS2(1)+ROTS1(6)*ROTS2(2)+ROTS1(9)*ROTS2(3)
      ROTS3(4)=ROTS1(1)*ROTS2(4)+ROTS1(4)*ROTS2(5)+ROTS1(7)*ROTS2(6)
      ROTS3(5)=ROTS1(2)*ROTS2(4)+ROTS1(5)*ROTS2(5)+ROTS1(8)*ROTS2(6)
      ROTS3(6)=ROTS1(3)*ROTS2(4)+ROTS1(6)*ROTS2(5)+ROTS1(9)*ROTS2(6)
      ROTS3(7)=ROTS1(1)*ROTS2(7)+ROTS1(4)*ROTS2(8)+ROTS1(7)*ROTS2(9)
      ROTS3(8)=ROTS1(2)*ROTS2(7)+ROTS1(5)*ROTS2(8)+ROTS1(8)*ROTS2(9)
      ROTS3(9)=ROTS1(3)*ROTS2(7)+ROTS1(6)*ROTS2(8)+ROTS1(9)*ROTS2(9)
!
      ROTS1(1)=1.D0
      ROTS1(2)=0.D0
      ROTS1(3)=-XBIH
      ROTS1(4)=0.D0
      ROTS1(5)=1.D0
      ROTS1(6)=YBIH
      ROTS1(7)=XBIH
      ROTS1(8)=-YBIH
      ROTS1(9)=1.D0
!
      ROTS2(1)=ROTS1(1)*ROTS3(1)+ROTS1(4)*ROTS3(2)+ROTS1(7)*ROTS3(3)
      ROTS2(2)=ROTS1(2)*ROTS3(1)+ROTS1(5)*ROTS3(2)+ROTS1(8)*ROTS3(3)
      ROTS2(3)=ROTS1(3)*ROTS3(1)+ROTS1(6)*ROTS3(2)+ROTS1(9)*ROTS3(3)
      ROTS2(4)=ROTS1(1)*ROTS3(4)+ROTS1(4)*ROTS3(5)+ROTS1(7)*ROTS3(6)
      ROTS2(5)=ROTS1(2)*ROTS3(4)+ROTS1(5)*ROTS3(5)+ROTS1(8)*ROTS3(6)
      ROTS2(6)=ROTS1(3)*ROTS3(4)+ROTS1(6)*ROTS3(5)+ROTS1(9)*ROTS3(6)
      ROTS2(7)=ROTS1(1)*ROTS3(7)+ROTS1(4)*ROTS3(8)+ROTS1(7)*ROTS3(9)
      ROTS2(8)=ROTS1(2)*ROTS3(7)+ROTS1(5)*ROTS3(8)+ROTS1(8)*ROTS3(9)
      ROTS2(9)=ROTS1(3)*ROTS3(7)+ROTS1(6)*ROTS3(8)+ROTS1(9)*ROTS3(9)
!
      ELEMNS(1,1)=ROTS2(1)*XSM(N,1)+ROTS2(4)*XSM(N,2)+ROTS2(7)*XSM(N,3)
      ELEMNS(2,1)=ROTS2(2)*XSM(N,1)+ROTS2(5)*XSM(N,2)+ROTS2(8)*XSM(N,3)
      ELEMNS(3,1)=ROTS2(3)*XSM(N,1)+ROTS2(6)*XSM(N,2)+ROTS2(9)*XSM(N,3)

      !write(6,*) 'pce: N, XSM(N,1:3)   ', N, XSM(N,1:3)
      !write(6,*) 'pce: N, VSM(N,1:3)   ', N, VSM(N,1:3)

      vsm(N,1) = vsm(N,1) + xsm(N,2) * THDOT
      vsm(N,2) = vsm(N,2) - xsm(N,1) * THDOT

      ELEMNS(1,2)=ROTS2(1)*VSM(N,1)+ROTS2(4)*VSM(N,2)+ROTS2(7)*VSM(N,3)
      ELEMNS(2,2)=ROTS2(2)*VSM(N,1)+ROTS2(5)*VSM(N,2)+ROTS2(8)*VSM(N,3)
      ELEMNS(3,2)=ROTS2(3)*VSM(N,1)+ROTS2(6)*VSM(N,2)+ROTS2(9)*VSM(N,3)

      !write(6,*) 'pce: N, XSM(N,1:3)   ', N, XSM(N,1:3)
      !write(6,*) 'pce: N, VSM(N,1:3)   ', N, VSM(N,1:3)
      !write(6,*) 'pce: N, ELEMNS(1:3,1) ', N, ELEMNS(1:3,1)
      !write(6,*) 'pce: N, ELEMNS(1:3,2) ', N, ELEMNS(1:3,2)

      GOTO 4000
!
      ENDIF
!
      IF(.NOT.LRADAL) THEN
      ELEMNS(NTYPE,1)=SQRT(XSM(N,1)**2+XSM(N,2)**2+XSM(N,3)**2)
      GOTO 4000
      ENDIF
!
      IF(.NOT.LPCETR) THEN
      DO 2100 I=1,3
      ELEMNS(I,1)=XTD(N,I)
      ELEMNS(I,2)=VTD(N,I)
 2100 END DO
      ELSE
      DO 2200 I=1,3
      ELEMNS(I,1)=XSM(N,I)
      ELEMNS(I,2)=VSM(N,I)
 2200 END DO
      ENDIF
!
      IF(MTYPE.LT.7) GO TO 4000
!
! TRANFORMATION FROM CARTESIAN TO KEPLERIAN AND PARTIALS OF KEPLERIAN
!               W.R.T. CARTESIAN
      GMX=GM
      IF(INDSAT(1).EQ.1.AND.LASTSN) GMX=BDSTAT(7,8)
      CALL ELEM(ELEMNS(1,1),ELEMNS(2,1),ELEMNS(3,1),                    &
     &          ELEMNS(1,2),ELEMNS(2,2),ELEMNS(3,2),                    &
     &          ELEMNS,IELEM,PKPX,GMX)
 4000 CONTINUE
      OBSC(N)=ELEMNS(NTYPE,1)
!     IFSECM=IFSECM+1
      IF(LNADJ ) GO TO 5000
      NROT=N-1
      CALL PCEPAR(PKPX,AA(KPMPXI),NM,N,MTYPE,LPCETR,AA(KROTMT+NROT),    &
     & AA(KROTMT+NDCRD2+NROT),     AA(KROTMT+NDCRD3+NROT),              &
     & AA(KROTMT+NDCRD4+NROT),     AA(KROTMT+NDCRD5+NROT),              &
     & AA(KROTMT+NDCRD6+NROT),     AA(KROTMT+NDCRD7+NROT),              &
     & AA(KROTMT+NDCRD8+NROT),     AA(KROTMT+NDCRD9+NROT), LRADAL,      &
     & XSM(N,1),   XSM(N,2),    XSM(N,3),    ELEMNS(NTYPE,1),LGPS,      &
     & ROTS2)
 5000 END DO
      IF(LNADJ) GO TO 9000
!
! CHAIN MEASUREMENT PARTIALS WITH FORCE MODEL PARTIALS
      ISAT=INDSAT(1)
      ISET=INDSET(1)
      IPXPF=KPXPFM
      IPMPVI=KPMPXI+NM*3
      NDIMX1=NEQN(ISET)
      NDIMX2=N3(ISET)
      NDIMX3=NM
      IF(LNPNM) GO TO 6000
      NDIMX1=NM
      NDIMX2=NEQN(ISET)
      NDIMX3=N3(ISET)
 6000 CONTINUE
!...CHAIN MEASUREMENT POSITION PARTIALS WITH FORCE MODEL PARTIALS
      CALL CHAIN (AA(KPMPXI),NM,3,1,AA(IPXPF),NDIMX1,NDIMX2,NDIMX3,     &
     &    NEQN(ISET),N3(ISET),IPTFMG(1,ISAT),ILNFMG(1,ISAT),NFMG(ISAT), &
     &    AA(KPMPA),NDIM1,NDIM2,LNPNM,.FALSE.,.FALSE.,SCALE,LL(KLAVOI))
      IF(MTYPE.LT.4) GO TO 7000
!...CHAIN MEASUREMENT VELOCITY PARTIALS WITH FORCE MODEL PARTIALS
      CALL CHAIN (AA(IPMPVI),NM,3,2,AA(IPXPF),NDIMX1,NDIMX2,NDIMX3,     &
     &    NEQN(ISET),N3(ISET),IPTFMG(1,ISAT),ILNFMG(1,ISAT),NFMG(ISAT), &
     &    AA(KPMPA),NDIM1,NDIM2,LNPNM,.FALSE.,.FALSE.,SCALE,LL(KLAVOI))
 7000 CONTINUE
!
! LIGHT TIME PARTIALS
      IF(LNADJ) GO TO 9000
      NVLITE=NPVAL0(IXVLIT)
      LITADJ=LSTINR.AND.NVLITE.GT.0
      IF(.NOT.LITADJ) GO TO 9000
! COMPUTE SPEED OF LIGHT PARTIAL
      INVLIT=IPVAL0(IXVLIT)
      CALL PLIGHT(AA(KPMPA),NDIM1,NDIM2,AA(KOBS),NM,INVLIT,LNPNM)
 9000 CONTINUE
! COMPUTE OBSERVATION RESIDUALS
      DO 9200 N=1,NM
      RESID (N)=OBS   (N)-OBSC  (N)
 9200 END DO
      IF(MTYPE.LT.10) GO TO 9800
      DO 9400 N=1,NM
      RESID (N)=MOD(RESID(N)+TWOPI,TWOPI)
      IF(RESID(N).GT.PI) RESID(N)=RESID(N)-TWOPI
 9400 END DO
! EDIT, PRINT, SUM STATISTICS AND SUM INTO NORMAL EQUATIONS
 9800 CONTINUE
      IF(.NOT.LACC.AND.LPSBL) GOTO 9900

      ALLOCATE(LEDIT_EXTRA(NM))
      LEDIT_EXTRA(:) = .FALSE.
      CALL PROCES(AA,II,LL,OBSC      ,RESID     ,AA(KSIGMA),AA(KRATIO), &
     &          AA(KPMPA ),OBS       ,AA(KSMCOR),AA(KOBTIM),AA(KOBSIG), &
     &          AA(KIAUNO),AA(KEDSIG),II(KINDH ),II(KNMH  ),AA(KS    ), &
     &          AA(KS0   ),AA(KS1   ),LL(KLEDIT),AA(KELEVS),AA(KDSCRP), &
     &          JSTATS    ,MTYPE     ,INDSTA    ,INDSAT    ,LELEVS    , &
     &          II(KISTNO),AA(KSTNAM),AA(KXPMPA),LL(KLSDAT),1,1,        &
     &          LL(KLSDAT),LL(KLFEDT),LEDIT_EXTRA)
      DEALLOCATE(LEDIT_EXTRA)
!     stop

 9900 CONTINUE
      RETURN
      END
