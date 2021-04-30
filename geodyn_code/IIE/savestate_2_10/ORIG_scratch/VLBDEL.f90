!$VLBDEL
      SUBROUTINE VLBDEL(EHAT,RJ2,RDJ2,B,SUNBP,GMS,GME,NM,EARBP,EARBV,   &
     & SCRDP,REHAT,RE,DEL,XT1,XT2,VT1,VT2)
!********1*********2*********3*********4*********5*********6*********7**
! VLBDEL          11.05.90          0000.0  WRITTEN BY LUCIA TSAOUSSI
!
! FUNCTION:        THE COMPUTATION OF VLBI DELAY OBSERVABLES
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS IN ALPHABETICAL ORDER
!   ------  ---  ---   ------------------------------------------------
!
!   B        O    A    THE BASELINE FROM SITE 1 TO SITE 2
!   DEL      O    A    THE THEORETICAL DELAY IN SECONDS AT TIMES NM
!                      ACCORDING TO THE SHAPIRO ALGORITHM
!   EARBP    I    A    THE J2000.0 BARYCENTRIC EARTH POSITION VECTOR
!   EARBV    I    A    THE J2000.0 BARYCENTRIC EARTH VELOCITY VECTOR
!   EHAT     I    A    THE UNIT VECTOR IN THE DIRECTION OF THE SOURCE
!                      AS VIEWED FROM THE SOLAR SYSTEM BARYCENTER
!                      PASSED THROUGH COMMON BLOCK CBLOKV
!   GMS      I    S    HELIOCENTRIC GRAVITATIONAL CONSTANT
!   GME      I    S    GEOCENTRIC GRAVITATIONAL CONSTANT
!   NM       I    S    NUMBER OF MEASUREMENTS IN THE PROCESSED BLOCK
!   RDJ2     I    A    THE SITE 1 & 2 GEOCENTRIC VELOCITY VECTORS IN
!                      J2000.0 (IE TIME DERIVATIVE OF RJ2 WITH RESPECT
!                      TO ATOMIC TIME ) AT TIME T1
!   RE       O    A    THE MAGNITUDE OF THE VECTOR REHAT
!   REHAT    O    A    UNIT VECTOR IN THE DIRECTION FROM THE CENTER OF
!                      THE SUN TO THE CENTER OF THE EARTH IN TDB
!                      CORRESPONDING TO ATOMIC TIME T1.
!   RJ2      I    A    THE SITE 1 & 2 GEOCENTRIC POSITION VECTORS IN
!                      J2000.0 AT TIME T1 (: ATOMIC TIME AT SITE 1)
!   SCRDP    S    A    SCRATCH ARRAY FOR DOT PRODUCT COMPUTATIONS
!   SPDLIT   I    S    THE SPEED OF LIGHT IN M/S
!   SUNBP    I    A    THE J2000.0 BARYCENTRIC SUN POSITION VECTOR
!
! COMMENTS:
! THE SITE ARRAYS RJ2,RDJ2 CONTAIN SITE 1 COORD. RJ2(NM,1-3) AND
! SITE 2 COORD. RJ2(NM,4-6). SIMILARLY FOR RDJ2.
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      PARAMETER ( GAMMA_L=1.D0,NI=3,ONE=1.D0,TWO=2.D0 )
      INCLUDE 'COMMON_DECL.inc'
      COMMON/CLIGHT/VLIGHT,ERRLIM,XCLITE
      COMMON/CNIGLO/MINTIM,MSATG3,MEQNG ,MEQNG3,MSATG ,MSATOB,MSATA ,   &
     &              MSATA3,MSETA ,MINTVL,MSORDR,MSORDV,NMXORD,          &
     &       MCIPV ,MXBACK,MXI   ,MPXPF ,MAXAB ,MSETDG,MXSATD,          &
     &       MXDEGS,MXDRP ,MXDRPA,MXSRP ,MXSRPA,MXGAP ,MSATDR,          &
     &       MSATSR,MSATGA,MXDRPD,MXSRPD,MXGAPD,MXBCKP,MXTPMS,          &
     &       NSTAIN,NXCNIG
!
      DIMENSION EHAT(3),RJ2(NM,6),RDJ2(NM,6),SCRDP(6*NM),SUNBP(NM,3),   &
     &    EARBP(NM,3),EARBV(NM,3),B(NM,3),RE(NM),REHAT(NM,3),DEL(NM)
      DIMENSION XT1(MINTIM,3),XT2(MINTIM,3),VT1(MINTIM,3),VT2(MINTIM,3)
