      SUBROUTINE EXDYN2(LNPNM,ND1,AA,II,LL,                             &
     &                  PMPA,                                           &
     &                  PXEPA,ACOEF,                                    &
     &                  ACOEF2,ACOF31,ACOF32,                           &
     &                  DDDA,NDM1,NDM2,ND2AC,                           &
     &                  NM1,NM2,MJDS1,FSEC1,MJDS2,FSEC2,                &
     &                  PPARM,LSMALT,DIST0,DIST,LFIND,IIQ,JJQ,          &
     &                  ISAT1,ISAT2,IDSAT1,IDSAT2,IDLAS1,IDLAS2,        &
     &                  KEY1,KEY2,LEDIT,MAXD,MADJST,MAXLAS,IAVP,NAVP,   &
     &                  DCDP1,DCDP2,AUX11,AUX12,ACOF4,NMF,NPDEGF,TIMEQ)
!***********************************************************************
!
! PURPOSE: FORM THE CONSTRAINT EQUATION ASSOCIATED WITH A DYNAMIC CROSSO
!
!          ND1    -  DEGREE +1 OF POLYNOMIAL USED TO FIT ASCENDING &
!                    DESCENDING STREAMS (QUADRATIC ; ND1=3)
!          AA     -  DYNAMIC FLOATING POINT ARRAY
!          II     -  DYNAMIC INTEGER ARRAY
!          LL     -  DYNAMIC LOGICAL ARRAY
!          PMPA   -  ARRAY OF PARTIALS OF MEASUREMENTS OR CONSTRAINTS WR
!                    ADJUSTING PARAMTERS (SCRATCH SPACE)
!          PXEPA   - ARRAY USED FOR EACH EARTH FIXED COORDINATE
!                    STREAM TO FORM THE PARTIAL OF THE COORDINATE WRT EA
!                    ADJUSTING PARAMETER
!          ACOEF   - SCRATCH ARRAY USED TO HOLD COEFFICIENTS OF 6 POLYNO
!                    DESCRIBING THE STREAM OF EACH CEARTH FIXED COORDIAT
!                    ALSO HOLDS THE PARTIAL OF EACH COEFFICIENT WRT EACH
!                    COORDINATE IN THE STREAM
!          DDDA    - SCRATCH ARRAY TO HOLD PARTIALS OF MINIMUM DISTANCE
!                    (BETWEEN STREAMS) WRT POLYNOMIAL COEFFICIENTS OF
!                    EACH STREAM
!          NDM1    - FIRST DIMENSION OF PXEPA ARRAY (ABOVE) ; NADJST IF
!                    LNPNM=TRUE ; NUCON OTHERWISE
!          NDM2    - SECOND DIMENSION OF PXEPA ARRAY (ABOVE) ; NUCON IF
!                    LNPNM=TRUE ; NADJST OTHERWISE
!
!
!***********************************************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      CHARACTER*6 EDC
      CHARACTER*2 AD
      SAVE
      PARAMETER(MAXND1=21)
      PARAMETER(MAXSTH=240)
!
! WATCH OUT IF CBLOKI IS ADDED (NM IS RESET)
      COMMON/CITER /NINNER,NARC,NGLOBL
      COMMON/CITERL/LSTGLB,LSTARC,LSTINR,LNADJ ,LITER1,LSTITR,          &
     &              LOBORB,LRESID,LFREEZ,LSAVEF,LHALT,LADJPI,LADJCI

      COMMON/CESTIM/MPARM,MAPARM,MAXDIM,MAXFMG,ICLINK,IPROCS,NXCEST
      COMMON/CNIGLO/MINTIM,MSATG3,MEQNG ,MEQNG3,MSATG ,MSATOB,MSATA ,   &
     &              MSATA3,MSETA ,MINTVL,MSORDR,MSORDV,NMXORD,          &
     &       MCIPV ,MXBACK,MXI   ,MPXPF ,MAXAB ,MSETDG,MXSATD,          &
     &       MXDEGS,MXDRP ,MXDRPA,MXSRP ,MXSRPA,MXGAP ,MSATDR,          &
     &       MSATSR,MSATGA,MXDRPD,MXSRPD,MXGAPD,MXBCKP,MXTPMS,          &
     &       NSTAIN,NXCNIG
      COMMON/CONSTR/PI,TWOPI,DEGRAD,SECRAD,SECDAY
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
      DIMENSION PMPA(NADJST)
      DIMENSION PXEPA(NDM1,NDM2,3,2)
      DIMENSION ACOEF(ND1,ND2AC,3,2)
      DIMENSION ACOEF2(3,1,3,2)
