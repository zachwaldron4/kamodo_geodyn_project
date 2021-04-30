!$PRETID
      SUBROUTINE PRETID(TIDES,MM,KK,HH,JJ,IBDY,SIGN1,SIGN2,ILL,QQ,      &
     &                  COEF,XQQ,IPT,XIEXP,XMM,XLL1,XSIGN1,XSN2QQ,      &
     &                  X2M2HH,X2M2HJ,XKK,JBDY,IIPPTT,NOSIDE,IQNDEX,    &
     &                  ILL1,XSIGN2,JJBDY,ICENTR,ITIDE,MAINNN,SCRTCH,   &
     &                  UNORM)
!********1*********2*********3*********4*********5*********6*********7**
! PRETID           85/08/15            0000.0    PGMR - D. ROWLANDS
!                                                PGMR - D. MORSBERGER
!                                                PGMR - A. MARSHALL
!
! FUNCTION:  PRECOMPUTE QUANTITIES FOR TIDAL FORCE MODEL THAT REMAIN
!            CONSTANT OVER A GLOBAL ITERATION
!
!  I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   TIDES   I/O   A    ARRAY CONTAINING CURRENT VALUES OF A&B
!                      COEFFCIENTS FOR THE EXPANDED TIDAL MODEL.
!                      UPON INPUT THESE HAVE EMAT ORDER
!                      UPON OUTPUT THESE DO NOT HAVE EMAT ORDER
!   MM       I    A    TIDAL EXPANSION ARGUMENT
!   KK       I    A    TIDAL EXPANSION ARGUMENT
!   HH       I    A    TIDAL EXPANSION ARGUMENT
!   JJ       I    A    TIDAL EXPANSION ARGUMENT
!   IBDY     I    A    INDICATES TO WHICH BODY EXPANSION ARGUMENT
!                      APPLIES
!   SIGN1    I    A    SIGN ASSOCIATED WITH EXPANSION ARGUMENTS
!   SIGN2    I    A    SIGN ASSOCIATED WITH LAMBDA TERM (+ FOR ETIDE)
!   ILL      I    A    DEGREE OF TIDAL HARMONIC (2 FOR ETIDE)
!   QQ       I    A    ORDER OF TIDAL HARMONIC (MM TOE ETIDE)
!   COEF     O    A    TIDAL COEFFICIENT. 3-MM
!                      FOR SOLID EARTH TIDES AND FROM LOADING
!                      CONSTANTS FOR OCEAN TIDES.
!   XQQ      O    A    DFLOAT OF ORDER OF TIDAL HARMONIC
!                      =XMM FOR SOLID EARTH TIDES
!   IPT      O    A    POINTER TO LGENDR POLYNOMIAL OF ILL,QQ
!   XIEXP    O    A    +1 IF XMM EVEN;-1 IF XMM ODD
!   XMM      O    A    DFLOAT OF EXPANSION ARGUMENT
!   XLL1     O    A    DFLOAT OF ILL+1
!   XSIGN1   O    A    SIGN ASSOCIATED WITH EXPANSION ARGUMENTS
!   XSN2QQ   O    A    SIGN ASSOCIATED WITH HARMONIC TERM TIMES QQ
!                      = + FOR SOLID EARTH TIDES
!   X2M2HH   O    A    2-2HH WHERE HH IS A TIDAL EXPAMSION TERM
!   X2M2HJ   O    A    X2M2HH+JJ WHERE JJ IS AN EXPANSION ARGUMENT
!   XKK      O    A    DFLOAT OF EXPANSION ARGUMENT
!   JBDY     O    A    PERTURBING BODIES
!   IIPPTT   O    A    POINTER FOR MULTIPLE SINES AND COSINES
!   NOSIDE   O    A    FLAG INDICATING MODEL USAGE
!                      0 = USE MEAN ELEMENTS (NO V/VF TERM) FOR AMP
!                      1 = USE OSCULATING V/VF TERM, INCLUDE SIDE BANDS
!                      2 = USE OSCULATING V/VF TERM, MAIN LINES ONLY
!   IQNDEX   O    A    POINTER FOR QQ*LAMBDA TERM
!   ILL1     O    A    ILL+1
!   XSIGN2   O    A    DFLOAT OF SIGN ASSOCIATED WITH EXPANSION
!                      ARGUMENTS
!   JJBDY    O    A    INDICATES DISTURBING BODY (LIKE JBDY, BUT IF
!                      JBDY=0, THEN JJBDY=1)
!   ICENTR   O    A    MAIN LINE TIDE POINTER
!   ITIDE    O    A    POINTER FOR AMPLITUDE INTERPOLATION
!   MAINNN   O    A    DEGREE OF MAIN LINE TIDE
!   SCRTCH        A    SCRATCH SPACE
!   UNORM    O         DENORMALIZING FACTORS FOR LEGENDRE POLYNOMIALS
!
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      SAVE
      DOUBLE PRECISION KL
      INTEGER HH,QQ,SIGN1,SIGN2
      DIMENSION MM(1),KK(1),HH(1),JJ(1),IBDY(1),SIGN1(1),               &
     &   SIGN2(1),TIDES(1),ILL(1),QQ(1),KL(41)
      DIMENSION COEF(1),XQQ(1),IPT(1),XIEXP(1),XMM(1),                  &
     &          XLL1(1),XSIGN1(1),XSN2QQ(1),X2M2HH(1),X2M2HJ(1),        &
     &          XKK(1),JBDY(1),SCRTCH(1)
      DIMENSION IIPPTT(NTIDE),NOSIDE(NTIDE),IQNDEX(NTIDE),ILL1(NTIDE),  &
     &          JJBDY(NTIDE),ICENTR(NTIDE),ITIDE(NTIDE),MAINNN(NTIDE)
      DIMENSION XSIGN2(NTIDE),UNORM(NTIDE)
      COMMON/CGRAV/GM,AE,AESQ,FE,FFSQ32,FSQ32,XK2,XK3,XLAM,SIGXK2,      &
     &      SIGXK3,SIGLAM,RATIOM(2),AU,RPRESS
      COMMON/CITER /NINNER,NARC,NGLOBL
      COMMON/CONSTR/PI,TWOPI,DEGRAD,SECRAD,SECDAY
      COMMON/CTIDES/NTIDE,NSTADJ,NET,NETADJ,NETUN,NOT,NOTADJ,           &
     &   NOTUN ,NETUNU,NETADU,NOTUNU,NOTADU,NBSTEP,KTIDA(3),            &
     &   ILLMAX,NUNPLY,NNMPLY,NDOODN,MXTMRT,NRESP ,NXCTID
      COMMON/CVIEW /IOUT6 ,ILINE6,IPAGE6,MLINE6,                        &
     &              IOUT8 ,ILINE8,IPAGE8,MLINE8,                        &
     &              IOUT9 ,ILINE9,IPAGE9,MLINE9,                        &
     &              IOUT10,ILIN10,IPAG10,MLIN10,                        &
     &              IOUT15,ILIN15,IPAG15,MLIN15,                        &
     &              IOUT16,ILIN16,IPAG16,MLIN16,                        &
     &              IOUT7 ,NXCVUE
      COMMON/QQTIDE/IQMAX,IQMIN,IQDIF,NUMFRQ,NBAND
