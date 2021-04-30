!$IFRACB
      SUBROUTINE IFRACB(AA,II,LL,IARCNO,LRDIFF,L12 ,IFFHDR,IFFLEN,    &
     &    FFBUF)
!********1*********2*********3*********4*********5*********6*********7**
! IFRACB           00/00/00            0000.0    PGMR - ?
!
! FUNCTION:  CONTROLS MOVEMENT OF ARC COMMON BLOCK INFORMATION
!            1. FROM INTERFACE FILE TO EXTENDED VIRTUAL MEMORY(VM)
!            2. FROM EXTENDED VIRTUAL MEMORY TO ARC COMMON BLOCKS
!            3. FROM ARC COMMON BLOCKS TO EXTENDED VITUAL MEMORY
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   AA      I/O   A    REAL DYNAMIC ARRAY
!   II      I/O   A    INTEGER DYNAMIC ARRAY
!   LL      I/O   A    LOGICAL DYNAMIC ARRAY
!   IARCNO   I    S    ARC NUMBER.
!   LRDIFF   I    S    FLAG USED TO CONTROL READING/LOADING
!                      = T READ IFF & STORE IN VIRTUAL MEMORY
!                      = F MOVE FROM VM. TO COMMON BLOCKS OR FROM
!                        COMMON TO VM AS INDICATED BY "L12"
!   L12      I    S    CONTROLS LOADING/UNLOADING OF INFORMATION
!                      =T LOAD FROM VM TO COMMON BLOCKS
!                      =F UNLOAD FROM COMMON TO EXTENDED VM
!   IFFHDR   I    A    SCRATCH ARRAY USED FOR READING HEADER
!                      IFFHDR(IFHEAD)
!   IFFLEN   I    A    SCRATCH ARRAY USED FOR READING LENGTHS
!                      IFFLEN(IFLNTH)  RECORD
!   FFBUF    I    A    SCRATCH ARRAY USED TO HOLD FLOATING POINT
!                      FFBUF(IFBUFR) DATA UNTIL IT IS CONVERTED TO IIE
!                      FLOATING POINT REPRESENTATION
!
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
! COMMON BLOCKS USED BY THIS ROUTINE BUT NOT RECEIVED FROM IFWACB
!
      COMMON/CIFF  /IFHEAD,IFLNTH,IFBUFL,IFBUFR,KDYNHD,KDYNLN,          &
     &              KDYNIF,KDYNFF,NXCIFF
      COMMON/CVIEW /IOUT6 ,ILINE6,IPAGE6,MLINE6,                        &
     &              IOUT8 ,ILINE8,IPAGE8,MLINE8,                        &
     &              IOUT9 ,ILINE9,IPAGE9,MLINE9,                        &
     &              IOUT10,ILIN10,IPAG10,MLIN10,                        &
     &              IOUT15,ILIN15,IPAG15,MLIN15,                        &
     &              IOUT16,ILIN16,IPAG16,MLIN16,                        &
     &              IOUT7 ,NXCVUE
      COMMON/DYNPTR/KDEPHM,KDEPH2,KDAHDR(3,9),KDYNAP(3,9,2),KDNEXT(3),  &
     &NXDYNP
      COMMON/UNITS/IUNT11,IUNT12,IUNT13,IUNT19,IUNT30,IUNT71,IUNT72,    &
     &             IUNT73,IUNT05,IUNT14,IUNT65,IUNT88,IUNT21,IUNT22,    &
     &             IUNT23,IUNT24,IUNT25,IUNT26
!
      DIMENSION FFBUF(IFBUFR)
      DIMENSION IFFHDR(IFHEAD),IFFLEN(IFLNTH)
      DIMENSION AA(1),II(1),LL(1)
!
! COMMON BLOCKS CONTAINING REAL DATA TO BE LOADED FROM IFF
!
      COMMON/ALBMIS/ALBON,ALBCON,EMSCON,ALBTUM,XALBMI
      COMMON/ARCPR /FSECRF,XARCPR
      COMMON/ATMPAR/XMAXHT,XATMPA
      COMMON/CAMCCD/CKXMAT(30,6),CAMCTR(30,2),XKXCCD
      COMMON/CEDIT /EDITX ,EDTRMS,EDLEVL,CONVRG,GLBCNV,EBLEVL,EDITSW,   &
     &              ENPX  ,ENPRMS,ENPCNV,EDBOUN,FREEZI,FREEZG,FREEZA,   &
     &              XCEDIT
      COMMON/CORBNA/FNFSTR,FNFSTP,FNFRT,XCORN
      COMMON/EMAT  /EMTNUM,EMTPRT,EMTCNT,VMATRT,VMATS,VMATFR,FSCVMA,    &
     &              XEMAT
      COMMON/PARAM0/spsf0(6),deltasp(6),rhosp(6),rhoxp(6),   &
     & rhozp(6),rhozm(6),aplusdxp(6),aplusdzp(6),aplusdzm(6),&
     & asmcsp0(6),asmcxp0(6),asmczp0(6),asmczm0(6),XPRM0
      COMMON/SIMLM/OBSINT,VINT,ELCUTO,XSMLM
      COMMON/THERMD/DRGSAT,DTHSC,ZETA,SPAXT,SPAXL,THRMFL,XTHERM
      COMMON/TIEOUT/XSCTIE,XSCTRF,YMDRRF,YMDTRF,XTIE,XTIEOU
      COMMON/TITLEC/TITLEG(10,3),TITLEA(10,10),XTITLE
      COMMON/TITLER/TITLEN,XTITLR
      COMMON/YAWTOP/YAWLIM(3),XYAWTP
      COMMON/UCLJAS/COLMAX,ROWMAX,RMNLON,RMXLON,RMNLAT,RMXLAT,XUCLJA
      COMMON/UCLGFO/COLMAXG,ROWMAXG,RMNLONG,RMXLONG,RMNLATG,RMXLATG,   &
     &              XUCLGF
      COMMON/UCLENV/COLMAXE,ROWMAXE,RMNLONE,RMXLONE,RMNLATE,RMXLATE,   &
     &              XUCLEN
