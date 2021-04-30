!$SUMCMP
      SUBROUTINE SUMCMP(AA,II,LL,ISAT,MJDS0,FSEC0,MJDSCV,FSECV,HV,      &
     &                  MJDSEC,FSEC,H,NEQN,NSAT,PARMVC,NRATE,           &
     &                  RATE)
!********1*********2*********3*********4*********5*********6*********7**
! SUMCMP           00/00/00            0000.0    PGMR - ?
!
! FUNCTION:  GET THE QUANTITIES IN ARRAY RATE FOR SUMMARY PAGE
!
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   AA      I/O        DYNAMIC REAL SPACE
!   II      I/O        DYNAMIC INTEGER SPACE
!   LL      I/O        DYNAMIC LOGICAL SPACE
!   ISAT     I         SATELLITE NUMBER IN ARC
!   MJDS0    I         EPOCH INTEGER SECONDS ARRAY
!   FSEC0    I         EPOCH FRACTIONAL SECON@S ARRAY
!   MJDSCV   I         INTEGER SECONDS VARIATIONAL TIME ARRAY
!   FSECV    I         FRACTIONAL SECONDS VARIATIONAL TIME ARRAY
!   HV       I         VARIATIONAL STEP SIZE ARRAY
!   MJDSEC   I         INTEGER SECONDS ORBIT TIME ARRAY
!   FSEC     I         FRACTIONAL SECONDS ORBIT TIME ARRAY
!   H        I         ORBIT STEP SIZE ARRAY
!   NEQN     I         NUMBER FORCE MODEL EQ ARRAY
!   NSAT     I         NUMBER OF SATELLITES IN SET ARRAY
!   PARMVC   I         UPDATED ADJUSTED PARAMETER ARRAY
!   NRATE    O         NUMBER OF ELEMENTS IN RATE ARRAY (5 OR 8)
!   RATE(1)  O         APOGEE                 (METERS)
!   RATE(2)  O         NODE RATE              (DEG/DAY)
!   RATE(3)  O         PERIGEE                (METERS)
!   RATE(4)  O         ARG PERIGEE RATE       (DEG/DAY)
!   RATE(5)  O         PERIOD                 (MINUTES)
!   RATE(6)  O         PERIOD RATE            (SEC/DAY)
!   RATE(7)  O         DRAG                   (M/DAY**2)
!   RATE(8)  O         SEMI MAJOR AXIS RATE   (M/DAY)
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE

      INCLUDE 'COMMON_DECL.inc'

      COMMON/IOS/ISTOS1,ISTOS2,ISTOS3,ISTLST,INTSUB(3),JNTSUB(3),      &
     &        ILSTSG(80),INTOSP,MAPSAT(3,4)
      COMMON/CGRAV/GM,AE,AESQ,FE,FFSQ32,FSQ32,XK2,XK3,XLAM,SIGXK2,      &
     &      SIGXK3,SIGLAM,RATIOM(2),AU,RPRESS
      COMMON/CNIARC/NSATA,NSATG,NSETA,NEQNG,NMORDR,NMORDV,NSORDR,       &
     &              NSORDV,NSUMX,NXDDOT,NSUMPX,NPXDDT,NXBACK,NXI,       &
     &              NXILIM,NPXPF,NINTIM,NSATOB,NXBCKP,NXTIMB,           &
     &              NOBSBK,NXTPMS,NXCNIA
      COMMON/CNIGLO/MINTIM,MSATG3,MEQNG ,MEQNG3,MSATG ,MSATOB,MSATA ,   &
     &              MSATA3,MSETA ,MINTVL,MSORDR,MSORDV,NMXORD,          &
     &       MCIPV ,MXBACK,MXI   ,MPXPF ,MAXAB ,MSETDG,MXSATD,          &
     &       MXDEGS,MXDRP ,MXDRPA,MXSRP ,MXSRPA,MXGAP ,MSATDR,          &
     &       MSATSR,MSATGA,MXDRPD,MXSRPD,MXGAPD,MXBCKP,MXTPMS,          &
     &       NSTAIN,NXCNIG
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
      COMMON/CORI02/KNTIME,KMJSTB,KMJSTC,KMJSTE,KISECT,                 &
     &              KINDH ,KNMH  ,KIVSAT,KIPXPF,KNTRTM,KMSTRC,          &
     &              KMSTRE,KISCTR,KISATR,KITRUN,KTRTMB,KTRTMC,          &
     &              KMJDVS,KNTMVM,NXCI02
      COMMON/LASTER/LASTR(2),LBINAST,NXASTR
      COMMON/LDUAL/LASTSN,LSTSNX,LSTSNY
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
      COMMON/SETADJ/LSADRG(4),LSASRD(4),LSAGA(4),LSAGP,LSATID,LSAGM,    &
     &              LSADPM,LSAKF,LSADNX,LSADJ2,LSAPGM
      COMMON/SETAPT/                                                    &
     &       JSADRG(1),JSASRD(1),JSAGA(1),JFAADJ,JTHDRG,JACBIA,JATITD,  &
     &       JDSTAT,JDTUM ,                                             &
     &       JSACS, JSATID,JSALG,JSAGM,JSAKF,JSAXYP,JSADJ2,JSAPGM,      &
     &       JFGADJ,JLTPMU,JLTPAL,JL2CCO,JL2SCO,JL2GM,JLRELT,           &
     &       JLJ2SN,JLGMSN,JLPLFM,JL2AE,JSAXTO,JSABRN
      COMMON/SETIOR/IORDRG,IORSRD,IORGA,IPDDRG,IPDSRD,IPDGA
      COMMON/SETOPT/LSDRG,LSSRD,LSGA,LSORB,LTHDRG,LROCK4
      COMMON/SETPPT/JSPDRG(3),JSPSRD(3),JSPGA(3),JCSAT
      COMMON/STARTT/ESSTRT,FSSTRT
      COMMON/XEPHL2/  L_call_sumcmp   ! jjm 20150413
      DIMENSION AA(1),II(1),LL(1),                                      &
     &          NEQN(1),MJDSCV(1),FSECV(1),HV(1),TIMEOC(1),             &
     &          DRGPAR(6),ORBELA(6),PARMVC(1),                          &
     &          MJDSEC(1),FSEC(1),H(1),MJDS0(1),FSEC0(1),ELEMS(6),      &
     &          ELEMST(6),XLHAT(3),RATE(8),OUTPUT(8),NSAT(1)
      DATA ZERO/0.D0/,X1DM3/1.D-3/,ONE/1.D0/,X1P5/1.5D0/,TWO/2.D0/,     &
     &     P1/.1D0/
