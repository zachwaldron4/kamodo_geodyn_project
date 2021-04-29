      SUBROUTINE GRANOM(XDDOT,NEQN,PXDDOT,ISTART,RSAT,COSPSB,SINPSB,    &
     &                  XLAMBK,ASUB,VSUB,IMAPLG)
!********1*********2*********3*********4*********5*********6*********7**
! GRANON
!
!
! FUNCTION:  COMPUTE SATELLITE ACCELERATION DUE TO LOCAL GRAVITY
!            ANOMALY PARAMETERS. ALSO COMPUTE EXPLICIT PARTIALS
!            FOR THESE PARAMETERS.
!
! I/O PARAMETERS:
!
!   XDDOT    O    A    TRUE OF REF ACCELERATIONS DUE TO LOCAL GRAVITY
!                      PARAMETERS
!   NEQN     I    S    TOTAL NUMBER OF ADJUSTING FORCE MODEL PARAMETERS
!                      FOR THE CURRENT SATELLITE
!   PXDDOT   O    A    ARRAY OF EXPLICIT FORCE MODEL PARTIALS. THE
!                      LOCAL GRAVITY PORTION IS LOADED BY THIS ROUTINE
!   ISTART   I    S    STARTING LOCATION OF LOCAL GRAVITY PARAMETERS
!                      IN THE PXDDOT ARRAY
!   RSAT     I    S    SATELLITE DISTANCE FROM PLANET CENTER OF MASS
!   COSPSB   I    A    ARRAY OF COSINES OF SUB BLOCK CENTER LATITUDES
!   SINPSB   I    A    ARRAY OF SINES OF SUB BLOCK CENTER LATITUDES
!   XLAMBK   I    A    ARRAY OF SUB BLOCK CENTER LONGITUDES
!   ASUB     I    A    ARRAY OF SUB BLOCK AREAS (ON UNIT SPHERE)
!   VSUB     I    A    ARRAY OF GRAVITY ANOMALY VALUES (FOR EACH SUBBLK)
!   IMAPLG   I    A    ARRAY WHICH MAPS SUB BLOCKS TO THE PARMV ARRAY
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
!
!
!
!
      COMMON/CITERL/LSTGLB,LSTARC,LSTINR,LNADJ ,LITER1,LSTITR,          &
     &              LOBORB,LRESID,LFREEZ,LSAVEF,LHALT,LADJPI,LADJCI
      COMMON/CONSTR/PI,TWOPI,DEGRAD,SECRAD,SECDAY
      COMMON/CRMBI/RMBI(9)
      COMMON/GRANI/NSUBLG,NXGRAN
      COMMON/GRANR/RGRAN
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
      COMMON/VRBLOK/SINPSI,COSPSI,XLAMDA,GMR,AOR
      DIMENSION XDDOT(3),PXDDOT(NEQN,3)
      DIMENSION COSPSB(NSUBLG),SINPSB(NSUBLG),XLAMBK(NSUBLG)
      DIMENSION ASUB(NSUBLG),VSUB(NSUBLG),IMAPLG(NSUBLG)
!
      IF(NSUBLG.LE.0) RETURN
!
!  FACTOR OF 1.D-5 ALLOWS UNITS OF MGALS TO PRODUCE ACCELS IN M/S**2
      RO4PI=1.D-5*RGRAN/(4.D0*PI)
!
      TARG=RGRAN/RSAT
      TARGSQ=TARG*TARG
      TARGS1=1.D0-TARGSQ
      TARG2=TARG+TARG
      TSQR=TARGSQ/RGRAN
      TSQ1=1.D0+TARGSQ
!
!
!
      TR=0.D0
      TP=0.D0
      TL=0.D0
!
!
!
      IF(LSTINR.AND.NPVAL0(IXLOCG).GT.0) THEN
         NDO=NPVAL0(IXLOCG)
         IS=ISTART-1
         DO I=1,NDO
           PXDDOT(IS+I,1)=0.D0
           PXDDOT(IS+I,2)=0.D0
           PXDDOT(IS+I,3)=0.D0
         ENDDO
      ENDIF