!
! COMMON BLOCKS CONTAINING INTEGER DATA
!
      COMMON/ACCEL9/MXACC9,ITOTGA,NUMGA,ITYPGA,MACC,NXACC9
      COMMON/ACCELO/IDYNDL(3),IDYNSN(3),IGEOSN(3),NXACCO
      COMMON/ALBINT/IRINGS,ISPOTS,IMAXA,IMAXE,MMAXA,MMAXE,KMAXA,KMAXE,  &
     &              KALB,KEMM,KLMOD,IMODEL,NPNALB,NXALBI
      COMMON/ALBMAX/MRINGS,MSPOTS,MIMAXA,MIMAXE,MMMAXA,MMMAXE,          &
     &              MKMAXA,MKMAXE,                                      &
     &              MIMA1A,MIMA1E,MMMA1A,MMMA1E,                        &
     &              MKMA1A,MKMA1E,                                      &
     &              NXALMX
      COMMON/ALTCB /NALTW,MAXIT,NPERT,NXALT
      COMMON/ARCPAR/MAXSEL,NSEL,MAXDEL,NDEL,MAXMET,NMETDT,NSATID,       &
     &              IATDEN,ISATEQ,ITRMAX,ITRMIN,ITRMX2,                 &
     &              MJDSRF,MREFSY,NTDDR,NBTOTL,IDRAGM,IMRNUT,           &
     &              NXARCP
      COMMON/ATTCB /KPAT,MAXAT,MAXLAS,IBLAS,                            &
     &              NASAT,IATCNT,NXATT
      COMMON/BURN  /NBGRP,NBMODE,NBURN
      COMMON/C12PRM/IDSATS(10,2),IP1,IP2,NXC12P
      COMMON/CAMSAT/NCAM,NSCID(30),NXSCID
      COMMON/CANTEN/NCUT,NXANTE
      COMMON/CEBARC/NEBIAS,NBIASE,NXCEBA
      COMMON/CIMDST/IDRLTM(200),ITRLTM(200),IRELON,IRLONA,NRLTMC,       &
     & IDRCK4(200),IRKONA,NROCK4,IRKRAD,NXIRTM
      COMMON/CITERM/MAXINR,MININR,MAXLST,IHYPSW,NXITER
      COMMON/CLASCI/LASCII,LIFCYB,LARECL,NXLASC
      COMMON/CNIARC/NSATA,NSATG,NSETA,NEQNG,NMORDR,NMORDV,NSORDR,       &
     &              NSORDV,NSUMX,NXDDOT,NSUMPX,NPXDDT,NXBACK,NXI,       &
     &              NXILIM,NPXPF,NINTIM,NSATOB,NXBCKP,NXTIMB,           &
     &              NOBSBK,NXTPMS,NXCNIA
      COMMON/COBSI /MODRES,NXCOBS
      COMMON/CORBNF/MAXINF,NORBNF,INFSTA(15),INFNDX(15),INFSTR,INFSTP,  &
     &              INFRT ,NXCORB
      COMMON/IMAG2S/NIMBLK,NIMTOT,NIMG2S
      COMMON/KNTSTS/KNTACC(9,40),MKNTAC,KNTDRG,KNTSLR,MAXNGA,MAXNDR,    &
     &              MAXNSR,NXKNTS
      COMMON/NEQINT/NINTOT,MEMTOT,NEQNIM,NXNEQS
      COMMON/NPCOM /NPNAME,NPVAL(92),NPVAL0(92),IPVAL(92),IPVAL0(92),   &
     &              MPVAL(28),MPVAL0(28),NXNPCM
      COMMON/SIMPAR/MAXCON,NCON,MXLEN,NSDLEN,NSDLER,NPATRN,ISTATS,      &
     &              NXSIML
      COMMON/SOLTUM/INDTUM,NDTUM,ITUMSC(32),IFLAG1,IFLAG3,NXSOLT
      COMMON/TOPOVR/NMTPAT,MXTPAT,NOVRID,NGCATT,NTPBIA,NSTLVS,          &
     &              NISLV, NYWBIA,MSATYW,MAXYWB,NSATTP,NXTOPO
      COMMON/UCLJAI/IUCLSAT(50),NUCLJAI
      COMMON/TRAJI/MJDSTR,NTRAJC,MTRAJC,NXTRAJ
      COMMON/TRJREF/NORBTV,NORBFL,NCOFM,NXTREF
      COMMON/XOVERS/NRXTOT,NXBLK,NUSIDE,NDEGX2,NDEGXX,NUCON,ITERNU,     &
     &              IPEDIT,IDEDIT,NXXOVR
      COMMON/ACCLRM/MDYNPD,MBAPPD,MACOBS,IDYNSC(200),MDYNST,IACCSC(200),&
     &              MACCSC,NACPRM(200),NATPRM(200),NXCLRM
      COMMON/MBIAST/MBTRAD,MBTRUN,ICONBIA,IPRCTP,IPREND,NXMBST
      COMMON/IDELTX/MXSTAT,NEVENTS,NDSTAT,IDSYST,NDELTX
      COMMON/YARINT/NYACRD,NXYARK
      COMMON/SPBIAS/NCTSTA,NXSPB
      COMMON/SNAPX /MAXD,MADJST,MAXNM,MXLASR,NPDEG,NXSNAP
      COMMON/SLFSHD/NSHSAT,IDSASH(200),NSPANL(200),IFLGSH(200),         &
     &              IATYSH(200),NSHRCD(200),MNSHPL,NXSFSD
      COMMON/SLRATI/ISLRNS,ISLRID(10),ISLRNO(10),ISLRMO,NXSLRI
      COMMON/GPSINT/IGPSBW,NGPSBW
      COMMON/TELEN/NTELEM,NXTELEN


