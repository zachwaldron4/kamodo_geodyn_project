!$VEVALC
      SUBROUTINE VEVALC(Y,YD,YDD,VMATRX,P,AORN,SINLAM,COSLAM,           &
     &   TANPSI,CORPAR,VRARAY,EXPRFL,AA,II,NEQN,LFCALC,LNDRAG)
!********1*********2*********3*********4*********5*********6*********7**
! VEVALC           82/12/17            8212.0    PGMR - D. ROWLANDS
!
! FUNCTION:  CALCULATE THE VMATRX OF THE VARIATIONAL
!            EQUATIONS AND TO EVALUATE THE VARIATIONAL
!            EQUATIONS (USING THE EXPLICIT PARTIALS OF
!            ACCELERATION,AND THE VMATRX TOGETHER WITH THE
!            PARTIALS OF THE STATE VECTOR) TO CALCULATE
!            THE PARTIALS OF ACCELERATION.
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   Y        I         PARTIALS OF POSITION
!   YD       I         PARTIALS OF VELOCITY
!   YDD     I/O        PARTIALS OF ACCELERATION: NOTE
!                      THESE ARE EXPLICIT PARTIALS UPON INPUT
!                      AND COMLETE PARTIALS UPON OUTPUT
!   VMATRX  I/O        VARIATIONAL EQ MATRX (TRUE OF INTEGRATION
!                      STEP) WITHOUT GEOPOTENTIAL EFFECTS AS INPUT
!                      VARIATIONAL EQUATION MATRX (TRUE OF
!                      INTEGRATION STEP) WITH GEOPOTENTIAL EFFECTS
!                      AS OUTPUT
!   P        I         LEGENDRE POLYNOMIALS
!   AORN     I         ARRAY OF (GM/R)*(AE/R)**N
!   SINLAM   I         ARRAY OF SIN(LAMDA*M)
!   COSLAM   I         ARRAY OF COS(LAMDA*M)
!   TANPSI   I         ARRAY OF M*TAN(PSI)
!   CORPAR   I         MATRIX OF PARTIALS OF R,PSI,LAMDA
!                      WRT XYZ
!   VRARAY   I         (1-3)=ACCELERATIONS DUE TO
!                        GEOPOTENTIAL IN R,PPSI,LAMDA
!                      (4-8)=R,RSQ,XYSQ,RTXYSQ,GM/R
!                      (9-14)=BODY FIXED STATE VECTOR
!   EXPRFL   I         PARTIALS OF ACCELERATION (R,PSI,LAMDA)
!                      WRT C&S COEFFCIENTS.ALSO USED AS SCRATCH.
!   AA      I/O   A    DYNAMIC SPACE
!   II      I/O   A
!   NEQN     I         # OF FORCE MODEL EQUATIONS.
!   LFCALC   I         LOGICAL VARIABLE.IF TRUE,THEN
!                      VEVAL EVALUATES THE VARIATIONAL
!                      EQUATIONS;OTHERWISE VEVAL ONLY
!                      FORMS THE VMATRX.
!   LNDRAG   I         FALSE IF FORCE MODEL IS VELOCITY DEPENDENT
!
! COMMENTS:
!
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      PARAMETER (  NPMSA=39)
      SAVE
      COMMON/CGVTMI/NCDT,NSDT,NCPD,NSPD,NCDTA,NSDTA,NCPDA,NSPDA,NGRVTM, &
     &       KCDT,KCPDA,KCPDB,KSDT,KSPDA,KSPDB,KOMGC,KOMGS,KCOMGC,      &
     &       KSOMGC,KCOMGS,KSOMGS,NXGVTI
      COMMON/CITERL/LSTGLB,LSTARC,LSTINR,LNADJ ,LITER1,LSTITR,          &
     &              LOBORB,LRESID,LFREEZ,LSAVEF,LHALT,LADJPI,LADJCI
      COMMON/CNIGLO/MINTIM,MSATG3,MEQNG ,MEQNG3,MSATG ,MSATOB,MSATA ,   &
     &              MSATA3,MSETA ,MINTVL,MSORDR,MSORDV,NMXORD,          &
     &       MCIPV ,MXBACK,MXI   ,MPXPF ,MAXAB ,MSETDG,MXSATD,          &
     &       MXDEGS,MXDRP ,MXDRPA,MXSRP ,MXSRPA,MXGAP ,MSATDR,          &
     &       MSATSR,MSATGA,MXDRPD,MXSRPD,MXGAPD,MXBCKP,MXTPMS,          &
     &       NSTAIN,NXCNIG
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
      COMMON/CORI06/KPTRAU,KPTRUA,KNFMG ,KIPTFM,KILNFM,KIGPC ,          &
     &              KIGPS ,KIGPCA,KIGPSA,KIELMT,KMFMG ,KTPGPC,          &
     &              KTPGPS,KTPUC ,KTPUS,                                &
     &              KLINK,KPTFAU,KPTFUA,NXCI06
      COMMON/CRESPR/LRESPA,LRESPG,LRESPD,LRESPP,LRESPT
      COMMON/CRMB/RMB(9), rmb0(9)
      COMMON/CRMB2/RMB2(9), rmb02(9)
      COMMON/GEODEG/NMAX,NMAXP1,NP,NTOLD,NTOLO,NADJC,NADJS,NADJCS,      &
     &              NPMAX,NXGDEG
      COMMON/GRANI/NSUBLG,NXGRAN
      COMMON/LASTER/LASTR(2),LBINAST,NXASTR
      COMMON/LDUAL/LASTSN,LSTSNX,LSTSNY
      COMMON/MASCNI/NMASSC,NMASSS,NPMASS,ICPNTM(11475),ISPNTM(11325)
      COMMON/NLOCGR/INTEGG,IOPTLG,ICUTLG,MAXDO,NLOCAL,NLATLG,NLONLG,    &
     &              nlocgu, nlocga, nxlocg
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
      COMMON/SETAGP/NAJCA,NAJSA,NAJCG,NAJSG,NAJCT,NAJST
      COMMON/SETAPT/                                                    &
     &       JSADRG(1),JSASRD(1),JSAGA(1),JFAADJ,JTHDRG,JACBIA,JATITD,  &
     &       JDSTAT,JDTUM ,                                             &
     &       JSACS, JSATID,JSALG,JSAGM,JSAKF,JSAXYP,JSADJ2,JSAPGM,      &
     &       JFGADJ,JLTPMU,JLTPAL,JL2CCO,JL2SCO,JL2GM,JLRELT,           &
     &       JLJ2SN,JLGMSN,JLPLFM,JL2AE,JSAXTO,JSABRN
      DIMENSION Y(NEQN,3),YD(NEQN,3),YDD(NEQN,3),                       &
     &   VMATRX(3,6),P(NP),AORN(NMAX),SINLAM(NMAXP1),COSLAM(NMAXP1),    &
     &   TANPSI(NMAXP1),CORPAR(9),VRARAY(14),TEMP(3,3),VMAT(3,3),     &
     &   VMATV(3,3),EXPRFL(NP,6),AA(1),II(1)
      DIMENSION CSA(NPMSA),SSA(NPMSA)
      DIMENSION RMBH(18)
      DIMENSION VMATB(3,3)
      DIMENSION I2CPNT(25),I2SPNT(20)
      DIMENSION WORKQ(27,3)
      DATA ZERO/0.D0/,TWO/2.D0/
      DATA I2CPNT/5,6,7,10,11,12,13,16,17,18,19,20,23,24,25,26,27,28,   &
     &            31,32,33,34,35,36,37/
      DATA I2SPNT/6,7,11,12,13,17,18,19,20,24,25,26,27,28,              &
     &            32,33,34,35,36,37/
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
! CHECK FOR PROBLEM WITH ARC GEOPOTENTAL VARIATIONAL PARTIALS
      LPROB=.FALSE.
      IF(LRESPA) LPROB=.TRUE.
      LP1=NAJCA.GT.0
      LP2=NAJSA.GT.0
      IF((LP1.OR.LP2).AND.(LRESPG.OR.LRESPD.OR.LRESPP.OR.LRESPT)) THEN
        LPROB=.TRUE.
      ENDIF
      IF(LPROB) THEN
        WRITE(6,6000)
        WRITE(6,6001)
        WRITE(6,6002)
        WRITE(6,6003)
        STOP
      ENDIF
