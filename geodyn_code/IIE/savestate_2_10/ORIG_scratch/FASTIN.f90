
      SUBROUTINE FASTIN(GM2,XPS,XDDP,XDDS,TRQP,TRQS,DXSDXA,IAP,AA,II,   &
     &                  NCCALL,MJDSEC,FSEC,PXDDXP,PXDDXS,NEQNP,NEQNS)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!  PURPOSE: COMPUTE THE GRAVITATIONAL INTERACTIONS BETWEEN A PRIMARY
!           AND SECONDARY ASTEROID. ASO COMPUTE THE MATRIX OF SECONDARY
!           ASTEROID ACCEL CHANGES WRT TO SECONDARY POSITION CHANGES
!
!  ARGS:  GM2    - (I) GM OF SECONDARY ASTEROID
!         XPS    - (I) STATE OF SECONDARY ASTEROID WRT PRIMARY IN J2000
!         XPS    - (I) STATE OF SECONDARY ASTEROID WRT PRIMARY IN J2000
!         XDDP   - (O) ACCEL OF PRIMARY DUE TO AST SYSTEM INTERACRIONS
!         XDDS   - (O) ACCEL OF SECONDARY DUE TO AST SYSTEM INTERACRIONS
!         TRQP   - (O) TORQUE ON PRIMARY DUE TO AST SYSTEM INTERACRIONS
!         TRQS   - (O) TORQUE ON PRIMARY DUE TO AST SYSTEM INTERACRIONS
!         DXSDXA - (O) MATRIX OF SECONDARY ASTEROID ACCEL CHANGES WRT TO
!                      SECONDARY POSITION CHANGES
!         IAP    - (I) ANGLE PERTURBATION FLAG. 0=>COMPUTE GRAVITY AND
!                      TORQUES WITH CORRECT VALUES OF RA,DEC AND W FOR
!                      BOTH ASTEROIDS. >0=>COMPUTE GRAVITY AND TORQUES
!                      WITH ONE OF THE SIX ANGLES PERTURBED. 1-3 FOR
!                      ASTEROUD. ORDER RA,DEC, W.
!         AA     - (I) ARRAY CONTAING ALL FLOATING POINT ARRAYS THAT
!                      HAVE BEEN ALLOCATED
!         II     - (I) ARRAY CONTAING ALL INTEGER ARRAYS THAT
!                      HAVE BEEN ALLOCATED
!         NCCALL - (I) POINTER TO PRECOMPUTED COORDINATE SYSTEM
!                      QUANTITIES FOR PTIMARY ASTREROID
!         MJDSEC - (I) ELAPSED INTEGER SECONDS FOR THIS CALL SINCE
!                      JD 2430000.5
!         FSEC   - (I) FRACTIONAL REMAINING SECONDS FOR THIS CALL
!                      SINCE MJDSEC
!         PXDDXP - (O) ARRAY OF EXPLCIT PARTIALS OF ACCELS FOR PRIMARY
!         PXDDXS - (O) ARRAY OF EXPLCIT PARTIALS OF ACCELS FOR SECODARY
!         NEQNP  - (I) NUMBER OF ADJUSTING FORCE MODEL PARAMETERS FOR
!                      THE PRIMARY
!         NEQNS  - (I) NUMBER OF ADJUSTING FORCE MODEL PARAMETERS FOR
!                      THE SECONARY
!
!
!  NOTES:   (1)THE PRIMARY ASTEROID IS IN ORBIT ABOUT THE SUN AND THE
!              SECONDARY IS IN ORBIT AROUND THE PRIMARY. THE SECONDARY
!              IS A 3RD BODY PERT ON THE PRIMARY. SO XDDP SHOULD BE
!              THE DIFFERNCE BETWEEN THE ACCELS THAT THE SECONDARY
!              IMPARTS ON THE SUN AND THE PRIMARY. IT IS ASSUMED THAT
!              SECONARY'S EFFECT ON THE SUN CAN BE IGNORED
!           (2)DXSDXA IS COMPUTED NUMERICALLY BECAUSE WHEN BOTH
!              ASTEROIDS HAVE NONSPHERICAL GRAVITY FIELDS, THE I
!              INTERACTIONS ARE VERY COMPLICATED. THIS QUANTITY IS
!              NOT COMPUTED UNLESS IAP=0
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      COMMON/AXIS/LINTAX
      COMMON/CGRAV/GM,AE,AESQ,FE,FFSQ32,FSQ32,XK2,XK3,XLAM,SIGXK2,      &
     &      SIGXK3,SIGLAM,RATIOM(2),AU,RPRESS
      COMMON/CITERL/LSTGLB,LSTARC,LSTINR,LNADJ ,LITER1,LSTITR,          &
     &              LOBORB,LRESID,LFREEZ,LSAVEF,LHALT,LADJPI,LADJCI
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
      COMMON/CORI03/KICRD ,KICON ,KISTNO,KINDPI,KMJDPL,KIPOLC,          &
     &              KNDOLA,KIOLPA,KKIOLA,KIP0OL,KNDOLM,KIOLPM,          &
     &              KKIOLM,KIPVOL,KICNL2,KICNH2,                        &
     &              KSTMJD, KNUMST, KITAST, KSTNRD, KICNV,              &
     &              KTIDES,KFODEG,KFOORD,KRDEGR,KRORDR,                 &
     &              KPHINC,KDOODS,KOTFLG,KJDN  ,KPTDN ,                 &
     &              KATIND,KPRESP,KMP2RS,KSITE,KPTOLS,NXCI03
      COMMON/CRMB/RMB(9), rmb0(9)
      COMMON/CRMB2/RMB2(9), rmb02(9)
      COMMON/INERTIA/WMNRT(6,2)
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
      COMMON/VAXINT/XAXIS(3,3,3)
      DIMENSION XAXISH(3,3,2)
      DIMENSION XPS(3),XDDP(3),XDDS(3),TRQP(3),TRQS(3)
      DIMENSION XDDPH(3,4),XDDSH(3,4)
      DIMENSION PXDDXP(NEQNP,3)
      DIMENSION PXDDXS(NEQNS,3)
      DIMENSION DXSDXA(3,6)
      DIMENSION AA(1),II(1)
      DIMENSION ROTI(9),X(3)
      DIMENSION H(3,4)
      DIMENSION DC123(3),DS123(3),DVECT(3),CMAT(3,3)
      DIMENSION XMNRT2(3)
      DIMENSION ACCA(3,4),ACCB(3,4)