!
! COMMON BLOCKS CONTAINING LOGICAL DATA
!
      COMMON/BUFOPT/LADRAG,LXTIDE,LPOLTI,NXBUFO
      COMMON/CONTRL/LSIMDT,LOBS  ,LORB  ,LNOADJ,LNADJL,LORFST,LORLST,   &
     &              LORALL,LORBOB,LOBFST,LOBLST,LOBALL,LPREPO,LORBVX,   &
     &              LORBVK,LACC3D,LSDATA,LCUTOT,LACCEL,LDYNAC,LFRCAT,   &
     &              LNIAU, NXCONT
      COMMON/CBINRL/LBINR,LLOCR,LODR,LBNCR,LBINRI,LLOCRI,LODRI,LBNCRI,  &
     &              NXCBIN
      COMMON/LCONST/LCONGA,LCONDR,LCONSR,NXCONS
      COMMON/LMARIN/ LRADEC, LMARIN, LPASCU, NXLMAR
      COMMON/TELEM/LTELEM,NXTELE
      COMMON/TETHER/LTETHR,NXTETH
      COMMON/EXATAL/LEXATA,LEXATM,NXEAAL
      COMMON/UCLJAL/LJBUS(50),LJPAN(50),LJTRR(50),LUGFO,LENVI,NUCLJA
      COMMON/SLRATL/LRATIO,NXSLRL
!
!
      DATA C1M10/1.0D-10/
!
! SET UP DUMMY ARRAYS FOR EQUIVALENCING TO COMMON BLOCKS
!
!  *REAL*
!
      DIMENSION AQARCP(1),AQCEDI(1),AQCORN(1),AQEMAT(1),AQTITL(1),      &
     &          AQSMLM(1),AQALBM(1),AQTITR(1),AQTHRM(1),                &
     &          AQATMP(1),AQYAWT(1),AQLOUV(1),AQTIEO(1),                &
     &          AQUCLJ(1),AQUCLG(1),AQUCLE(1),AQKCCD(1),AQPRM0(1)
!
!  *INTEGER*
!
      DIMENSION IQARCP(1),IQCNIA(1),IQCORB(1),IQNPCM(1),IQCOBS(1),      &
     &          IQTRAJ(1),IQCEBA(1),IQSMPR(1),IQITER(1),IQACC9(1),      &
     &          IQALBI(1),IQALMX(1),IQMDST(1),IQTOPO(1),IQXOVR(1),      &
     &          IQKNTS(1),IQALTC(1),IQATTC(1),IQTREF(1),IQCLRM(1),      &
     &          IQCMBS(1),IQIDST(1),IQANTE(1),IQC12P(1),IQYARK(1),      &
     &          IQSPB(1) ,IQNEQS(1),IQSNAP(1),IQSFSH(1),IQIMAG(1)
      DIMENSION IQACCO(1)
      DIMENSION IQJASN(1)
      DIMENSION IQSLRI(1)
      DIMENSION IQGPSI(1)
      DIMENSION IQCAMS(1)
      DIMENSION IQSOLT(1)
      DIMENSION IQTEL(1)
      DIMENSION IQBURN(1)


!
!  *LOGICAL*
!
      DIMENSION ILBUFO(1),ILCONT(1),ILCBIN(1)
      DIMENSION ILLMAR(1),ILTELE(1),ILEAAL(1)
      DIMENSION ILTETH(1)
      DIMENSION ILCONS(1)
      DIMENSION ILJASN(1)
      DIMENSION ILSLRL(1)
!
!
! EQUIVALENCES FOR COMMON BLOCKS
!
!  *REAL*
!                  ALBMIS
      EQUIVALENCE (AQALBM(1),ALBON)
!                  ARCPR              ATMPAR
      EQUIVALENCE (AQARCP(1),FSECRF),(AQATMP(1),XMAXHT)
!                  CEDIT
      EQUIVALENCE (AQCEDI(1),EDITX)
!                  CORBNA
      EQUIVALENCE (AQCORN(1),FNFSTR)
!                  EMAT
      EQUIVALENCE (AQEMAT(1),EMTNUM)
!                  SIMLM
      EQUIVALENCE (AQSMLM(1),OBSINT)
!                  THERMD             TITLEC
      EQUIVALENCE (AQTHRM(1),DRGSAT),(AQTITL(1),TITLEG(1,1))
!                  TITLER             TIEOUT
      EQUIVALENCE (AQTITR(1),TITLEN),(AQTIEO(1),XSCTIE)
!                  YAWTOP
      EQUIVALENCE (AQYAWT(1),YAWLIM(1))
!                  UCLJAS
      EQUIVALENCE (AQUCLJ(1),COLMAX)
!                  UCLGFO
      EQUIVALENCE (AQUCLG(1),COLMAXG)
!                  UCLENV
      EQUIVALENCE (AQUCLE(1),COLMAXE)
!                      CAMCCD
      EQUIVALENCE (AQKCCD(1),CKXMAT(1,1))
