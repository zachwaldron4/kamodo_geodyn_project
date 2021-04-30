


!$DMARS
      SUBROUTINE DMARS(XSC,MJDSEC,FSEC,DENST)
!********1*********2*********3*********4*********5*********6*********7**
! DMARS            00/00/00            0000.0    PGMR - DDR
!
! FUNCTION: COMPUTE ATMOSPHERIC DENSITY FOR MARS ORBITING SATELLITES
!           BASED ON THE CULP AND STEWART MODEL
!
!  I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   XSC      I    A    SPACECRAFT POSITION VECTOR
!   MJDSEC   I    S    TIME IN INTEGRAL SECONDS FROM GEODYN REF. TIME
!   FSEC     I    S    TIME IN FRACTIONAL SECONDS FOR EACH MEASUREMENT
!   DENST    I    S    MARS ATMOSPHERIC DENSITY
!
! COMMENTS:
!
! REFERENCES:  CULP AND STEWART (?)
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      COMMON/CONSTR/PI,TWOPI,DEGRAD,SECRAD,SECDAY
      COMMON/CRMB/RMB(9), rmb0(9)
      COMMON/CVIEW /IOUT6 ,ILINE6,IPAGE6,MLINE6,                        &
     &              IOUT8 ,ILINE8,IPAGE8,MLINE8,                        &
     &              IOUT9 ,ILINE9,IPAGE9,MLINE9,                        &
     &              IOUT10,ILIN10,IPAG10,MLIN10,                        &
     &              IOUT15,ILIN15,IPAG15,MLIN15,                        &
     &              IOUT16,ILIN16,IPAG16,MLIN16,                        &
     &              IOUT7 ,NXCVUE
      COMMON/DTMGDN/TGTYMD,TMGDN1,TMGDN2,REPDIF,XTMGN
      COMMON/MNSNSP/XMNSNS(7,2)
      COMMON/STARTT/ESSTRT,FSSTRT
!
      DIMENSION XSNI(3)
      DIMENSION XSC(3),XSN(3),PP(9),TINF(3),ZF(3),F(9),DZDS(3),VD(3)
      DIMENSION XNBDNS(9),XMW(9)
!     REAL MB , MBAR,MBOK ,NBDNS ,MW ,K ,LWFCTR
!          XMB,XMBAR,XMBOK,XNBDNS,XMW,XK,FCTLW
!
      DATA FPD3/3000.0D0/
!
!     DATA BDAT/2430000.5D0/
      DATA A,AF,AVOGDR,ED,ES/2.279D8,60.D0,0.1660081676D-20,.1D0,.1D0/
      DATA F/.93D0,.02D0,.027D0,.016D0,.01D0,.0013D0,5.0D-5,1.D-6,      &
     &        4.D-6/
      DATA XK,XMW/8314.39D0,44.01D0,16.D0,28.012D0,39.948D0,28.01D0,    &
     &           32.D0,4.D0,1.D0,2.D0/
      DATA XMBAR,NC,PERIOD/43.3D0,9,686.98D0/
      DATA P6,RA,RB,RC/610.D0,3394.67D0,3393.21D0,3376.78D0/
      DATA REFDAT,SIGMA,SOLDAY,U/2443951.D0,1.D0,365.25636D0,           &
     &                          .42828443D10/
      DATA SCLNGA/1.893682238D0/
      DATA DJ3935/2443935.D0/,D26P35/26.35D0/,D360/360.D0/,D250/250.D0/
      DATA D2P8/2.8D0/,D59/59.D0/,D210/210.D0/,D270/270.D0/
      DATA D7P5/7.5D0/,FIVE/5.D0/,D35/35.D0/,DP65/.65D0/,D13P5/13.5D0/
      DATA D1P2/1.2D0/,D3P66C/3.6651914D0/,DJ2870/2442870.D0/
      DATA D11P04/11.04D0/,D75/75.D0/,D30/30.D0/,DP0011/.0011D0/
      DATA D220/220.D0/,D140/140.D0/,D172P5/172.5D0/
      DATA DP02/0.02D0/,DP9457/.9457D0/,D205/205.D0/,D150/150.D0/
      DATA DP16/.16D0/,D125/125.D0/,D10/10.D0/,D32/32.D0/,D100/100.D0/
      DATA D18/18.D0/,D6P3M9/6.3D-9/,D1P4M7/1.44D-7/,D4DM5/4.D-5/
      DATA D400/400.D0/,D4P6M9/4.6D-9/,D1440/1440.D0/,DP1/.1D0/
      DATA D50/50.D0/,D500/500.D0/,D1P45/1.45D0/,DP9/.9D0/
      DATA DP0145/.0145D0/,DP001/.001D0/
      DATA EMO/.09338D0/
