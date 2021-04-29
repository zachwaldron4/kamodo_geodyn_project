      SUBROUTINE CONCLK(NSATA,PLAB,PARMV0,PARMVC,SUM1,SUM2,PMPA,NADJST, &          
     &                  NRMTOT,SCRTCH,LAVOID)
      IMPLICIT REAL*8(A-H,O-Z),LOGICAL(L)
      COMMON/ICLCKP/IUS65(50),NCLCKP(50),ICLKP(3,1000,50)
      DIMENSION PLAB(3,1),PARMV0(1),PARMVC(1)
      DIMENSION SUM1(1),SUM2(1),PMPA(1),SCRTCH(1),LAVOID(1)
      DIMENSION ISTRNG(2,1000)
      DIMENSION RESID(1),WT(1)
!
      DO 100 ISAT=1,NSATA
      WRITE(6,6000)
      WRITE(6,6000)
      IF(IUS65(ISAT).GT.0) THEN
        WRITE(6,6001) ISAT,IUS65(ISAT),NCLCKP(ISAT)
        NP=NCLCKP(ISAT)
        IF(NP.GT.0) THEN
          NSTRNG=1
          ISTRNG(1,NSTRNG)=1
          ISTRNG(2,NSTRNG)=1
          DO I=1,NP
           WRITE(6,6002) I,(PARMVC(ICLKP(IQP,I,ISAT)),IQP=1,3)      
           WRITE(6,6004) PLAB(2,ICLKP(1,I,ISAT)),PLAB(3,ICLKP(1,I,ISAT))
           IF(I.GE.2) THEN
             TDIF=PLAB(2,ICLKP(1,I,ISAT))-PLAB(3,ICLKP(1,I-1,ISAT))
             IF(TDIF.LE.0.D0) THEN
               WRITE(6,6005) I
               STOP 
             ELSE
               IF(TDIF.GT.10.D0) THEN
                 ISTRNG(2,NSTRNG)=I-1
                 NSTRNG=NSTRNG+1
                 ISTRNG(1,NSTRNG)=I
                 WRITE(6,6006) I
               ENDIF
             ENDIF
           ENDIF
          ENDDO
          ISTRNG(2,NSTRNG)=NP
          WRITE(6,6007) NSTRNG
          DO 90 I=1,NSTRNG
          WRITE(6,6008) I,ISTRNG(1,I),ISTRNG(2,I)
! ANCHOR THE FIRST POLYNOMIAL'S CONSTANT TERM
          J0=ISTRNG(1,I)
          IPJ0=ICLKP(1,J0,ISAT)
          RESID(1)=PARMV0(IPJ0)-PARMVC(IPJ0)
          DO K=1,NADJST
            PMPA(K)=0.D0
            LAVOID(K)=.TRUE.
          ENDDO 
          PMPA(IPJ0)=1.D0
          LAVOID(IPJ0)=.FALSE.
          WT(1)=1.D40
          CALL SUMNM(PMPA,RESID,WT,NADJST,NRMTOT,1,SUM1,SUM2,           &           
     &               SCRTCH,LAVOID)
!
!
          IF(ISTRNG(1,I).EQ.ISTRNG(2,I)) GO TO 90
          J1=ISTRNG(1,I)+1
          J2=ISTRNG(2,I)
          DO 80 J=J1,J2
          TD=PLAB(3,ICLKP(1,J,ISAT))-PLAB(2,ICLKP(1,J-1,ISAT))
          TD=TD/3600.D0
          TD2=TD*TD
          VALL=PARMVC(ICLKP(1,J-1,ISAT))+PARMVC(ICLKP(2,J-1,ISAT))*TD
          VALL=VALL+PARMVC(ICLKP(3,J-1,ISAT))*TD2
          VALR=PARMVC(ICLKP(1,J,ISAT))
          RESID(1)=VALL-VALR
          DO K=1,NADJST
            PMPA(K)=0.D0
            LAVOID(K)=.TRUE.
          ENDDO 
          LAVOID(ICLKP(1,J-1,ISAT))=.FALSE.
          LAVOID(ICLKP(2,J-1,ISAT))=.FALSE.
          LAVOID(ICLKP(3,J-1,ISAT))=.FALSE.
          LAVOID(ICLKP(1,J,ISAT))=.FALSE.
          PMPA(ICLKP(1,J-1,ISAT))=-1.D0
          PMPA(ICLKP(2,J-1,ISAT))=-TD
          PMPA(ICLKP(3,J-1,ISAT))=-TD2
          PMPA(ICLKP(1,J,ISAT))=1.D0
          WT(1)=1.D22
          CALL SUMNM(PMPA,RESID,WT,NADJST,NRMTOT,1,SUM1,SUM2,           &           
     &               SCRTCH,LAVOID)
   80     CONTINUE 
   90     CONTINUE 
        ENDIF
      ELSE
        WRITE(6,6003) ISAT
      ENDIF
  100 CONTINUE
      RETURN
6000  FORMAT(' ')
6001  FORMAT(' SATELLITE # ',I4,' HAS ID ',I7,' AND HAS ',I4,' CLOCK P')
6002  FORMAT(' CLOCK POLYNOMIAL # ',I3,' HAS FOLLOWING COEFS ',3D20.11)
6003  FORMAT(' SATELLITE # ',I4,' HAS NO CLOCK P')
6004  FORMAT(' START & STOP ',2F20.3)
6005  FORMAT(' EXECUTION TERMINATING. POLYNOMIAL # 'I4,' OUT OF ORDER')
6006  FORMAT(' POLYNOMIAL # 'I4,' STARTS A NEW STRING')
6007  FORMAT(' THERE ARE ',I4,' STRINGS')
6008  FORMAT('  STRING ',I3,' START & STOP ',2I3)
      END

