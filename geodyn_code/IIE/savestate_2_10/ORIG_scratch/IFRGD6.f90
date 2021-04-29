!$IFRGD6
      SUBROUTINE IFRGD6(AA,II,LL,IFFHDR,IFFLEN,FFBUF)
!********1*********2*********3*********4*********5*********6*********7**
! IFRGD6           84/03/12            0000.0    PGMR - B. EDDY
!
! FUNCTION:  READ GLOBAL DYNAMIC ARRAYS FROM THE INTERFACE FILE
!            FOR ALLOCATION GROUP #6 - ESTIMATION ARRAYS
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   AA      I/O   A    DYNAMIC ARRAY FOR REAL DATA
!   II      I/O   A    DYNAMIC ARRAY FOR INTEGER DATA
!   LL      I/O   A    DYNAMIC ARRAY FOR LOGICAL DATA
!   IFFHDR   I    A    SCRATCH ARRAY USED FOR HEADER INFORMATION
!   IFFLEN   I    A    SCRATCH ARRAY USED FOR LENGTHS OF DATA
!   FFBUF    I    A    SCRATCH ARRAY USED FOR CONVERTING IBM
!                      FLOATING POINT NUMBERS TO CYBER F.P.
!
! COMMENTS:     INTERFACE FORMAT #2 USED:
!
! INTEGER  HEADER RECORD  - WITH IFFHDR(5)=0 INDICATING LENGTHS RECORDS
!                           FOLLOWS
! INTEGER LENGTHS RECORD  - CONTAINING IFFHDR(4)-1 LENGTHS
!            DATA RECORDS - IFFHDR(4)-1  DATA RECORDS. DATA RECORDS ARE
!                           OF THE TYPE INDICATED IN IFFHDR(3)
!
! COMMENTS:   TO READ ADDITIONAL RECORDS IN THIS ROUTINE
!             1. INCREMENT IRECS IN PROPER GROUP-REAL,INTEGER OR LOGICAL
!             2. ADD CALL TO BINRD2 (REAL) OR BINRD (INTEGER,LOGICAL)
!                IN PROPER GROUP
!             3. FOR FLOATING POINT DATA CALL SUBROUTINE Q9ICLA TO
!                CONVERT REAL WORDS TO THE CORRECT REPRESENTATION
!                FOR THE COMPUTER IIE IS RUNNING ON
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      COMMON/CIFF  /IFHEAD,IFLNTH,IFBUFL,IFBUFR,KDYNHD,KDYNLN,          &
     &              KDYNIF,KDYNFF,NXCIFF
      COMMON/CORA06/KPRMV ,KPNAME,KPRMV0,KPRMVC,KPRMVP,KPRMSG,KPARVR,   &
     &              KPRML0,KPDLTA,KSATCV,KSTACV,KPOLCV,KTIDCV,KSUM1 ,   &
     &              KSUM2 ,KGPNRA,KGPNRM,KPRSG0,KCONDN,KVELCV,          &
     &              KSL2CV,KSH2CV,KTIEOU,KPRMDF,NXCA06
      COMMON/CORI06/KPTRAU,KPTRUA,KNFMG ,KIPTFM,KILNFM,KIGPC ,          &
     &              KIGPS ,KIGPCA,KIGPSA,KIELMT,KMFMG ,KTPGPC,          &
     &              KTPGPS,KTPUC ,KTPUS,                                &
     &              KLINK,KPTFAU,KPTFUA,NXCI06
      COMMON/CVIEW /IOUT6 ,ILINE6,IPAGE6,MLINE6,                        &
     &              IOUT8 ,ILINE8,IPAGE8,MLINE8,                        &
     &              IOUT9 ,ILINE9,IPAGE9,MLINE9,                        &
     &              IOUT10,ILIN10,IPAG10,MLIN10,                        &
     &              IOUT15,ILIN15,IPAG15,MLIN15,                        &
     &              IOUT16,ILIN16,IPAG16,MLIN16,                        &
     &              IOUT7 ,NXCVUE
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
      COMMON/UNITS/IUNT11,IUNT12,IUNT13,IUNT19,IUNT30,IUNT71,IUNT72,    &
     &             IUNT73,IUNT05,IUNT14,IUNT65,IUNT88,IUNT21,IUNT22,    &
     &             IUNT23,IUNT24,IUNT25,IUNT26
