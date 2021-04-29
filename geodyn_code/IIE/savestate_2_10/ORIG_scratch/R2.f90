      SUBROUTINE R2(ANG,ROT)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      DIMENSION ROT(3,3)
!
      COSA=COS(ANG)
      SINA=SIN(ANG)
!
      ROT(1,1)=COSA
      ROT(1,2)=0.D0
      ROT(1,3)=-SINA
!
      ROT(2,1)=0.D0
      ROT(2,2)=1.D0
      ROT(2,3)=0.D0
!
      ROT(3,1)=SINA
      ROT(3,2)=0.D0
      ROT(3,3)=COSA
!
      RETURN
      END