!                  PARAM0
      EQUIVALENCE (AQPRM0(1),spsf0(1))
!
!  *INTEGER*
!                  ACCEL9               ALBINT
      EQUIVALENCE (IQACC9(1),MXACC9),(IQALBI(1),IRINGS)
!                  ACCELO
      EQUIVALENCE (IQACCO(1),IDYNDL(1))
!                  ALBMAX
      EQUIVALENCE (IQALMX(1),MRINGS)
!                  ARCPAR               CNIARC
      EQUIVALENCE (IQARCP(1),MAXSEL),(IQCNIA(1),NSATA )
!                  CEBARC
      EQUIVALENCE (IQCEBA(1),NEBIAS)
!                  CITERM            CIMDST
      EQUIVALENCE (IQITER(1),MAXINR),(IQMDST(1),IDRLTM(1))
!                  COBSI
      EQUIVALENCE (IQCOBS(1),MODRES)
!                  CORBNF               NPCOM
      EQUIVALENCE (IQCORB(1),MAXINF),(IQNPCM(1),NPNAME)
!                  SIMPAR               TRAJI
      EQUIVALENCE (IQSMPR(1),MAXCON),(IQTRAJ(1),MJDSTR)
!                  TOPOVR
      EQUIVALENCE (IQTOPO(1),NMTPAT)
!                  UCLJAI
      EQUIVALENCE (IQJASN(1),IUCLSAT(1))
!                  XOVERS
      EQUIVALENCE (IQXOVR(1),NRXTOT)
!                  KNTSTS
      EQUIVALENCE (IQKNTS(1),KNTACC(1,1))
!                  ALTCB                ATTCB
      EQUIVALENCE (IQALTC(1),NALTW),(IQATTC(1),KPAT)
!                  TRJREF
      EQUIVALENCE (IQTREF(1),NORBTV)
!                  ACCLRM
      EQUIVALENCE (IQCLRM(1),MDYNPD)
!                  MBIAST
      EQUIVALENCE (IQCMBS(1),MBTRAD)
!                  IDELTX
      EQUIVALENCE (IQIDST(1),MXSTAT)
!                  CANTEN
      EQUIVALENCE (IQANTE(1),NCUT)
!                  C12PRM
      EQUIVALENCE (IQC12P(1),IDSATS(1,1))
!                  YARINT
      EQUIVALENCE (IQYARK(1),NYACRD)
!                  SPBIAS
      EQUIVALENCE (IQSPB(1),NCTSTA)
!                  NEQS
      EQUIVALENCE (IQNEQS(1),NINTOT)
!                  SNAPX
      EQUIVALENCE (IQSNAP(1),MAXD)
!                  SLFSHD
      EQUIVALENCE (IQSFSH(1),NSHSAT)
!                  IMAGE
      EQUIVALENCE (IQIMAG(1),NIMBLK)
!                  SLRATI
      EQUIVALENCE (IQSLRI(1),ISLRNS)
!                  GPSINT
      EQUIVALENCE (IQGPSI(1),IGPSBW)
!                  CAMSAT
      EQUIVALENCE (IQCAMS(1),NCAM)
!                  SOLTUM
      EQUIVALENCE (IQSOLT(1),INDTUM)
!                  TELEN
      EQUIVALENCE (IQTEL(1),NTELEM)
!                  BURN
      EQUIVALENCE (IQBURN(1),NBGRP)
!
!  *LOGICAL*
!
!                  BUFOPT             CONTRL
      EQUIVALENCE (ILBUFO(1),LADRAG),(ILCONT(1),LSIMDT)
!                  CBINRL
      EQUIVALENCE (ILCBIN(1),LBINR )
!                 LMARIN
      EQUIVALENCE (ILLMAR(1),LRADEC)
!                 TELEM
      EQUIVALENCE (ILTELE(1),LTELEM)
!                 EXATAL
      EQUIVALENCE (ILEAAL(1),LEXATA)
!                 TETHER
      EQUIVALENCE (ILTETH(1),LTETHR)
!                 LCONST
      EQUIVALENCE (ILCONS(1),LCONGA)
!                 UCLJAL
      EQUIVALENCE (ILJASN(1),LJBUS(1))
!                 SLRATL
      EQUIVALENCE (ILSLRL(1),LRATIO)

!
!
      DATA IBLOCK/50/
      DATA LTIT1/.TRUE./
!
!**********************************************************************
! START OF EXECUTABLE CODE ********************************************
!**********************************************************************
!
      IF(.NOT.LRDIFF) GOTO 1000
!
!**********************************************************************
!  HEADAR RECORD FOR REAL COMMON BLOCKS
!***********************************************************************
      ITYPE=1
      CALL BINRD(IUNT11,IFFHDR  ,IFHEAD)
! TEST BLOCK NUMBER AND DATA TYPE
      IF(IFFHDR(1).NE.IBLOCK .OR. IFFHDR(3).NE.ITYPE) GO TO 60150
      NCOMS1=IFFHDR(4)
      NCOMS =NCOMS1-1
! STORE NCOMS1 IN  EXTENDED VIRTUAL MEMORY
      IPTHDR=KDAHDR(ITYPE,1)
      II(IPTHDR)=NCOMS1
!**********************************************************************
! READ LENGTHS RECORD FOR REAL COMMON BLOCKS(STORE IN VIRTUAL MEMORY)
!**********************************************************************
      CALL BINRD(IUNT11,II(IPTHDR+1) ,NCOMS1)
! LAST WORD READ CONTAINS SUM OF LENGTHS
      NWORDS=II(IPTHDR+NCOMS1)
      IF(NCOMS.LT.1) GOTO 350