!
      DIMENSION AA(1)
      DIMENSION FFBUF(IFBUFR)
      DIMENSION IFFHDR(IFHEAD),IFFLEN(IFLNTH)
      DIMENSION II(1)
      DIMENSION LL(1)
!
      DATA IBLOCK/20/,IGROUP/6/
      DATA ONE/1.0D0/
!
!**********************************************************************
! START OF EXECUTABLE CODE ********************************************
!**********************************************************************
!
!**********************************************************************
! READ HEADER RECORD FOR REAL DATA
!**********************************************************************
      ITYPE=1
      CALL BINRD(IUNT11,IFFHDR,IFHEAD)
! TEST BLOCK NUMBER,GROUP NUMBER AND DATA RECORD TYPE
      IF(IFFHDR(1).NE.IBLOCK .OR. IFFHDR(2).NE.IGROUP .OR.              &
     &   IFFHDR(3).NE.ITYPE) GO TO 60400
      NRECS1=IFFHDR(4)
      NRECS=NRECS1-1
!**********************************************************************
! READ LENGTHS RACORD FOR REAL DATA
!**********************************************************************
      CALL BINRD(IUNT11,IFFLEN,NRECS1)
! SAVE LAST WORD READ WHICH IS THE SUM OF THE LENGTHS
      NWORDS=IFFLEN(NRECS1)
!**********************************************************************
! READ DATA RECORDS FOR REAL DATA
!**********************************************************************
      IREC=0
      IWORDS=0
      IGLB =IPVAL(IXGLBL)
      IGLB0=IPVAL0(IXGLBL)
! KPRMV/PARMV - PARAMETER VALUES
      IREC=IREC+1
      NX=IFFLEN(IREC)
      IF(NX.GT.IFBUFR) GO TO 60100
      IWORDS=IWORDS+NX
      CALL BINRD2(IUNT11,FFBUF,NX  )
      IF(NX.GT.0) CALL Q9ICLA(FFBUF,AA(KPRMV+IGLB-1),NX,ISTAT)
! KPNAME/PNAME - PARAMETER NAMES
      IREC=IREC+1
      NX=IFFLEN(IREC)
      IF(NX.GT.IFBUFR) GO TO 60100
      IWORDS=IWORDS+NX
      IOFF=(IGLB-1)*2
      CALL BINRDC(IUNT11,AA(KPNAME+IOFF),NX  )
! KPRMV0/PARMV0 - A PRIORI ADJUSTED PARAMETER VALUES
      IREC=IREC+1
      NX=IFFLEN(IREC)
      IF(NX.GT.IFBUFR) GO TO 60100
      IWORDS=IWORDS+NX
      CALL BINRD2(IUNT11,FFBUF,NX  )
      IF(NX.GT.0) CALL Q9ICLA(FFBUF,AA(KPRMV0+IGLB0-1),NX,ISTAT)
! KPRSG0/PARSG0 - A PRIORI PARAMETER SIGMAS
      IREC=IREC+1
      NX=IFFLEN(IREC)
      IF(NX.GT.IFBUFR) GO TO 60100
      IWORDS=IWORDS+NX
      CALL BINRD2(IUNT11,FFBUF,NX  )
      IF(NX.GT.0) CALL Q9ICLA(FFBUF,AA(KPRSG0+IGLB0-1),NX,ISTAT)