!     EQUIVALENCE (OUTPUT(1),APHT),(OUTPUT(2),PEHT),(OUTPUT(3),PRDMIN),
!    .            (OUTPUT(4),DL),(OUTPUT(5),RANDOT),(OUTPUT(6),PERDOT),
!    .            (OUTPUT(7),DT),(OUTPUT(8),ARATE)
      EQUIVALENCE (OUTPUT(1),APHT),(OUTPUT(2),RANDOT),(OUTPUT(3),PEHT), &
     &            (OUTPUT(4),PERDOT),(OUTPUT(5),PRDMIN),(OUTPUT(6),DT), &
     &            (OUTPUT(7),DL),(OUTPUT(8),ARATE)
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
      L_call_sumcmp = .TRUE.
      IF(LASTSN.AND.ISAT.LE.1) RETURN
      IF(LBINAST.AND.ISAT.LE.2) RETURN

!CC   WRITE(6,*) 'SUMCMP: ENTRY'
      DO 10 I=1,8
      OUTPUT(I)=ZERO
   10 END DO
!  DETERNINE TO WHICH SET SATELLITE BELONGS AND WHICH SATELLITE IT
!    IS IN THE SET
      NSATC=0
      DO 20 JSET=1,NSETA
      NSATC=NSATC+NSAT(JSET)
      IF(ISAT.LE.NSATC) GO TO 50
   20 END DO
   50 CONTINUE
!CC   WRITE(6,*) 'SUMCMP: AFTER 50'
      ISET=JSET
      ISATIS=ISAT-(NSATC-NSAT(ISET))
