!$LITPRX
      SUBROUTINE LITPRX(MJDSTB,FSECTB,MJDSST,FSECST,AA,II)
!********1*********2*********3*********4*********5*********6*********7**
! LITPRX           00/00/00            8709.0    PGMR - D. ROWLANDS
!
!  FUNCTION:  GET THE APPROXIMATE SATELLITE TIME OF THE
!             MEASUREMENT FOR THE CASE WHEN THE SATELLITE
!             IS BEING INTEGRATED AROUND A DIFFERENT BODY THAN
!             THE TRACKING STATION IS LOCATED ON. THIS WAY THE
!             INTEGRATOR WILL NOT BE ADVANCED TOO FAR BECAUSE
!             TRACKING BODY TIME HAS BEEN USED.
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   MJDSTB   I    S    INTEGER NUMBER OF SECONDS SINCE GEODYN REF. TIME
!                      AT TRACKING BODY RECIEVE TIME OF MEASUREMENT
!   FSECTB   I    S    FRACTIONAL REMAINING SECONDS FROM MJDSTB
!   MJDSST   O    S    INTEGER NUMBER OF SECONDS SINCE GEODYN REF.TIME
!                      AT CENTER OF BODY OF INTEGRATION
!   FSECST   O    S    FRACTIONAL REMAINING SECONDS FROM MJDSST
!   AA      I/O   A    REAL DYNAMIC ARRAY
!   II      I/O   A    INTEGER DYNAMIC ARRAY
!
! COMMENTS:
!
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      COMMON/ASTLGT/CBODY1(7)
      COMMON/CBARYC/CBODY(6),TBODY(6),SUNRF(6)
      COMMON/CBDSTA/BDSTAT(7,999),XBDSTA
      COMMON/CLIGHT/VLIGHT,ERRLIM,XCLITE
      COMMON/CORA07/KELEVT,KSRFEL,KTINT,KFSCSD,KXTIM,KFSDM,             &
     & KSGM1,KSGM2,KNOISE,KEPHMS,NXCA07
      COMMON/CORI07/KSMSA1,KSMSA2,KSMSA3,KSMST1,KSMST2,KSMST3,KSMTYP,   &
     &              KSMT1,KSMT2,KMSDM,KIOUT,KISUPE,NXCI07
      COMMON/IBODPT/IBDCF(999),IBDSF(999),IBDGM(999),IBDAE(999),    &
     &              IBDPF(999),                                     &
     &              ICBDCF,ICBDSF,ICBDGM,ICBDAE,ICBDPF,             &
     &              ITBDCF,ITBDSF,ITBDGM,ITBDAE,ITBDPF,NXBDPT
      COMMON/IEPHM2/ISUPL,ICBODY,ISEQB(2),MAXDEG,ITOTSE,IREPL(988), &
     &              NXEPH2
      COMMON/LDUAL/LASTSN,LSTSNX,LSTSNY
      COMMON/LEPHM2/LXEPHM
      COMMON/NLIGHT/KNTLIM,NXNLIT
      COMMON/PLNETI/IPLNET(999),IPLNIN(999),MPLNGD(999),MPLNGO(999),   &
     &              IPLNZ(999),NXPLNI
      COMMON/XLITSD/DELULT,DDLULT,UNVLTU(3),DELDLT,DDLDLT,UNVLTD(3),    &
     &              GRELLT,TOLLTX,GRLFCT,FCTJUP,FCTSAT
      DIMENSION AA(1),II(1),FBODY(6)
      DATA ONE/1.D0/,ZERO/0.D0/,TOL1/.5D-10/,TOL2/.00001D0/
      DATA LGNREL/.TRUE./
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
!
!  NOTES ON THE SETTING OF LIGHT TIME TOLS:
!
!    WHEN THE INITIAL GUESS OF THE LIGHT TIME IS CLOSE TO
!    THE FINAL RESULT (THIS WILL BE TRUE WHEN THE SOLVED FOR DELTAT
!    IS SMALL), THE PSEUDEO RANGE FUNCTION (PSEUDEO BECAUSE ONE BODY
!    IS HELD FIXED FOR LIGHT TIME CALCULATIONS) IS LINEAR. WHEN THE
!    PSEUDO RANGE IS LINEAR, THE SERIES APPROACH USED BELOW AND IN
!    SUBROUTINES LITEUP & LITEDN CONVERGES WITHOUT ITERATION. THE SOLVED
!    FOR DELTAT IS CORRECT AND FURTHER ITERATIONS ARE NOT NECESSARY
!    EXCEPT TO UPDATE THE POSITION OF THE BODY HELD FIXED AND THE RANGE.
!    THE POSITION CAN BE UPDATED LINEARLY. A TOLS MUST BE CHOSEN TO
!    INSURE THE PROBLEM IS LINEAR BELOW THE CM LEVEL. LET RDDOTM BE
!    THE MAX BARYCENTRIC ACCEL THAT ANY BODY IN THE PROBLEM EXPERIENCES.
!    THEN THE NONLINEARITY EFFECT IS BOUNDED BY .5*RDDOTM*(DELTAT)**2.
!    FOR THE MARS-EARTH PROBLEM RDDOTM<<100. A TOLS OF .001 IS SURELY
!    SMALL ENOUGH. A SMALLER TOLS IS USED IN SUBROUTINE LITPRX BECAUSE
!    UPDATING DOES NOT OCCUR EXCEPT UPON ITERATION.
!
!
!
      TOLLTX=TOL1
      GRLGAM=ONE
      KOUNT=0
      MJDSST=MJDSTB
      FSECST=FSECTB
      DIFTMP=ZERO
 1000 CONTINUE
      KOUNT=KOUNT+1
      CALL BUFXTR(MJDSST,FSECST,MJDSST,FSECST,1,MJDR,FSECR,LRECAL,AA)