!!!!! DIMENSION ACOF31(MAXD,4),ACOF32(MAXD,4)
      DIMENSION ACOF31(NPDEGF,4),ACOF32(NPDEGF,4)
      DIMENSION DDDA(ND1,3,2)
      DIMENSION FSECIN(2),FSECOT(2)
      DIMENSION XPRN(3,2),PRP(2),XLATP(2),XLONP(2),DV(3,2)
      DIMENSION XPRN0(3,2)
      DIMENSION X1Q(3),X2Q(3)
      DIMENSION SCR(MAXND1)
      DIMENSION FSECET(1)
      DIMENSION FSECUT(2)
      DIMENSION PMPAH(MAXSTH)
      DIMENSION IAVP(MADJST,MAXLAS,2),NAVP(MAXLAS,2)
      DIMENSION DCDP1(MAXD,MADJST,3),DCDP2(MAXD,MADJST,3)
      DIMENSION IJPT(2)
      DIMENSION AUX11(ND2AC,5),AUX12(ND2AC,5)
      DIMENSION ACOF4(NPDEGF,ND2AC,3,2)
      DIMENSION FSEC1(NM1),FSEC2(NM2)
      DIMENSION TIMEQ(NMF)

!
! THE FOLLOWOMG TWO VARAIBLES SHOULD BE MOVED TO THE XOVERS COMMON BLOCK
      DATA IRMSED/500/,ISLPED/25/
!
      IJPT(1)=IIQ
      IJPT(2)=JJQ
!
      CPEDIT=DBLE(IPEDIT)/100.D0
      CDEDIT=DBLE(IDEDIT)/100.D0
      CRMSED=DBLE(IRMSED)/100.D0
      CSLPED=DBLE(ISLPED)/100.D0
!
      LED1=.FALSE.
      LED2=.FALSE.
      LED3=.FALSE.
      LED4=.FALSE.
      LED5=.FALSE.
      LED6=.FALSE.
!
       IF(ND1.GT.MAXND1) THEN
         NDP=ND1-1
         MDP=MAXND1-1
         WRITE(6,6000)
         WRITE(6,6000)
         WRITE(6,6001)
         WRITE(6,6002) NDP
         WRITE(6,6003) MDP
         WRITE(6,6000)
         STOP
      ENDIF

!
!
! GET APPROX TIMES OF CROSSOVER USING QUADRATIC POLYNOMIAL
      LFIND=.FALSE.
      DINV1=FSEC1(NM1)-FSEC1(1)
      DINV2=FSEC2(NM2)-FSEC2(1)
      T1X=0.D0
      T2X=0.D0
!
      CALL MINDST(3,1,T1X,T2X,ACOEF2,T1,T2,DIST)
!!!!       WRITE(6,78913) T1,T2,DIST
78913 FORMAT(' PRELIM ESTS 2TD OF CROSSOVER ',2F15.4,F20.6)
!
      T1LH=(DINV1)*.5D0
      T2LH=(DINV2)*.5D0
      IF(T1.LT.-T1LH) RETURN
      IF(T1.GT.T1LH) RETURN
      IF(T2.LT.-T2LH) RETURN
      IF(T2.GT.T2LH) RETURN
      LFIND=.TRUE.
      T1X=2.D0*T1/DINV1
      T2X=2.D0*T2/DINV2
!
!
      CALL MINDS3(ND1,ND2AC,T1X,T2X,ACOEF,T1,T2,DIST,XPRN0,LA1,LA2)