!
!**********************************************************************
! START OF EXECUTABLE CODE ********************************************
!**********************************************************************
!
!     WRITE(6,*) '  VLBDEL  :SPEED OF LIGHT : ',VLIGHT
!     WRITE(6,*) ' VLBDEL : XT1 ', (XT1(1,I),I=1,3)
!     WRITE(6,*) ' VLBDEL : XT2 ', (XT2(1,I),I=1,3)
!     WRITE(6,*) ' VLBDEL : VT1 ', (VT1(1,I),I=1,3)
!     WRITE(6,*) ' VLBDEL : VT2 ', (VT2(1,I),I=1,3)
      DO 10 J=1,NM
      DO 10 I=1,3
      RJ2(J,I)=XT1(J,I)
      RJ2(J,I+3)=XT2(J,I)
      B(J,I)=RJ2(J,I+3)-RJ2(J,I)
      RDJ2(J,I)=VT1(J,I)
      RDJ2(J,I+3)=VT2(J,I)
   10 CONTINUE
!     WRITE(6,*) ' VLBDEL : BASELINE ',(B(1,I),I=1,3)
!  COMPUTATION OF DOT PRODUCT (E . B)
      DO 20 I=1,NM
      SCRDP(I)=DOTPDT(EHAT,B(I,1))
   20 END DO
!  COMPUTE 1ST TERM OF THE ALGORITHM
      DO 30 I=1,NM
      DEL(I)=-SCRDP(I)/VLIGHT
!     WRITE(6,*) ' VLBDEL : 1ST TERM ',DEL(I)
   30 END DO
!  COMPUTE DOT PRODUCT (B . V G)
      CALL DOTPRD(B,EARBV,SCRDP(NM+1),NM,NM,NM,NI)
!   COMPUTE DOT PRODUCT (E . V G)
      DO 40 I=1,NM
      SCRDP(2*NM+I)=DOTPDT(EHAT,EARBV(I,1))
   40 END DO
!   COMPUTE 2ND TERM OF THE ALGORITHM
      DO 50 I=1,NM
      DEL(I)=DEL(I)-(SCRDP(NM+I)-SCRDP(I)*SCRDP(2*NM+I))/VLIGHT**2
      DEBUG=-(SCRDP(NM+I)-SCRDP(I)*SCRDP(2*NM+I))/VLIGHT**2
!     WRITE(6,*) ' VLBDEL : 2ND TERM ',DEBUG
!     WRITE(6,*) ' VLBDEL :ADD 2ND TERM ',DEL(I)
   50 END DO
!     WRITE(6,*) 'VLBDEL :  EHAT  ',EHAT
!     WRITE(6,*) ' VLBDEL : RJ2  ', (RJ2(1,J),J=1,6)
!     WRITE(6,*) ' VLBDEL : RDJ2  ', (RDJ2(1,J),J=1,6)
!
!   COMPUTE DOT PRODUCT (E . R DOT 2)
      DO 60 I=1,NM
      SCRDP(3*NM+I)=DOTPDT(EHAT,RDJ2(I,4))
   60 END DO
!   COMPUTE 3RD TERM OF THE ALGORITHM
      DO 70 I=1,NM
      DEL(I)=DEL(I)+SCRDP(I)*SCRDP(3*NM+I)/VLIGHT**2
      DEBUG=+SCRDP(I)*SCRDP(3*NM+I)/VLIGHT**2
!     WRITE(6,*) ' VLBDEL : 3RD TERM ',DEBUG
!     WRITE(6,*) ' VLBDEL :ADD 3RD TERM ',DEL(I)
   70 END DO
!   COMPUTE DOT PRODUCT (V G . V G)
      CALL DOTPRD(EARBV,EARBV,SCRDP(4*NM+1),NM,NM,NM,NI)
!   COMPUTE 4TH TERM OF THE ALGORITHM
      DO 80 I=1,NM
      DEL(I)=DEL(I)+(SCRDP(NM+I)*SCRDP(2*NM+I)/TWO                      &
     &      +SCRDP(I)*SCRDP(4*NM+I)/TWO                                 &
     &      -SCRDP(I)*(SCRDP(2*NM+I)**2))/VLIGHT**3
      DEBUG=+(SCRDP(NM+I)*SCRDP(2*NM+I)/TWO                             &
     &      +SCRDP(I)*SCRDP(4*NM+I)/TWO                                 &
     &      -SCRDP(I)*(SCRDP(2*NM+I)**2))/VLIGHT**3
!     WRITE(6,*) ' VLBDEL : 4TH TERM ',DEBUG
!     WRITE(6,*) ' VLBDEL :ADD 4TH TERM ',DEL(I)
   80 END DO
      DO 90 I=1,3
      DO 90 J=1,NM
      REHAT(J,I)=EARBP(J,I)-SUNBP(J,I)
   90 CONTINUE
      CALL DOTPRD(REHAT,REHAT,SCRDP(5*NM+1),NM,NM,NM,NI)
      DO 100 I=1,3
      DO 100 J=1,NM
      RE(J)=SQRT(SCRDP(5*NM+J))
      REHAT(J,I)=REHAT(J,I)/RE(J)
  100 CONTINUE
      CALL DOTPRD(EHAT,RDJ2(1,4),SCRDP(3*NM+1),NM,NM,NM,NI)