!
!C    DATA OPDM78/1.D-78/
      DATA DM50/1.0D-50/
!
      DATA ZERO/0.D0/,HALF/.5D0/,ONE/1.D0/,THREE/3.D0/
!
!********1*********2*********3*********4*********5*********6*********7**
! START OF EXECUTABLE CODE
!********1*********2*********3*********4*********5*********6*********7**
!
!
!
      DATE=TMGDN1+(DBLE(MJDSEC)+FSEC)/SECDAY
!
!    PULL QUANTITIES FOR SUN FROM XMNSNS
      RSN=XMNSNS(4,2)
      XSNI(1)=RSN*XMNSNS(1,2)
      XSNI(2)=RSN*XMNSNS(2,2)
      XSNI(3)=RSN*XMNSNS(3,2)
      RSN=RSN*DP001
!
!    CONVERT COORDINATE SYSTEM
      XSN(1)=RMB(1)*XSNI(1)+RMB(4)*XSNI(2)+RMB(7)*XSNI(3)
      XSN(2)=RMB(2)*XSNI(1)+RMB(5)*XSNI(2)+RMB(8)*XSNI(3)
      XSN(3)=RMB(3)*XSNI(1)+RMB(6)*XSNI(2)+RMB(9)*XSNI(3)
      XYSC=XSC(1)*XSC(1)+XSC(2)*XSC(2)
      XYSN=XSN(1)*XSN(1)+XSN(2)*XSN(2)
      RSC=SQRT(XYSC+XSC(3)*XSC(3))*DP001
      SCLONG=ATAN2(XSC(2),XSC(1))
      SCLAT=ATAN2(XSC(3),SQRT(XYSC))
      SNLONG=ATAN2(XSN(2),XSN(1))
      SNLAT=ATAN2(XSN(3),SQRT(XYSN))
!    CALCULATE LOCAL TIME
      DL=SCLONG-SNLONG
      TIME=PI+DL
      IF(TIME.LT.ZERO) TIME=TIME+TWOPI
      IF(TIME.GE.TWOPI) TIME=TIME-TWOPI
      SCLONG=SCLONG+SCLNGA
!    CALCULATE THE FRACTION OF HELIOCENTRIC PERIOD
      DT=DATE-REFDAT
      FP=MOD(DT,PERIOD)/PERIOD
      IF(FP.LT.ZERO) FP=FP+ONE
      DAYS=MOD(DATE-DJ3935,D26P35)
      IF(DAYS.LT.ZERO) DAYS=DAYS+D26P35
!    CALCULATE RADIUS OF REF SPHEROID
      AOR=A/RSN
      AC=(AOR*(ONE-EMO*EMO)-ONE)/EMO
      IF(ABS(AC).GT.ONE) AC=AINT(AC)
!CC      ALM=DARCOS(AC)/DEGRAD
      ALM=ACOS(AC)/DEGRAD
      IF(FP.GT.HALF) ALM=D360-ALM
      ALS=ALM+D250
      IF(ALS.GT.D360) ALS=ALS-D360
      CSCLAT=COS(SCLAT)
      CSCLNG=COS(SCLONG)
      SSCLAT=SIN(SCLAT)
      SSCLNG=SIN(SCLONG)
      RSQ=(CSCLAT*CSCLNG/RA)**2+(CSCLAT*SSCLNG/RB)**2+(SSCLAT/RC)**2
      R61MB=SQRT(ONE/RSQ)
      R61MB=R61MB-D2P8*SIN((ALS-D59)*DEGRAD)
