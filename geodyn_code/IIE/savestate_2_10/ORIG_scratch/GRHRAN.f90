!$GRHRAN
      SUBROUTINE GRHRAN(MJDSEC,FSEC,LEQC,LONLEQ,EQN,SCRTCH,THETAG,      &
     &                  COSTHG,SINTHG,NM,AA,II,UTDT,LNUPRT,XNM,TN)
!********1*********2*********3*********4*********5*********6*********7**
! GRHRAN           83/03/25            0000.0    PGMR - TOM MARTIN
!                  89/06/06            0000.0    PGMR - A. MARSHALL
!
! FUNCTION:  COMPUTE THE EQUATION OF THE EQUINOX.
!            THROUGH CALL TO GRHRN2, COMPUTE
!            THE RIGHT ASCENSION OF GREENWICH FOR
!            A VECTOR OF TIMES OF LENGTH "NM".
!            COMPUTE THE COSINES AND SINES OF THE RIGHT
!            ASCENSION OF GREENWICH VECTOR.
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   MJDSEC   I    S    MODIFIED JULIAN DAY SECONDS OF THE VECTOR
!                      OF TIMES OF INTEREST (EPHEMERIS TIME)
!   FSEC     I    A    THE FRACTION OF SECONDS OF THE VECTOR OF
!                      TIMES OF INTEREST (EPHEMERIS TIME)
!   LEQC     I    S    .TRUE. IF IT IS NECCESSARY TO CALCULATE EQN
!                      OF THE EQUINOX IN ROUTINE
!   LONLEQ   I    S    LOGICAL VAIABLE; IF TRUE ONLY THE EQUATION
!                      OF EQUINOX IS CALCULATED;ELSE NP MATRIX CALCULATE
!   EQN     I/O   A    EQUATION OF THE EQUINOX (INPUT IF LEQC=.FALSE.)
!                      EQN OF THE EQUINOX (OUTPUT IF LEQC=.TRUE.)
!   SCRTCH  I/O   A    SCRATCH 5*NM
!   THETAG   O    A    VECTOR OF VALUES OF RIGHT ASCENSION OF
!                      GREENWICH
!   COSTHG   O    A    COSINES OF THETAG
!   SINTHG   O    A    SINES OF THETAG
!   NM       I    S    NUMBER OF TIMES OF INTEREST
!   AA       I    A    REAL DYNAMIC ARRAY
!   II       I    A    INTEGER DYNAMIC ARRAY
!   LNUPRT   I    S    .TRUE.  WHEN NUTATION PARTIALS ARE TO BE COMPUTED.
!
! COMMENTS:
!
!
!*********1*********2*********3*********4*********5*********6*********7*
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
!
      DIMENSION FSEC(NM),THETAG(NM),COSTHG(NM),SINTHG(NM),EQN(NM),      &
     &          SCRTCH(NM,11),AA(1),II(1)
      DIMENSION UTDT(NM),XNM(3)
      DIMENSION TN(3,2,2)
      COMMON/CONSTR/PI,TWOPI,DEGRAD,SECRAD,SECDAY
      COMMON/CONTRL/LSIMDT,LOBS  ,LORB  ,LNOADJ,LNADJL,LORFST,LORLST,   &
     &              LORALL,LORBOB,LOBFST,LOBLST,LOBALL,LPREPO,LORBVX,   &
     &              LORBVK,LACC3D,LSDATA,LCUTOT,LACCEL,LDYNAC,LFRCAT,   &
     &              LNIAU, NXCONT
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
      COMMON/CRDDIM/NDCRD2,NDCRD3,NDCRD4,NDCRD5,NDCRD6,NDCRD7,          &
     &              NDCRD8,NDCRD9,NXCRDM
      COMMON/CTHDOT/THDOT
      COMMON/CTHETG/DJ1900,TG1900,TDOT00,TGDDOT, DCENT,DAYEAR
      COMMON/DTMGDN/TGTYMD,TMGDN1,TMGDN2,REPDIF,XTMGN
      COMMON/THETGC/THTGC(4)
!
      DATA TWO/2.0D0/,THREE/3.D0/,ADDON/.7272205216643040D-04/
      DATA ZERO/0.0/
      DATA CAPTA/0.4101437397284052D+00/,CAPTB/0.3168808892311202D-09/
      DATA XNA/-0.3490658503988659D-07/,XNB/-0.3630284844148205D-04/,   &
     &     XNC/ 0.3375714627564109D+02/,XND/-0.4523601602118369D+01/
      DATA ARG1/.127991D-7/,ARG2/.30543D-9/
!
!********1*********2*********3*********4*********5*********6*********7**
! START OF EXECUTABLE CODE
!********1*********2*********3*********4*********5*********6*********7**
!
! GET EQN OF EQUINOX
      IF(.NOT.LEQC) GO TO 500
      CALL BUFEAR(MJDSEC,FSEC(1),MJDSEC,FSEC(NM),1,MJDDUM,FSCDM,LDUM,   &
     &            AA,II)
      CALL NUVECT(MJDSEC,FSEC,AA(KDPSI),AA(KEPST),AA(KEPSM),            &
     &            NM,SCRTCH)
!     WRITE(6,*) '  GRHRAN :  CALL NPVECT MJDSEC,FSEC  ',MJDSEC,FSEC
      CALL NPVECT(MJDSEC,FSEC,AA(KDPSI),AA(KEPST),AA(KEPSM),            &
     &            AA(KETA),AA(KTHTA),AA(KZTA),NM,SCRTCH,                &
     &            AA(KROTMT),EQN,NDCRD2,LONLEQ,                         &
     &            AA(KPDPSI),AA(KPEPST),AA(KNUTIN),AA(KNUTMD),LNUPRT,   &
     &            AA(KDXDNU),AA(KDPSIE),AA(KEPSTE),XNM,TN)
!     IF(MJDSEC.LT.1771804800) GO TO 500
!     1771804800/86400.D0=20507 (MJD=50507, -> Feb.27,1997 )
       IF(LNIAU)  THEN
      X22797=50507.D0
      XMJD=DBLE(MJDSEC)/86400.D0+TMGDN2
      IF(XMJD.LT.X22797)GO TO 500
      DLT3=(TMGDN2-30000.D0)*86400.D0
      DO 400 I=1,NM
      SCRTCH(I,5)=CAPTA+CAPTB*(DBLE(MJDSEC)+FSEC(I))
      SCRTCH(I,5)=SCRTCH(I,5)+CAPTB*DLT3
      SCRTCH(I,1)=-(((XNA*SCRTCH(I,5)+XNB)*SCRTCH(I,5)+XNC)             &
     &                *SCRTCH(I,5)+XND)
      SCRTCH(I,2)=TWO*SCRTCH(I,1)
      EQN(I)=EQN(I)+ARG1*SIN(SCRTCH(I,1))+ARG2*SIN(SCRTCH(I,2))
  400 END DO
!
       ENDIF    ! LNIAU
! GET GREENWICH HOUR ANGLE
  500 CONTINUE
      CALL GRHRN2(MJDSEC,FSEC,EQN,SCRTCH,THETAG,COSTHG,                 &
     &           SINTHG,NM,AA,UTDT)
      RETURN
      END