!
!  ZERO OUT 6 EXPLICIT STATE PARTIALS FIRST
      DO 600 J=1,3
      DO 600 I=1,6
  600 YDD(I,J)=ZERO
!   GET EXPLICIT PARTIALS OF MASCONS
      IF(NLOCAL.LE.0.OR.IOPTLG.LT.3) GO TO 605
      CALL RESMAS(YDD,ICPNTM,ISPNTM,AA(KSINCO),AA(KSINCO+NSUBLG),       &
     &     VRARAY,CORPAR,EXPRFL,NLOCAL,II(KPTRAU),II(KMAPLG),NEQN,      &
     &     JSALG,NMASSC,NMASSS,                                         &
     &     AA(KXM),AA(KXNP1),AA(KPN),AA(KCOSLM),AA(KSINLM),             &
     &     AA(KAORN))

  605 CONTINUE
!   GET EXPLICIT PARTIALS OF ACCEL WRT C&S ; STANDARD GLOBAL C & S
      IF(.NOT.LRESPG) GO TO 610
      NTOT=NAJCG+NAJSG
      IF(NTOT.LE.0) GO TO 610
      NSTART=JSACS+NAJCA+NAJSA
      CALL RESPAR(YDD,AA(KGPNRM),II(KICNT),II(KISNT),II(KICNT),         &
     &     II(KISNT),.FALSE.,VRARAY,                                    &
     &     CORPAR,EXPRFL,AA(KWRK),NEQN,NSTART,NSTART,NAJCG,NAJSG,       &
     &     NAJCG,NAJSG,AA(KXM),AA(KXNP1),AA(KPN),AA(KCOSLM),AA(KSINLM), &
     &     AA(KAORN))
  610 CONTINUE