! DETERMINE TIME THAT WILL BE USED TO GET DRAG INFORMATION
! MAKE SURE INTEGRATOR DOES NOT GET CALLED
      MJDOC=MJDSCV(ISET)
      TIMEOC(1)=FSECV(ISET)-TWO*HV(ISET)
      XTMV=DBLE(MJDSCV(ISET))+FSECV(ISET)-TWO*HV(ISET)
      XTMO=DBLE(MJDSEC(ISET))+FSEC(ISET)-TWO*H(ISET)
      UTM=MIN(XTMV,XTMO)
      IF(UTM.NE.XTMV) GO TO 60
      MJDOC=MJDSEC(ISET)
      TIMEOC(1)=FSEC(ISET)-TWO*H(ISET)
   60 CONTINUE
!CC   WRITE(6,*) 'SUMCMP: AFTER 60'
      DSKRET=P1*MIN(H(ISET),HV(ISET))
!  CALL ORBIT TO GET INTEGRATED PARTIALS FOR CD AND TO GET FORCE MODEL
!  COMMON BLOCKS FOR THE SET OF INTEREST
      II(KIVSAT)=ISAT
      DO 70 I=1,NSETA
      IPT=KLSETS+I-1
      LL(IPT)=.FALSE.
   70 END DO
      LL(KLSETS+ISET-1)=.TRUE.

      ISATID=II(KISATN-1+ISET)
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

      CALL ORBIT(MJDOC,TIMEOC,AA(KS),1,II(KINDH),II(KNMH),              &
     &           II(KMJDSC),AA(KFSEC),MJDSCV,FSECV,                     &
     &           LL(KLSETS),II(KIPXPF),II(KIVSAT),1,II(KNMAX),          &
     &           II(KNTOLD),AA(KXTN),AA(KPXPFM),.FALSE.,.FALSE.,        &
     &           II(KPLPTR),II(KPANEL),II(KNMOVE),                      &
     &           AA(KTPMES),LL(KLTPMS),LL(KSETDN),                      &
     &   AA(KTMOS0-1+INTOSP),AA(KTMOS-1+INTOSP),AA(KTMOSP-1+INTOSP),    &
     &   AA(KSMXOS-1+KSUMXOS),AA(KSMXOS-1+KSUMPOS),AA(KSMXOS-1+KXDDTOS),&
     &   AA(KSMXOS-1+KPDDTOS),KNSTEPS,NEQNI,II(KSGMNT-1+IRET),          &
     &   AA(KSGTM1-1+IRET),AA(KSGTM2-1+IRET),AA,II,LL)
!CC   WRITE(6,*) 'SUMCMP: AFTER ORBIT'
!
      DO 75 I=1,3
      JPTX=KXTN+(I-1)*MINTIM
      JPTV=KVTN+(I-1)*MINTIM
      ELEMS(I)=AA(JPTX)
      ELEMS(I+3)=AA(JPTV)
   75 END DO
!CC   WRITE(6,*) 'SUMCMP: AFTER 75'
!
      ESSTRT=MJDS0(ISET)+FSEC0(ISET)
      FSSTRT=UTM-ESSTRT
      DSSTRT=FSSTRT/SECDAY
      IEQN=NEQN(ISET)
! DEBUG PRINTS
!CC   WRITE(6,*) 'IN SUMCMP: IPVAL0 ', (IPVAL0(IJJ),IJJ=1,41)
!CC   WRITE(6,*) 'IN SUMCMP: PARMVC ', (PARMVC(IPVAL0(IJJ)),IJJ=1,41)
!  DECIDE IF DRAG HAS BEEN ADJUSTED;IF NOT SKIP SOME CODE
      LCDA=LSADRG(1).OR.(LSADRG(4).AND.IORDRG.EQ.1)
      IF(LCDA) THEN
!        EXTRACT THE CD PARTIAL OUT OF AA(KPXPFM)
         IPT=KPXPFM+JSADRG(1)-1
         IPD=0
         IF(.NOT.LSADRG(4)) GO TO 120