!!!!       WRITE(6,78914) T1,T2,DIST
78914 FORMAT(' ESTS OF CROSSOVER WITH ACOEF ',2F15.4,F20.6)
!
! T1T & T2T ARE ON PAR WITH FSEC1 & FSEC2
!
!!!!      WRITE(6,88914) MJDS1,FSEC1(1),FSEC1(NM1)
88914 FORMAT(' MJDS1, FSEC1(1),FSEC1(NM1)' ,I12,2F15.4)
!!!!      WRITE(6,88915) MJDS2,FSEC2(1),FSEC2(NM2)
88915 FORMAT(' MJDS2, FSEC2(1),FSEC2(NM2)' ,I12,2F15.4)
      T1T=T1*DINV1/2.D0+DINV1/2.D0+FSEC1(1)
      T2T=T2*DINV2/2.D0+DINV2/2.D0+FSEC2(1)
!!!!      WRITE(6,88916) T1T,T2T
88916 FORMAT(' T1T,T2T ',2F15.4)
      CALL GET1(T1T,FSEC1,NM1,NMF,I1PT)
      CALL GET1(T2T,FSEC2,NM2,NMF,I2PT)
!!!!      WRITE(6,88917) MJDS1,FSEC1(I1PT),FSEC1(I1PT-1+NMF)
88917 FORMAT(' MJDS1, FSEC1(I1PT),FSEC1(I1PT-1+NMF)' ,I12,2F15.4)
!!!!      WRITE(6,88918) MJDS2,FSEC2(I2PT),FSEC2(I2PT-1+NMF)
88918 FORMAT(' MJDS2, FSEC2(I2PT),FSEC2(I2PT-1+NMF)' ,I12,2F15.4)
      T1EST=(FSEC1(I1PT)+FSEC1(NMF+I1PT-1))*.5D0
      DO I=1,NMF
       TIMEQ(I)=FSEC1(I1PT-1+I)-T1EST
      ENDDO