! II(KICNT) should be pointing to AA(KXM),AA(KXNP1)
      IF(.NOT.LRESPT) GO TO 615
! TIME PERIOD LOCAL GRAVITY
      NTOT=NAJCT+NAJST
      IF(NTOT.LE.0) GO TO 615
      NSTART=JSACS+NAJCA+NAJSA
      NSTRTT=JSACS+NAJCA+NAJSA+NAJCG+NAJSG
      CALL RESPAR(YDD,AA(KGPNRM),II(KICNTT),II(KISNTT),II(KICNTP),      &
     &     II(KISNTP),.TRUE.,VRARAY,                                    &
     &     CORPAR,EXPRFL,AA(KWRK),NEQN,NSTRTT,NSTART,NAJCT,NAJST,       &
     &     NAJCG,NAJSG,AA(KXM),AA(KXNP1),AA(KPN),AA(KCOSLM),AA(KSINLM), &
     &     AA(KAORN))
  615 CONTINUE
      IF(.NOT.LRESPA) GO TO 620
! ARC GEOPTENTIAL
      NTOT=NAJCA+NAJSA
      IF(NTOT.LE.0) GO TO 620
      CALL RESPAR(YDD,AA(KGPNRA),II(KICNTA),II(KISNTA),II(KICNT),       &
     &            II(KISNT),.FALSE.,VRARAY,CORPAR,                      &
     &            EXPRFL,AA(KWRK),NEQN,JSACS,JSACS,NAJCA,NAJSA,NAJCA,   &
     &            NAJSA,AA(KXM),AA(KXNP1),AA(KPN),AA(KCOSLM),AA(KSINLM),&
     &            AA(KAORN))
  620 CONTINUE
      IF(.NOT.LRESPD) GO TO 630
! C & S DOT
!
! COMPUTE CONTRIBUTION DUE TO C&S DOT TERMS
      NSTART=JSACS+NAJCA+NAJSA+NAJCG+NAJSG+NAJCT+NAJST
