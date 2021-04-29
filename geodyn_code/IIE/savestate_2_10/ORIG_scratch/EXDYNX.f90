!$EXDYNX
      SUBROUTINE EXDYNX(NU,NU1,ND1,ISAT1,ISET1,ISAT2,ISET2,AA,II,LL,    &
     &                  XTD,XTP,XMP,PMPA,PXEPXI,NEQN,N3,IPTFMG,ILNFMG,  &
     &                  NFMG,PXEPA,ACOEF,MJDSC1,MJDSC2,T1EST,T2EST,     &
     &                  FSEC1,FSEC2,AUX1,                               &
     &                  TIME1,TIME2,DDDA,NDM1,NDM2,TAT1,                &
     &                  IPAT11,IPAT12,TAT2,IPAT21,IPAT22,SUM1,SUM2,     &
     &                  OBSSIG,X2VSPR,NDMX1,NDMX2,NDMX3,X2SPA,          &
     &                  RESID,ATPER,NM,NM1,T11,T12,T21,T22,LRESD,LED,   &
     &                  KEY,LSTIT,PPARM,PDELTA)
!***********************************************************************
!
! PURPOSE: FORM THE CONSTRAINT EQUATION ASSOCIATED WITH A DYNAMIC CROSSO
!
!          NU     -  NUMBER OF POINTS USED FROM EACH STREAM (ASCENDING &
!                    DESCENDING) TO DETERMINE MINIMUM DISTANCE
!          NU1    -  NU+1
!          ND1    -  DEGREE +1 OF POLYNOMIAL USED TO FIT ASCENDING &
!                    DESCENDING STREAMS (QUADRATIC ; ND1=3)
!          ISAT1  -  INTERNAL SATELLITE NUMBER ASSOCIATED WITH FIRST STR
!          ISET1  -  SATELLITE SET NUMBER ASSOCIATED WITH FIRST STREAM
!          ISAT2  -  INTERNAL SATELLITE NUMBER ASSOCIATED WITH SECOND ST
!          ISET2  -  SATELLITE SET NUMBER ASSOCIATED WITH SECOND STREAM
!          AA     -  DYNAMIC FLOATING POINT ARRAY
!          II     -  DYNAMIC INTEGER ARRAY
!          LL     -  DYNAMIC LOGICAL ARRAY
!          XTD    -  SCRATCH SPACE DIMENSIONED MINTIM*3
!          XTP    -  SCRATCH SPACE DIMENSIONED MINTIM*3
!          XMP    -  SCRATCH SPACE DIMENSIONED MINTIM*3
!          PMPA   -  ARRAY OF PARTIALS OF MEASUREMENTS OR CONSTRAINTS WR
!                    ADJUSTING PARAMTERS (SCRATCH SPACE)
!          PXEPXI -  ARRAY OF PARTIALS OF EARTH FIXED COORDINATES OF STR
!                    WRT INERTIAL TRUE OF REFERENCE COORDINATES OF SATEL
!                    (SCRATCH SPACE)
!          NEQN   -  ARRAY WITH NUMBER OF ADJUSTING FORCE MODEL PARAMETE
!                    FOR EACH SATELLITE SET
!          N3     -  ARRAY WITH 3*NUMBER OF SATS FOR EACH SATELLITE SET
!          IPTFMG -  POINTER TO STARTING LOCATIONS OF ADJUSTING FORCE
!                    MODEL PARAMETER GROUPS IN THE SET OF ALL ADJUSTING
!                    PARAMETERS (FOR EACH SATELLITE)
!          ILNFMG -  NUMBER OF ADJUSTING FORCE MODEL PARAMETERS IN EACH
!                    FORCE MODEL GROUP (FOR EACH SATELLITE)
!          NFMG   -  NUMBER OF FORCE MODEL PARAMETERS GROUPS FOR (EACH
!                    SATELLITE)
!          PXEPA   - SRATCH ARRAY USED FOR EACH EARTH FIXED COORDINATE O
!                    STREAM TO FORM THE PARTIAL OF THE COORDINATE WRT EA
!                    ADJUSTING PARAMETER
!          ACOEF   - SCRATCH ARRAY USED TO HOLD COEFFICIENTS OF 6 POLYNO
!                    DESCRIBING THE STREAM OF EACH CEARTH FIXED COORDIAT
!                    ALSO HOLDS THE PARTIAL OF EACH COEFFICIENT WRT EACH
!                    COORDINATE IN THE STREAM
!          MJDSC1  - TIME IN INTEGER SECONDS FROM (2430000.5) TO START O
!                    FIRST STREAM
!          MJDSC2  - TIME IN INTEGER SECONDS FROM (2430000.5) TO START O
!                    SECOND STREAM
!          T1EST   - ESTIMATE OF TIME TAG (IN ELAPSED SECONDS FROM MJDSC
!                    AT POINT IN FIRST STREAM WHICH IS CLOSEST TO SECOND
!                    STREAM (THIS WILL BE REFINED DURING THIS CALL).
!          T2EST   - ESTIMATE OF TIME TAG (IN ELAPSED SECONDS FROM MJDSC
!                    AT POINT IN SECOND STREAM WHICH IS CLOSEST TO FIRST
!                    STREAM (THIS WILL BE REFINED DURING THIS CALL).
!          FSEC1   - TIME TAGS OF FIRST STREAM (MJDSC1+FSEC1)
!          FSEC2   - TIME TAGS OF SECOND STREAM (MJDSC2+FSEC2)
!          TIME1   - SCRATCH ARRAY TO HOLD TIME TAGS OF FIRST STREAM
!          TIME2   - SCRATCH ARRAY TO HOLD TIME TAGS OF SECOND STREAM
!          DDDA    - SCRATCH ARRAY TO HOLD PARTIALS OF MINIMUM DISTANCE
!                    (BETWEEN STREAMS) WRT POLYNOMIAL COEFFICIENTS OF
!                    EACH STREAM
!          NDM1    - FIRST DIMENSION OF PXEPA ARRAY (ABOVE) ; NADJST IF
!                    LNPNM=TRUE ; NUCON OTHERWISE
!          NDM2    - SECOND DIMENSION OF PXEPA ARRAY (ABOVE) ; NUCON IF
!                    LNPNM=TRUE ; NADJST OTHERWISE
!          TAT1    - TIME TAG ASSOCIATED WITH TIME DEPENDENT ATTITUDE
!                    PARAMETERS OF FIRST STREAM
!          IPAT11  - STARTING LOCATION IN IN ADJUSTED PARAMETER ARRAY OF
!                    ATTITUDE PARAMTERS OF SATELLITE OF FIRST STREAM (0
!                    IF NO ADJUSTMENT)
!          IPAT12  - STARTING LOCATION IN IN ADJUSTED PARAMETER ARRAY OF
!                    ATTITUDE PARAMTERS OF INSTRUMENT OF FIRST STREAM (0
!                    IF NO ADJUSTMENT)
!          TAT2    - TIME TAG ASSOCIATED WITH TIME DEPENDENT ATTITUDE
!                    PARAMETERS OF SECOND STREAM
!          IPAT21  - STARTING LOCATION IN IN ADJUSTED PARAMETER ARRAY OF
!                    ATTITUDE PARAMTERS OF SATELLITE OF SECOND STREAM (0
!                    IF NO ADJUSTMENT)
!          IPAT22  - STARTING LOCATION IN IN ADJUSTED PARAMETER ARRAY OF
!                    ATTITUDE PARAMTERS OF INSTRUMENT OF SECOND STREAM (
!                    IF NO ADJUSTMENT)
!          SUM1    - NORMAL MATRIX
!          SUM2    - RHS OF NORMAL EQUATIONS
!          OBSSIG  - WEIGHT OF CROSSOVER CONSTRAINT EQUATION
!          XSCR1   - FRACTIONAL TIMES FOR STREAM 1 ALL OBS
!          XSCR2   - FRACTIONAL TIMES FOR STREAM 2 ALL OBS
!
!
!***********************************************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      CHARACTER*6 EDC
      CHARACTER*6 CLAND
      CHARACTER*2 AD
      SAVE
!
! WATCH OUT IF CBLOKI IS ADDED (NM IS RESET)
      COMMON/ATTCB /KPAT,MAXAT,MAXLAS,IBLAS,                            &
     &              NASAT,IATCNT,NXATT
      COMMON/AXIS/LINTAX
      COMMON/CITER /NINNER,NARC,NGLOBL
      COMMON/CITERL/LSTGLB,LSTARC,LSTINR,LNADJ ,LITER1,LSTITR,          &
     &              LOBORB,LRESID,LFREEZ,LSAVEF,LHALT,LADJPI,LADJCI
      COMMON/CESTIM/MPARM,MAPARM,MAXDIM,MAXFMG,ICLINK,IPROCS,NXCEST
      COMMON/CESTML/LNPNM ,NXCSTL
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
      COMMON/CPMPA /KTMPAR(3)    ,KMBPAR(2)    ,KRFPAR(2)    ,          &
     &              KAEPAR,KFEPAR,KFPPAR,KVLPAR,KETPAR(2,2)  ,          &
     &              KPMPAR,KUTPAR,KSTPAR(3,4)  ,NADJST       ,          &
     &              NDIM1 ,NDIM2 ,NXDIM1,NXDIM2
      COMMON/LTOTCR/LEDCR(100000)
      COMMON/NEWCON/XOK0,XNOK0
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
      COMMON/NTOTCR/NTCR,NWCR
      COMMON/RMSCR/RMSTCR,RMSWCR,RMSRCR,RMSPCR
      COMMON/XOVERS/NRXTOT,NXBLK,NUSIDE,NDEGX2,NDEGXX,NUCON,ITERNU,     &
     &              IPEDIT,IDEDIT,NXXOVR
!
      DIMENSION AA(1),II(1),LL(1)
      DIMENSION FSEC1(NU),FSEC2(NU),TIME1(NU),TIME2(NU)
      DIMENSION XTD(MINTIM,3),XTP(MINTIM,3),XMP(MINTIM,3)
      DIMENSION PMPA(NADJST),PXEPXI(NM,3,3)
      DIMENSION NEQN(MSETA),N3(MSETA),IPTFMG(MAXFMG,MSATA)
      DIMENSION ILNFMG(MAXFMG,MSATA),NFMG(MSATA)
      DIMENSION PXEPA(NDM1,NDM2)
      DIMENSION ACOEF(ND1,NM1,3,2)
      DIMENSION DDDA(ND1,3,2)
      DIMENSION RESID(1)
      DIMENSION SUM1(1),SUM2(1),OBSSIG(1),SIGMA(1)
      DIMENSION AUX1(NU,6)
      DIMENSION X2VSPR(NDMX1,NDMX2,NDMX3,2)
      DIMENSION X2SPA(NUCON,3,20,2)
      DIMENSION FSECIN(2),FSECOT(2),IYMD(2),IHM(2),SEC(2)
      DIMENSION XPRN(3,2),PRP(2),XLATP(2),XLONP(2),DV(3,2)
      DIMENSION ATPER(1)
      DIMENSION IPTTMB(2)
      DIMENSION PDELTA(NADJST)
      DIMENSION PPOR(3,NM)
      DIMENSION TMPPOR(NM)
      DIMENSION DADA0(1),DADIC(1)
!
      CPEDIT=DBLE(IPEDIT)/100.D0
      CDEDIT=DBLE(IDEDIT)/100.D0
      IPTN=(NU-NM)/2
      IPTN1=IPTN+1
      LPC=NINNER.GT.ITERNU
      LEDP=.FALSE.
!     LPC=.FALSE.
!
!
      NCLEAR=NADJST
      CALL CLEARA(PMPA,NCLEAR)
!
!  LOAD THE NU PERTINENT TIMES OF THE PASSES INTO FSEC1 FSEC2
!  MJDSCX + FSECX  WILL BE USED FOR ABSOLUTE TIME REFERENCE
!
!  ADJUST THE PERTINENT TIMES PUT INTO TIME1 & TIME2
!
!   T1EST IS ALSO REFERENCED FROM MJDSC1
      DO 100 I=1,NU
      TIME1(I)=FSEC1(I)-T1EST
      TIME2(I)=FSEC2(I)-T2EST
  100 END DO
      T1X=0.D0
      T2X=0.D0
!
!
!  LOAD 1ST PASS OF ECF BOUNCE POINTS INTO XTD
      DO I=1,NU
      XTD(I,1)=AUX1(I,1)
      XTD(I,2)=AUX1(I,2)
      XTD(I,3)=AUX1(I,3)
! DEBUG ****************************************************************
!     write(6,*)' dbg EX1 ',xtd(i,1),fsec1(i),time1(i)
!     write(6,*)' dbg EX1 ',xtd(i,2)
!     write(6,*)' dbg EX1 ',xtd(i,3)
! DEBUG ****************************************************************
      ENDDO
      IATST1=1
      IF(XTD(2,3).LT.XTD(1,3)) IATST1=-1
!
      CALL PFTPAR(NM,NM1,ND1,TIME1(IPTN1),XTD(IPTN1,1),XTD(IPTN1,2),    &
     &            XTD(IPTN1,3),ACOEF(1,1,1,1),RMS1,SLOPE1)
!
!
!  LOAD 2ND PASS OF ECF BOUNCE POINTS INTO XTD
      DO I=1,NU
      XTD(I,1)=AUX1(I,4)
      XTD(I,2)=AUX1(I,5)
      XTD(I,3)=AUX1(I,6)
! DEBUG ****************************************************************
!     write(6,*)' dbg EX2 ',xtd(i,1),fsec2(i),time2(i)
!     write(6,*)' dbg EX2 ',xtd(i,2)
!     write(6,*)' dbg EX2 ',xtd(i,3)
! DEBUG ****************************************************************
      ENDDO
      IATST2=1
      IF(XTD(2,3).LT.XTD(1,3)) IATST2=-1
!
      CALL PFTPAR(NM,NM1,ND1,TIME2(IPTN1),XTD(IPTN1,1),XTD(IPTN1,2),    &
     &            XTD(IPTN1,3),ACOEF(1,1,1,2),RMS2,SLOPE2)
!
!
      CALL MINDST(ND1,NM1,T1X,T2X,ACOEF,T1,T2,DIST)
!
! ZERO PROTECTION
!
      LSMALL=.FALSE.
      TEST=PPARM
      PARSPC=0.D0
      DIST0=DIST
      DO IXYZ=1,3
         DV(IXYZ,1)=0.D0
         DV(IXYZ,2)=0.D0
      ENDDO
      IF(TEST.GT.0.D0.AND.DIST.LT.TEST) THEN
         LSMALL=.TRUE.
         XNOK0=XNOK0+1.D0
         FSECIN(1)=T1
         FSECIN(2)=T2
         DO IPS=1,2
            DO IXYZ=1,3
              XPRN(IXYZ,IPS)=ACOEF(1,1,IXYZ,IPS)
              FSECOT(IPS)=FSECIN(IPS)
              DO IDX=2,ND1
                XPRN(IXYZ,IPS)=XPRN(IXYZ,IPS)                           &
     &                        +ACOEF(IDX,1,IXYZ,IPS)*FSECOT(IPS)
                FSECOT(IPS)=FSECOT(IPS)*FSECIN(IPS)
              ENDDO
            ENDDO
         ENDDO
         DV(1,2)=XPRN(1,2)-XPRN(1,1)
         DV(2,2)=XPRN(2,2)-XPRN(2,1)
         DV(3,2)=XPRN(3,2)-XPRN(3,1)
         DVR=SQRT(DV(1,2)*DV(1,2)+DV(2,2)*DV(2,2)                      &
     &            +DV(3,2)*DV(3,2))/TEST
         DV(1,2)=DV(1,2)/DVR
         DV(2,2)=DV(2,2)/DVR
         DV(3,2)=DV(3,2)/DVR
         ACOEF(1,1,1,2)=ACOEF(1,1,1,2)+DV(1,2)
         ACOEF(1,1,2,2)=ACOEF(1,1,2,2)+DV(2,2)
         ACOEF(1,1,3,2)=ACOEF(1,1,3,2)+DV(3,2)
         CALL MINDST(ND1,NM1,T1X,T2X,ACOEF,T1,T2,DIST)
         PARSPC=(DIST-DIST0)/TEST
      ENDIF
!
! END ZERO PROTECTION
!
!
!
      TT1=T1
      TT2=T2
      DO 400 J=1,2
      DO 300 I=1,3
      DO 200 K=1,ND1
      SAVE=ACOEF(K,1,I,J)
      DEL=1.D-10*ABS(SAVE)
      IF(DEL.LT.1.D-10) DEL=1.D-10
      ACOEF(K,1,I,J)=SAVE+DEL
      CALL MINDST(ND1,NM1,TT1,TT2,ACOEF,TTT1,TTT2,DDDA(K,I,J))
      DDDA(K,I,J)=(DDDA(K,I,J)-DIST)/DEL
      ACOEF(K,1,I,J)=SAVE
  200 END DO
  300 END DO
  400 END DO
!
! COMPUTE PARTIALS ONLY ON LATER ITERATIONS
!
      IF(.NOT.LPC) GO TO 1010
!
!
      DO 1000 KPASS=1,2
!
!  GET PXEPXI ARRAY OF FIRST PASS
!  XTD,XTP AND XMP ARE JUST SCRATCH ARRAYS
!
      IF(KPASS.EQ.1) THEN
         JSAT=ISAT1
         JSET=ISET1
         IP0AT1=IPAT11
         IP0AT2=IPAT12
!!!!!    PER=ATPER(JSAT)
         DO 410 I=1,NM
         TIME1(I)=FSEC1(IPTN+I)-(TAT1-DBLE(MJDSC1))
  410    CONTINUE
         CALL DXEDXI(AA,II,LL,MJDSC1,FSEC1(IPTN1),NM,XTD,XTP,XMP,PXEPXI)
      ENDIF
      IF(KPASS.EQ.2) THEN
         JSAT=ISAT2
         JSET=ISET2
         IP0AT1=IPAT21
         IP0AT2=IPAT22
!!!!!    PER=ATPER(JSAT)
         DO 420 I=1,NM
         TIME1(I)=FSEC2(IPTN+I)-(TAT2-DBLE(MJDSC2))
  420    CONTINUE
         CALL DXEDXI(AA,II,LL,MJDSC2,FSEC2(IPTN1),NM,XTD,XTP,XMP,PXEPXI)
      ENDIF
!
!  FOR KPASS PASS OF DATA
!  LOAD PARTIALS OF XYZ TOR WRT FORCE MODELS INTO AA(KPXPFM)
!
!
!  CHAIN PXEPXI WITH PXIPFM TO GET PARTIALS OF XE1 WRT FORCE MODEL
!
      DO 900 IX=1,3
      NCLEAR=NM*NADJST
      CALL CLEARA(PXEPA,NCLEAR)
      CALL CHAIN (PXEPXI(1,1,IX),NM,3,1,X2VSPR(1,1,1,KPASS),NDMX1,      &
     &    NDMX2,NDMX3,                                                  &
     &    NEQN(JSET),N3(JSET),IPTFMG(1,JSAT),ILNFMG(1,JSAT),NFMG(JSAT), &
     &    PXEPA,NDM1,NDM2,LNPNM,.FALSE.,.FALSE.,1.D0,LL(KLAVOI))
      IF(LSTINR.AND.NPVAL0(IXXTRO).GT.0) THEN
        IF(LINTAX) THEN
           IPT=IPVAL0(IXXTRO)
           KPT=IPVAL0(IXXTRO)+NPVAL0(IXXTRO)-6
           IF(LNPNM) THEN
               DO I=1,NM
                 PXEPA(IPT,I)=PXEPA(IPT,I)+X2SPA(I,IX,12,KPASS)
                 PXEPA(IPT+1,I)=PXEPA(IPT+1,I)+X2SPA(I,IX,13,KPASS)
                 PXEPA(IPT+2,I)=PXEPA(IPT+2,I)+X2SPA(I,IX,14,KPASS)
                 PXEPA(IPT+3,I)=PXEPA(IPT+3,I)+X2SPA(I,IX,15,KPASS)
                 PXEPA(IPT+4,I)=PXEPA(IPT+4,I)+X2SPA(I,IX,16,KPASS)
                 PXEPA(IPT+5,I)=PXEPA(IPT+5,I)+X2SPA(I,IX,17,KPASS)
                 PXEPA(KPT,I)=PXEPA(KPT,I)+X2SPA(I,IX,6,KPASS)
                 PXEPA(KPT+1,I)=PXEPA(KPT+1,I)+X2SPA(I,IX,7,KPASS)
                 PXEPA(KPT+2,I)=PXEPA(KPT+2,I)+X2SPA(I,IX,8,KPASS)
                 PXEPA(KPT+3,I)=PXEPA(KPT+3,I)+X2SPA(I,IX,9,KPASS)
                 PXEPA(KPT+4,I)=PXEPA(KPT+4,I)+X2SPA(I,IX,10,KPASS)
                 PXEPA(KPT+5,I)=PXEPA(KPT+5,I)+X2SPA(I,IX,11,KPASS)
               ENDDO
           ELSE
               DO I=1,NM
                 PXEPA(I,IPT)=PXEPA(I,IPT)+X2SPA(I,IX,12,KPASS)
                 PXEPA(I,IPT+1)=PXEPA(I,IPT+1)+X2SPA(I,IX,13,KPASS)
                 PXEPA(I,IPT+2)=PXEPA(I,IPT+2)+X2SPA(I,IX,14,KPASS)
                 PXEPA(I,IPT+3)=PXEPA(I,IPT+3)+X2SPA(I,IX,15,KPASS)
                 PXEPA(I,IPT+4)=PXEPA(I,IPT+4)+X2SPA(I,IX,16,KPASS)
                 PXEPA(I,IPT+5)=PXEPA(I,IPT+5)+X2SPA(I,IX,17,KPASS)
                 PXEPA(I,KPT)=PXEPA(I,KPT)+X2SPA(I,IX,6,KPASS)
                 PXEPA(I,KPT+1)=PXEPA(I,KPT+1)+X2SPA(I,IX,7,KPASS)
                 PXEPA(I,KPT+2)=PXEPA(I,KPT+2)+X2SPA(I,IX,8,KPASS)
                 PXEPA(I,KPT+3)=PXEPA(I,KPT+3)+X2SPA(I,IX,9,KPASS)
                 PXEPA(I,KPT+4)=PXEPA(I,KPT+4)+X2SPA(I,IX,10,KPASS)
                 PXEPA(I,KPT+5)=PXEPA(I,KPT+5)+X2SPA(I,IX,11,KPASS)
               ENDDO
           ENDIF
        ELSE
           DO I=1,NM
             IF(KPASS.EQ.1) THEN
                TMPPOR(I)=FSEC1(IPTN+I)+DBLE(MJDSC1)
             ELSE
                TMPPOR(I)=FSEC2(IPTN+I)+DBLE(MJDSC2)
             ENDIF
             PPOR(1,I)=X2SPA(I,IX,12,KPASS)
             PPOR(2,I)=X2SPA(I,IX,13,KPASS)
             PPOR(3,I)=X2SPA(I,IX,14,KPASS)
           END DO
           CALL CHPOR(PPOR,PXEPA,NM,NDM1,NDM2,LNPNM,                    &
     &                TMPPOR,LL(KLAVOI),AA(KANGWT),AA(KWT),AA(KPPER),   &
     &                DADA0,DADIC,1)
!!!!!!!!ENDIF FOR:  IF(LINTAX) THEN
        ENDIF
!!!!!ENDIF FOR: IF(LSTINR.AND.NPVAL0(IXXTRO).GT.0) THEN
      ENDIF
!
!  INSERT THE PARTIALS OF XE WRT ATTITUDE INTO PXEPA ARRAY
!
!  FIRST INSERT PARTIALS OF COMPONENT IX WRT ROLL PITCH YAW OF SATELLITE
!  INTO XTD
      DO 125 I=1,NM
      DO 120 IK=1,3
      XTD(I,IK)=X2SPA(I,IX,IK,KPASS)
  120 END DO
  125 END DO
      IF(IP0AT1.GT.0) THEN
        IF(KPASS.EQ.1) ISATQ=ISAT1
        IF(KPASS.EQ.2) ISATQ=ISAT2
        CALL FNDNUM(II(KISATN-1+ISATQ),II(KATSAT),NASAT,IATSAT)
        IF(IATSAT.LE.0) THEN
          WRITE(6,6500) II(KISATN-1+ISATQ)
          WRITE(6,6501)
          WRITE(6,6502)
          STOP
        ENDIF
        PER=ATPER(IATSAT)
          CALL CHNAT(XTD,PXEPA,NDM1,NDM2,MINTIM,LNPNM,NM,IP0AT1,        &
     &               TIME1,PER,LL(KLAVOI))
      ENDIF
!
!  NOW INSERT PARTIALS OF COMPONENT IX WRT ROLL PITCH YAW OF LASER
!  INTO XTD
      DO 135 I=1,NM
      DO 130 IK=1,3
      XTD(I,IK)=X2SPA(I,IX,IK,KPASS)
  130 END DO
  135 END DO
      IF(IP0AT2.GT.0) THEN
        IF(KPASS.EQ.1) ISATQ=ISAT1
        IF(KPASS.EQ.2) ISATQ=ISAT2
        CALL FNDNUM(II(KISATN-1+ISATQ),II(KATSAT),NASAT,IATSAT)
        IF(IATSAT.LE.0) THEN
          WRITE(6,6500) II(KISATN-1+ISATQ)
          WRITE(6,6501)
          WRITE(6,6502)
          STOP
        ENDIF
        PER=ATPER(IATSAT)
          CALL CHNAT(XTD,PXEPA,NDM1,NDM2,MINTIM,LNPNM,NM,IP0AT2,        &
     &               TIME1,PER,LL(KLAVOI))
      ENDIF
!
!  NOW INSERT PARTIALS OF OBS AND ATTITUDE TIMING BIAS
!  INTO XTD
      DO 145 I=1,NM
      DO 140 IK=1,2
      XTD(I,IK)=X2SPA(I,IX,IK+3,KPASS)
  140 END DO
  145 END DO
      IPTTMB(1)=X2SPA(1,1,18,KPASS)+.001D0
      IPTTMB(2)=X2SPA(1,2,18,KPASS)+.001D0
      NTTB=IPTTMB(1)+IPTTMB(2)
      IF(NTTB.GT.0) THEN
          CALL CHNTM(IPTTMB,XTD,PXEPA,NDM1,NDM2,MINTIM,LNPNM,NM,        &
     &           LL(KLAVOI))
      ENDIF
!
! REGULAR BIAS AND INDIVIDUAL LASER BIAS
!
      DO ISBIA=1,2
        IBF=0
        IF(ISBIA.EQ.1) IBF=X2SPA(1,2,20,KPASS)+.001D0
        IF(ISBIA.EQ.2) IBF=X2SPA(1,3,18,KPASS)+.001D0
        IF(IBF.GT.0) THEN
         LL(KLAVOI-1+IBF)=.FALSE.
         IF(LNPNM) THEN
          DO I=1,NM
             PXEPA(IBF,I)=-(X2SPA(I,1,19,KPASS)*PXEPXI(I,1,IX)          &
     &                     +X2SPA(I,2,19,KPASS)*PXEPXI(I,2,IX)          &
     &                     +X2SPA(I,3,19,KPASS)*PXEPXI(I,3,IX))
           ENDDO
          ELSE
            DO I=1,NM
             PXEPA(I,IBF)=-(X2SPA(I,1,19,KPASS)*PXEPXI(I,1,IX)          &
     &                     +X2SPA(I,2,19,KPASS)*PXEPXI(I,2,IX)          &
     &                     +X2SPA(I,3,19,KPASS)*PXEPXI(I,3,IX))
            ENDDO
          ENDIF
        ENDIF
      ENDDO
!
! END REG AND INDIVIDUAL BIAS
!
!
! CHAIN ALL ASPECTS TOGETHER
      IF(LNPNM) THEN
         DO 600 J=1,NM
         DO 550 I=1,ND1
         DO 500 K=1,NADJST
!      LL(KLAVOI-1+K)=.FALSE.
      PMPA(K)=PMPA(K)                                                   &
     &       +DDDA(I,IX,KPASS)*ACOEF(I,J+1,IX,KPASS)*PXEPA(K,J)
  500    CONTINUE
  550    CONTINUE
  600    CONTINUE
      ELSE
         DO 800 J=1,NM
         DO 750 I=1,ND1
         DO 700 K=1,NADJST
!      LL(KLAVOI-1+K)=.FALSE.
      PMPA(K)=PMPA(K)                                                   &
     &       +DDDA(I,IX,KPASS)*ACOEF(I,J+1,IX,KPASS)*PXEPA(J,K)
  700    CONTINUE
  750    CONTINUE
  800    CONTINUE
      ENDIF
!
!
  900 END DO
!
!
 1000 END DO
      IF(NPVAL0(IXRSEP).GE.1) THEN
         PMPA(IPVAL0(IXRSEP))=PARSPC
         LL(KLAVOI-1+IPVAL0(IXRSEP))=.FALSE.
      ENDIF
!
      JQP=1+(ISAT1-1)*6
      IF(ABS(PMPA(JQP)).GT.CPEDIT) LEDP=.TRUE.
      IF(ABS(PMPA(JQP+1)).GT.CPEDIT) LEDP=.TRUE.
      IF(ABS(PMPA(JQP+2)).GT.CPEDIT) LEDP=.TRUE.
      JQP=1+(ISAT2-1)*6
      IF(ABS(PMPA(JQP)).GT.CPEDIT) LEDP=.TRUE.
      IF(ABS(PMPA(JQP+1)).GT.CPEDIT) LEDP=.TRUE.
      IF(ABS(PMPA(JQP+2)).GT.CPEDIT) LEDP=.TRUE.
!
 1010 CONTINUE
      SIGMA(1)=0.D0
      LED1=.FALSE.
      LED2=.FALSE.
      LED3=.FALSE.
      LED4=.FALSE.
      IF(RMS1.GT.5.D0) LED1=.TRUE.
      IF(RMS2.GT.5.D0) LED2=.TRUE.
      IF(SLOPE1.GT..05D0) LED3=.TRUE.
      IF(SLOPE2.GT..05D0) LED4=.TRUE.
! ****
!     IF(SLOPE1.GT..03D0) LED3=.TRUE.
!     IF(SLOPE2.GT..03D0) LED4=.TRUE.
!     LED=LED1.OR.LED2.OR.LED3.OR.LED4
! ****
      LED=LED1.OR.LED2.OR.LED3.OR.LED4
!
       LED=.FALSE.
!
      OBSSGX=OBSSIG(1)
      IF(OBSSIG(1).LE.0.D0) OBSSGX=1.D0
!     IF(NINNER.GT.3.OR.NGLOBL.GT.1) SIGMA(1)=1.D0/(OBSSGX*OBSSGX)
      IF(NINNER.GT.ITERNU) SIGMA(1)=1.D0/(OBSSGX*OBSSGX)
      IF(NGLOBL.GT.1) SIGMA(1)=1.D0/(OBSSGX*OBSSGX)
      TESTRX=2.00D0*RMSPCR
      IF(DIST0.GT.TESTRX) LED=.TRUE.
!
       LED=.FALSE.
      LED=LED1.OR.LED2.OR.LED3.OR.LED4
      IF(DIST.GT.CDEDIT) LED=.TRUE.
      LEDD=.FALSE.
      IF(DIST.GT.CDEDIT) LEDD=.TRUE.
      IF(LEDP) LED=.TRUE.

!
      NTCR=NTCR+1
! ****
! ****
!!!!!!!!!!!!!! TO SHUT DOWN EDITING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!        LED=.FALSE.
!        LED3=.FALSE.
!        LED4=.FALSE.
!!!!!!!!!!!!!! TO SHUT DOWN EDITING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      IF(LED3.OR.LED4) THEN
         LED=.TRUE.
         LEDCR(NTCR)=LED
      ENDIF
! ****
      IF(NINNER.LT.7.AND.NGLOBL.EQ.1) THEN
         LEDCR(NTCR)=LED
      ELSE
         LED=LEDCR(NTCR)
      ENDIF
      IF(LED) SIGMA(1)=0.D0
      RESID(1)=-DIST
      RMSTCR=RMSTCR+DIST0*DIST0
      IF(.NOT.LED) THEN
        NWCR=NWCR+1
        RMSWCR=RMSWCR+DIST0*DIST0
        DISTR=DIST0/OBSSGX
        RMSRCR=RMSRCR+DISTR*DISTR
      ENDIF
!
!
      IF(LPC) THEN
        CALL SUMNPF(PMPA,RESID,SIGMA,NADJST,MAPARM,1,                   &
     &             SUM1,SUM2,PDELTA,LL(KLAVOI))
      ENDIF
      IF(LPC.AND.LSMALL.AND.XNOK0.LT.1.5D0.AND.NPVAL0(IXRSEP).GE.1) THEN
        RESID(1)=-ABS(PPARM)
        SIGMA(1)=1.D20
        CALL CLEARA(PMPA,NADJST)
        PMPA(IPVAL0(IXRSEP))=1.D0
        CALL SUMNPF(PMPA,RESID,SIGMA,NADJST,MAPARM,1,                   &
     &             SUM1,SUM2,PDELTA,LL(KLAVOI))
      ENDIF
      DIST=DIST0
      RESID(1)=DIST
!
!
!
      T1P=T1EST
      T2P=T2EST
      T1EST=T1EST+T1
      T2EST=T2EST+T2
!     LRX=.TRUE.
!     IF(LRX) THEN
      IF(LRESD.OR.LSTIT) THEN
        IF(LRESD) WRITE(6,6000)
        IF(LRESD) WRITE(6,6000)
        IF(LRESD) WRITE(6,6001)
        FSECIN(1)=T11
        FSECIN(2)=T12
        CALL UTCET(.FALSE.,2,MJDSC1,FSECIN,FSECOT,AA(KA1UT))
        CALL YMDHMS(MJDSC1,FSECOT,IYMD,IHM,SEC,2)
        IYMD(1)=MOD(IYMD(1),1000000)
        IYMD(2)=MOD(IYMD(2),1000000)
         IF(LRESD) THEN
         WRITE(6,6003) IYMD(1),IHM(1),SEC(1),IYMD(2),IHM(2),SEC(2)
         ENDIF
         FSECIN(1)=T21
         FSECIN(2)=T22
         CALL UTCET(.FALSE.,2,MJDSC2,FSECIN,FSECOT,AA(KA1UT))
         CALL YMDHMS(MJDSC2,FSECOT,IYMD,IHM,SEC,2)
         IYMD(1)=MOD(IYMD(1),1000000)
         IYMD(2)=MOD(IYMD(2),1000000)
         IF(LRESD) THEN
         WRITE(6,6004) IYMD(1),IHM(1),SEC(1),IYMD(2),IHM(2),SEC(2)
         WRITE(6,6005)
         WRITE(6,6006)
         ENDIF
         NDPX=ND1-1
         IF(LRESD) THEN
         WRITE(6,6008) NDPX,NM
         WRITE(6,6010)
         WRITE(6,6011) RMS1,SLOPE1
         WRITE(6,6012) RMS2,SLOPE2
         ENDIF
         FSECIN(1)=T1P
         CALL UTCET(.FALSE.,1,MJDSC1,FSECIN,FSECOT,AA(KA1UT))
         CALL YMDHMS(MJDSC1,FSECOT,IYMD,IHM,SEC,1)
         IYMD(1)=MOD(IYMD(1),1000000)
         FSECIN(2)=T2P
         CALL UTCET(.FALSE.,1,MJDSC2,FSECIN(2),FSECOT(2),AA(KA1UT))
         CALL YMDHMS(MJDSC2,FSECOT(2),IYMD(2),IHM(2),SEC(2),1)
         IYMD(2)=MOD(IYMD(2),1000000)
         IF(LRESD) THEN
         WRITE(6,6025) IYMD(1),IHM(1),SEC(1),IYMD(2),IHM(2),SEC(2)
         ENDIF
         FSECIN(1)=T1EST
         CALL UTCET(.FALSE.,1,MJDSC1,FSECIN,FSECOT,AA(KA1UT))
         CALL YMDHMS(MJDSC1,FSECOT,IYMD,IHM,SEC,1)
         IYMD(1)=MOD(IYMD(1),1000000)
         FSECIN(2)=T2EST
         CALL UTCET(.FALSE.,1,MJDSC2,FSECIN(2),FSECOT(2),AA(KA1UT))
         CALL YMDHMS(MJDSC2,FSECOT(2),IYMD(2),IHM(2),SEC(2),1)
         IYMD(2)=MOD(IYMD(2),1000000)
         IF(LRESD) THEN
         WRITE(6,6026) IYMD(1),IHM(1),SEC(1),IYMD(2),IHM(2),SEC(2)
         ENDIF
         FSECIN(1)=T1
         FSECIN(2)=T2
         DO 1500 IPS=1,2
         DO 1400 IXYZ=1,3
         XPRN(IXYZ,IPS)=ACOEF(1,1,IXYZ,IPS)
         FSECOT(IPS)=FSECIN(IPS)
         DO 1300 IDX=2,ND1
         XPRN(IXYZ,IPS)=XPRN(IXYZ,IPS)+ACOEF(IDX,1,IXYZ,IPS)*FSECOT(IPS)
         FSECOT(IPS)=FSECOT(IPS)*FSECIN(IPS)
 1300   CONTINUE
 1400   CONTINUE
         PRP(IPS)=SQRT(XPRN(1,IPS)*XPRN(1,IPS)+XPRN(2,IPS)*XPRN(2,IPS)  &
     &                +XPRN(3,IPS)*XPRN(3,IPS))
         XLATP(IPS)=ASIN(XPRN(3,IPS)/PRP(IPS))/DEGRAD
        XLONP(IPS)=ATAN2(XPRN(2,IPS),XPRN(1,IPS))/DEGRAD
 1500   CONTINUE
        IF(LRESD) THEN
        WRITE(6,6027)
        WRITE(6,6028) XLATP(1),XLONP(1),PRP(1)
        WRITE(6,6029)
        WRITE(6,6028) XLATP(2),XLONP(2),PRP(2)
        WRITE(6,6000)
        WRITE(6,6030) DIST
         IF(NINNER.LE.ITERNU.AND.NGLOBL.EQ.1) THEN
            WRITE(6,6031)
            WRITE(6,6032)
            WRITE(6,6033)
          ELSE
            IF(.NOT.LED) THEN
              RAT=DIST/OBSSGX
              WRITE(6,6034) RAT
            ELSE
              WRITE(6,6035)
            ENDIF
          ENDIF
        WRITE(6,6000)
        WRITE(6,6000)
      ENDIF
      ENDIF
      IF(LSTIT) THEN
!     LSTITX=.TRUE.
!     IF(LSTITX) THEN
         RMSX=RMS1
         IF(RMS2.GT.RMS1) RMSX=RMS2
         SLOPEX=SLOPE1
         IF(SLOPE2.GT.SLOPE1) SLOPEX=SLOPE2
         IMIDX=(IPTN1+NM)/2
         ANG1=X2SPA(IPTN1,1,20,1)
         ANG2=X2SPA(IPTN1,1,20,2)
         ANGV=ANG1
         IF(ANG2.GT.ANG1) ANGV=ANG2
         FSECIN(1)=T1EST
         CALL UTCET(.FALSE.,1,MJDSC1,FSECIN,FSECOT,AA(KA1UT))
         FSECIN(2)=T2EST
         CALL UTCET(.FALSE.,1,MJDSC2,FSECIN(2),FSECOT(2),AA(KA1UT))
         IF(LED) THEN
            WRITE(48,7000) KEY,MJDSC1,FSECOT(1),MJDSC2,FSECOT(2),       &
     &                     ANGV,RMSX,SLOPEX
         ELSE
            WRITE(47,7000) KEY,MJDSC1,FSECOT(1),MJDSC2,FSECOT(2),       &
     &                     ANGV,RMSX,SLOPEX
         ENDIF
      ENDIF
!
      IF(LSTIT) THEN
            M1=MJDSC1-3000
            FSECOT(1)=FSECOT(1)+3000.D0
            M1A=FSECOT(1)
            FSECOT(1)=FSECOT(1)-DBLE(M1A)
            M1=M1+M1A
!
            M2=MJDSC2-3000
            FSECOT(2)=FSECOT(2)+3000.D0
            M2A=FSECOT(2)
            FSECOT(2)=FSECOT(2)-DBLE(M2A)
            M2=M2+M2A
            PDIF=PRP(2)-PRP(1)
            IF(IATST2.LT.0) PDIF=-PDIF
            EDC='FFFFFF'
            IF(LED1) EDC(1:1)='T'
            IF(LED2) EDC(2:2)='T'
            IF(LED3) EDC(3:3)='T'
            IF(LED4) EDC(4:4)='T'
            IF(LEDD) EDC(5:5)='T'
            IF(LEDP) EDC(6:6)='T'
            IQP=1+NUCON/2
            ILAND1=X2SPA(IQP,3,20,1)+.001D0
            ILAND2=X2SPA(IQP,3,20,2)+.001D0
            ILAND1=ILAND1+1
            ILAND2=ILAND2+1
            IF(ILAND1.GT.6) ILAND1=6
            IF(ILAND2.GT.6) ILAND2=6
            CLAND='012345'
            AD(1:1)='A'
            IF(IATST1.LT.0) AD(1:1)='D'
            AD(2:2)='A'
            IF(IATST2.LT.0) AD(2:2)='D'
!
            WRITE(49,7000) KEY,M1,FSECOT(1),M2,FSECOT(2),               &
     &                     ANGV,RMSX,SLOPEX,XLATP(1),XLONP(1),DIST,     &
     &                     PDIF,II(KISATN-1+ISAT1),II(KISATN-1+ISAT2),  &
     &                     CLAND(ILAND1:ILAND1),CLAND(ILAND2:ILAND2),   &
     &                     AD,EDC
      ENDIF
      RETURN
 6000 FORMAT(' ')
 6001 FORMAT(' CROSSOVER CONSTRAINT EQUATION BETWEEN TWO STREAMS',      &
     &       ' OF DIRECT ALTIMETRY:')
 6003 FORMAT(' FIRST  STREAM START ',I6,1X,I4,F10.2,' END ',I6,1X,I4,   &
     &         F10.2)
 6004 FORMAT(' SECOND STREAM START ',I6,1X,I4,F10.2,' END ',I6,1X,I4,   &
     &         F10.2)
 6005 FORMAT(' ONLY PORTIONS OF THESE STREAMS ARE BEING USED.')
 6006 FORMAT(' THE PORTIONS ARE CENTERED ON THE INITIAL ESTIMATE',      &
     &       ' OF CROSSOVER TIMES.')
 6008 FORMAT(' A DEGREE ',I3,' POLYNOMIAL IS BEING USED TO REPRESENT',  &
     &         I5,' POINTS IN EACH STREAM.')
 6010 FORMAT(' RMS OF FIT (M) OF POLYNOMIAL AT THREE CENTER POINTS')
 6011 FORMAT(' FOR STREAM # 1 :',F15.3,' SLOPE: ',F12.5)
 6012 FORMAT(' FOR STREAM # 2 :',F15.3,' SLOPE: ',F12.5)
 6025 FORMAT(' INITIAL CROSSOVER TIMES ',I6,1X,I4,F12.5,5X,I6,1X,I4,    &
     &         F12.5)
 6026 FORMAT(' UPDATED CROSSOVER TIMES ',I6,1X,I4,F12.5,5X,I6,1X,I4,    &
     &         F12.5)
 6027 FORMAT(' APPROXIMATE CROSSOVER LOCATION (PLANET CENTERED) # 1:')
 6028 FORMAT(' LATITUTE   ',F15.5,' LONGITUDE ', F15.5,' RADIUS ',F15.2)
 6029 FORMAT(' APPROXIMATE CROSSOVER LOCATION (PLANET CENTERED) # 2:')
 6030 FORMAT(' CROSSOVER DISCREPANCY (M): ',F15.3)
 6031 FORMAT(' ON THIS ITERATION THE CROSSOVERS ARE NOT BEING USED')
 6032 FORMAT(' FOR PARAMTER ADJUSTMENT. THEY ARE BEING USED ONLY')
 6033 FORMAT(' TO REFINE CROSSOVER TIME ESTIMATES.')
 6034 FORMAT(' DESCREPANCY RATIO TO CONSTRAINT EQ SIGMA: ',F12.3)
 6035 FORMAT(' THIS POINT WAS EDITED ')
 6500 FORMAT(' EXECUTION TERMINATING IN EXDYNX FOR SATELLITE ',I12)
 6501 FORMAT(' ATTITUD IS ADJUSING BUT SATELLITE NOT FOUND IN ARRAY')
 6502 FORMAT(' OF SATELLITES WITH ATITUD PARAMETERS')
 7000 FORMAT(I10,1X,I10,1X,F9.4,1X,I10,1X,F9.4,1X,F5.1,1X,F7.1,1X,F7.3, &
     &       1X,F9.4,1X,F9.4,1X,F8.3,1X,F9.3,2I9,1X,2A1,1X,A2,1X,A6)
      END