!    CALCULATE THE INCREMENT OF DUST STORM
      DL1=ALS-D210
      DL2=ALS-D270
      IF(DL1.LT.ZERO) DL1=DL1+D360
      IF(DL2.LT.ZERO) DL2=DL2+D360
      DZ1=D7P5*(ONE-EXP(-DL1/FIVE))*EXP(-DL1/D35)/DP65
      DZ2=D13P5*(ONE-EXP(-DL2/FIVE))*EXP(-DL2/D35)/DP65
      DZDS(1)=DZ1+DZ2+D1P2
!   CALCULATE THE DIURNAL AND SEASONAL EFFECT
      DZSN=ED-COS(TIME-D3P66C)*CSCLAT+ES*COS(SNLAT-SCLAT)
!   CALCULATE F10.7 AND TEMPERATURE
      Y=(DATE-DJ2870)*TWOPI/(D11P04*SOLDAY)
      F107=D75+AF*(ONE-COS(Y+D30*DEGRAD*(ONE-COS(Y))))
      B=DP0011*F107
      F107=F107*(ONE+B*SIN(TWOPI*DAYS/D26P35))
      T6=D220*AOR
      TA=D140*AOR
      TB=TA
      TF=D172P5*AOR
!    CALCULATE PARAMETERS AT POINTS L,A,B,F
      F(2)=DP02*(ONE-HALF*SIN(TIME))
      F(1)=DP9457-F(2)
      Z6=ZERO
      DZDS(2)=DZDS(1)+THREE*SIGMA
      DZDS(3)=DZDS(1)-THREE*SIGMA
      IF(DZDS(3).LT.ZERO) DZDS(3)=ZERO
      TINF(1)=D205*AOR*AOR*((F107+D75)/D150)
      TINF(2)=TINF(1)*(ONE+DP16*SIGMA)
      TINF(3)=TINF(1)*(ONE-DP16*SIGMA)
      ZF(1)=DZDS(1)+D125*AOR+DZSN
      ZF(2)=ZF(1)-THREE*SIGMA
      ZF(3)=ZF(1)+THREE*SIGMA
      XMBOK=D10*XMBAR/XK
      G6=U/R61MB**2
      H6=XMBOK*G6/T6
      IC=0
!
      Z=RSC-R61MB
!
!     ....Z IS SATELLITE HEIGHT IN KM
!     ....DO NOT CALCULATE DENSITY IF Z > 3000 KM
!
      IF( Z .GT. FPD3 ) RETURN
!
      G=U/(RSC*RSC)
      DO 10 M=1,3
        ZL=DZDS(M)/(ONE-TA/T6)
        ZA=ZL+D32*AOR
        ZB=DZDS(M)+D100*AOR
        GL=U/(R61MB+ZL)**2
        GA=U/(R61MB+ZA)**2
        GB=U/(R61MB+ZB)**2
        XL=(ZL-Z6)*(R61MB+Z6)/(R61MB+ZL)
        XA=(ZA-ZL)*(R61MB+ZL)/(R61MB+ZA)
        XB=(ZB-ZA)*(R61MB+ZA)/(R61MB+ZB)
        TPL=(TA-T6)/XA
        EL=XMBOK*GL/TPL
        HA=XMBOK*GA/TA
        PL=P6*EXP(-XL*H6)
        PA=PL*(T6/TA)**EL
        PB=PA*EXP(-XB*HA)
        GF=U/(R61MB+ZF(M))**2
        XF=(ZF(M)-ZB)*(R61MB+ZB)/(R61MB+ZF(M))
        TPB=(TF-TB)/XF
        EB=XMBOK*GB/TPB
        PF=PB*(TB/TF)**EB
        AH=TINF(M)/D18
        GFOKT=D10*GF/(XK*TINF(M))
        F(7)=TINF(M)*D6P3M9
        TSQ=SQRT(TINF(M))
        F(9)=TSQ*D1P4M7
        F(8)=TINF(M)*EXP(-HALF*TSQ)*D4DM5
       IF(TINF(M).GE.D400) F(8)=TSQ*D4P6M9*EXP(D1440/TINF(M))/         &
     &                           (ONE+D1440/TINF(M))
!
!    CALCULATE MASS DENSITY FOR Z < ZF
        IF(Z.GT.ZF(M)) GO TO 5