! DEBUG WEI
!     PRINT 19000,NSTART,JSACS,KIPTC,KIPTS
!9000 FORMAT(1X,'NSTART,JSACS,KIPTC,KIPTS:',4I15)
! DEBUG WEI
      CALL RESPDT(YDD,VRARAY,CORPAR,EXPRFL,AA(KWRK),NEQN,NSTART,        &
     &            II(KIPTC),II(KIPTS),AA(KXM),AA(KXNP1),AA(KPN),        &
     &            AA(KCOSLM),AA(KSINLM),AA(KAORN))
  630 CONTINUE
      IF(.NOT.LRESPP) GO TO 640
! PERIODIC   C & S
!
! COMPUTE CONTRIBUTION DUE TO C&S PERIODIC TERMS
      NSTART=JSACS+NAJCA+NAJSA+NAJCG+NAJSG+NAJCT+NAJST+NCDTA
! DEBUG WEI
!     PRINT 19200,KIPTC,NCDTA,KIPTS,NSDTA,KCOMGC,KSOMGC,KCOMGS,KSOMGS
!9200 FORMAT(1X,'KIPTC,NCDTA,KIPTS,NSDTA,KCOMGC,KSOMGC,KCOMGS,KSOMGS'/
!    1       1X,8I10)
! DEBUG WEI
      CALL RESPPD(YDD,VRARAY,CORPAR,EXPRFL,AA(KWRK),NEQN,NSTART,        &
     &     II(KIPTC+NCDT),II(KIPTS+NSDT),AA(KCOMGC),AA(KSOMGC),         &
     &            AA(KCOMGS),AA(KSOMGS),AA(KXM),AA(KXNP1),AA(KPN),      &
     &            AA(KCOSLM),AA(KSINLM),AA(KAORN))
  640 CONTINUE
!    IF DYNAMIC POLAR MOTION IS APPLIED CERTAIN (ADJUSTED) PARAMETERS
!    WILL HAVE PARTIALS WITH CONTRIBUTIONS FROM THIS EFFECT. CALL DYNPMP
!    TO CALCULATE THESE CONTRIBUTIONS.
      IF(LSADPM) CALL DYNPMP(EXPRFL,YDD,NEQN,AA(KCN),CORPAR,            &
     &                       VRARAY,AA(KXM),AA(KXNP1),P,COSLAM,         &
     &                       SINLAM,AORN)
!
!   GET  CONTRIBUTION TO VARIATIONAL MATRX FROM GEOPOTENTIAL
!
      DO IQ=1,9
        VMATB(IQ,1)=0.D0
      ENDDO
      CALL GVMAT(VMATRX,P,AORN,SINLAM,COSLAM,TANPSI,CORPAR,             &
     &           VRARAY,VMATB,EXPRFL,AA(KCN),AA(KSN),AA)
!
! IF PLANET ORIENTATION PARAMETERS ARE BEING SOLVED FOR USE
! THE BODY FIXED CARTESIAN GROPOTENTIAL VMAT TO GET THEIR
! EXPLCIT PARTIALS
      IF(LSTINR.AND.NPVAL0(IXXTRO).GT.0) THEN
         CALL EXPLOR(VMATB,NEQN,YDD,CORPAR,VRARAY,AA(KANGWT),AA(KWT),   &
     &               AA(KPPER),1)
      ENDIF
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!  START GVMAT AND EXPLOR CALLS FOR SECONDARY ASTEROID
      IF(LBINAST) THEN
         NGH1=NMAX
         NGH2=NMAXP1
         NGH3=NP
         NTOLDH=NTOLD
         NTOLD=3
         NUP=NPVAL(IX2CCO)
         ITEST=NMAX
         NMAX=6
         IF(ITEST.LT.NMAX) NMAX=ITEST
         NMAXP1=NMAX+1
         NP=NMAX*NMAXP1/2+3*NMAX
         DO IQP=1,18
          RMBH(IQP)=RMB(IQP)
          RMB(IQP)=RMB2(IQP)
         ENDDO
         DO IQP=1,NUP
           CSA(IQP)=AA(KPRMV-2+IPVAL(IX2CCO)+IQP)
           SSA(IQP)=AA(KPRMV-2+IPVAL(IX2SCO)+IQP)
         ENDDO