!        FIGURE WHICH PERIOD APPLIES
         ISTDRG=JSPDRG(3)+(ISATIS-1)*IPDDRG-1
         DO 115 I=1,IPDDRG
         IF(UTM.LT.AA(ISTDRG-1)) GO TO 116
  115   CONTINUE
         IPD=0
         GO TO 120
  116   CONTINUE
         IPD=I
  120   CONTINUE
         IPT=IPT+IPD
         IVPT=IPT
         DRGPAR(1)=AA(IPT)
         IPT=IPT+IEQN
         DRGPAR(2)=AA(IPT)
         IPT=IPT+IEQN
         DRGPAR(3)=AA(IPT)
         TIMEOC(1)=TIMEOC(1)+DSKRET
         CALL ORBIT(MJDOC,TIMEOC,AA(KS),1,II(KINDH),II(KNMH),           &
     &           II(KMJDSC),AA(KFSEC),MJDSCV,FSECV,                     &
     &           LL(KLSETS),II(KIPXPF),II(KIVSAT),1,II(KNMAX),          &
     &           II(KNTOLD),AA(KXTN),AA(KPXPFM),.FALSE.,.FALSE.,        &
     &           II(KPLPTR),II(KPANEL),II(KNMOVE),                      &
     &           AA(KTPMES),LL(KLTPMS),LL(KSETDN),                      &
!orig &   AA(KTMOS0-1+INTOSP),AA(KTMOS-1+INTOSP),AA(KTMOSP-1+INOSP),    &
! jjm 20120531 changed "INOSP" to "INTOSP" below
     &   AA(KTMOS0-1+INTOSP),AA(KTMOS-1+INTOSP),AA(KTMOSP-1+INTOSP),    &
     &   AA(KSMXOS-1+KSUMXOS),AA(KSMXOS-1+KSUMPOS),AA(KSMXOS-1+KXDDTOS),&
     &   AA(KSMXOS-1+KPDDTOS),KNSTEPS,NEQNI,II(KSGMNT-1+IRET),          &
     &   AA(KSGTM1-1+IRET),AA(KSGTM2-1+IRET),AA,II,LL)
         IPT=IVPT
         DRGPAR(4)=AA(IPT)
         IPT=IPT+IEQN
         DRGPAR(5)=AA(IPT)
         IPT=IPT+IEQN
         DRGPAR(6)=AA(IPT)
         DRGPAR(4)=(DRGPAR(4)-DRGPAR(1))/DSKRET
         DRGPAR(5)=(DRGPAR(5)-DRGPAR(2))/DSKRET
         DRGPAR(6)=(DRGPAR(6)-DRGPAR(3))/DSKRET
!     DETERMINE CD AT THE END OF THE RUN
         IDRGPT=IPVAL0(IXDRAG)
!     DETERMINE POINTER AT START OF SET
         IF(ISET.EQ.1) GO TO 250
         IUPSET=ISET-1
         DO 200 I=1,IUPSET
         IDRGPT=IDRGPT+(II(KJSAFR+(I-1)*22+1)-7)*NSAT(I)
  200   CONTINUE
  250   CONTINUE
!     DETERMINE POINTER AT SATELLITE IN SET
         IDRGPT=IDRGPT+(II(KJSAFR+ISET*22+1)-7)*(ISATIS-1)
         IPD=0
         IF(IPDDRG.LE.0) GO TO 320
!     FIGURE WHICH PERIOD APPLIES
         ISTDRG=JSPDRG(3)+(ISATIS-1)*IPDDRG-1
         DO 315 I=1,IPDDRG
         IF(UTM.LT.AA(ISTDRG-1)) GO TO 316
  315   CONTINUE
         IPD=0
         GO TO 320
  316   CONTINUE
         IPD=I
  320   CONTINUE
         CD=PARMVC(IDRGPT+IPD)
      ENDIF
  500 CONTINUE
!CC   WRITE(6,*) 'SUMCMP: AFTER 500'
!
!
! IF GM IS ADJUSTED SET GMA TO ADJUSTED VALUE
      GMA=GM
      IF(NPVAL0(IXGM).GT.0) GMA=PARMVC(IPVAL0(IXGM))

! IF FE IS ADJUSTED SET FEA TO INVERSE OF ADJUSTED VALUE
      FEA=FE
      IF(NPVAL0(IXFLTP).GT.0) FEA=ONE/PARMVC(IPVAL0(IXFLTP))


! IF AE IS ADJUSTED SET AEA TO ADJUSTED VALUE
      AEA=AE
      IF(NPVAL0(IXSMA).GT.0) AEA=PARMVC(IPVAL0(IXSMA))


! GET ADJUSTED KEPLERIAN ELEMENTS & CARTESIAN
!CC   WRITE(6,*) 'SUMCMP: BEFORE 520 LOOP'
      DO 520 I=1,6
      IKPT=KCKEP+6*(ISAT-1)+I-1
      ICPT=KXEPOC+6*(ISAT-1)+I-1
      ORBELA(I)=AA(IKPT)
      ELEMST(I)=AA(ICPT)
  520 END DO