!     IF(NX.LE.0) GO TO 1420
!     CALL Q9ICLA(FFBUF,AA(KPRSG0+IGLB0-1),NX,ISTAT)
!     J1=IGLB0-2
!     DO 1400 J=1,NX
!     J1=J1+1
!     AA(KPARVR+J1)=ONE/(AA(KPRSG0+J1)*AA(KPRSG0+J1))
!1400 CONTINUE
!1420 CONTINUE
! KPARVR/PARVAR
      IREC=IREC+1
      NX=IFFLEN(IREC)
      IF(NX.GT.IFBUFR) GO TO 60100
      IWORDS=IWORDS+NX
      CALL BINRD2(IUNT11,FFBUF,NX  )
      IF(NX.GT.0) CALL Q9ICLA(FFBUF,AA(KPARVR+IGLB0-1),NX,ISTAT)
! KPRML0/PARML0 - PARAMETER LABELS
      IREC=IREC+1
      NX=IFFLEN(IREC)
      IF(NX.GT.IFBUFR) GO TO 60100
      IWORDS=IWORDS+NX
      CALL BINRD2(IUNT11,FFBUF,NX  )
      IPT=KPRML0+(IGLB0-1)*3
      IF(NX.GT.0) CALL Q9ICLA(FFBUF,AA(IPT),NX,ISTAT)
! KSTACV/STACOV - STATION COVARIANCE
      IREC=IREC+1
      NX=IFFLEN(IREC)
      IF(NX.GT.IFBUFR) GO TO 60100
      IWORDS=IWORDS+NX
      CALL BINRD2(IUNT11,FFBUF,NX  )
      IF(NX.GT.0) CALL Q9ICLA(FFBUF,AA(KSTACV),NX,ISTAT)
! KPOLCV/POLCOV - POLAR MOTION/UT1 COVARIANCE
      IREC=IREC+1
      NX=IFFLEN(IREC)
      IF(NX.GT.IFBUFR) GO TO 60100
      IWORDS=IWORDS+NX
      CALL BINRD2(IUNT11,FFBUF,NX  )
      IF(NX.GT.0) CALL Q9ICLA(FFBUF,AA(KPOLCV),NX,ISTAT)
! KTIDCV/TIDCOV - TIDE COVARIANCE
      IREC=IREC+1
      NX=IFFLEN(IREC)
      IF(NX.GT.IFBUFR) GO TO 60100
      IWORDS=IWORDS+NX
      CALL BINRD2(IUNT11,FFBUF,NX  )
      IF(NX.GT.0) CALL Q9ICLA(FFBUF,AA(KTIDCV),NX,ISTAT)
! KVELCV/VELCOV - STATION VELOCITY COVARIANCE
      IREC=IREC+1
      NX=IFFLEN(IREC)
      IF(NX.GT.IFBUFR) GO TO 60100
      IWORDS=IWORDS+NX
      CALL BINRD2(IUNT11,FFBUF,NX  )
      IF(NX.GT.0) CALL Q9IC64(FFBUF,AA(KVELCV),NX,ISTAT)
! KSL2CV/STL2CV - STATION ETIDE L2 COVARIANCE
      IREC=IREC+1
      NX=IFFLEN(IREC)
      IF(NX.GT.IFBUFR) GO TO 60100
      IWORDS=IWORDS+NX
      CALL BINRD2(IUNT11,FFBUF,NX  )
      IF(NX.GT.0) CALL Q9IC64(FFBUF,AA(KSL2CV),NX,ISTAT)
! KSH2CV/STH2CV - STATION ETIDE L2 COVARIANCE
      IREC=IREC+1
      NX=IFFLEN(IREC)
      IF(NX.GT.IFBUFR) GO TO 60100
      IWORDS=IWORDS+NX
      CALL BINRD2(IUNT11,FFBUF,NX  )
      IF(NX.GT.0) CALL Q9IC64(FFBUF,AA(KSH2CV),NX,ISTAT)
