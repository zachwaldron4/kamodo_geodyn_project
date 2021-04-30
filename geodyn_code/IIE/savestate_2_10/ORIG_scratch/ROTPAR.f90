!$ROTPAR
      SUBROUTINE ROTPAR(PXDDEX,NEQN,                                    &
     &                  IMAPAR,IMAPEM,IMAPSP,IMAPDF,                    &
     &                  IMAPTA,IMAPTC,IMAPTD,IMAPTF,IMAPTX)
!*******************************************************************
!  ROUTINE NAME:   ROTPAR   DATE: 06/03/91      PGMR: A. MARSHALL
!
!   FUNCTION - TO ROTATE "BOXWING" PARTIALS FROM TRUE OF DATE TO
!              TRUE OF REFEERENCE
!
!  I/O PARAMETERS:
!
!   NAME    A/S    I/O   DESCRIPTION OF I/O PARAMETERS IN ARGUMENT LIST
!   -----  ------ -----  -----------------------------------------------
!   PXDDEX   A      I    TOD EXPLICIT PARTIAL OF ACCEL. WRT PARAMETERS
!            A      O    TOR EXPLICIT PARTIAL OF ACCEL. WRT PARAMETERS
!   NEQN     S      I    NUMBER OF ADJUSTED FORCE MODEL PARAMETERS
!   IMAPAR   A      I    MAP FROM UNADJUSTED TO ADJUSTED POINTERS FOR
!                        PLATE AREA
!   IMAPEM   A      I    MAP FROM UNADJUSTED TO ADJUSTED POINTERS FOR
!                        PLATE EMISSIVITY
!   IMAPSP   A      I    MAP FROM UNADJUSTED TO ADJUSTED POINTERS FOR
!                        PLATE SPECUALR REFLECTIVITY
!   IMAPDF   A      I    MAP FROM UNADJUSTED TO ADJUSTED POINTERS FOR
!                        PLATE DIFFUSE REFLECTIVITY
!   IMAPTA   A      I    MAP FROM UNADJUSTED TO ADJUSTED POINTERS FOR
!                        PLATE TEMPA
!   IMAPTC   A      I    MAP FROM UNADJUSTED TO ADJUSTED POINTERS FOR
!                        PLATE TEMPC
!   IMAPTD   A      I    MAP FROM UNADJUSTED TO ADJUSTED POINTERS FOR
!                        PLATE TIMED
!   IMAPTF   A      I    MAP FROM UNADJUSTED TO ADJUSTED POINTERS FOR
!                        PLATE TIMED
!   IMAPTX   A      I    MAP FROM UNADJUSTED TO ADJUSTED POINTERS FOR
!                        PLATE THTX
!   NFACE    S      I    NUMBER OF FLAT PLATES USED TO MODEL SATELLITE
!*******************************************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
!
      DIMENSION IMAPAR(NFACE),IMAPEM(NFACE),IMAPTA(NFACE),IMAPTC(NFACE),&
     &          IMAPTD(NFACE),IMAPTF(NFACE),IMAPTX(NFACE),              &
     &          IMAPSP(NFACE),IMAPDF(NFACE)
      DIMENSION PXDDEX(NEQN,3)
      DIMENSION PART(3)
!
      COMMON/BWINTG/JBFNRM,JTDNRM,JBWARE,JBWSPC,JBWDIF,JBWEMS,JBWTPA,   &
     &              JBWTPC,JBWTMD,JBWTMF,JBWTHX,JARADJ,JSPADJ,JDFADJ,   &
     &              JEMADJ,JTAADJ,JTCADJ,JTDADJ,JTFADJ,JTXADJ,JARUA ,   &
     &              JSPUA ,JDFUA ,JEMUA ,JTAUA ,JTCUA ,JTDUA ,JTFUA ,   &
     &              JTXUA ,NFACE ,NMOVE,NTFACE,JBFNR2,JBFNR3,JTDNR2,    &
     &              JTDNR3
      COMMON/CRMI/RMI(9)