!**********************************************************************
! READ DATA RECORDS FOR REAL COMMON BLOCKS(STORE IN VIRTUAL MEMORY)
!**********************************************************************
      IPTR=KDYNAP(ITYPE,1,1)+(IARCNO-1)*KDYNAP(ITYPE,1,2)
      IPTSTR=IPTR
      DO 300 ICOM=1,NCOMS
      NX=II(IPTHDR+ICOM)
      NXABS=ABS(NX)
      IF(NXABS.GT.IFBUFR) GOTO 60400
      XEND=NXABS
      IF(NX.GE.0) THEN
         CALL BINRD2(IUNT11,FFBUF(1),NXABS)
         IF(NX.GT.0) CALL Q9ICLA(FFBUF(1),AA(IPTR),NXABS,ISTAT)
      ELSE
! PROCESS COMMON BLOCKS WITH CHARACTER DATA
         NXABS1=NXABS-1
         CALL BINRCC(IUNT11,FFBUF(1),NXABS)
         CALL MOVER(FFBUF(1),AA(IPTR),NXABS1,.TRUE.)
         CALL Q9ICLA(FFBUF(NXABS),AA(IPTR+NXABS1),1,ISTAT)
! RESET LENGTH TO POSITIVE NUMBER (NEGATIVE INDICATES CHARACTER DATA)
         II(IPTHDR+ICOM)=NXABS
      ENDIF
      IF(ISTAT.NE.0) GOTO 60500
      IPTR=IPTR+NXABS
! VERIFY THAT LAST VARIABLE IN COMMON IS THE LENGTH OF THE COMMON BLOCK
      IF(ABS(AA(IPTR-1) - XEND).GT.C1M10) GO TO 60100
  300 END DO
! TEST IF CORRECT NUMBER OF WORDS READ
      IF(NWORDS.NE.IPTR-IPTSTR) GO TO 60220
  350 CONTINUE
!**********************************************************************
! READ HEADER RECORD FOR INTEGER COMMON BLOCKS
!**********************************************************************
      ITYPE=2
      CALL BINRD(IUNT11,IFFHDR  ,IFHEAD)
! TEST BLOCK NUMBER AND DATA TYPE
      IF(IFFHDR(1).NE.IBLOCK .OR. IFFHDR(3).NE.ITYPE) GO TO 60150
      NCOMS1=IFFHDR(4)
      NCOMS =NCOMS1-1
! STORE NCOMS1 IN  EXTENDED VIRTUAL MEMORY
      IPTHDR=KDAHDR(ITYPE,1)
      II(IPTHDR)=NCOMS1
!**********************************************************************
! READ LENGTHS RECORD FOR INTEGER COMMON BLOCKS-STORE IN V. MEMORY
!**********************************************************************
      CALL BINRD(IUNT11,II(IPTHDR+1),NCOMS1)
      IF(NCOMS.LT.1) GOTO 650
! SAVE LAST WORD READ WHICH CONTAINS SUM OF THE LENGTHS
      NWORDS=II(IPTHDR+NCOMS1)
!**********************************************************************
! READ DATA RECORDS FOR INTEGER COMMON BLOCKS- STORE IN V. MEMORY
!**********************************************************************
      IPTR=KDYNAP(ITYPE,1,1)+(IARCNO-1)*KDYNAP(ITYPE,1,2)
      IPTSTR=IPTR
      DO 600 ICOM=1,NCOMS
      NX=II(IPTHDR+ICOM)
      CALL BINRD(IUNT11,II(IPTR),NX)
      IPTR=IPTR+NX
! VERIFY THAT LAST VARIABLE IN COMMON IS THE LENGTH OF THE COMMON
      IF(II(IPTR-1) .NE. NX) GO TO 60100
  600 END DO
! TEST IF CORRECT NUMBER OF WORDS READ
      IF(NWORDS.NE.IPTR-IPTSTR) GO TO 60220
  650 CONTINUE
!**********************************************************************
! HEADER RECORD FOR LOGICAL COMMON BLOCKS
!**********************************************************************
      ITYPE=3
      CALL BINRD(IUNT11,IFFHDR  ,IFHEAD)
! TEST BLOCK NUMBER AND DATA TYPE
      IF(IFFHDR(1).NE.IBLOCK .OR. IFFHDR(3).NE.ITYPE) GO TO 60150
      NCOMS1=IFFHDR(4)
      NCOMS =NCOMS1-1
! STORE NCOMS1 IN  EXTENDED VIRTUAL MEMORY
      IPTHDR=KDAHDR(ITYPE,1)
      II(IPTHDR)=NCOMS1
!**********************************************************************
! READ LENGTHS RECORD FOR LOGICAL COMMON BLOCKS-STORE IN V. MEMORY
!**********************************************************************
      CALL BINRD(IUNT11,II(IPTHDR+1),NCOMS1)
! SAVE LAST WORD READ WHICH CONTAINS SUM OF THE LENGTHS
      NWORDS=II(IPTHDR+NCOMS1)
      IF(NCOMS.LT.1) GOTO 950
!**********************************************************************
! READ DATA RECORDS FOR LOGICAL COMMON BLOCKS-STORE IN V. MEMORY
!**********************************************************************
      IPTR=KDYNAP(ITYPE,1,1)+(IARCNO-1)*KDYNAP(ITYPE,1,2)
      IPTSTR=IPTR
      DO 900 ICOM=1,NCOMS
      NX=II(IPTHDR+ICOM)
      CALL BINRLC(IUNT11,LL(IPTR),NX)
      IPTR=IPTR+NX