!
! TEST IF CORRECT NUMBER OF DATA RECORDS READ
!
      IF(IREC.NE.NRECS) GO TO 60200
! TEST IF CORRECT NUMBER OF WORDS READ
      IF(NWORDS.NE.IWORDS) GO TO 60300
!**********************************************************************
! READ HEADER RECORD FOR INTEGER DATA
!**********************************************************************
      ITYPE=2
      CALL BINRD(IUNT11,IFFHDR,IFHEAD)
! TEST BLOCK NUMBER,GROUP NUMBER AND DATA RECORD TYPE
      IF(IFFHDR(1).NE.IBLOCK .OR. IFFHDR(2).NE.IGROUP .OR.              &
     &   IFFHDR(3).NE.ITYPE) GO TO 60400
      NRECS1=IFFHDR(4)
      NRECS =NRECS1-1
!**********************************************************************
! READ LENGTHS RECORD FOR INTEGER DATA
!**********************************************************************
      CALL BINRD(IUNT11,IFFLEN,NRECS1)
! SAVE SUM OF RECORD LENGTHS
      NWORDS=IFFLEN(NRECS1)
!**********************************************************************
! READ DATA RECORDS FOR INTEGER DATA
!**********************************************************************
      IREC=0
      IWORDS=0
! KPTRAU/IPTRAU - POINTERS FROM ADJUSTED TO UNADJUSTED PARAMETER ARRAYS
      IREC=IREC+1
      IWORDS=IWORDS+IFFLEN(IREC)
      CALL BINRD(IUNT11,II(KPTRAU+IGLB0-1),IFFLEN(IREC) )
! KPTRUA/IPTRUA - POINTERS FROM UNADJUSTED TO ADJUSTED PARAMETER ARRAYS
      IREC=IREC+1
      IWORDS=IWORDS+IFFLEN(IREC)
      CALL BINRD(IUNT11,II(KPTRUA+IGLB-1),IFFLEN(IREC) )
! KIGPC /IGPC  - DEG & ORD FOR ADJUSTED C COEFFICIENTS
      IREC=IREC+1
      IWORDS=IWORDS+IFFLEN(IREC)
      CALL BINRD(IUNT11,II(KIGPC),IFFLEN(IREC) )
! KIGPS /IGPS  - DEG & ORD FOR ADJUSTED S COEFFICIENTS
      IREC=IREC+1
      IWORDS=IWORDS+IFFLEN(IREC)
      CALL BINRD(IUNT11,II(KIGPS),IFFLEN(IREC) )
! KTPGPC /ITPGPC  - DEG & ORD FOR ADJUSTED C COEFFICIENTS
!                    FOR TIME PERIOD GRAVITY
      IREC=IREC+1
      IWORDS=IWORDS+IFFLEN(IREC)
      CALL BINRD(IUNT11,II(KTPGPC),IFFLEN(IREC) )
! KTPGPS /ITPGPS  - DEG & ORD FOR ADJUSTED S COEFFICIENTS
!                    FOR TIME PERIOD GRAVITY
      IREC=IREC+1
      IWORDS=IWORDS+IFFLEN(IREC)
      CALL BINRD(IUNT11,II(KTPGPS),IFFLEN(IREC) )
! KTPUC /ITPUC  - DEG & ORD  OF C COEFFICIENTS
!                    FOR TIME PERIOD GRAVITY
      IREC=IREC+1
      IWORDS=IWORDS+IFFLEN(IREC)
      CALL BINRD(IUNT11,II(KTPUC),IFFLEN(IREC) )
! KTPUS /ITPUS  - DEG & ORD OF S COEFFICIENTS
!                    FOR TIME PERIOD GRAVITY
      IREC=IREC+1
      IWORDS=IWORDS+IFFLEN(IREC)
      CALL BINRD(IUNT11,II(KTPUS),IFFLEN(IREC) )