!
!***********************************************************************
!  START OF EXECUTABLE CODE
!***********************************************************************
! INITIALIZE
      ICNTAR = JARADJ-1
      ICNTEM = JEMADJ-1
      ICNTSP = JSPADJ-1
      ICNTDF = JDFADJ-1
      ICNTTA = JTAADJ-1
      ICNTTC = JTCADJ-1
      ICNTTD = JTDADJ-1
      ICNTTF = JTFADJ-1
      ICNTTX = JTXADJ-1
      DO 100 I=1,NFACE
! AREA PARTIAL
      IF(IMAPAR(I).GT.0) THEN
         ICNTAR=ICNTAR+1
         PART(1) = PXDDEX(ICNTAR,1)
         PART(2) = PXDDEX(ICNTAR,2)
         PART(3) = PXDDEX(ICNTAR,3)
!........ROTATE TO TRUE OF REFERENCE
         PXDDEX(ICNTAR,1)=RMI(1)*PART(1)+RMI(2)*PART(2)+RMI(3)*PART(3)
         PXDDEX(ICNTAR,2)=RMI(4)*PART(1)+RMI(5)*PART(2)+RMI(6)*PART(3)
         PXDDEX(ICNTAR,3)=RMI(7)*PART(1)+RMI(8)*PART(2)+RMI(9)*PART(3)
      ENDIF
! EMISSIVITY PARTIAL
      IF(IMAPEM(I).GT.0) THEN
         ICNTEM=ICNTEM+1
         PART(1) = PXDDEX(ICNTEM,1)
         PART(2) = PXDDEX(ICNTEM,2)
         PART(3) = PXDDEX(ICNTEM,3)
!........ROTATE TO TRUE OF REFERENCE
         PXDDEX(ICNTEM,1)=RMI(1)*PART(1)+RMI(2)*PART(2)+RMI(3)*PART(3)
         PXDDEX(ICNTEM,2)=RMI(4)*PART(1)+RMI(5)*PART(2)+RMI(6)*PART(3)
         PXDDEX(ICNTEM,3)=RMI(7)*PART(1)+RMI(8)*PART(2)+RMI(9)*PART(3)
      ENDIF
! SPEC. REFLECTIVITY PARTIAL
      IF(IMAPSP(I).GT.0) THEN
         ICNTSP=ICNTSP+1
         PART(1) = PXDDEX(ICNTSP,1)
         PART(2) = PXDDEX(ICNTSP,2)
         PART(3) = PXDDEX(ICNTSP,3)
!........ROTATE TO TRUE OF REFERENCE
         PXDDEX(ICNTSP,1)=RMI(1)*PART(1)+RMI(2)*PART(2)+RMI(3)*PART(3)
         PXDDEX(ICNTSP,2)=RMI(4)*PART(1)+RMI(5)*PART(2)+RMI(6)*PART(3)
         PXDDEX(ICNTSP,3)=RMI(7)*PART(1)+RMI(8)*PART(2)+RMI(9)*PART(3)
      ENDIF
! DIFF. REFLECTIVITY PARTIAL
      IF(IMAPDF(I).GT.0) THEN
         ICNTDF=ICNTDF+1
         PART(1) = PXDDEX(ICNTDF,1)
         PART(2) = PXDDEX(ICNTDF,2)
         PART(3) = PXDDEX(ICNTDF,3)
!........ROTATE TO TRUE OF REFERENCE
         PXDDEX(ICNTDF,1)=RMI(1)*PART(1)+RMI(2)*PART(2)+RMI(3)*PART(3)
         PXDDEX(ICNTDF,2)=RMI(4)*PART(1)+RMI(5)*PART(2)+RMI(6)*PART(3)
         PXDDEX(ICNTDF,3)=RMI(7)*PART(1)+RMI(8)*PART(2)+RMI(9)*PART(3)
      ENDIF