! VERIFY THAT LAST VARIABLE IN COMMON IS THE LENGTH OF THE COMMON
!     IF(LL(IPTR-1) .NE. NX) GO TO 60100
  900 END DO
! TEST IF CORRECT NUMBER OF WORDS READ
      IF(NWORDS.NE. IPTR-IPTSTR) GO TO 60220
  950 CONTINUE
!
      RETURN
!**********************************************************************
!**********************************************************************
! LOAD FROM EXTENDED VIRTUAL MEMORY TO ARC COMMON BLOCKS
!**********************************************************************
!**********************************************************************
 1000 CONTINUE
!**********************************************************************
! LOAD REAL COMMON BLOCKS FROM VIRTUAL MEMORY
!***********************************************************************
      ITYPE=1
      IPTHDR=KDAHDR(ITYPE,1)
      IPTR=KDYNAP(ITYPE,1,1)+(IARCNO-1)*KDYNAP(ITYPE,1,2)
      IPTSTR=IPTR
      NCOMS1=II(IPTHDR)
      NCOMS =NCOMS1-1
      IF(NCOMS.EQ.0) GO TO 2000
      NWORDS=II(IPTHDR+NCOMS1)
      ICOM =0
! /ALBMIS/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      XX=NX
      CALL MOVER(AA(IPTR),AQALBM,NX,L12)
      IPTR=IPTR+NX
      IF(XALBMI .NE. XX) GO TO 60100
! /ARCPR /
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      XX=NX
      CALL MOVER(AA(IPTR),AQARCP,NX,L12)
      IPTR=IPTR+NX
      IF(XARCPR .NE. XX) GO TO 60100
! /ATMPAR/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      XX=NX
      CALL MOVER(AA(IPTR),AQATMP,NX,L12)
      IPTR=IPTR+NX
      IF(XATMPA .NE. XX) GO TO 60100
! /CEDIT /
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      XX=NX
      CALL MOVER(AA(IPTR),AQCEDI,NX,L12)
      IPTR=IPTR+NX
      IF(XCEDIT .NE. XX) GO TO 60100
! /CORBNA/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      XX=NX
      CALL MOVER(AA(IPTR),AQCORN,NX,L12)
      IPTR=IPTR+NX
      IF(XCORN.NE.XX) GO TO 60100
! /EMAT  /
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      XX=NX
      CALL MOVER(AA(IPTR),AQEMAT,NX,L12)
      IPTR=IPTR+NX
      IF(XEMAT  .NE. XX) GO TO 60100
! /SIMLM /
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      XX=NX
      CALL MOVER(AA(IPTR),AQSMLM,NX,L12)
      IPTR=IPTR+NX
      IF(XSMLM  .NE. XX) GO TO 60100
! /THERMD/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      XX=NX
      CALL MOVER(AA(IPTR),AQTHRM,NX,L12)
      IPTR=IPTR+NX
      IF(ABS(XTHERM - XX).GT.C1M10) GO TO 60100
! /TIEOUT/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      XX=NX
      CALL MOVER(AA(IPTR),AQTIEO,NX,L12)
      IPTR=IPTR+NX
      IF(ABS(XTIEOU - XX).GT.C1M10) GO TO 60100
! /TITLEC/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      XX=NX
      CALL MOVER(AA(IPTR),AQTITL,NX,L12)
      IPTR=IPTR+NX
      IF(XTITLE .NE. XX) GO TO 60100
! /TITLER/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      XX=NX
      CALL MOVER(AA(IPTR),AQTITR,NX,L12)
      IPTR=IPTR+NX
      IF(XTITLR .NE. XX) GO TO 60100
! /YAWTOP/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      XX=NX
      CALL MOVER(AA(IPTR),AQYAWT,NX,L12)
      IPTR=IPTR+NX
      IF(XYAWTP .NE. XX) GO TO 60100
! /UCLJAS/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      XX=NX
      CALL MOVER(AA(IPTR),AQUCLJ,NX,L12)
      IPTR=IPTR+NX
      IF(XUCLJA .NE. XX) GO TO 60100
! /UCLGFO/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      XX=NX
      CALL MOVER(AA(IPTR),AQUCLG,NX,L12)
      IPTR=IPTR+NX
! /UCLENV/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      XX=NX
      CALL MOVER(AA(IPTR),AQUCLE,NX,L12)
      IPTR=IPTR+NX
! /CAMCCD/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      XX=NX
      CALL MOVER(AA(IPTR),AQKCCD,NX,L12)
      IPTR=IPTR+NX
! /PARAM0/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      XX=NX
      CALL MOVER(AA(IPTR),AQPRM0,NX,L12)
      IPTR=IPTR+NX

!
! TEST IF PROPER NUMBER OF COMMON BLOCKS RETRIEVED
!
      IF(ICOM.NE.NCOMS) GO TO 60200
! TEST IF CORRECT NUMBER OF WORDS RELOADED
      IF(NWORDS.NE. IPTR-IPTSTR) GO TO 60220
!**********************************************************************
! LOAD INTEGER COMMON BLOCKS FROM VIRTUAL MEMORY
!**********************************************************************
 2000 ITYPE=2
      IPTHDR=KDAHDR(ITYPE,1)
      IPTR=KDYNAP(ITYPE,1,1)+(IARCNO-1)*KDYNAP(ITYPE,1,2)
      IPTSTR=IPTR
      NCOMS1=II(IPTHDR)
      NCOMS =NCOMS1-1
      NWORDS=II(IPTHDR+NCOMS1)
      ICOM=0