! KLINK /ILINK  -  CONSTRAINT LINK ARRAY
      IREC=IREC+1
      IWORDS=IWORDS+IFFLEN(IREC)
      CALL BINRD(IUNT11,II(KLINK),IFFLEN(IREC) )
!
! TEST IF CORRECT NUMBER OF DATA RECORDS READ
!
      IF(IREC.NE.NRECS) GO TO 60200
! TEST IF CORRECT NUMBER OF WORDS READ
      IF(NWORDS.NE.IWORDS) GO TO 60300
!**********************************************************************
! READ HEADER RECORD FOR LOGICAL DATA
!**********************************************************************
      ITYPE=3
      CALL BINRD(IUNT11,IFFHDR,IFHEAD)
! TEST BLOCK NUMBER,GROUP NUMBER AND DATA RECORD TYPE
      IF(IFFHDR(1).NE.IBLOCK .OR. IFFHDR(2).NE.IGROUP .OR.              &
     &   IFFHDR(3).NE.ITYPE) GO TO 60400
      NRECS1=IFFHDR(4)
      NRECS =NRECS1-1
!**********************************************************************
! READ LENGTHS RECORD FOR LOGICAL DATA
!**********************************************************************
      CALL BINRD(IUNT11,IFFLEN,NRECS1)
! SAVE SUM OF DATA RECORD LENGTHS
      NWORDS=IFFLEN(NRECS1)
!**********************************************************************
! READ DATA RACORDS FOR LOGICAL DATA
!**********************************************************************
      IREC=0
      IWORDS=0
!
! LOGICAL DAPA RECORDS GO HERE
!
! TEST IF CORRECT NUMBER OF DATA RECORDS READ
!
      IF(IREC.NE.NRECS) GO TO 60200
! TEST IF CORRECT NUMBER OF WORDS READ
      IF(NWORDS.NE.IWORDS) GO TO 60300
      RETURN
!**********************************************************************
! ERROR PROCESSING
!**********************************************************************
!
! RECORD SIZE EXCEEDS BUFFER SPACE
60100 WRITE(IOUT6,80100) ITYPE,NX,IFBUFR
      WRITE(IOUT6,89999)
      STOP
! NUMBER OF RECORDS READ DISAGREES WITH NUMBER OF LENGTHS EXPECTED
60200 WRITE(IOUT6,80200) ITYPE,IREC,NRECS
      WRITE(IOUT6,89999)
      STOP
! NUMBER OF WORDS SENT DISAGREES WITH NUMBER OF WORDS EXPECTED
60300 WRITE(IOUT6,80300) ITYPE,NWORDS,IWORDS
      WRITE(IOUT6,89999)
      STOP
! BLOCK NUMBER,GROUP NUMBER OR RECORD TYPE INCORRECT
60400 WRITE(IOUT6,80400) IBLOCK,IGROUP,ITYPE,IFFHDR
      WRITE(IOUT6,89999)
      STOP
80000 FORMAT(1X,'UNEXPECTED END OF FILE ON UNIT ',I2,' FOR DATA TYPE ', &
     & I2)
80100 FORMAT(1X,'RECORD SIZE EXCEEDS BUFFER SPACE AVAILABLE. ITYPE,NX,' &
     &'IFBUFR FOLLOW: '/1X,3I10)
80200 FORMAT(1X,'NUMBER OF TYPE (',I2,') RECORDS READ FROM INTERFACE ',&
     &'FILE DISAGREES WITH NUMBER OF LENGTHS EXPECTED',2I5)
80300 FORMAT(1X,'SUM OF RECORD LENGTHS FROM IFF LENGTHS RECORD DOES ',&
     &'NOT AGREE WITH SUM CALCULATED',3I6)
80400 FORMAT(1X,'BLOCK NUMBER,GROUP NO. OR DATA TYPE IS INCORRECT',2I5/ &
     &1X,20I5)
89999 FORMAT(1X,'EXECUTION TERMINATING IN SUBROUTINE IFRGD6 ')
      END