!
!
!  FORCE MODE PARTIALS FOR ARTIFICIAL SAT WRT 2ND AST C & S
!
      IF(LSTINR.AND.(NPVAL0(IX2CCO).GT.0.OR.NPVAL0(IX2SCO).GT.0)) THEN
        CALL CHK2GA(NEQN,NSTRT2,NADJC2,NADJS2)
        NADCSH=NADJCS
        NADJCS=27
        CALL RESPAR(YDD,AA(KGPNRM),I2CPNT,I2SPNT,I2CPNT,                &
     &     I2SPNT,.FALSE.,VRARAY(15),                                   &
!!!  &     CORPAR(10),EXPRFL(6*NGH3+1,1),AA(KWRK),NEQN,                 &
     &     CORPAR(10),EXPRFL(6*NGH3+1,1),WORKQ,NEQN,                    &
     &     NSTRT2,NSTRT2,NADJC2,NADJS2,                                 &
     &     NADJC2,NADJS2,AA(KXM),AA(KXNP1),P(1+NGH3),                   &
!!!  &     COSLAM(1+NGH2),SINLAM(1+NGH2),AORN(1+NGH1))
     &     AA(KCOSLM+NGH2),AA(KSINLM+NGH2),AA(KAORN+NGH1))
        NADJCS=NADCSH
      ENDIF
!
!      GET  CONTRIBUTION TO VARIATIONAL MATRX FROM GEOPOTENTIAL
!
      DO IQ=1,9
        VMATB(IQ,1)=0.D0
      ENDDO
         CALL GVMAT(VMATRX,P(1+NGH3),AORN(1+NGH1),SINLAM(1+NGH2),       &
                    COSLAM(1+NGH2),TANPSI(1+NGH2),CORPAR(10),           &
     &              VRARAY(15),VMATB,EXPRFL(6*NGH3+1,1),CSA,SSA,AA)

!    IF PLANET ORIENTATION PARAMETERS ARE BEING SOLVED FOR USE
!    THE BODY FIXED CARTESIAN GROPOTENTIAL VMAT TO GET THEIR
!    EXPLCIT PARTIALS
         IF(LSTINR.AND.NPVAL0(IXXTRO).GT.0) THEN
            CALL EXPLOR(VMATB,NEQN,YDD,CORPAR(10),VRARAY(16),AA(KANGWT),&
     &                  AA(KWT),AA(KPPER),2)
         ENDIF
         NMAX=NGH1
         NMAXP1=NGH2
         NP=NGH3
         NTOLD=NTOLDH
         DO IQP=1,18
          RMB(IQP)=RMBH(IQP)
         ENDDO
      ENDIF
!  END GVMAT AND EXPLOR CALLS FOR SECONDARY ASTEROID
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      IF(.NOT.LFCALC) RETURN
! CALCULATE YDD
      DO 970 J=1,3
      DO 970 I=1,NEQN
      YDD(I,J)=YDD(I,J)+VMATRX(J,1)*Y(I,1)                              &
     &        +VMATRX(J,2)*Y(I,2)+VMATRX(J,3)*Y(I,3)
  970 CONTINUE
      IF(LNDRAG) RETURN
      DO 980 J=1,3
      DO 980 I=1,NEQN
      YDD(I,J)=YDD(I,J)+VMATRX(J,4)*YD(I,1)                             &
     &        +VMATRX(J,5)*YD(I,2)+VMATRX(J,6)*YD(I,3)
  980 CONTINUE
      RETURN
 6000 FORMAT(' EXECUTION TERMIATING IN VEVALC')
 6001 FORMAT(' ARC GEOPOTENTIAL BEING ADJUSTED')
 6002 FORMAT(' ARC GEOPOTENTIAL VARIATIONAL POINTERS')
 6003 FORMAT(' ARE NOT CORRECT')
      END