!           FOR ALTITUDE BETWEEN ZB AND ZF
        IF(Z.LT.ZB) GO TO 1
        X=(Z-ZB)*(R61MB+ZB)/(R61MB+Z)
        T=TB+X*TPB
        P=PB*(TB/T)**EB
        GO TO 4
!           FOR ALTITUDE BETWEEN ZA AND ZB
    1   IF(Z.LT.ZA) GO TO 2
        T=TA
        X=(Z-ZA)*(R61MB+ZA)/(R61MB+Z)
        P=PA+EXP(-X*HA)
        GO TO 4
!           FOR ALTITUDE BETWEEN ZL ZND ZA
    2   IF(Z.LT.ZL) GO TO 3
        X=(Z-ZL)*(R61MB+ZL)/(R61MB+Z)
        T=T6+X*TPL
        P=PL*(T6/T)**EL
        GO TO 4
!           FOR ALTITUDE BETWEEN Z6 AND ZL
    3   X=(Z-Z6)*R61MB/(R61MB+Z)
        T=T6
        P=P6*EXP(-X*H6)
    4   DENST=DP1*XMBOK*P/T
        XMB=XMBAR
        GO TO 9
!
!     CALCULATE MASS DENSITY FOR ALTITUDE Z > ZF
    5   CONTINUE
!
        X=(Z-ZF(M))/(ONE+(Z-ZF(M))/(RSC-Z+ZF(M)))
        T=TINF(M)-(TINF(M)-TF)*EXP(-X/AH)
!
        TFOT=TF/T
        TKAV=ONE/(T*XK*AVOGDR)
        DO 6 I=1,NC
          HINF=XMW(I)*GFOKT
!
        PP(I)=PF*F(I)*TFOT**(AH*HINF)
        DEXH = EXP(-X*HINF)
        IF( DEXH .LT. DM50) DEXH = ZERO
        PP(I)=PP(I)*DEXH
          XNBDNS(I)=PP(I)*TKAV
    6     CONTINUE
        SNM2=ZERO
        P=ZERO
        DENST=ZERO
        DO 7 I=1,NC
          P=P+PP(I)
          SNM2=SNM2+XNBDNS(I)*XMW(I)*XMW(I)
          DENST=DENST+XNBDNS(I)*XMW(I)
          IF(I.EQ.7) DNST7=DENST
    7   CONTINUE
!
        IF((DENST-DNST7).LT.(D50*DNST7).OR.IC.EQ.1) GO TO 8
        IF(Z.LT.D500) GO TO 8
        IC=1
        TINFO=TINF(2)
        TINF(2)=TINF(3)
        TINF(3)=TINFO
    8   CONTINUE
        XMB=SNM2/DENST
        DENST=DENST*AVOGDR
!
    9   VD(M)=DENST
        IF(M.NE.1) GO TO 10
        TEMP=T
        H=DP1*XK*T/(XMB*G)
   10   CONTINUE
!
      DENST=VD(1)
      UPFCTR=VD(2)/VD(1)
      FCTRLW=VD(3)/VD(1)
!
      IF(Z.GT.ZA) RETURN
!
      UPFCTR=ONE+(DP1+D1P45*Z/ZB)*SIGMA
      FCTRLW=DP9-SIGMA*DP0145*Z/(ZA-ZL)
      ZP=Z/DP001
      ZAP=ZA/DP001
      XLSIG=DENST*FCTRLW
      XHSIG=DENST*UPFCTR
      WRITE(IOUT6,6000) ZP
      WRITE(IOUT6,6001) ZAP
      WRITE(IOUT6,6002) FSSTRT
      WRITE(IOUT6,6003)
      WRITE(IOUT6,6004) DENST,XLSIG,XHSIG
      RETURN
 6000 FORMAT('  WARNING: SPACE CRAFT HT (M) ',D20.11,' IS LESS THAN')
 6001 FORMAT('  BEGINNING HT (M) OF STRATOSPHERE ',D20.11)
 6002 FORMAT('  AT ',D20.11,' SECONDS FROM EPOCH ')
 6003 FORMAT('  COMPUTED DENSITY (KG/M**3) AND SIGMAS ')
 6004 FORMAT('   UPPER & LOWER FOLLOW:   ',3D20.11)
      END