!!!!  CALL PFTPR3(MAXD,ND2AC,ND1,NM,TIME1,XTD(1,1),XTD(1,2),            &
!!!! &            XTD(1,3),ACOEF(1,1,1),X2SPA(1,1,20),X2SPA(1,3,20),    &
!!!! &            ACOEF3,XTP)
!!!!  CALL PFTPR3(MAXD,ND2AC,NPDEGF,NMF,TIMEQ,AUX11(I1PT,1),            &
      CALL PFTPR3(NPDEGF,ND2AC,NPDEGF,NMF,TIMEQ,AUX11(I1PT,1),          &
     &            AUX11(I1PT,2),AUX11(I1PT,3),ACOF4(1,1,1,1),           &
     &            AUX11(I1PT,4),AUX11(I1PT,5),ACOF31,AA(KXTN))
!
      T2EST=(FSEC2(I2PT)+FSEC2(NMF+I2PT-1))*.5D0
      DO I=1,NMF
       TIMEQ(I)=FSEC2(I2PT-1+I)-T2EST
      ENDDO
!!!!  CALL PFTPR3(MAXD,ND2AC,NPDEGF,NMF,TIMEQ,AUX12(I2PT,1),            &
      CALL PFTPR3(NPDEGF,ND2AC,NPDEGF,NMF,TIMEQ,AUX12(I2PT,1),            &
     &            AUX12(I2PT,2),AUX12(I2PT,3),ACOF4(1,1,1,2),           &
     &            AUX12(I2PT,4),AUX12(I2PT,5),ACOF32,AA(KXTN))
!
      DINV12=FSEC1(I1PT+NMF-1)-FSEC1(I1PT)
      DINV22=FSEC2(I2PT+NMF-1)-FSEC2(I2PT)
      T1X=2.D0*(T1T-FSEC1(I1PT))/DINV12-1.D0
      T2X=2.D0*(T2T-FSEC2(I2PT))/DINV22-1.D0
!!!!       WRITE(6,78915) T1X,T2X
78915  FORMAT(' TIME EST FOR ACOF4 CALL TO MINDS3 ',2F15.4) 
      CALL MINDS3(NPDEGF,ND2AC,T1X,T2X,ACOF4,T1,T2,DIST,XPRN0,LA1,LA2)
!!!!       WRITE(6,78916) T1,T2,DIST
78916 FORMAT(' ESTS OF CROSSOVER WITH ACOF4 ',2F15.4,F20.6)
      T1C=T1
      T2C=T2
      T1X=T1
      T2X=T2
!
!
!   DO SOME CHECKING FOR EDITING BEFORE PARTIALS ARE SUMMED
      ANGV1=0.D0
      RMS1=0.D0
      RLAND1=0.D0
      SLOPE1=0.D0
      ANGV2=0.D0
      RMS2=0.D0
      RLAND2=0.D0
      SLOPE2=0.D0
!
      SCR(1)=1.D0
      CALL CHEBPL(SCR,SCR,T1C,NPDEGF,.FALSE.)
      DO I=1,NPDEGF
        ANGV1=ANGV1+SCR(I)*ACOF31(I,1)
        RMS1=RMS1+SCR(I)*ACOF31(I,2)
        RLAND1=RLAND1+SCR(I)*ACOF31(I,3)
        SLOPE1=SLOPE1+SCR(I)*ACOF31(I,4)
      ENDDO
      SCR(1)=1.D0
      CALL CHEBPL(SCR,SCR,T2C,NPDEGF,.FALSE.)
      DO I=1,NPDEGF
        ANGV2=ANGV2+SCR(I)*ACOF32(I,1)
        RMS2=RMS2+SCR(I)*ACOF32(I,2)
        RLAND2=RLAND2+SCR(I)*ACOF32(I,3)
        SLOPE2=SLOPE2+SCR(I)*ACOF32(I,4)
      ENDDO
      ANGV1=ABS(ANGV1)
      IF(ANGV1.GT.150.D0) ANGV1=180.D0-ANGV1
      ANGV1=ABS(ANGV1)
      ANGV2=ABS(ANGV2)
      IF(ANGV2.GT.150.D0) ANGV2=180.D0-ANGV2
      ANGV2=ABS(ANGV2)
      ANGV=ANGV1
      IF(ANGV2.GT.ANGV) ANGV=ANGV2
      RMS=RMS1
      IF(RMS2.GT.RMS) RMS=RMS2
      SLOPE=SLOPE1
      IF(SLOPE2.GT.SLOPE) SLOPE=SLOPE2
      ILAND1=(RLAND1+.001D0)
      ILAND2=(RLAND2+.001D0)
      IF(RMS1.GT.CRMSED) LED1=.TRUE.
      IF(RMS2.GT.CRMSED) LED2=.TRUE.
      IF(SLOPE1.GT.CSLPED) LED3=.TRUE.
      IF(SLOPE2.GT.CSLPED) LED4=.TRUE.
      IF(DIST.GT.CDEDIT) LED5=.TRUE.
      LEDIT=LED1.OR.LED2.OR.LED3.OR.LED4.OR.LED5
!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      LEDIT=.FALSE.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      LED6=.FALSE.
      LSMALL=.FALSE.
      IF(LEDIT) GO TO 1010
!
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
         FSECIN(1)=T1
         FSECIN(2)=T2
!   THIS CODE WOULD NEED TO BE REVISED
!   TO TAKE INTO ACOUNT NPDEGF & ACOF4
!         DO IPS=1,2
!            DO IXYZ=1,3
!              XPRN(IXYZ,IPS)=ACOEF(1,1,IXYZ,IPS)
!              FSECOT(IPS)=FSECIN(IPS)
!              DO IDX=2,ND1
!                XPRN(IXYZ,IPS)=XPRN(IXYZ,IPS)                           &
!     &                        +ACOEF(IDX,1,IXYZ,IPS)*FSECOT(IPS)
!                FSECOT(IPS)=FSECOT(IPS)*FSECIN(IPS)
!              ENDDO
!            ENDDO
!         ENDDO
         DV(1,2)=XPRN0(1,2)-XPRN0(1,1)
         DV(2,2)=XPRN0(2,2)-XPRN0(2,1)
         DV(3,2)=XPRN0(3,2)-XPRN0(3,1)
         DVR=SQRT(DV(1,2)*DV(1,2)+DV(2,2)*DV(2,2)                      &
     &            +DV(3,2)*DV(3,2))/TEST
         DV(1,2)=DV(1,2)/DVR
         DV(2,2)=DV(2,2)/DVR
         DV(3,2)=DV(3,2)/DVR
         ACOF4(1,1,1,2)=ACOF4(1,1,1,2)+DV(1,2)
         ACOF4(1,1,2,2)=ACOF4(1,1,2,2)+DV(2,2)
         ACOF4(1,1,3,2)=ACOF4(1,1,3,2)+DV(3,2)
         CALL MINDS3(NPDEGF,ND2AC,T1X,T2X,ACOF4,T1,T2,DIST,XPRN,LA1D,  &
     &               LA2D)
         PARSPC=(DIST-DIST0)/TEST
      ENDIF
!
! END ZERO PROTECTION
!
!
!
      TT1=T1
      TT2=T2
      TTQ=T1
      DO 400 J=1,2
      IF(J.EQ.2) TTQ=T2
      SCR(1)=1.D0
      CALL CHEBPL(SCR,SCR,TTQ,NPDEGF,.FALSE.)
      DO 300 I=1,3
      DO 200 K=1,NPDEGF
      DDDA(K,I,J)=0.D0
      SAVE=ACOF4(K,1,I,J)
!     DEL=1.D-10*ABS(SAVE)
!     DEL=1.D-02*ABS(SAVE)
!     DEL=1.D-05*ABS(SAVE)
!     IF(DEL.LT.1.D-10) DEL=1.D-10
!     IF(DEL.LT.1.D-02) DEL=1.D-02
!     IF(DEL.LT.1.D-10) DEL=1.D-10
!     DEL=1.D0
      DEL=0.D0
      IF(SCR(K).EQ.0.D0) GO TO 199
      DEL=ABS(.01D0*DIST/SCR(K))
      TESTQ=10.D0*ABS(SAVE)
!     IF(DEL.GT.TESTQ) DEL=TESTQ
      ACOF4(K,1,I,J)=SAVE+DEL
      CALL MINDS3(NPDEGF,ND2AC,TT1,TT2,ACOF4,TTT1,TTT2,DDDA(K,I,J),     &
     &            XPRN,LAQ1,LAQ2)
      DDDA(K,I,J)=(DDDA(K,I,J)-DIST)/DEL
  199 CONTINUE
      ACOF4(K,1,I,J)=SAVE
!      WRITE(6,43211) K,I,J,DEL,DDDA(K,I,J)
43211 FORMAT(' K,I,J,DEL,DDDA(K,I,J) ',3I3,2D20.11)
  200 END DO
  300 END DO
  400 END DO
!
! COMPUTE PARTIALS ONLY ON LATER ITERATIONS
!
!
      NP1=NPVAL0(IXSATP)
      NCUT=2
      IF(NP1.GT.0) THEN
        IF(NP1.GT.MAXSTH) THEN
           WRITE(6,6001)
           WRITE(6,6004) NP1
           WRITE(6,6003) MAXSTH
           STOP
        ENDIF
        DO I=1,NP1
          PMPAH(I)=PMPA(I)
        ENDDO
      ENDIF
!
      DO 1005 ICUT=1,NCUT
      DO 1000 KPASS=1,2
         IF(ICUT.EQ.1) THEN
           IS=1
           NP=6
         ELSE
           IS=7
           NP=NAVP(IJPT(KPASS),KPASS)
           IF(NP.LT.IS) GO TO 1000
         ENDIF
!!!      NM=NM1
!!!      IF(KPASS.EQ.2) NM=NM2
         NM=NMF
      DO 900 IX=1,3
!
! CHAIN ALL ASPECTS TOGETHER
      IF(LNPNM) THEN
         DO 600 J=1,NM
         TMP=0.D0
         DO 500 I=1,NPDEGF
         TMP=TMP+DDDA(I,IX,KPASS)*ACOF4(I,J+1,IX,KPASS)
  500    CONTINUE
         TMP=TMP*DIST
         DO 550 K=IS,NP
      PMPA(IAVP(K,IJPT(KPASS),KPASS))=PMPA(IAVP(K,IJPT(KPASS),KPASS))+  &
     &   TMP*PXEPA(IAVP(K,IJPT(KPASS),KPASS),J,IX,KPASS)
!     if(J.eq.1)                                                       &
!    & write(6,*)' dbg PM1 ',PMPA(IAVP(K,IJPT(KPASS),KPASS)),           &
!    & PXEPA(IAVP(K,IJPT(KPASS),KPASS),J,IX,KPASS) ,                    &
!    & IAVP(K,IJPT(KPASS),KPASS),J,IX,KPASS
  550    CONTINUE
  600    CONTINUE
      ELSE
         DO 800 J=1,NM
         TMP=0.D0
         DO 700 I=1,NPDEGF
         TMP=TMP+DDDA(I,IX,KPASS)*ACOF4(I,J+1,IX,KPASS)
  700    CONTINUE
         TMP=TMP*DIST
         DO 750 K=IS,NP
      PMPA(IAVP(K,IJPT(KPASS),KPASS))=PMPA(IAVP(K,IJPT(KPASS),KPASS))+  &
     &   TMP*PXEPA(J,IAVP(K,IJPT(KPASS),KPASS),IX,KPASS)
  750    CONTINUE
  800    CONTINUE
      ENDIF
!
!
  900 CONTINUE

!
!
 1000 CONTINUE
      IF(ICUT.EQ.2) GO TO 1005
      JQP=1+(ISAT1-1)*6
      TEST=ABS(PMPA(JQP)-PMPAH(JQP))
      IF(TEST.GT.CPEDIT) LED6=.TRUE.
      TEST=ABS(PMPA(JQP+1)-PMPAH(JQP+1))
      IF(TEST.GT.CPEDIT) LED6=.TRUE.
      TEST=ABS(PMPA(JQP+2)-PMPAH(JQP+2))
      IF(TEST.GT.CPEDIT) LED6=.TRUE.
      IF(ISAT1.EQ.ISAT2) GO TO 1001
      JQP=1+(ISAT2-1)*6
      TEST=ABS(PMPA(JQP)-PMPAH(JQP))
      IF(TEST.GT.CPEDIT) LED6=.TRUE.
      TEST=ABS(PMPA(JQP+1)-PMPAH(JQP+1))
      IF(TEST.GT.CPEDIT) LED6=.TRUE.
      TEST=ABS(PMPA(JQP+2)-PMPAH(JQP+2))
      IF(TEST.GT.CPEDIT) LED6=.TRUE.
 1001 CONTINUE
      IF(DIST.GT.1.5D0) LEDIT=.TRUE.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!   IF(IDLAS1.NE.2.AND.IDLAS2.NE.2) LEDIT=.TRUE.
!!!   IF(IDLAS1.EQ.2.AND.IDLAS2.EQ.2) LEDIT=.TRUE.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      IF(.NOT.LED6) GO TO 1004
      LEDIT=.TRUE.
      LSMALL=.FALSE.
      JQP=1+(ISAT1-1)*6
      PMPA(JQP)=PMPAH(JQP)
      PMPA(JQP+1)=PMPAH(JQP+1)
      PMPA(JQP+2)=PMPAH(JQP+2)
      PMPA(JQP+3)=PMPAH(JQP+3)
      PMPA(JQP+4)=PMPAH(JQP+4)
      PMPA(JQP+5)=PMPAH(JQP+5)
      IF(ISAT1.EQ.ISAT2) GO TO 1010
      JQP=1+(ISAT2-1)*6
      PMPA(JQP)=PMPAH(JQP)
      PMPA(JQP+1)=PMPAH(JQP+1)
      PMPA(JQP+2)=PMPAH(JQP+2)
      PMPA(JQP+3)=PMPAH(JQP+3)
      PMPA(JQP+4)=PMPAH(JQP+4)
      PMPA(JQP+5)=PMPAH(JQP+5)
      GO TO 1010
 1004 CONTINUE
      IS=NP1+1
      NP=NADJST
 1005 CONTINUE
      IF(LSMALL.AND.NPVAL0(IXRSEP).GE.1) THEN
         PMPA(IPVAL0(IXRSEP))=PMPA(IPVAL0(IXRSEP))+PARSPC*DIST
         LL(KLAVOI-1+IPVAL0(IXRSEP))=.FALSE.
      ENDIF
 1010 CONTINUE
!
!
!
      IF(LSMALL.AND..NOT.LSMALT) XNOK0=XNOK0+1.D0
      IF(LSMALL) LSMALT=.TRUE.
      IF(.NOT.LSTINR) RETURN
      TIME1=DFLOAT(MJDS1)+FSEC1(I1PT)+0.5D0*(1.D0+T1C)*DINV12
      TIME2=DFLOAT(MJDS2)+FSEC2(I2PT)+0.5D0*(1.D0+T2C)*DINV22
      M1=TIME1
      FSECET(1)=TIME1-DBLE(M1)
      CALL UTCET(.FALSE.,1,M1,FSECET,FSECUT,AA(KA1UT))
      M2=TIME2
      FSECET(1)=TIME2-DBLE(M2)
      CALL UTCET(.FALSE.,1,M2,FSECET,FSECUT(2),AA(KA1UT))
      DO IPS=1,2
         PRP(IPS)=SQRT(XPRN0(1,IPS)*XPRN0(1,IPS)                       &
     &                 +XPRN0(2,IPS)*XPRN0(2,IPS)                       &
     &                 +XPRN0(3,IPS)*XPRN0(3,IPS))
         XLATP(IPS)=ASIN(XPRN0(3,IPS)/PRP(IPS))/DEGRAD
         XLONP(IPS)=ATAN2(XPRN0(2,IPS),XPRN0(1,IPS))/DEGRAD
      ENDDO
      PDIF=PRP(2)-PRP(1)
      IF(.NOT.LA2) PDIF=-PDIF
      AD(1:1)='A'
      AD(2:2)='A'
      IF(.NOT.LA1) AD(1:1)='D'
      IF(.NOT.LA2) AD(2:2)='D'
      EDC='FFFFFF'
      IF(LED1) EDC(1:1)='T'
      IF(LED2) EDC(2:2)='T'
      IF(LED3) EDC(3:3)='T'
      IF(LED4) EDC(4:4)='T'
      IF(LED5) EDC(5:5)='T'
      IF(LED6) EDC(6:6)='T'
!
!
!
!
            WRITE(49,7000) KEY1,M1,FSECUT(1),M2,FSECUT(2),              &
     &                     ANGV,RMS,SLOPE,XLATP(1),XLONP(1),DIST,       &
     &                     PDIF,IDSAT1,IDSAT2,                          &
     &                     ILAND1,ILAND2,                               &
     &                     AD,EDC,                                      &
     &                     KEY2,IDLAS1,IDLAS2
      RETURN
 6000 FORMAT(' ')
 6001 FORMAT(' EXECUTION TERMINATING IN SUBROUTINE EXDYN2')
 6002 FORMAT(' DEGREE OF POLYNIMIAL FIT REQUESTED:',I3)
 6003 FORMAT(' LARGER THAN MAX ALLOWABLE:',I3)
 6004 FORMAT(' NUMBER OF SAT STATE PARAMETERS ',I7)
 7000 FORMAT(I10,1X,I10,1X,F9.4,1X,I10,1X,F9.4,1X,F5.2,1X,F7.4,1X,F7.4, &
      &       1X,F9.4,1X,F9.4,1X,F8.3,1X,F9.3,2I9,1X,2I1,1X,A2,1X,A6,   &
      &       1X,I10,2I5)
      END