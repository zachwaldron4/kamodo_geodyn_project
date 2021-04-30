      SUBROUTINE MXYWEX(TM1,TM2,OA1,OAS,BET1,BETS,YAWRM,BIASD,LEX,      &
     &                  TEX1,TEX2,YAWM,YAWDOT,LPROB)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      COMMON/CONSTR/PI,TWOPI,DEGRAD,SECRAD,SECDAY
      DATA IFRAC/5/
!
      LEX=.TRUE.
      LPROB=.FALSE.
!
      TDIF=TM2-TM1
      IDIF=TDIF
      NT=IFRAC*IDIF
      DELT=1.D0/DBLE(IFRAC)
      YB=BIASD*DEGRAD
!
      DO 100 I=1,NT
      ORBAD=OA1+DBLE(I-1)*DELT*OAS
      ORBA=ORBAD*DEGRAD
      BETAD=BET1+DBLE(I-1)*DELT*BETS
      IF(BETAD.GT.0.D0.AND.BETAD.LT..01D0) BETAD=.01D0
      IF(BETAD.LT.0.D0.AND.BETAD.GT.-.01D0) BETAD=.01D0
      IF(BETAD.EQ.0.D0) THEN
         IF(BETS.GT.0.D0) BETAD=.01D0
         IF(BETS.LT.0.D0) BETAD=-.01D0
      ENDIF
      BETA=BETAD*DEGRAD
      TBETA=TAN(BETA)
      YAW=ATAN2(TBETA,-SIN(ORBA))
      E=ACOS(COS(BETA)*COS(ORBA))
      LSING=.FALSE.
      IF(ABS(SIN(E)).LE.0.00001D0) LSING=.TRUE.
      IF(.NOT.LSING) RAT=YB/SIN(E)
      IF(RAT.GT.1.D0) LSING=.TRUE.
      IF(.NOT.LSING) THEN
         B=ASIN(RAT)/DEGRAD
      ELSE
         B=0.D0
      ENDIF
      YAWD=B+YAW/DEGRAD
      ORBAP=(ORBAD-DELT*OAS)*DEGRAD
      YAWP=ATAN2(TBETA,-SIN(ORBAP))
      E=ACOS(COS(BETA)*COS(ORBAP))
      LSING=.FALSE.
      IF(ABS(SIN(E)).LE.0.00001D0) LSING=.TRUE.
      IF(.NOT.LSING) RAT=YB/SIN(E)
      IF(RAT.GT.1.D0) LSING=.TRUE.
      IF(.NOT.LSING) THEN
         B=ASIN(RAT)/DEGRAD
      ELSE
         B=0.D0
      ENDIF
      YAWPD=B+YAWP/DEGRAD
      YAWRAT=(YAWD-YAWPD)/DELT
      IF(ABS(YAWRAT).GE.YAWRM) THEN
         I0=I
         IS=I+20
         YAWM=YAWD
         YAWDOT=YAWRM
         IF(YAWRAT.LT.0.D0) YAWDOT=-YAWRM
         TEX1=TM1+DBLE(I-1)*DELT
         GO TO 110
      ENDIF
  100 END DO
      LEX=.FALSE.
      RETURN
  110 CONTINUE
      DO 200 I=IS,NT
      ORBAD=OA1+DBLE(I-1)*DELT*OAS
      ORBA=ORBAD*DEGRAD
      BETAD=BET1+DBLE(I-1)*DELT*BETS
      IF(BETAD.GT.0.D0.AND.BETAD.LT..01D0) BETAD=.01D0
      IF(BETAD.LT.0.D0.AND.BETAD.GT.-.01D0) BETAD=.01D0
      IF(BETAD.EQ.0.D0) THEN
         IF(BETS.GT.0.D0) BETAD=.01D0
         IF(BETS.LT.0.D0) BETAD=-.01D0
      ENDIF
      BETA=BETAD*DEGRAD
      TBETA=TAN(BETA)
      YAW=ATAN2(TBETA,-SIN(ORBA))
      E=ACOS(COS(BETA)*COS(ORBA))
      LSING=.FALSE.
      IF(ABS(SIN(E)).LE.0.00001D0) LSING=.TRUE.
      IF(.NOT.LSING) RAT=YB/SIN(E)
      IF(RAT.GT.1.D0) LSING=.TRUE.
      IF(.NOT.LSING) THEN
         B=ASIN(RAT)/DEGRAD
      ELSE
         B=0.D0
      ENDIF
      YAWD=B+YAW/DEGRAD
      YAW2=YAWM+DBLE(I-I0)*DELT*YAWDOT
      LREACH=.FALSE.
      IF(YAWDOT.GT.0.D0.AND.YAW2.GE.YAWD) LREACH=.TRUE.
      IF(YAWDOT.LT.0.D0.AND.YAW2.LE.YAWD) LREACH=.TRUE.
      IF(LREACH) THEN
         TEX2=TM1+DBLE(I-1)*DELT
         RETURN
      ENDIF
  200 END DO
      LPROB=.TRUE.
      RETURN
      END