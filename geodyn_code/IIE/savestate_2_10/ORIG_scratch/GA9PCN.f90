!$GA9PCN
      SUBROUTINE GA9PCN(PMPP,RESID,WT,NP,NRMTOT,NM,ATPA,ATPL,SCRTCH,    &
     &                 PARMVC,NREDGA,LREDGA,IREDGA,WTAACC,CTMACC,       &
     &                 RTGRGA,IDIM1,IDIMT,IDIM4,IK,AA,LAVOID,IFWEGA)
!********1*********2*********3*********4*********5*********6*********7**
! GA9PCN
!
! FUNCTION:  CALL SUMNM WITH THE RIGHT CONSTRAINT INFORMATION
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   PMPP     I         FULL ARRAY OF PARTIALS(INCLUDING ZEROS WHERE
!                      NECCESSARY) FOR EACH MEASUREMENT.SOMETIMES A
!                      INCLUDES ONLY ARC,SOMTIMES ARC&COMMON.
!   RESID    I         RESIDUAL ARRAY
!   WT       I         MEASUREMENT WEIGHT ARRAY
!   NP       I         NUMPER OF PARAMETERS
!   NRMTOT   I         MAXIMUM DIMENSION OF NORMAL MATRIX
!   NM       I         NUMBER OF MEASUREMENTS
!   ATPA     O         NORMAL MATRIX
!   ATPL     O         RIGHT HAND SIDE OF NORMAL EQUATIONS
!   SCRTCH       A     SCRATCH ARRAY
!   LREDGA  I     A    FLAGS FOR CONSTRAINTS APPLICATION (IDIR,ICON,ISAT
!   NREGDA  I     A    NUMBER OF CONTINUOUS TIME PERIODS (ISET,IDIR,ICON
!                      ISAT)
!   IREDGA  0     A    ARRAY OF POINTERS TO ADJUSTED PARAMETERS
!   WTAACC  I     A    ARRAY OF WEIGHTS FOR ACCELERATION CONSTRAINTS
!   CTMACC  I     A    ARRAY OF CORRELATION TIMES FOR ACCELERARTION
!                      CONSTRAINTS
!   RTGRGA  I     A    ARRAY OF TIMES
!   IDIM1   I     S    FIRST DIMENSION OF NREDGA
!   IDIM4   I     S    FOURTH  DIMENSION OF NREDGA
!   IDIMT   I     S    FIRST DIMENSION OF RTGRGA
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION  (A-H,O-Z),LOGICAL(L)
      SAVE
!
      COMMON/BIAOR/NAMBB,NCYCB,NAMBBH
      COMMON/CGLBAR/LGDRAG,NXGLAR
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
      COMMON/CNIARC/NSATA,NSATG,NSETA,NEQNG,NMORDR,NMORDV,NSORDR,       &
     &              NSORDV,NSUMX,NXDDOT,NSUMPX,NPXDDT,NXBACK,NXI,       &
     &              NXILIM,NPXPF,NINTIM,NSATOB,NXBCKP,NXTIMB,           &
     &              NOBSBK,NXTPMS,NXCNIA
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
      COMMON/CITERL/LSTGLB,LSTARC,LSTINR,LNADJ ,LITER1,LSTITR,          &
     &              LOBORB,LRESID,LFREEZ,LSAVEF,LHALT,LADJPI,LADJCI
      COMMON/EMAT  /EMTNUM,EMTPRT,EMTCNT,VMATRT,VMATS,VMATFR,FSCVMA,    &
     &              XEMAT
!
      DIMENSION PMPP(NP),RESID(1),WT(1),ATPA(1),ATPL(NP),SCRTCH(NP)
      DIMENSION PARMVC(NP)
      DIMENSION LREDGA(3,3,1)
      DIMENSION NREDGA(IDIM1,3,3,IDIM4)
      DIMENSION RTGRGA(IDIMT,IDIM1,3,3,IDIM4)
      DIMENSION IREDGA(IDIMT,IDIM1,3,3,IDIM4)
      DIMENSION WTAACC(IDIM1,3,3,IDIM4)
      DIMENSION CTMACC(IDIM1,3,3,IDIM4)
      DIMENSION FSEC(1),IYMD(1),IHM(1),SEC(1)
      DIMENSION AA(1)
      DIMENSION LAVOID(1)
      DIMENSION IFWEGA(IDIM1,3,3,IDIM4)
!
!
      DATA ZERO/0.0D0/,ONE/1.D0/
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
      DO 5000 IL=1,IDIM1
      DO 3000 II=1,3
      DO 2000 JJ=1,3
      IF(.NOT.LREDGA(JJ,II,IK)) GO TO 2000
      IF(LSTITR) THEN
! IF THIS IS THE LAST ITERATION, CHECK IF THIS HAS BEEN DONE
! FOR EMATRIX.
! IFWEGA(IL,JJ,II,IK)=-1, NOMRMAL MATRIX HAS ALREADY BEEN UPDATED BEFORE
! CALLING EMATRIX IN ENDITR.
! IFWEGA(IL,JJ,II,IK)=0 OR 1, WE UPDATE THE NORMAL MATRIX
        IF(IFWEGA(IL,JJ,II,IK).LT.0) THEN
          GOTO 2000
        ELSE IF(IFWEGA(IL,JJ,II,IK).EQ.1) THEN
          IFWEGA(IL,JJ,II,IK)=-1
        ENDIF
      ENDIF
      SCAL=EXP(1.D0)
      WTB=SCAL/(WTAACC(IL,JJ,II,IK)*WTAACC(IL,JJ,II,IK))
      NTR=NREDGA(IL,JJ,II,IK)
!     write(6,*)' dbg NTR WTAACC ',NTR, il,jj,ii,ik,wtaacc(il,jj,ii,ik),
!    .scal,wtb
      IF(NTR.LE.1) THEN
!     WRITE(6,*)' SKIP THIS PARAMETER IT CANNOT BE CONSTRAINED '
      GOTO 5000
      ENDIF
      NTR1=NTR-1
      DO 500 J=1,NTR1
      J1=IREDGA(J,IL,JJ,II,IK)
!     write(6,*)' GA IREDGA ',iredga(j,il,jj,ii,ik),j,il,jj,ii,ik
      TJ=RTGRGA(J,IL,JJ,II,IK)
      ITAG=TJ
      CALL YMDHMS(ITAG,FSEC,IYMD,IHM,SEC,1)
      ITAG=SEC(1)
      IHMS=IHM(1)*100+ITAG
!     WRITE(6,34571) IREDGA(J,IL,JJ,II,IK),IYMD(1),IHMS
      K1=J+1
      DO 100 K=K1,NTR
      K2=IREDGA(K,IL,JJ,II,IK)
!     write(6,*)' GA IREDGA 2  ',iredga(k,il,jj,ii,ik),k,il,jj,ii,ik
      TK=RTGRGA(K,IL,JJ,II,IK)
      ITAG=TK
      CALL YMDHMS(ITAG,FSEC,IYMD,IHM,SEC,1)
      ITAG=SEC(1)
      IHMS=IHM(1)*100+ITAG
!     WRITE(6,34571) IREDGA(K,IL,JJ,II,IK),IYM@(1),IHMS
      VAL=ABS(TK-TJ)
!     WRITE(6,*)' dbg TIME DIFF ',VAL
!     WRITE(6,*)' SAT PARAM INTERVAL  ',IK,JJ,II,J
!
      EARG=-ABS(TK-TJ)/CTMACC(IL,JJ,II,IK)
      WW=EXP(earg)
      WT(1)=WTB*EXP(EARG)
!     WRITE(6,*)' dbg WEIGHT ',WT(1),WTB,EARG,WW,ctmacc(il,jj,ii,ik)
      RESID(1)=PARMVC(K2)-PARMVC(J1)
!     WRITE(6,*)' dbg RESID ',RESID(1),PARMVC(K2),K2,PARMVC(J1),J1
      DO 60 KK=1,NP
      LAVOID(KK)=.TRUE.
!     write(6,*)' dbg PMPP ',pmpp(kk),kk
      PMPP(KK)=ZERO
   60 END DO
      LAVOID(K2+NAMBB)=.FALSE.
      LAVOID(J1+NAMBB)=.FALSE.
      PMPP(K2+NAMBB)=-ONE
      PMPP(J1+NAMBB)=ONE
      CALL SUMNM(PMPP,RESID,WT,NP,NRMTOT,1,ATPA,ATPL,SCRTCH,LAVOID)
  100 END DO
  500 END DO
 2000 END DO
 3000 END DO
 5000 END DO
      RETURN
34571 FORMAT('  ADJUSTED PARM NUM:',I8,' TIME TAG ',I8,3X,I6)
      END