!
      IF(LXEPHM) THEN
      DO IJ=1,ICBODY
      CALL BUFSUP(AA,MJDSST,FSECST,MJDSST,FSECST,II(KISUPE),            &
     &AA(KEPHMS),IJ,1)
      ENDDO
      ENDIF
!
      CALL PLANPO(MJDSST,FSECST,.TRUE.,.TRUE.,AA,II)
      IF(LASTSN.AND.CBODY1(7).GT.0.99D0) THEN
        DO J=1,6
          CBODY(J)=CBODY1(J)
        ENDDO
      ENDIF
      IPTTB=IPLNIN(ITBDGM)
      IF(KOUNT.GT.1) GO TO 100
      FBODY(1)=TBODY(1)
      FBODY(2)=TBODY(2)
      FBODY(3)=TBODY(3)
      FBODY(4)=TBODY(4)
      FBODY(5)=TBODY(5)
      FBODY(6)=TBODY(6)
      GMS=BDSTAT(7,8)
      GMJUP=BDSTAT(7,3)
      GMSAT=BDSTAT(7,4)
      SUNV1=SUNRF(1)-TBODY(1)
      SUNV2=SUNRF(2)-TBODY(2)
      SUNV3=SUNRF(3)-TBODY(3)
      RSUNT=SQRT(SUNV1*SUNV1+SUNV2*SUNV2+SUNV3*SUNV3)
  100 CONTINUE
      X=CBODY(1)-FBODY(1)
      Y=CBODY(2)-FBODY(2)
      Z=CBODY(3)-FBODY(3)
      R0=X*X+Y*Y+Z*Z
      R0=SQRT(R0)
      R0DOT=X*CBODY(4)+Y*CBODY(5)+Z*CBODY(6)
      R0DOT=R0DOT/R0
      GRELLT=ZERO
      VLT3=VLIGHT*VLIGHT*VLIGHT
      GRLFCT=(ONE+GRLGAM)*GMS/VLT3
      FCTJUP=(ONE+GRLGAM)*GMJUP/VLT3
      FCTSAT=(ONE+GRLGAM)*GMSAT/VLT3
      IF(ICBDGM.EQ.11) GOTO 200
      IF(.NOT.LGNREL) GO TO 200
      SUNV1=SUNRF(1)-CBODY(1)
      SUNV2=SUNRF(2)-CBODY(2)
      SUNV3=SUNRF(3)-CBODY(3)
      RSUNI=SQRT(SUNV1*SUNV1+SUNV2*SUNV2+SUNV3*SUNV3)
      GRSUM=RSUNI+RSUNT
      GRARG=(GRSUM+R0)/(GRSUM-R0)
      GRELLT=GRLFCT*LOG(GRARG)
  200 CONTINUE
      TERM=-R0DOT/VLIGHT
      TERM2=TERM*TERM
      TERM3=TERM*TERM2
      TERM4=TERM2*TERM2
      FACT1=((TERM4+TERM3)+TERM2)+TERM
      FACT2=R0+VLIGHT*(GRELLT-DIFTMP)
      RANGE=R0+FACT1*FACT2
      DIFTIM=RANGE/VLIGHT+GRELLT
      DELTA=DIFTIM-DIFTMP
      CONVRG=ABS(DELTA*R0DOT/VLIGHT)
      DIFTMP=DIFTIM
      LAST=(CONVRG.LT.TOLLTX).OR.(KOUNT.GT.KNTLIM)
      IIFTIM=DIFTIM
      DIFTIM=DIFTIM-DBLE(IIFTIM)
      IIFTIM=IIFTIM+1
      DIFTIM=DIFTIM-ONE
      MJDSST=MJDSTB-IIFTIM
      FSECST=FSECTB-DIFTIM
      IF(.NOT.LAST) GO TO 1000
      DELULT=DIFTMP
      XD=CBODY(4)-FBODY(4)
      YD=CBODY(5)-FBODY(5)
      ZD=CBODY(6)-FBODY(6)
      RDOT=X*XD+Y*YD+Z*ZD
      RDOT=RDOT/R0
      DDLULT=RDOT/VLIGHT
      UNVLTU(1)=-X/R0
      UNVLTU(2)=-Y/R0
      UNVLTU(3)=-Z/R0