! TEMPERATURE A PARTIAL
      IF(IMAPTA(I).GT.0) THEN
         ICNTTA=ICNTTA+1
         PART(1) = PXDDEX(ICNTTA,1)
         PART(2) = PXDDEX(ICNTTA,2)
         PART(3) = PXDDEX(ICNTTA,3)
!........ROTATE TO TRUE OF REFERENCE
         PXDDEX(ICNTTA,1)=RMI(1)*PART(1)+RMI(2)*PART(2)+RMI(3)*PART(3)
         PXDDEX(ICNTTA,2)=RMI(4)*PART(1)+RMI(5)*PART(2)+RMI(6)*PART(3)
         PXDDEX(ICNTTA,3)=RMI(7)*PART(1)+RMI(8)*PART(2)+RMI(9)*PART(3)
      ENDIF
! TEMPERATURE C PARTIAL
      IF(IMAPTC(I).GT.0) THEN
         ICNTTC=ICNTTC+1
         PART(1) = PXDDEX(ICNTTC,1)
         PART(2) = PXDDEX(ICNTTC,2)
         PART(3) = PXDDEX(ICNTTC,3)
!........ROTATE TO TRUE OF REFERENCE
         PXDDEX(ICNTTC,1)=RMI(1)*PART(1)+RMI(2)*PART(2)+RMI(3)*PART(3)
         PXDDEX(ICNTTC,2)=RMI(4)*PART(1)+RMI(5)*PART(2)+RMI(6)*PART(3)
         PXDDEX(ICNTTC,3)=RMI(7)*PART(1)+RMI(8)*PART(2)+RMI(9)*PART(3)
      ENDIF
! TIME D PARTIAL
      IF(IMAPTD(I).GT.0) THEN
         ICNTTD=ICNTTD+1
         PART(1) = PXDDEX(ICNTTD,1)
         PART(2) = PXDDEX(ICNTTD,2)
         PART(3) = PXDDEX(ICNTTD,3)
!........ROTATE TO TRUE OF REFERENCE
         PXDDEX(ICNTTD,1)=RMI(1)*PART(1)+RMI(2)*PART(2)+RMI(3)*PART(3)
         PXDDEX(ICNTTD,2)=RMI(4)*PART(1)+RMI(5)*PART(2)+RMI(6)*PART(3)
         PXDDEX(ICNTTD,3)=RMI(7)*PART(1)+RMI(8)*PART(2)+RMI(9)*PART(3)
      ENDIF
! TIME F PARTIAL
      IF(IMAPTF(I).GT.0) THEN
         ICNTTF=ICNTTF+1
         PART(1) = PXDDEX(ICNTTF,1)
         PART(2) = PXDDEX(ICNTTF,2)
         PART(3) = PXDDEX(ICNTTF,3)
!........ROTATE TO TRUE OF REFERENCE
         PXDDEX(ICNTTF,1)=RMI(1)*PART(1)+RMI(2)*PART(2)+RMI(3)*PART(3)
         PXDDEX(ICNTTF,2)=RMI(4)*PART(1)+RMI(5)*PART(2)+RMI(6)*PART(3)
         PXDDEX(ICNTTF,3)=RMI(7)*PART(1)+RMI(8)*PART(2)+RMI(9)*PART(3)
      ENDIF
! THTX PARTIAL
      IF(IMAPTX(I).GT.0) THEN
         ICNTTX=ICNTTX+1
         PART(1) = PXDDEX(ICNTTX,1)
         PART(2) = PXDDEX(ICNTTX,2)
         PART(3) = PXDDEX(ICNTTX,3)
!........ROTATE TO TRUE OF REFERENCE
         PXDDEX(ICNTTX,1)=RMI(1)*PART(1)+RMI(2)*PART(2)+RMI(3)*PART(3)
         PXDDEX(ICNTTX,2)=RMI(4)*PART(1)+RMI(5)*PART(2)+RMI(6)*PART(3)
         PXDDEX(ICNTTX,3)=RMI(7)*PART(1)+RMI(8)*PART(2)+RMI(9)*PART(3)
      ENDIF
  100 END DO
      RETURN
      END