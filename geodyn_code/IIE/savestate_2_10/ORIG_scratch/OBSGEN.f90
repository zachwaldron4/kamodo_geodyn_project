!$OBSGEN
      SUBROUTINE OBSGEN(AA,II,LL,INDSTA,INDSAT,INDSET,INPSTA,INPSAT,    &
     &   LELEVS,ILCORR)
!********1*********2*********3*********4*********5*********6*********7**
! OBSGEN           00/00/00            0000.0    PGMR - ?
!
! FUNCTION:  MAIN SUBROUTINE FOR OBSERVATION GENERATION FOR ALL
!            MEASUREMENT TYPES
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   AA      I/O   A    REAL DYNAMIC ARRAY
!   II      I/O   A    INTEGER DYNAMIC ARRAY
!   LL      I/O   A    LOGICAL DYNAMIC ARRAY
!   INDSTA   O    A    FOR A GIVEN INTERNAL STA NO (1,2,3) INDSTA
!                      GIVES THE ACTUAL LOCATION IN THE STATION
!                      RELATED ARRAYS FOR THIS STATION.
!                      (EG.   STA NO=ISTANO(INDSTA(1,2,OR 3))
!   INDSAT   O    A    FOR A GIVEN INTERNAL SAT NO (1,2,3) INDSAT
!                      GIVES THE ACTUAL LOCATION IN THE SATELLITE
!                      RELATED ARRAYS FOR THIS SATELLITE.
!                      (EG.   SAT ID=ISATNO(INDSAT(1,2,OR 3))
!   INDSET   O    A    FOR A GIVEN INTERNAL SATELLITE NUMBER INDSET TELL
!                      WHICH SAT SET THAT THE GIVEN SAT BELONGS TO.
!   INPSTA   O    A    POINTER ARRAY THAT RELATES THE INTERNAL STATION
!                      NUMBER (1,2,3) TO THE STATIONS DEFINED IN THE
!                      DATA HEADER RECORDS (N=1,2,3). (EG.
!                      ISTAP=INPSTA(1) WOULD TELL WHICH OF THE THREE
!                      POSSIBLE STATIONS DEFINED IN THE DATA HEADER
!                      RECORDS PERTAINED TO INTERNAL STATION NO. 1)
!   INPSAT   O    A    POINTER ARRAY THAT RELATES THE INTERNAL SATELLITE
!                      NUMBER (1,2,3) TO THE SATELLITES DEFINED IN THE
!                      DATA HEADER RECORDS (N=1,2,3). (EG.
!                      ISATP=INPSAT(1) WOULD TELL WHICH OF THE THREE
!                      POSSIBLE SATELLITES DEFINED IN THE DATA HEADER
!                      RECORDS PERTAINED TO INTERNAL SATELLITE NO. 1)
!   LELEVS  I/O   A    INDICATES WHICH ELEVATION ANGLES NEED TO BE
!                      COMPUTED FOR THE THREE POSSIBLE STATION SATELLITE
!                      CONFIGURATIONS DEFINED IN THE BLOCK HEADER
!                      RECORDS
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      COMMON/CBINRL/LBINR,LLOCR,LODR,LBNCR,LBINRI,LLOCRI,LODRI,LBNCRI,  &
     &              NXCBIN
      COMMON/CBLOKA/FSECBL,SIGNL ,VLITEC,SECEND,BLKDAT(6,4),DOPSCL(5,4)
      COMMON/CBLOKI/MJDSBL,MTYPE ,NM    ,JSTATS,NPSEG ,JSATNO(3),ITSYS ,&
     &       NHEADB,NELEVS,ISTAEL(12),INDELV(3,4),JSTANO(3),ITARNO,     &
     &       KTARNO
      COMMON/CBLOKL/LIGHT ,LNRATE,LNREFR,LPOLAD,LTDRIV,LNANT ,LNTRAK,   &
     &       LASER ,LGPART,LGEOID,LETIDE,LOTIDE,LNTIME,LAVGRR,LRANGE,   &
     &       LSSTMD,LSSTAJ,LNTDRS,LPSBL,LACC,LAPP,LTARG,LTIEOU,LEOTRM,  &
     &       LSURFM,LGEOI2,LSSTM2,LOTID2,LOTRM2,LETID2,LNUTAD
      COMMON/CEGREL/LGRELE,LRLCLK,LGRELR,LXPCLK,LBPCLK,NXEGRL
      COMMON/CESTML/LNPNM ,NXCSTL
      COMMON/COBLOC/KXMN  (3,4)  ,KENVN (3,4)  ,KSTINF(3,4)  ,          &
     &       KOBS  ,KDTIME,KSMCOR,KSMCR2,KTMCOR,KOBTIM,KOBSIG,KOBSG2,   &
     &       KIAUNO,KOBCOR(9,7)  ,KFSECS(6,8)  ,KOBSUM(8)    ,          &
     &       KEDSIG,KEDSG2
      COMMON/CINTI/IBACK ,IBACKV,IORDER,IORDRV,NOSTEP,NOCORR,           &
     &      NSAT  ,N3    ,NEQN  ,NEQN3 ,NH    ,NHV   ,NSTEPS,           &
     &      NSTEPV,ICPP  ,ICPV  ,ICCP  ,ICCV  ,ICCPV ,ICCVV ,           &
     &      ISUMX ,IXDDOT,ISUMPX,IPXDDT
      COMMON/CNIGLO/MINTIM,MSATG3,MEQNG ,MEQNG3,MSATG ,MSATOB,MSATA ,   &
     &              MSATA3,MSETA ,MINTVL,MSORDR,MSORDV,NMXORD,          &
     &       MCIPV ,MXBACK,MXI   ,MPXPF ,MAXAB ,MSETDG,MXSATD,          &
     &       MXDEGS,MXDRP ,MXDRPA,MXSRP ,MXSRPA,MXGAP ,MSATDR,          &
     &       MSATSR,MSATGA,MXDRPD,MXSRPD,MXGAPD,MXBCKP,MXTPMS,          &
     &       NSTAIN,NXCNIG
      COMMON/COFFST/JXYZOF(2),JSADLY(2),JSTDLY(2),JXYZCG(2,2),          &
     &              MJDFCG(2,2),JXYOF2(2),JEXTOF(2),JXYOF3(2)
      COMMON/COFSTL/LOFEXT(2)
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
      COMMON/CORA05/KOBTYP,KDSCRP,KGMEAN,KGLRMS,KWGMEA,KWGRMS,KTYMEA,   &
     &       KTYRMS,KWTMTY,KWTYRM,KTMEAN,KTRMS ,KWMEAN,KWTRMS,KWTRND,   &
     &       KPRVRT,KEBSTT,KVLOPT,NXCA05
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
      COMMON/CORL01/KLORBT,KLORBV,KLNDRG,KLBAKW,KLSETS,KLAFRC,KLSTSN,   &
     &              KLSNLT,KLAJDP,KLAJSP,KLAJGP,KLTPAT,KEALQT,KLRDGA,   &
     &              KLRDDR,KLRDSR,KFHIRT,KLSURF,KHRFON,KLTPXH,KSETDN,   &
     &              KTALTA,NXCL01
      COMMON/CORL04/KLEDIT,KLBEDT,KLEDT1,KLEDT2,KNSCID,KEXTOF,KLSDAT,   &
     &              KLRDED,KLAVOI,KLFEDT,KLANTC,NXCL04
      COMMON/CPMPA /KTMPAR(3)    ,KMBPAR(2)    ,KRFPAR(2)    ,          &
     &              KAEPAR,KFEPAR,KFPPAR,KVLPAR,KETPAR(2,2)  ,          &
     &              KPMPAR,KUTPAR,KSTPAR(3,4)  ,NADJST       ,          &
     &              NDIM1 ,NDIM2 ,NXDIM1,NXDIM2
      COMMON/CPRESW/LPRE9 (24),LPRE  (24,3),LSWTCH(10,8),LOBSIN,LPREPW, &
     &              LFS   (40)
      COMMON/CLPRNR/LPR9NR(24),LPRNRM(24,3)
      COMMON/CNIARC/NSATA,NSATG,NSETA,NEQNG,NMORDR,NMORDV,NSORDR,       &
     &              NSORDV,NSUMX,NXDDOT,NSUMPX,NPXDDT,NXBACK,NXI,       &
     &              NXILIM,NPXPF,NINTIM,NSATOB,NXBCKP,NXTIMB,           &
     &              NOBSBK,NXTPMS,NXCNIA
      COMMON/CSBSAT/KR,KRT,KZT,KXY2,KUZ,KUZSQ,KTEMP,KC3,KTHETG
      COMMON/DELOFF/NOFFST,NSATDL,NSTADL,NCGMAS,NXDELO
      COMMON/ELRTNX/NELVS,NELVC,IELSTA(6),IELSAT(6),IELSA2(6),          &
     &       INDXEL(5,4)
      COMMON/LASTER/LASTR(2),LBINAST,NXASTR
      COMMON/IBODPT/IBDCF(999),IBDSF(999),IBDGM(999),IBDAE(999),    &
     &              IBDPF(999),                                     &
     &              ICBDCF,ICBDSF,ICBDGM,ICBDAE,ICBDPF,             &
     &              ITBDCF,ITBDSF,ITBDGM,ITBDAE,ITBDPF,NXBDPT
      COMMON/NFORCE/NHRATE,NSURF,MPXHDT,MXHRG,MXFMG,NFSCAC,NXFORC
      COMMON/OCCLTL/LOCCLT(200),LMSHD(200)
      COMMON/RIMAGE/VIMAGE(6),QUCAM(4),QURSYS,TLBOD2
!
      DIMENSION AA(1),II(1),LL(1),INDSTA(3,4),INDSAT(3,4),INDSET(3,4),  &
     &   LELEVS(3,4),INPSTA(3,4),INPSAT(3,4),ILCORR(5,4)
      DIMENSION XSCR(20)

      DIMENSION OBSPIX(2)

!
!**********************************************************************
! START OF EXECUTABLE CODE ********************************************
!**********************************************************************
!
! CALL ATPARP TO SORT OUT ATITUDE PARAMETERS (IF THEY ARE IN PLAY)
      CALL ATPARP(AA,II,LL,MTYPE,INDSAT(1,1),NM,MJDSBL,AA(KFSECS(1,1)), &
     &            II(KATSAT),II(KKVLAS),AA(KATIME))
! IN CASE OF SIMULATION OF INTERPLANETRY,INITIALIZE LOCCLT TO FALSE
      NELVS=0
      LSIMX=LSIMDT
      IF(ICBDGM.EQ.ITBDGM) LSIMX=.FALSE.
      IF(LSIMX) THEN
      DO 40 I=1,NM
      LOCCLT(I)=.FALSE.
      LMSHD(I)=.FALSE.
   40 END DO
      ENDIF
!
! SET DIMENSIONS OF PMPA
      NDIM1=NADJST
      NDIM2=NM
      IF(LNPNM) GO TO 100
      NDIM1=NM
      NDIM2=NADJST
  100 CONTINUE
! WRITE OUT BINARY LENGTHS RECORD

!!!      write(6,*)'JTW OBSGEN, CALL BINLEN',MTYPE,LBINRI

      IF(MTYPE.EQ.33.OR.MTYPE.EQ.34) GOTO 45
      IF(LBINRI) CALL BINLEN(AA,II)
 45   CONTINUE
!
      IF (MTYPE.LE.12) THEN

!        KVTKP HAS EXTRA WORKING SPACE OF SIZE 6*MINTIM (LOOK IN KORP02)
         KXTD=KVTKP+3*MINTIM
         KVTD=KXTD+3*MINTIM
!
         CALL PCE   (AA,II,LL,AA(KXSM),AA(KVSM),AA(KOBS),AA(KOBSC),     &
     &      AA(KRESID),INDSAT,INDSET,INPSAT,LELEVS,II(KNEQN),           &
     &      II(KN3),II(KIPTFM),II(KILNFM),II(KNFMG),AA(KXTD),AA(KVTD),  &
     &      AA(KXUTDT))
!
      ELSE IF (MTYPE.GE.13.AND.MTYPE.LE.30) THEN
!
         CALL ANGLES(AA,II,LL  ,AA(KSTAIN),II(KN3   ),II(KNEQN ),       &
     &            II(KIPTFM),II(KILNFM),II(KNFMG ),                     &
     &            INDSTA    ,INDSAT    ,INDSET    ,                     &
     &            INPSTA    ,INPSAT    ,LELEVS    )
!
      ELSE IF (MTYPE.EQ.31.OR.MTYPE.EQ.32) THEN
!
!LT      WRITE(6,*) ' OBSGEN :  CALL QVLBI ROUTINE '
!LT      WRITE(6,*) ' OBTIM : ',AA(KOBTIM)
!LT      WRITE(6,*) ' MJDSBL & FSECBL : ',MJDSBL,FSECBL
!LT      WRITE(6,*) ' KFSEC : ',AA(KFSEC)
!LT      WRITE(6,*) ' OBSGEN: AA(KXTN), AA(KXTK) ',AA(KXTN),AA(KXTK)
!
         CALL QVLBI(AA,II,LL,INDSTA,INPSTA,LELEVS,AA(KPMPA),AA(KSTAIN), &
     &          AA(KQUINF),AA(KVLOPT),AA(KSIGSP),II(KBSPLN),II(KSSPLN),&
     &          TAU_GR)

!
!     ELSE IF (MTYPE.GE.37.AND.MTYPE.LE.96) THEN
      ELSE IF (MTYPE.GE.36.AND.MTYPE.LE.96) THEN
!
         LBPCLK=.FALSE.
         IF(LXPCLK.AND.MTYPE.EQ.51.AND.JSTANO(1).GT.5000) LBPCLK=.TRUE.
         CALL METRIC(AA,II,LL,INDSTA,INDSAT,INDSET,INPSTA,INPSAT,LELEVS,&
     &            ILCORR,AA(KPRMVC),AA(KPRMV),LL(KLANTC))
         LBPCLK=.FALSE.
!
      ELSE IF (MTYPE.GE.200.AND.MTYPE.LE.203) THEN
!
         JFSECN=KFSECS(1,1)
         ISATID=II(KISATN+INDSAT(1,1)-1)
         CALL ACCSEL(AA,II,LL,AA(JFSECN),INDSAT,INDSET,INPSAT,LELEVS,   &
     &              LL(KHRFON),II(KIXDDN),II(KIORDR),II(KIORDV),II(KNH),&
     &              II(KNSTPS),II(KN3),II(KDXDDN),II(KIPXDA),AA(KH),    &
     &              ISATID)

      ELSE IF (MTYPE.EQ.99.OR.MTYPE.EQ.101) THEN
!
!     ....ALTIMETER
!
! CHECK FOR APPLICABLE ALTIMETER ANTENNA OFFSETS
         JXYZOF(1)=KFRQOF
         JXYOF2(1)=KFRQOF
         JXYOF3(1)=KFRQOF
         JSADLY(1)=KFRQSA
         JSTDLY(1)=KFRQST
         JXYZCG(1,1)=KFRQOF
         JXYZCG(2,1)=KFRQOF
         MJDFCG(1,1)=0
         MJDFCG(2,1)=0
         LOFEXT(1)=.FALSE.

! GET SATELLITE ID BY USING INTERNAL SAT INDEX

         ISATID=II(KISATN+INDSAT(1,1)-1)

         IF( NOFFST.GT.0 ) THEN

             CALL IDANT(ISATID,0,.FALSE.,IANT)

             !write(6,*)'obsgen: call offdel'
             CALL OFFDEL(ISATID,0,BLKDAT(3,1),                &
                         II(KISATO),II(KISATD),II(KISATC),II(KISTAD),   &
                         AA(KFRQOF),AA(KFRQSA),AA(KFRQST),II(KMJDCG),   &
                         JICOOR, JXYZOF(1),JSADLY(1),JSTDLY(1),         &
                         JXYZCG(1,1),MJDFCG(1,1), IANT,ii(KANTOF), &
                         JXYOF2(1),       &
                         LL(KNSCID),II(KIANTO),LL(KEXTOF), LOFEXT(1),   &
                         .TRUE.,II,FRQLNK,1,AA,JXYOF3(1))

         ENDIF !   NOFFST.GT.0


! EVENT TIMES
         JFSECN=KFSECS(1,1)
         JFSECM=KFSECS(2,1)
         JFSECK=KFSECS(3,1)
         JFSECO=KFSECS(4,1)
!         print *,''
!         print *,'obsgen: KFSECS(1,1): ',JFSECN
!         print *,'obsgen: KFSECS(2,1): ',JFSECM
!         print *,'obsgen: KFSECS(3,1): ',JFSECK
!         print *,'obsgen: KFSECS(4,1): ',JFSECO
!         print *,''
! OBSERVATION CORRECTIONS RECORD
         JOBMET=KOBCOR(1,1)
         JOCTPC=KOBCOR(2,1)
         JOCDRY=KOBCOR(3,1)
         JOCWET=KOBCOR(4,1)
         IF(LPRNRM(5,1)) JOCWET=KOBCOR(5,1)
         JOCION=KOBCOR(6,1)
! OCEAN DYNAMICS RECORD
         JETIDE=KOBCOR(2,4)
         JOTIDE=KOBCOR(3,4)
         IF(LPRNRM(13,1)) JOTIDE=KOBCOR(4,4)
         JSST=KOBCOR(5,4)
! LOCATIONS DATA RECORD
         JGEOID=KOBCOR(4,7)
         JUNQIN=KOBCOR(7,7)
         JRLAND=KOBCOR(8,7)

!        print *,'obsgen: lprnrm(5,1): ',lprnrm(5,1)
!      print *,'obsgen: lprnrm(13,1): ',lprnrm(13,1)
!      print *,'obsgen: jocdry,jocwet: ',jocdry,jocwet
!      print *,'obsgen: jetide,jotide: ',jetide,jotide

         CALL ALTIM(AA,II,LL,                                           &
     &       AA(JFSECN),AA(JFSECM),AA(JFSECK),AA(KOBS  ),AA(KXTN  ),    &
     &       AA(KVTN  ),AA(KXSM  ),AA(KVSM  ),AA(KXTK  ),AA(KVTK  ),    &
     &       AA(KSATLT),AA(KSATLN),AA(KSATH ),AA(KRESID),               &
     &       AA(KPMPXI),AA(KPMPXE),AA(KWORK ),AA(KTPRTL),AA(JGEOID),    &
     &       AA(JETIDE),AA(JOTIDE),AA(KTHETG),AA(KCOSTH),AA(KSINTH),    &
     &       AA(KZT   ),AA(KXY2  ),AA(KR    ),AA(KRT   ),AA(KUZ   ),    &
     &       AA(KUZSQ ),AA(KRRNM ),AA(KTEMP ),AA(KC3   ),AA(KPMPA ),    &
     &       AA(JOBMET),AA(JOCDRY),AA(JOCWET),AA(JOCION),AA(JOCTPC),    &
     &       AA(JXYZCG(1,1))      ,AA(JXYZCG(2,1))       ,AA(JXYZOF(1)),&
     &       AA(KSMCOR),AA(KSMCR2),                                     &
     &       II(KN3   ),II(KNEQN ),II(KIPTFM),II(KILNFM),II(KNFMG ),    &
     &       INDSAT    ,INDSET    ,INPSAT    ,                          &
     &       LELEVS    ,AA(JSST)  ,INDSTA    ,AA(KPRMV),                &
     &       ISATID,II(KISATO),AA(KFRQOF),AA(KRA),AA(KX2SCR),AA(KVARAY),&
     &       AA(KEXTRA),AA(JFSECO),AA(KXUTDT),AA(JUNQIN),AA(JRLAND))
!
      ELSE IF (MTYPE.EQ.33) THEN

!     **************  NEW IMAGE DATA PROCESSING ***********
!
!  SET ADJUSTMENT POINTERS
!
      ISET=INDSET(1,1)
      ISAT=INDSAT(1,1)
      NDIMX1=II(KNEQN-1+ISET)
      NEQN=NDIMX1
      NDIMX2=II(KN3-1+ISET)
      NDIMX3=NM
      NDIM1=NADJST
      NDIM2=NDIMX3
      IF(LNPNM) GO TO 45000
      NDIMX1=NM
      NDIMX2=II(KNEQN-1+ISET)
      NEQN=NDIMX2
      NDIMX3=II(KN3-1+ISET)
      NDIM1=NDIMX1
      NDIM2=NADJST
45000 CONTINUE

        write(6,*)' dbg CALL IMAGE '
      CALL IMAGE(AA,II,LL,INDSAT(1,1),INDSET(1,1),AA(KRESID),AA(KSIGMA),&
     &       AA(KRATIO),AA(KPMPA ),AA(KOBS  ),AA(KOBSIG),AA(KS1),JSTATS,&
     &       MTYPE,AA(KIMTIM),AA(KIMOBS),AA(KXRNDX),                    &
     &       XSCR,II(KIMBLK),AA(KXSM),AA(KXTN),AA(KXTK),                &
     &       AA(KXSJ),AA(KVSM),AA(KVTK),AA(KVSJ),AA(KVTN),AA(KVTI),     &
     &       AA(KIMSAT),AA(KX2PAR),II(KNEQN-1+ISET),                    &
     &       AA(KPXPFM),NDIMX1,NDIMX2,NDIMX3,          II(KN3-1+ISET),  &
     &          II(KIMPRT),ISAT,ISET,R,AA(KX2AUX),AA(KM2VPA),           &
     &          AA(KATPER),LL(KLEDIT),AA(KEDSIG),AA(KTHETG),AA(KCOSTH), &
     &          AA(KSINTH),AA(KEXTRA),AA(KWORK),AA(KXHOLD),AA(KATROT),  &
     &          II(KIPTFM),II(KILNFM),II(KNFMG),AA(KPXEPA),AA(KOBTIM))


!     **************  NEW IMAGE DATA PROCESSING ***********
!
       ELSE IF (MTYPE.EQ.34) THEN
!
! MT 34 IS LANDMARK DATA; THERE ARE TWO TYPES OF CONFIGURATIONS:
!
!   (1) ARTIFICIAL SATELLITE IS ORBITING THE ASTEROID. IN THIS CASE
!        SUBROUTINE LANDMK IS CALLED
!   (2) ARTIFICIAL SATELLITE  AND ASTEROID ARE BOTH IN HELIOCENTRIC
!       ORBIT. IN THIS CASE SUBROUTINE LNDMK2 IS CALLED
!
      LMK2=.FALSE.
      IF(ICBDGM.EQ.11) LMK2=.TRUE.
!
      ISET=INDSET(1,1)
      ISAT=INDSAT(1,1)
      NDIMX1=II(KNEQN-1+ISET)
      NEQN=NDIMX1
      NDIMX2=II(KN3-1+ISET)
      NDIMX3=NM
      NDIMA1=NDIMX1
      NDIMA2=NDIMX2
      NDIMA3=NDIMX3
      IF(LBINAST) NDIMA1=II(KNEQN+1)
      NDIM1=NADJST
      NDIM2=NDIMX3
      IF(LMK2) THEN
        NDIM21=II(KNEQN)
        NEQN2=NDIM21
        NDIM22=3
        NDIM23=NM
      ENDIF
      IF(LNPNM) GO TO 45001
      NDIMX1=NM
      NDIMX2=II(KNEQN-1+ISET)
      NEQN=NDIMX2
      NDIMX3=II(KN3-1+ISET)
      NDIMA1=NDIMX1
      NDIMA2=NDIMX2
      NDIMA3=NDIMX3
      IF(LBINAST) NDIMA2=II(KNEQN+1)
      NDIM1=NDIMX1
      NDIM2=NADJST
      IF(LMK2) THEN
        NDIM21=NM
        NDIM22=II(KNEQN)
        NEQN2=NDIM22
        NDIM23=3
      ENDIF
45001 CONTINUE
      JPXPFM=KPXPFM
      IF(LBINAST) JPXPFM=KPXPFM+NDIMX1*NDIMX2*NDIMX3
      NEQNA=II(KNEQN-1+ISET)
      IF(LBINAST) NEQNA=II(KNEQN+1)

!      write(6,*)'KLMBLK,KLMBST',KLMBLK,KLMBST
!      write(6,*)'KLMKEY',KLMKEY
!      write(6,*)'KEY = II(KLMKEY+KLMBST-1)'
!      write(6,*)'KEY = ',II(KLMKEY+KLMBST-1)
!      write(6,*)'CALL LANDMK'
!      write(6,*)'LANDMK ID'
!      write(6,*)'AA(KOBS),+1',AA(KOBS),AA(KOBS+1)

!      write(6,*)'TARGET ID,JSTANO(1)'
!      write(6,*)JSTANO(1)

      OBSPIX(1)=AA(KOBS)
      OBSPIX(2)=AA(KOBS+1)
!
      IF(LMK2) GO TO 45002
      CALL       LANDMK(AA(KFSECS(1,1)),II(KNEQN-1+ISET),               &
     &    JSTANO(1),AA(KOBS),AA(KOBSIG),INDSAT(1,1),ISAT,ISET,OFF,      &
     &    XTRA, HOLD, AA(KATROT), AA(KATPER), NDIMX1,NDIMX2,NDIMX3,     &
     &    AA(KPXPFM),AA(KPMPA),II(KIPTFM),II(KILNFM),II(KNFMG),         &
     &    PIXEL,AA(KEDSIG),JSTATS,AA(KOBTIM),NDIMA1,NDIMA2,NDIMXA,      &
     &    AA(JPXPFM),NEQNA,AA,II,LL)
!       write(6,*)'dbg BACK TO OBSGEN '
      GO TO 45003
45002 CONTINUE
      KPXPFK=KPXPFM
!!!
!! CHECK AND SEE IF ASTEROID IS ON SUP EPHEM OR IS BEINF INTEGRATED
!!
      LASTSP=.TRUE.
!  IF THE MASS OF THE FIRST SATELLITE IN THE DECK IS GREATER THAN 100000 KG
!  THEN THE ASTEROID IS BRING INTEGRATED ALONG WITH THE ARTIFICIAL SATELLITE
      IF(AA(KXMASS).GT.100000.D0) LASTSP=.FALSE.
      IF(.NOT.LASTSP) KPXPFK=KPXPFM+6*II(KNEQN)
      CALL       LNDMK2(AA(KFSECS(1,1)),II(KNEQN-1+ISET),               &
     &    JSTANO(1),AA(KOBS),AA(KOBSIG),INDSAT(1,1),ISAT,ISET,OFF,      &
     &    XTRA, HOLD, AA(KATROT), AA(KATPER), NDIMX1,NDIMX2,NDIMX3,     &
     &    AA(KPXPFK),AA(KPMPA),II(KIPTFM),II(KILNFM),II(KNFMG),         &
!!!! &    PIXEL,AA(KEDSIG),JSTATS,AA(KOBTIM),AA,II,LL)
     &    PIXEL,AA(KEDSIG),JSTATS,AA(KOBTIM),NDIM21,NDIM22,NDIM23,      &
     &    NEQN2,AA(KPXPFM),AA, II, LL)
45003 CONTINUE

      ELSE IF (MTYPE.EQ.110.OR.MTYPE.EQ.111) THEN

      ISET=INDSET(1,1)
      ISAT=INDSAT(1,1)
      IF(LNPNM) THEN
      NDIM1=NADJST
      NDIM2=1
      NDIMA=II(KNEQN-1+ISET)
      NDIMB=3
      NDIMC=1
      ELSE
      NDIM1=1
      NDIM2=NADJST
      NDIMA=1
      NDIMB=II(KNEQN-1+ISET)
      NDIMC=3
      ENDIF

!     write(6,*)' dbg OBSGEN calling CONGEN '
      CALL CONGEN(AA,II,LL,INDSAT,INDSET,AA(KEXTRA),AA(KPXEPA),         &
     &            AA(KEDSIG),MAXNM,MXLASR,NDIMA,NDIMB,NDIMC,LIN,AA(KPV),&
     &            AA(KPMPA),AA(KPXPFM),AA(KM2VPA),AA(KOBSIG),AA(KOBS),  &
     &            AA(KC2PAR),AA(KBOUNC),AA(KBPART))

      ENDIF

!
!CCC WRITE OUT OBSERVATIONS &  OBS DIRECTORY IF REQUESTED
!CC      IF(LODRI) THEN
!CC          write(6,*) 'obsgen: call bod'
!CC          CALL BOD(AA,II,NM)
!CC      ENDIF
      RETURN
      END