! /ACCEL9/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQACC9,NX,L12)
      IPTR=IPTR+NX
      IF(NXACC9 .NE. NX) GO TO 60100
! /ACCEL9/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQACCO,NX,L12)
      IPTR=IPTR+NX
      IF(NXACCO .NE. NX) GO TO 60100
! /ALBINT/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQALBI,NX,L12)
      IPTR=IPTR+NX
      IF(NXALBI .NE. NX) GO TO 60100
! /ALBMAX/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQALMX,NX,L12)
      IPTR=IPTR+NX
      IF(NXALMX .NE. NX) GO TO 60100
! /ARCPAR/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQARCP,NX,L12)
      IPTR=IPTR+NX
      IF(NXARCP .NE. NX) GO TO 60100
! /CEBARC/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQCEBA,NX,L12)
      IPTR=IPTR+NX
      IF(NXCEBA .NE. NX) GO TO 60100
! /CIMDST/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQMDST,NX,L12)
      IPTR=IPTR+NX
      IF(NXIRTM .NE. NX) GO TO 60100
! /CITERM/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQITER,NX,L12)
      IPTR=IPTR+NX
      IF(NXITER .NE. NX) GO TO 60100
! /CNIARC/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQCNIA,NX,L12)
      IPTR=IPTR+NX
      IF(NXCNIA .NE. NX) GO TO 60100
! /COBSI /
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQCOBS,NX,L12)
      IPTR=IPTR+NX
      IF(NXCOBS .NE. NX) GO TO 60100
! /CORBNF/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQCORB,NX,L12)
      IPTR=IPTR+NX
      IF(NXCORB .NE. NX) GO TO 60100
! /NPCOM /
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQNPCM,NX,L12)
      IPTR=IPTR+NX
      IF(NXNPCM .NE. NX) GO TO 60100
! /SIMPAR/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQSMPR,NX,L12)
      IPTR=IPTR+NX
      IF(NXSIML .NE. NX) GO TO 60100
! /TOPOVR/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQTOPO,NX,L12)
      IPTR=IPTR+NX
      IF(NXTOPO .NE. NX) GO TO 60100
! /UCLJAI/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQJASN,NX,L12)
      IPTR=IPTR+NX
      IF(NUCLJAI .NE. NX) GO TO 60100
! /TRAJI /
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQTRAJ,NX,L12)
      IPTR=IPTR+NX
      IF(NXTRAJ .NE. NX) GO TO 60100
! /XOVERS/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQXOVR,NX,L12)
      IPTR=IPTR+NX
      IF(NXXOVR .NE. NX) GO TO 60100
! /KNTSTS/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQKNTS,NX,L12)
      IPTR=IPTR+NX
      IF(NXKNTS .NE. NX) GO TO 60100
! /ALTCB /
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQALTC,NX,L12)
      IPTR=IPTR+NX
      IF(NXALT .NE. NX) GO TO 60100
! /ATTCB /
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQATTC,NX,L12)
      IPTR=IPTR+NX
      IF(NXATT .NE. NX) GO TO 60100
! /TRJREF/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQTREF,NX,L12)
      IPTR=IPTR+NX
      IF(NXTREF .NE. NX) GO TO 60100
! /ACCLRM/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQCLRM,NX,L12)
      IPTR=IPTR+NX
      IF(NXCLRM .NE. NX) GO TO 60100
! /MBIAST/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQCMBS,NX,L12)
      IPTR=IPTR+NX
      IF(NXMBST .NE. NX) GO TO 60100
! /IDELTX/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQIDST,NX,L12)
      IPTR=IPTR+NX
      IF(NDELTX .NE. NX) GO TO 60100
! /CANTEN/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQANTE,NX,L12)
      IPTR=IPTR+NX
      IF(NXANTE .NE. NX) GO TO 60100
! /C12PRM/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQC12P,NX,L12)
      IPTR=IPTR+NX
      IF(NXC12P .NE. NX) GO TO 60100
! /YARINT/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQYARK,NX,L12)
      IPTR=IPTR+NX
      IF(NXYARK .NE. NX) GO TO 60100
! /SPBIAS/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQSPB,NX,L12)
      IPTR=IPTR+NX
      IF(NXSPB .NE. NX) GO TO 60100
! /NEQ/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQNEQS,NX,L12)
      IPTR=IPTR+NX
      IF(NXNEQS .NE. NX) GO TO 60100
! /SNAPX/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQSNAP,NX,L12)
      IPTR=IPTR+NX
      IF(NXSNAP .NE. NX) GO TO 60100
! /SLFSHD/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQSFSH,NX,L12)
      IPTR=IPTR+NX
      IF(NXSFSD .NE. NX) GO TO 60100
! /IMAG2S/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQIMAG,NX,L12)
      IPTR=IPTR+NX
      IF(NIMG2S .NE. NX) GO TO 60100

! /SLRATI/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQSLRI,NX,L12)
      IPTR=IPTR+NX
      IF(NXSLRI .NE. NX) GO TO 60100

! /GPSINT/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQGPSI,NX,L12)
      IPTR=IPTR+NX
      IF(NGPSBW .NE. NX) GO TO 60100

! /CAMSAT/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQCAMS,NX,L12)
      IPTR=IPTR+NX
      IF(NXSCID .NE. NX) GO TO 60100

! /SOLTUM/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQSOLT,NX,L12)
      IPTR=IPTR+NX
      IF(NXSOLT .NE. NX) GO TO 60100

! /TELEN
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQTEL,NX,L12)
      IPTR=IPTR+NX
      IF(NXTELEN .NE. NX) GO TO 60100