!CC   WRITE(6,*) 'SUMCMP: AFTER 520 LOOP'
! CALCULATE APOGEE AND PERIGEE HT
      FSQ32=X1P5*AEA*FEA**2
      FFSQ32=AEA*FEA+FSQ32
      SPSISQ=SIN(ORBELA(3)*DEGRAD)*SIN(ORBELA(5)*DEGRAD)
!      SPSISQ=SPSISQ**2
!CC   WRITE(6,*) 'SUMCMP: AFTER FF SPS CALCULATION'
! CALCULATE THE EARTH RADIUS TO THE CIRCLE OF INTERSECTION OF THE
! SATELLITE SEMI-MAJOR AXIS WITH THE SPHEROID
      EARTH=AEA+FFSQ32*SPSISQ-FSQ32*SPSISQ**2
!      EARTH=AEA+FSQ32*SPSISQ**2-FFSQ32*SPSISQ
      AESAT=ORBELA(1)*ORBELA(2)
! DEBUG PRINTS
!CC   WRITE(6,*) 'IN SUMCMP: BEFORE CALCULATION OF APOGEE AND PERIGEE'
! CALCULATE THE APOGEE AND PERIGEE DISTANCES
! SUBTRACT OUT THE EARTH RADIUS TO CALCULATE APOGEE AND PERIGEE
! HEIGHTS
      PEHT=(ORBELA(1)-AESAT-EARTH)
      APHT=(ORBELA(1)+AESAT-EARTH)
! INITIALIZATION OF DL, DT, AND ARATE
        DL=ZERO
        DT=ZERO
        ARATE=ZERO
      IF(LCDA) THEN
  530   CONTINUE
        RV=ELEMS(1)*ELEMS(4)+ELEMS(2)*ELEMS(5)+ELEMS(3)*ELEMS(6)
        VSQ=ELEMS(4)*ELEMS(4)+ELEMS(5)*ELEMS(5)+ELEMS(6)*ELEMS(6)
        RSQ=ELEMS(1)*ELEMS(1)+ELEMS(2)*ELEMS(2)+ELEMS(3)*ELEMS(3)
        D=SQRT(VSQ-RV**2/RSQ)
        DO 550 J=1,3
  550   XLHAT(J)=(-RV*ELEMS(J)/RSQ+ELEMS(J+3))/D
        DL=XLHAT(1)*DRGPAR(1)+XLHAT(2)*DRGPAR(2)+XLHAT(3)*DRGPAR(3)
        DL=DL*CD/DSSTRT**2
      ENDIF ! LCDA

  575 continue
      !write(6,'(A)') 'sumcmp: after 575 '

      AEA35=(AEA/ABS(ORBELA(1)))**3.5/(ONE-ORBELA(2)**2)**2

      !write(6,'(A, 1x, E20.10)') 'sumcmp: AEA35 ', AEA35

      COSI=COS(ORBELA(3)*DEGRAD)
      RANDOT=-9.97D0*AEA35*COSI
      PERDOT=4.98D0*AEA35*(5.0D0*COSI**2-1.0D0)
      IF(LCDA) THEN
        PEREND=TWOPI*SQRT(ABS(ORBELA(1))**3/GMA)
        DP1=ELEMS(1)*DRGPAR(1)+ELEMS(2)*DRGPAR(2)+ELEMS(3)*DRGPAR(3)
        DP2=ELEMS(4)*DRGPAR(4)+ELEMS(5)*DRGPAR(5)+ELEMS(6)*DRGPAR(6)
        DT=PEREND*3.0D0*ORBELA(1)*CD*(DP1/(SQRT(RSQ)*RSQ)+DP2/GMA)
        DT=DT/DSSTRT
        ARATE=2.0D0*ORBELA(1)*DT/(3.0D0*PEREND)
      ENDIF ! LCDA

  600 CONTINUE
!CC   WRITE(6,*) 'SUMCMP: AFTER 600 '
      PRD=TWOPI*SQRT(ABS(ORBELA(1))**3/GMA)
      PRDMIN=PRD/60.0D0
      NRATE=8
        DO 1000 I=1,8
        RATE(I)=OUTPUT(I)
 1000   CONTINUE
        RETURN
      END