!!!   DATA PERT/1.D-2/
      DATA PERT/1.D-3/
!
!
      IF(IAP.EQ.0) THEN
        IF(NEQNP.GT.0) THEN
          DO I=1,NEQNP
            PXDDXP(I,1)=0.D0
            PXDDXP(I,2)=0.D0
            PXDDXP(I,3)=0.D0
          ENDDO
        ENDIF
        IF(NEQNS.GT.0) THEN
          DO I=1,NEQNS
            PXDDXS(I,1)=0.D0
            PXDDXS(I,2)=0.D0
            PXDDXS(I,3)=0.D0
          ENDDO
        ENDIF
      ENDIF
!
!
      ITUP=4
      IF(IAP.GT.0) ITUP=1
!
! MAKE SURE ASTEROID AXES ARE SET CORRECTLY
! IF IAP=0, NO NEED TO PERTURB AXES
!
      IF(IAP.EQ.0) THEN
        IF(.NOT.LINTAX) CALL LODAX2(MJDSEC,SEC,AA,II)
        DO I=1,18
         XAXISH(I,1,1)=XAXIS(I,1,1)
        ENDDO
        GO TO 50
      ENDIF
!
!  THE FOLLOWING CODE THROUGH 50 CONTINUE IS TO PERTURB
!  AXES FOR THE SAKE OF GETING DERIVATIVES OF TORQUE
!  WIT RESPECT TO RA, DEC AND W ANGLES
!  IAP HERE MUST BE GT.0
!
      I1PERT=0
      I2PERT=0
      IF(IAP.GE.1.AND.IAP.LE.3) I1PERT=IAP
      IF(IAP.GE.4.AND.IAP.LE.6) I2PERT=IAP-3
!
! GET THE SECONDARY'S  J2000 ---> BF MATRIX (RMB2)
      CALL PREFCS(MJDSEC,FSEC,AA,II,COSTG,SINTG,ROTI)
      CALL REFCRS(.FALSE.,SINTG,COSTG,                                  &
     &   AA(KDPSR),AA(KXPUT),AA(KYPUT),MJDSEC,FSEC,ROTI(1),             &
     &   ROTI(2),ROTI(3),ROTI(4),ROTI(5),ROTI(6),ROTI(7),               &
     &   ROTI(8),ROTI(9),AA(KA1UT),                                     &
     &   II(KINDPI),AA(KXDPOL),AA(KXDOTP),I2PERT)
! SWITCH RMB TO RMB2
       DO I=1,9
         RMB2(I)=RMB(I)
       ENDDO
!
! GET THE PRIMARY'S  J2000 ---> BF MATRIX (RMB)
      CALL PREFCR(NCCALL,0.D0,.FALSE.,AA,COSTG,SINTG,ROTI)
      CALL REFCRS(.FALSE.,SINTG,COSTG,                                  &
     &   AA(KDPSR),AA(KXPUT),AA(KYPUT),MJDSEC,FSEC,ROTI(1),             &
     &   ROTI(2),ROTI(3),ROTI(4),ROTI(5),ROTI(6),ROTI(7),               &
     &   ROTI(8),ROTI(9),AA(KA1UT),                                     &
     &   II(KINDPI),AA(KXDPOL),AA(KXDOTP),I1PERT)
!
!
      XAXISH(1,1,1)=RMB(1)
      XAXISH(2,1,1)=RMB(4)
      XAXISH(3,1,1)=RMB(7)
!
      XAXISH(1,2,1)=RMB(2)
      XAXISH(2,2,1)=RMB(5)
      XAXISH(3,2,1)=RMB(8)