! /BURN
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEI(II(IPTR),IQBURN,NX,L12)
      IPTR=IPTR+NX
      IF(NBURN .NE. NX) GO TO 60100
!
!
!
!
!
! TEST IF CORRECT NUMBER OF COMMON BLOCKS RELOADED
!
      IF(ICOM .NE. NCOMS ) GO TO 60200
! TEST IF CORRECT NUMBER OF WORDS RELOADED
      IF(NWORDS.NE. IPTR-IPTSTR) GO TO 60220
!**********************************************************************
!  LOAD LOGICAL COMMON BLOCKS FROM VIRTUAL MEMORY
!***********************************************************************
      ITYPE=3
      IPTHDR=KDAHDR(ITYPE,1)
      IPTR=KDYNAP(ITYPE,1,1)+(IARCNO-1)*KDYNAP(ITYPE,1,2)
      IPTSTR=IPTR
      NCOMS1=II(IPTHDR)
      NCOMS =NCOMS1-1
      NWORDS=II(IPTHDR+NCOMS1)
      ICOM=0
! /BUFOPT/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEL(LL(IPTR),ILBUFO,NX,L12)
      IPTR=IPTR+NX
      IF(NXBUFO .NE. NX) GO TO 60100
! /CONTRL/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEL(LL(IPTR),ILCONT,NX,L12)
      IPTR=IPTR+NX
      IF(NXCONT .NE. NX) GO TO 60100
! /CBINRL/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEL(LL(IPTR),ILCBIN,NX,L12)
      IPTR=IPTR+NX
      IF(NXCBIN .NE. NX) GO TO 60100
! /LMARIN/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEL(LL(IPTR),ILLMAR,NX,L12)
      IPTR=IPTR+NX
      IF(NXLMAR .NE. NX) GO TO 60100
! /TELEM/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEL(LL(IPTR),ILTELE,NX,L12)
      IPTR=IPTR+NX
      IF(NXTELE .NE. NX) GO TO 60100
! /EXATAL/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEL(LL(IPTR),ILEAAL,NX,L12)
      IPTR=IPTR+NX
      IF(NXEAAL .NE. NX) GO TO 60100
! /TETHER/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEL(LL(IPTR),ILTETH,NX,L12)
      IPTR=IPTR+NX
      IF(NXTETH .NE. NX) GO TO 60100
!
! /LCONST/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEL(LL(IPTR),ILCONS,NX,L12)
      IPTR=IPTR+NX
      IF(NXCONS .NE. NX) GO TO 60100
!
! /UCLJAL/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEL(LL(IPTR),ILJASN,NX,L12)
      IPTR=IPTR+NX
      IF(NUCLJA .NE. NX) GO TO 60100
!
! /SLRATL/
      ICOM=ICOM+1
      NX=II(IPTHDR+ICOM)
      CALL MOVEL(LL(IPTR),ILSLRL,NX,L12)
      IPTR=IPTR+NX
      IF(NXSLRL .NE. NX) GO TO 60100
!
! TEST IF CORRECT NUMBER OF COMMON BLOCKS RELOADED
!

      IF(ICOM .NE. NCOMS ) GO TO 60200
! TEST IF CORRECT NUMBER OF WORDS RELOADED
      IF(NWORDS.NE. IPTR-IPTSTR) GO TO 60220
      RETURN
!**********************************************************************
! ERROR MESSAGES
!**********************************************************************
60100 WRITE(IOUT6,80100) ICOM,ITYPE,NX
      WRITE(IOUT6,80999)
      STOP
! BLOCK NUMBER OR RECORD TYPE INCORRECT
60150 WRITE(IOUT6,80150) IBLOCK,ITYPE,IFFHDR
      WRITE(IOUT6,80999)
      STOP
60200 WRITE(IOUT6,80200) ICOM,NCOMS,ITYPE
      WRITE(IOUT6,80999)
      STOP
60220 WRITE(IOUT6,80220) LRDIFF,IARCNO,ITYPE,NWORDS,IPTSTR,IPTR
      WRITE(IOUT6,80999)
      STOP
60400 WRITE(IOUT6,80400) IFBUFR,NX
      WRITE(IOUT6,80999)
      STOP
60500 WRITE(IOUT6,80500) ISTAT
      WRITE(IOUT6,80999)
      STOP
!
! FORMATS
!
80100 FORMAT(5X,'LENGTH FOR COMMON BLOCK NUMBER',I3,' OF TYPE ',I1,     &
     & ' DOES NOT MATCH',I5/1X,'TYPE 1:REAL;  2:INTEGER;  3:LOGICAL')
80150 FORMAT(1X,'BLOCK NUMBER OR DATA TYPE INCORRECT ',2I5/(1X,20I4))
80200 FORMAT(5X,'NUMBER OF COMMON BLOCKS (',I2,') READ FROM INTERFACE', &
     &'FILE FOR TYPE ',I1,' DOES NOT AGREE WITH EXPECTED NUMBER (',I2,  &
     & ')' )
80220 FORMAT(1X,'INCORRECT NUMBER OF WORDS READ/RELOADED. LRDIFF',  &
     &',IARCNO,ITYPE, NWORDS,IPTSTR,IPTR FOLLOW: '/1X,L4,5I10)
80400 FORMAT(1X,'MAXIMUM BUFFER LENGTH IS:',I6,1X,'AND REQUESTED',      &
     &     ' BUFFER LENGTH IS:',I6)
80500 FORMAT(1X,'SUBROUTINE Q9ICLA RETURNED WITH CONDITION CODE:',I6)
80999 FORMAT(1X,'EXECUTION TERMINATING IN SUBROUTINE IFRACB')
      END