!   COMPUTE 5TH TERM OF THE ALGORITHM
      DO 110 I=1,NM
      DEL(I)=DEL(I)+TWO*GMS*SCRDP(I)/(VLIGHT**3*RE(I))+                 &
     &       SCRDP(NM+I)*SCRDP(3*NM+I)/VLIGHT**3
      DEBUG=+TWO*GMS*SCRDP(I)/(VLIGHT**3*RE(I))+                        &
     &       SCRDP(NM+I)*SCRDP(3*NM+I)/VLIGHT**3
!     WRITE(6,*) ' VLBDEL : 5TH TERM ',DEBUG
!     WRITE(6,*) ' VLBDEL :ADD 5TH TERM ',DEL(I)
  110 END DO
      FCT1=(ONE+GAMMA_L)*GMS/VLIGHT**3
      DO 120 I=1,NM
!   COMPUTE DOT PRODUCT  (RE . E)
      SCRDP(I)=DOTPDT(REHAT(I,1),EHAT)
!   COMPUTE DOT PRODUCT  (R1 . E)
      SCRDP(NM+I)=DOTPDT(RJ2(I,1),EHAT)
!   COMPUTE DOT PRODUCT  (R2 . E)
      SCRDP(2*NM+I)=DOTPDT(RJ2(I,4),EHAT)
  120 END DO
!   COMPUTE DOT PRODUCT  (R1 . RE)
      CALL DOTPRD(RJ2,REHAT,SCRDP(3*NM+1),NM,NM,NM,NI)
!   COMPUTE DOT PRODUCT  (R2 . RE)
      CALL DOTPRD(RJ2(1,4),REHAT,SCRDP(4*NM+1),NM,NM,NM,NI)
!   COMPUTE 6,1 TH TERM OF THE ALGORITHM
      DO 130 I=1,NM
      DEL(I)=DEL(I)+FCT1*LOG((RE(I)*(ONE+SCRDP(I))+SCRDP(3*NM+I)+       &
     & SCRDP(NM+I))/(RE(I)*(ONE+SCRDP(I))+SCRDP(4*NM+I)+SCRDP(2*NM+I)))
      DEBUG=+FCT1*LOG((RE(I)*(ONE+SCRDP(I))+SCRDP(3*NM+I)+              &
     & SCRDP(NM+I))/(RE(I)*(ONE+SCRDP(I))+SCRDP(4*NM+I)+SCRDP(2*NM+I)))
!     WRITE(6,*) ' VLBDEL :    6,1TH TERM ',DEBUG
!     WRITE(6,*) ' VLBDEL :ADD 6,1TH TERM ',DEL(I)
  130 END DO
      FCT2=(ONE+GAMMA_L)*GME/VLIGHT**3
      CALL DOTPRD(RJ2,RJ2,SCRDP,NM,NM,NM,NI)
      CALL DOTPRD(RJ2(1,4),RJ2(1,4),SCRDP(3*NM+1),NM,NM,NM,NI)
      DO 140 I=1,NM
      SCRDP(4*NM+I)=SQRT(SCRDP(I))
      SCRDP(5*NM+I)=SQRT(SCRDP(3*NM+I))
  140 END DO
!   COMPUTE 6,2 TH TERM OF THE ALGORITHM
      DO 150 I=1,NM
      DEL(I)=DEL(I)+FCT2*LOG((SCRDP(4*NM+I)*(ONE+SCRDP(NM+I)/           &
     &        SCRDP(4*NM+I)))/                                          &
     &        (SCRDP(5*NM+I)*(ONE+SCRDP(2*NM+I)/SCRDP(5*NM+I))))
      DEBUG=+FCT2*LOG((SCRDP(4*NM+I)*(ONE+SCRDP(NM+I)/                  &
     &        SCRDP(4*NM+I)))/                                          &
     &        (SCRDP(5*NM+I)*(ONE+SCRDP(2*NM+I)/SCRDP(5*NM+I))))
!     WRITE(6,*) ' VLBDEL : 6,2TH TERM ',DEBUG
!     WRITE(6,*) ' VLBDEL :ADD 6,2TH TERM ',DEL(I)
  150 END DO
!
!  ** SCALE THE OBSERVATIONS  ******
!     DEL(1)=DEL(1)*1.D6
!     WRITE(6,*) ' DELAY OBSERVABLE COMPUTED : ',DEL(1)
      RETURN
      END