!
      XAXISH(1,3,1)=RMB(3)
      XAXISH(2,3,1)=RMB(6)
      XAXISH(3,3,1)=RMB(9)
!
      XAXISH(1,1,2)=RMB2(1)
      XAXISH(2,1,2)=RMB2(4)
      XAXISH(3,1,2)=RMB2(7)
!
      XAXISH(1,2,2)=RMB2(2)
      XAXISH(2,2,2)=RMB2(5)
      XAXISH(3,2,2)=RMB2(8)
!
      XAXISH(1,3,2)=RMB2(3)
      XAXISH(2,3,2)=RMB2(6)
      XAXISH(3,3,2)=RMB2(9)
!
!
!
!
!
  50  CONTINUE
!
!
!
      XMNRT2(1)=WMNRT(1,2)
      XMNRT2(2)=WMNRT(2,2)
      XMNRT2(3)=WMNRT(3,2)
!
      DO 100 IT=1,ITUP
      LONLYF=.FALSE.
      IF(IT.GT.1) LONLYF=.TRUE.
      X(1)=XPS(1)
      X(2)=XPS(2)
      X(3)=XPS(3)
      IF(IT.EQ.2) X(1)=X(1)+PERT
      IF(IT.EQ.3) X(2)=X(2)+PERT
      IF(IT.EQ.4) X(3)=X(3)+PERT
      R2=X(1)*X(1)+X(2)*X(2)+X(3)*X(3)
      R3=SQRT(R2)*R2
      H(1,IT)=-X(1)/R3
      H(2,IT)=-X(2)/R3
      H(3,IT)=-X(3)/R3
      CALL GETOR2(XAXISH,XAXISH(1,1,2),X,CMAT,DNORM,DC123,DS123,DVECT, &
     &           .FALSE.)
      CALL FTAST(XAXISH(1,1,2),XMNRT2,AA(KCN),GM2,CMAT,DNORM,DS123,     &
     &           DC123,DVECT,ACCA(1,IT),ACCB(1,IT),TRQP,TRQS,LONLYF)
      XDDPH(1,IT)=-H(1,IT)*GM2
      XDDPH(2,IT)=-H(2,IT)*GM2
      XDDPH(3,IT)=-H(3,IT)*GM2
      XDDSH(1,IT)=H(1,IT)*(GM+GM2)
      XDDSH(2,IT)=H(2,IT)*(GM+GM2)
      XDDSH(3,IT)=H(3,IT)*(GM+GM2)
 100  CONTINUE
!
      DO I=1,3
        XDDP(I)=XDDPH(I,1)
        XDDS(I)=XDDSH(I,1)
      ENDDO
!
      DO I=1,3
       XDDP(I)=XDDP(I)+ACCA(I,1)
       XDDS(I)=XDDS(I)+ACCB(I,1)-ACCA(I,1)
      ENDDO
!!!
!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      IF(ITUP.LT.2) RETURN
      DO 200 IT=2,4
      DO 190 I=1,3
      DXSDXA(I,IT-1)=(XDDSH(I,IT)+ACCB(I,IT)-ACCA(I,IT)-XDDS(I))/PERT
      DXSDXA(I,IT+2)=0.D0
 190  CONTINUE
 200  CONTINUE
      IF(.NOT.LSTINR) RETURN
      IF(NPVAL0(IXGM).EQ.0.AND.NPVAL0(IX2GM).EQ.0) RETURN
      IF(NPVAL0(IXGM).EQ.0) GO TO 300
!
! THIS IS FOR THE SECONDARY ASTEROID
      IPT=NEQNS-NPVAL0(IX2GM)-NPVAL0(IX2SCO)-NPVAL0(IX2CCO)
      IPT=IPT-NPVAL0(IXFGFM)-NPVAL0(IXXTRO)
      PXDDXS(IPT,1)=H(1,1)+ACCB(1,1)/GM
      PXDDXS(IPT,2)=H(2,1)+ACCB(2,1)/GM
      PXDDXS(IPT,3)=H(3,1)+ACCB(3,1)/GM
 300  CONTINUE
!
! THIS IS FOR BOTH THE PRIMARY AND SECONDARY ASTEROID
! GM OF THE SECONARY SHOULD BE THE FINAL FORCE MODEL PARMETER FOR THE PRIMARY AN
      IF(NPVAL0(IX2GM).EQ.0) RETURN
      PXDDXP(NEQNP,1)=-H(1,1)+ACCA(1,1)/GM2
      PXDDXP(NEQNP,2)=-H(2,1)+ACCA(2,1)/GM2
      PXDDXP(NEQNP,3)=-H(3,1)+ACCA(3,1)/GM2
      PXDDXS(NEQNS,1)=H(1,1)-ACCA(1,1)/GM2
      PXDDXS(NEQNS,2)=H(2,1)-ACCA(2,1)/GM2
      PXDDXS(NEQNS,3)=H(3,1)-ACCA(3,1)/GM2
      RETURN
      END