!
      MJDGT=MJDSST
      FSECGT=FSECST-DIFTMP
      KOUNT=0
      FBODY(1)=CBODY(1)
      FBODY(2)=CBODY(2)
      FBODY(3)=CBODY(3)
      FBODY(4)=CBODY(4)
      FBODY(5)=CBODY(5)
      FBODY(6)=CBODY(6)
 2000 CONTINUE
      KOUNT=KOUNT+1
      CALL BUFXTR(MJDGT,FSECGT,MJDGT,FSECGT,1,MJDR,FSECR,LRECAL,AA)
!
      IF(LXEPHM) THEN
      DO IJ=1,ICBODY
      CALL BUFSUP(AA,MJDGT,FSECGT,MJDGT,FSECGT,II(KISUPE),              &
     &AA(KEPHMS),IJ,1)
      ENDDO
      ENDIF
!
      CALL PLANPO(MJDGT,FSECGT,.TRUE.,.TRUE.,AA,II)
      IF(LASTSN.AND.CBODY1(7).GT.1.D0) THEN
        DO J=1,6
          CBODY(J)=CBODY1(J)
        ENDDO
      ENDIF
      X=TBODY(1)-FBODY(1)
      Y=TBODY(2)-FBODY(2)
      Z=TBODY(3)-FBODY(3)
      R0=X*X+Y*Y+Z*Z
      R0=SQRT(R0)
      R0DOT=X*TBODY(4)+Y*TBODY(5)+Z*TBODY(6)
      R0DOT=R0DOT/R0
      TERM=-R0DOT/VLIGHT
      TERM2=TERM*TERM
      TERM3=TERM*TERM2
      TERM4=TERM2*TERM2
      FACT1=((TERM4+TERM3)+TERM2)+TERM
      FACT2=R0+VLIGHT*(GRELLT-DIFTMP)
      RANGE=R0+FACT1*FACT2
      DIFTIM=RANGE/VLIGHT+GRELLT
      DELTA=DIFTIM-DIFTMP
      CONVRG=ABS(DELTA*R0DOT/VLIGHT)
      DIFTMP=DIFTIM
      LAST=(CONVRG.LT.TOLLTX).OR.(KOUNT.GT.KNTLIM)
      FSECGT=FSECST-DIFTIM
      IF(.NOT.LAST) GO TO 2000
      DELDLT=DIFTMP
      XD=TBODY(4)-FBODY(4)
      YD=TBODY(5)-FBODY(5)
      ZD=TBODY(6)-FBODY(6)
      RDOT=X*XD+Y*YD+Z*ZD
      RDOT=RDOT/R0
      DDLDLT=RDOT/VLIGHT
      UNVLTD(1)=-X/R0
      UNVLTD(2)=-Y/R0
      UNVLTD(3)=-Z/R0
      TOLLTX=TOL2
!
      CBODY1(7)=-99.D0
!
!     WRITE(6,12345)
!2345 FORMAT(' LITPRX CONTENTS OF COMMON XLITSD ')
!     WRITE(6,12346)
!2346 FORMAT(' DELULT,DDLULT,UNVLTU(3) ')
!     WRITE(6,12347) DELULT,DDLULT,UNVLTU
!2347 FORMAT(' ',5E25.16)
!     WRITE(6,12348)
!2348 FORMAT(' DELDLT,DDLDLT,UNVLTD(3) ')
!     WRITE(6,12347) DELDLT,DDLDLT,UNVLTD
!     WRITE(6,12349)
!2349 FORMAT(' GRELLT,TOLLTX,GRLFCT ')
!     WRITE(6,12347) GRELLT,TOLLTX,GRLFCT
      RETURN
      END