!
!
!
!
!
!
!
      DO 1000 ISUB=1,NSUBLG
!
      COSDF=COS(XLAMBK(ISUB)-XLAMDA)
      COSTSI=SINPSI*SINPSB(ISUB)                                        &
     &      +COSPSI*COSPSB(ISUB)*COSDF
      SINTS2=1.D0-COSTSI*COSTSI
      SINTSI=SQRT(SINTS2)
!
      SINALF=(COSPSB(ISUB)*SIN(XLAMBK(ISUB)-XLAMDA))/SINTSI
      COSALF=(COSPSI*SINPSB(ISUB)-SINPSI*COSPSB(ISUB)*COSDF)/SINTSI
!
      D2=TSQ1-TARG2*COSTSI
      D=SQRT(D2)
      D3=D*D2
!
      TCTSI=TARG*COSTSI
      ARGLN=1.D0-TCTSI+D
      ARGLN2=1.D0-TCTSI-D
      EVLN=LOG(.5D0*ARGLN)
!
      PART1=-TSQR*(TARGS1/D3+4.D0/D+1.D0-6.D0*D                         &
     &            -TCTSI*(13.D0+6.D0*EVLN))
!     PART2=-TARGSQ*SINTSI*(2.D0/D3+6.D0/D-8.D0-3.D0*ARGLN/(D*SINTS2)
      PART2=-TARGSQ*SINTSI*(2.D0/D3+6.D0/D-8.D0-3.D0*ARGLN2/(D*SINTS2)  &
     &                     -3.D0*EVLN)
      PART1=PART1*ASUB(ISUB)
      PART2=PART2*ASUB(ISUB)
      PART3=PART2*SINALF
      PART2=PART2*COSALF
      TR=TR+PART1*VSUB(ISUB)
      TP=TP+PART2*VSUB(ISUB)
      TL=TL+PART3*VSUB(ISUB)
      IF(.NOT.LSTINR) GO TO 1000
      IF(IMAPLG(ISUB).LE.0) GO TO 1000
      IPT=IMAPLG(ISUB)-IPVAL0(IXLOCG)+ISTART
      PXDDOT(IPT,1)=PXDDOT(IPT,1)+PART1
      PXDDOT(IPT,2)=PXDDOT(IPT,2)+PART2
      PXDDOT(IPT,3)=PXDDOT(IPT,3)+PART3
 1000 END DO
      TR=TR*RO4PI
      TP=-TP*RO4PI
      TL=-TL*RO4PI*COSPSI
      XDDOT(1)=TR*RMBI(1)+TP*RMBI(4)+TL*RMBI(7)
      XDDOT(2)=TR*RMBI(2)+TP*RMBI(5)+TL*RMBI(8)
      XDDOT(3)=TR*RMBI(3)+TP*RMBI(6)+TL*RMBI(9)
!
      IF(.NOT.LSTINR.OR.NPVAL0(IXLOCG).LE.0) RETURN
!
      NDO=NPVAL0(IXLOCG)
      IS=ISTART-1
      DO I=1,NDO
        PXDDOT(IS+I,1)=PXDDOT(IS+I,1)*RO4PI
        PXDDOT(IS+I,2)=-PXDDOT(IS+I,2)*RO4PI
        PXDDOT(IS+I,3)=-PXDDOT(IS+I,3)*RO4PI*COSPSI
        TR=PXDDOT(IS+I,1)*RMBI(1)+PXDDOT(IS+I,2)*RMBI(4)                &
     &    +PXDDOT(IS+I,3)*RMBI(7)
        TP=PXDDOT(IS+I,1)*RMBI(2)+PXDDOT(IS+I,2)*RMBI(5)                &
     &    +PXDDOT(IS+I,3)*RMBI(8)
        TL=PXDDOT(IS+I,1)*RMBI(3)+PXDDOT(IS+I,2)*RMBI(6)                &
     &    +PXDDOT(IS+I,3)*RMBI(9)
        PXDDOT(IS+I,1)=TR
        PXDDOT(IS+I,2)=TP
        PXDDOT(IS+I,3)=TL
      ENDDO
      RETURN
      END
