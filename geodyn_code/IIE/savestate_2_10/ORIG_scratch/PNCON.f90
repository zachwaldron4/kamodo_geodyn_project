!$PNCON
      SUBROUTINE PNCON
!********1*********2*********3*********4*********5*********6*********7**
! PNCON            83/04/06            8202.3    PGMR - D. ROWLANDS
!
!  FUNCTION:  DETERMINE ELEMENTS OF PRECESION SINCE 1950.0
!             AND THE MEAN OBLIQUITY.THIS IS DONE ONLY AT
!             12 HR INTERPOLATION ENDPOINT TIMES.IN ADDITION,
!             DETERMINE THE COEFFICIENTS OF THE QUADRATIC
!             POLYNOMIALS NEEDED TO CALCULATE THE ABOVE
!             QUANTITIES AT OTHER TIMES, GIVEN THE NUMBER
!             OF EPHEMERIS SECONDS SINCE THE FIRST 12 HR
!             ENDPOINT IN THE CURRENT BUFFER.
!
! COMMENTS:  INPUT AND OUTPUT BY MEANS OF COMMON BLOCKS
!
! INPUT-OUTPUT   THIS SUBROUTINE CALCULATES THE ELEMENTS AT
!                THE FIRST TIME IN COMMON BLOCK ENDTRP USING
!                THE STANDARD FORMULATION. AFTER THIS, NEW
!                COEFFICIENTS ARE COMPUTED FOR A QUADRATIC
!                POLYNOMIAL WITH ORIGIN AT THE FIRST TIME IN
!                ENDTRP. THESE COEFFICIENTS ARE PLACED IN
!                COMMONS NUTCON & PRECON. FINALLY, THESE
!                COEFFICIENTS ARE USED TO CALCULATE THE
!                ELEMENTS AT OTHER TIMES IN ENDTRP.
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      DIMENSION PRE50(3,3),OBLQ50(4)
      COMMON/EPHMPT/NTOT,NTOTS,NNPDPR,NUTORD,IBODDG(8),IGRPDG(4),       &
     &              NENPD,INRCD(2),KPLAN(11),NINEP,NEPHMR,NEPHEM,       &
     &              IBHINT,NINTBH,NXEPHP
      COMMON/EPHSET/EMFACT,DTENPD,DTINPD,FSC1EN,FSCENP(2),FSCINP(4),    &
     &   FSDINP(4),XEPHST
      COMMON/NUTCON/CNUT(3)
      COMMON/PRECON/PRECON(3,3)
      COMMON/CNUTAT/SINEM(1),COSEM(1),SINDP(1),COSDP(1),SINET(1),       &
     &   COSET(1),SINZ(1),COSZ(1),SINTH(1),COSTH(1),SINEA(1),COSEA(1),  &
     &   SDSE(1),SDCE(1),CDSE(1),CDCE(1),SESD(1),SECD(1),CESD(1),       &
     &   CECD(1),SESE(1),SECE(1),CESE(1),CECE(1),CECT(1),SEST(1),       &
     &   CEST(1),SECT(1),CECZ(1),CESZ(1),SECZ(1),SESZ(1),STSZ(1),       &
     &   CTCZ(1),STCZ(1),CTSZ(1),CTCZCE(1),STSZSE(1),CTCZSE(1),         &
     &   CTSZCE(1),STCZCE(1),STSZCE(1),STCZSE(1),CTSZSE(1),SESDSE(1),   &
     &   SESDCE(1),SECDSE(1),SECDCE(1),CESDSE(1),CESDCE(1),CECDSE(1),   &
     &   CECDCE(1),EPSM(1),EPST(1),DPSI(1),Z(1),THTA(1),ETA(1),AK1(1),  &
     &   AK2(1),AK3(1),AK4(1),AK5(1),AK6(1),AK7(1),AK8(1),SUMMY(198)
      DATA PRE50/.1117470324644D-1,.1117470324644D-1,                   &
     &.9716902444311D-2,.1464137316950D-5,.5299013534521D-5,            &
     &-.2065306281524D-5,.8678164891851D-7,.9308422677293D-7,           &
     &-.2016824913413D-6/
      DATA OBLQ50/.4092061941425D0,-.7197410180482D-13,                 &
     &           -.1550521991071D-26,.2792167967453D-36/
      DATA ONE/1.D0/,TWO/2.D0/,THREE/3.D0/
!***************************'WRONG' CONSTANTS FOR SAKE OF COMPARISON
      DATA TRATE/.00000614D0/,TRATH/.00000614D0/
      DATA EDPTC0/36524.219879D0/
!******************************** END 'WRONG' CONSTANTS
      DATA MJD50S/283558147/,FJD50S/.2D0/
      DATA SECDAY/86400.D0/,CENT/36525.D0/
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
      XES50=(FSCINP(1)-MJD50S)-FJD50S
      XED50=XES50/SECDAY
      XEC50=XED50/CENT
      AEDPTC=EDPTC0-XEC50*TRATH
      XTC50=XED50/AEDPTC
      ETA(1)=((PRE50(1,3)*XTC50+PRE50(1,2))*XTC50+PRE50(1,1))*XTC50
      Z(1)=((PRE50(2,3)*XTC50+PRE50(2,2))*XTC50+PRE50(2,1))*XTC50
      THTA(1)=((PRE50(3,3)*XTC50+PRE50(3,2))*XTC50+PRE50(3,1))*XTC50
      EPSM(1)=((OBLQ50(4)*XES50+OBLQ50(3))*XES50+OBLQ50(2))*XES50       &
     &   +OBLQ50(1)
      PRECON(1,1)=ETA(1)
      PRECON(2,1)=Z(1)
      PRECON(3,1)=THTA(1)
      CNUT(1)=EPSM(1)
      DO 100 I=1,3
      PRECON(I,2)=PRE50(I,1)+XTC50*(THREE*XTC50*PRE50(I,3)+             &
     &            TWO*PRE50(I,2))
      PRECON(I,3)=PRE50(I,2)+XTC50*THREE*PRE50(I,3)
  100 END DO
      CNUT(2)=OBLQ50(2)+XES50*(THREE*XES50*OBLQ50(4)+TWO*OBLQ50(3))
      CNUT(3)=OBLQ50(3)+THREE*XES50*OBLQ50(4)
! AT THIS STAGE CONSTANTS ARE IN RAD/TROP CENTURY
      PEDPTC=EDPTC0-XEC50*TRATE
      PESPTC=PEDPTC*SECDAY
      PTCPES=ONE/PESPTC
      DO 200 J=2,3
      DO 200 I=1,3
  200 PRECON(I,J)=PRECON(I,J)*PTCPES**(J-1)
! NOW ALL CONSTANTS ARE IN TERMS OF RAD/ET SECONDS SAME FIRST 12 HR
!  PERIOD. NOW, TO GET ELEMENTS AT OTHER TIMES.
      DO 300 I=2,NINEP
      TM=FSCINP(I)-FSCINP(1)
      INDX=(I-1)*66+1
      ETA(INDX)=(PRECON(1,3)*TM+PRECON(1,2))*TM+PRECON(1,1)
      Z(INDX)=(PRECON(2,3)*TM+PRECON(2,2))*TM+PRECON(2,1)
      THTA(INDX)=(PRECON(3,3)*TM+PRECON(3,2))*TM+PRECON(3,1)
      EPSM(INDX)=(CNUT(3)*TM+CNUT(2))*TM+CNUT(1)
  300 END DO
      RETURN
      END