!  NEGATIVE OF LONGMANS LOAD DEFORMATION COEFFICIENTS : K PRIME OF (L+1)
!  VALUES BEGIN WITH L=0 AND PROGRESS TO L=41
!     DATA KL/0.0D0  ,0.0D0  ,0.310D0,0.197D0,0.133D0,0.104D0,0.090D0,
!    .        0.082D0,0.076D0,0.072D0,0.069D0,0.066D0,0.064D0,0.062D0,
!    .        0.060D0,0.058D0,0.056D0,0.055D0,0.054D0,0.052D0,0.051D0,
!    .        0.050D0,0.049D0,0.048D0,0.047D0,0.046D0,0.045D0,0.044D0,
!    .        0.043D0,0.042D0,0.041D0,0.040D0,0.040D0,0.039D0,0.038D0,
!    .        0.037D0,0.037D0,0.036D0,0.035D0,0.034D0,0.034D0/
! COEFFICIENTS = 4*PI*R*G*RHO*(1-KL)/(2L+1)
!   WHERE R = AVG EARTH RADIUS
!         G = GRAVITATIONAL CONSTANT
!       RHO = AVG SEA WATER DENSITY (1.031
      DATA KL/0.55064029824D+01,0.18354676608D+01,0.75988361158D+00,    &
     &        0.63166308498D+00,0.53045015397D+00,0.44852155202D+00,    &
     &        0.38544820877D+00,0.33699186252D+00,0.29928919740D+00,    &
     &        0.26894431409D+00,0.24411719889D+00,0.22360784285D+00,    &
     &        0.20615972766D+00,0.19129651843D+00,0.17848340702D+00,    &
     &        0.16732360030D+00,0.15751649744D+00,0.14867288053D+00,    &
     &        0.14078533031D+00,0.13384794942D+00,0.12745308367D+00,    &
     &        0.12165308915D+00,0.11636864970D+00,0.11153394977D+00,    &
     &        0.10709391923D+00,0.10300212638D+00,0.99219148080D-01,    &
     &        0.95711295476D-01,0.92449607968D-01,0.89409051816D-01,    &
     &        0.86567876396D-01,0.83907093066D-01,0.81325336356D-01,    &
     &        0.78979899494D-01,0.76770429987D-01,0.74685437635D-01,    &
     &        0.72639261261D-01,0.70775633001D-01,0.69008816598D-01,    &
     &        0.67331459254D-01,0.65668954087D-01/
      DATA ZERO /0.D0/
      DATA TWO  /2.D0/
      DATA FOUR /4.D0/
!********1*********2*********3*********4*********5*********6*********7**
! START OF EXECUTABLE CODE
!********1*********2*********3*********4*********5*********6*********7**
      IF(NTIDE.LE.0) RETURN
       IF(ILLMAX .GT. 41) THEN
         WRITE(IOUT6,*) ' KL SIZE(41) EXCEEDED IN PRETID',ILLMAX
         STOP
       ENDIF
! SEPARATE NOSIDE & JBDY VALUES FROM THE IBDY ARRAY
! NOSIDE IS COLUMN 23 ON INPUT CARD
! JBDY   IS COLUMN 24 ON INPUT CARD
! THEY ARE FED IN TOGETHER IN THE IBDY ARRAY
       IF(NGLOBL.GT.1) GO TO 261
       DO 2 I=1,NTIDE
       ITMP=IBDY(I)/10
       JBDY(I)=IBDY(I)-(ITMP*10)
       ITMP1=ITMP/10
       NOSIDE(I)=ITMP-ITMP1*10
    2  CONTINUE
      DO 260 I=1,NTIDE
      IMULT=JBDY(I)
      IF(IMULT.GT.0) IMULT=1
! FORCING DEGREE CAN BE INPUT AS 1 OR THREE FOR OTIDES WITHOUT FAMILIES.
! IF FORCING DEGREE IS 1 THEN FORCING ORDER (MM) WILL BE INPUT AS
! 3 FOR DEGREE 1 ORDER 0 ; OR 4 FOR DEGREE 1 ORDER 1
! A SIMILAR SCHEME IS USED FOR DEGREE 3
      IFDEG=2
      IF(MM(I).GE.3.AND.MM(I).LE.4) THEN
         IFDEG=1
         MM(I)=MM(I)-3
      ENDIF
      IF(MM(I).GE.5.AND.MM(I).LE.8) THEN
         IFDEG=3
         MM(I)=MM(I)-5
      ENDIF
      I2M2HH=IMULT*(IFDEG-2*HH(I))
      X2M2HH(I)=DBLE(I2M2HH)
      I2M2HJ=IMULT*(I2M2HH+JJ(I))
      X2M2HJ(I)=DBLE(I2M2HJ)
      IKK=IMULT*KK(I)
      XKK(I)=DBLE(IKK)
  260 END DO
  261 CONTINUE
!
! GET A&B COEFFCIENTS IN THE ORDER THAT THE FORCE MODEL WILL USE THEM
      NTIDE2=2*NTIDE
      DO 10 I=1,NTIDE2
      SCRTCH(I)=TIDES(I)
   10 END DO
!
      IF(NETADJ.LE.0) GO TO 30
      DO 20 I=1,NETADJ
      TIDES(NTIDE+I)=SCRTCH(NETADJ+I)
   20 END DO
   30 CONTINUE
      IF(NOTADJ.LE.0) GO TO 50
      DO 40 I=1,NOTADJ
      TIDES(NETADJ+I)=SCRTCH(2*NETADJ+I)
      TIDES(NTIDE+NETADJ+I)=SCRTCH(2*NETADJ+NOTADJ+I)
   40 END DO
   50 CONTINUE
      IF(NETUN.LE.0) GO TO 70
      DO 60 I=1,NETUN
      TIDES(NETADJ+NOTADJ+I)=SCRTCH(2*NETADJ+2*NOTADJ+I)
      TIDES(NTIDE+NETADJ+NOTADJ+I)=SCRTCH(2*NETADJ+2*NOTADJ+NETUN+I)
   60 END DO
   70 CONTINUE
      IF(NOTUN.LE.0) GO TO 90
      DO 80 I=1,NOTUN
      TIDES(NETADJ+NOTADJ+NETUN+I)=SCRTCH(2*NETADJ+2*NOTADJ+2*NETUN+I)
   80 END DO
   90 CONTINUE
!
!
       IF(NGLOBL.GT.1)  RETURN
!
!
! LOAD COEF
      DO 140 J=1,NET
      JPT=J
      IF(J.GT.NETADJ)JPT=JPT+NOTADJ
      COEF(JPT)=3-MM(JPT)
  140 END DO
      IF(NOTADJ.LE.0) GO TO 160
      DO 150 I=1,NOTADJ
      COEF(NETADJ+I)=KL(ILL(NETADJ+I)+1)
  150 END DO
  160 CONTINUE
      IF(NOTUN.LE.0) GO TO 180
      DO 170 I=1,NOTUN
      COEF(NETADJ+NOTADJ+NETUN+I)=KL(ILL(NETADJ+NOTADJ+NETUN+I)+1)
  170 END DO
  180 CONTINUE
      DO 190 I=1,NTIDE
      XQQ(I)=DBLE(QQ(I))
  190 END DO
! GET POINTER TO LGENDR POLYNOMIAL, AND DENORMALIZING FACTOR
      DO 200 I=1,NTIDE
      IDEG=ILL(I)
      IORD=QQ(I)
      IPT(I)=(IDEG-1)*IDEG/2+(IDEG-1)*3+1+IORD
      UNORM(I)=DENORM(IDEG,IORD)
  200 END DO
! GET XIEXP
      DO 210 I=1,NTIDE
      IEXP=1-2*MOD(MM(I),2)
      XIEXP(I)=DBLE(IEXP)
  210 END DO
      DO 220 I=1,NTIDE
      XMM(I)=DBLE(MM(I))
  220 END DO
      DO 230 I=1,NTIDE
      XLL1(I)=DBLE(ILL(I)+1)
  230 END DO
      DO 240 I=1,NTIDE
      XSIGN1(I)=DBLE(SIGN1(I))
  240 END DO
      DO 250 I=1,NTIDE
      XSN2QQ(I)=DBLE(SIGN2(I)*QQ(I))
  250 END DO
! DETERMINE THE MAX AND MIN OF THE Q'S  & L'S
       IQMAX=QQ(1)
       DO 252 IY=2,NTIDE
       IQMAX=MAX(IQMAX,QQ(IY))
  252  CONTINUE
       IQMIN=QQ(1)
       DO 253 IZ=2,NTIDE
       IQMIN=MIN(IQMIN,QQ(IZ))
  253  CONTINUE
       IQDIF=IQMAX-IQMIN+1
      DO 254 IW=1,NTIDE
       IQNDEX(IW)=QQ(IW)-IQMIN+1
  254 END DO
!
! SEPARATE NOSIDE & JBDY VALUES FROM THE IBDY ARRAY
! NOSIDE IS COLUMN 23 ON INPUT CARD
! JBDY   IS COLUMN 24 ON INPUT CARD
! THEY ARE FED IN TOGETHER IN THE IBDY ARRAY
!       DO 2 I=1,NTIDE
!       ITMP=IBDY(I)/10
!       JBDY(I)=IBDY(I)-(ITMP*10)
!       ITMP1=ITMP/10
!       NOSIDE(I)=ITMP-ITMP1*10
!2      CONTINUE
! THE FOLLOWING THREE QUANTITIES ARE SET TO ZERO IF JBDY=ZERO
!      DO 260 I=1,NTIDE
!      IMULT=JBDY(I)
!      IF(IMULT.GT.0) IMULT=1
!      I2M2HH=IMULT*(2-2*HH(I))
!      X2M2HH(I)=DFLOAT(I2M2HH)
!      I2M2HJ=IMULT*(I2M2HH+JJ(I))
!      X2M2HJ(I)=DFLOAT(I2M2HJ)
!      IKK=IMULT*KK(I)
!      XKK(I)=DFLOAT(IKK)
! 260  CONTINUE
      DO 270 I=1,NTIDE
      JJBDY(I)=MAX(JBDY(I),1)
  270 END DO
      DO 262 I=1,NTIDE
      XSIGN2(I)=DBLE(SIGN2(I))
      ILL1(I)=ILL(I)+1
  262 END DO
! DETERMINE HOW MANY DISTINCT FREQUENCIES YOU HAVE
       NUMFRQ=1
       IIPPTT(1)=1
       DO 75 J=2,NTIDE
         DO 15 I=1,NUMFRQ
           IF(XSIGN1(J).NE.XSIGN1(I))GOTO 15
           IF(XMM(J).NE.XMM(I))GOTO 15
           IF(XKK(J).NE.XKK(I))GOTO 15
           IF(X2M2HH(J).NE.X2M2HH(I))GOTO 15
           IF(X2M2HJ(J).NE.X2M2HJ(I))GOTO 15
           IF(JJBDY(J).NE.JJBDY(I))GOTO 15
           IIPPTT(J)=I
           GOTO 75
   15      CONTINUE
         NUMFRQ=NUMFRQ+1
         XSIGN1(NUMFRQ)=XSIGN1(J)
         XMM(NUMFRQ)=XMM(J)
         XKK(NUMFRQ)=XKK(J)
         X2M2HH(NUMFRQ)=X2M2HH(J)
         X2M2HJ(NUMFRQ)=X2M2HJ(J)
         JJBDY(NUMFRQ)=JJBDY(J)
         IIPPTT(J)=NUMFRQ
   75  CONTINUE
!
! DETERMINE WHAT MAIN LINE AND SIDEBAND FREQUENCIES YOU HAVE
      CALL PRESET(SIGN1,MM,KK,HH,JJ,JBDY,QQ,ITIDE,NOSIDE,ICENTR,        &
     &            IBDY,ILL,MAINNN)
      RETURN
      END