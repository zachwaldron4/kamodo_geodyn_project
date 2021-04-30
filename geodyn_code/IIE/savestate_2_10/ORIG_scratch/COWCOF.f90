!$COWCOF
      SUBROUTINE COWCOF(POS,VEL,IORDER,IPC)
!********1*********2*********3*********4*********5*********6*********7**
! COWCOF           00/00/00            0000.0    PGMR - ?
!
! FUNCTION:  TO ASSIGN INTEGRATOR COEFFICIENT VALUES -
!            ORDERS 5 - 15
!            CALLING SEQUENCE  CALL COWCOF(POS,VEL,IORDER,IPC)
!
! I/O PARAMETERS:
!
!   NAME    I/O  A/S   DESCRIPTION OF PARAMETERS
!   ------  ---  ---   ------------------------------------------------
!   POS      O    A    VECTOR OF POSITION COEFFICIENTS
!   (1)
!   VEL      O    A    VECTOR OF VELOCITY COEFFICIENTS
!   (1)
!   IORDER   I    S    ORDER
!   IPC      I    S    PREDICTOR/CORRECTOR SELECTION SWITCH
!
! COMMENTS:  SUBROUTINES USED  NONE
!            COMMON BLOCKS     NONE
!            INPUT FILES       NONE
!            OUTPUT FILES      PRINTER - 6
!
! COMMENTS:
!
!********1*********2*********3*********4*********5*********6*********7**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z),LOGICAL(L)
      SAVE
      DIMENSION POS(1),VEL(1)
      DIMENSION BETA(99),BETAS(99),ALPHA(99),ALPHAS(99)
      DIMENSION B5(4),B6(5),B7(6),B8(7),B9(8),B10(9),B11(10),B12(11),   &
     &   B13(12),B14(13),B15(14),BS5(4),BS6(5),BS7(6),BS8(7),BS9(8),    &
     &   BS10(9),BS11(10),BS12(11),BS13(12),BS14(13),BS15(14)
      DIMENSION A5(4),A6(5),A7(6),A8(7),A9(8),A10(9),A11(10),A12(11),   &
     &   A13(12),A14(13),A15(14),AS5(4),AS6(5),AS7(6),AS8(7),AS9(8),    &
     &   AS10(9),AS11(10),AS12(11),AS13(12),AS14(13),AS15(14)
      COMMON/CVIEW /IOUT6 ,ILINE6,IPAGE6,MLINE6,                        &
     &              IOUT8 ,ILINE8,IPAGE8,MLINE8,                        &
     &              IOUT9 ,ILINE9,IPAGE9,MLINE9,                        &
     &              IOUT10,ILIN10,IPAG10,MLIN10,                        &
     &              IOUT15,ILIN15,IPAG15,MLIN15,                        &
     &              IOUT16,ILIN16,IPAG16,MLIN16,                        &
     &              IOUT7 ,NXCVUE
      EQUIVALENCE (B5(1),BETA(1)),(B6(1),BETA(5)),(B7(1),BETA(10)),     &
     &   (B8(1),BETA(16)),(B9(1),BETA(23)),(B10(1),BETA(31)),           &
     &   (B11(1),BETA(40)),(B12(1),BETA(50)),(B13(1),BETA(61)),         &
     &   (B14(1),BETA(73)),(B15(1),BETA(86))
      EQUIVALENCE (BS5(1),BETAS(1)),(BS6(1),BETAS(5)),                  &
     &   (BS7(1),BETAS(10)),(BS8(1),BETAS(16)),(BS9(1),BETAS(23)),      &
     &   (BS10(1),BETAS(31)),(BS11(1),BETAS(40)),(BS12(1),BETAS(50)),   &
     &   (BS13(1),BETAS(61)),(BS14(1),BETAS(73)),(BS15(1),BETAS(86))
      EQUIVALENCE (A5(1),ALPHA(1)),(A6(1),ALPHA(5)),(A7(1),ALPHA(10)),  &
     &   (A8(1),ALPHA(16)),(A9(1),ALPHA(23)),(A10(1),ALPHA(31)),        &
     &   (A11(1),ALPHA(40)),(A12(1),ALPHA(50)),(A13(1),ALPHA(61)),      &
     &   (A14(1),ALPHA(73)),(A15(1),ALPHA(86))
      EQUIVALENCE (AS5(1),ALPHAS(1)),(AS6(1),ALPHAS(5)),                &
     &   (AS7(1),ALPHAS(10)),(AS8(1),ALPHAS(16)),(AS9(1),ALPHAS(23)),   &
     &   (AS10(1),ALPHAS(31)),(AS11(1),ALPHAS(40)),(AS12(1),ALPHAS(50)),&
     &   (AS13(1),ALPHAS(61)),(AS14(1),ALPHAS(73)),(AS15(1),ALPHAS(86))
!        K = (IORDER-5) * (IORDER+2) / 2
      DATA  B5/+.164027777777777777D+01, -.221249999999999999D+01,      &
     &          +.142083333333333333D+01,-.348611111111111110D+00/
      DATA  B6/+.197013888888888888D+01, -.353194444444444444D+01,      &
     &          +.339999999999999999D+01,-.166805555555555555D+01,      &
     &          +.329861111111111111D+00/
      DATA  B7/+.228573082010582010D+01, -.510990410052910052D+01,      &
     &          +.655591931216931216D+01,-.482397486772486772D+01,      &
     &          +.190782076719576719D+01,-.315591931216931216D+00/
      DATA  B8/+.258995535714285714D+01, -.693525132275132275D+01,      &
     &          +.111192873677248677D+02,-.109084656084656084D+02,      &
     &          +.647118882275132274D+01,-.214093915343915343D+01,      &
     &          +.304224537037037036D+00/
      DATA  B9/+.288482335758377424D+01, -.899932732583774250D+01,      &
     &          +.173115153769841269D+02,-.212288456238977072D+02,      &
     &          +.167915688381834214D+02,-.833316716269841269D+01,      &
     &          +.236830054012345678D+01,-.294868000440917107D+00/
      DATA B10/+.317179880401234567D+01, -.112951308972663139D+02,      &
     &          +.253468278769841269D+02,-.372994706238977071D+02,      &
     &          +.368798500881834214D+02,-.244037921626984126D+02,      &
     &          +.104036130401234567D+02,-.259067157186948853D+01,      &
     &          +.286975446428571428D+00/
      DATA B11/+.345198840045628239D+01, -.138168372652617444D+02,      &
     &          +.354336533489658489D+02,-.608353967251883918D+02,      &
     &          +.721837392401194484D+02,-.597076813146344396D+02,      &
     &          +.339395391414141414D+02,-.126774970438512105D+02,      &
     &          +.280868181442400192D+01,-.280189596443936721D+00/
      DATA B12/+.372625394048788145D+01, -.165594926655777349D+02,      &
     &          +.477756026503878066D+02,-.937472615289802789D+02,      &
     &          +.129779502646755250D+03,-.128822597402597402D+03,      &
     &          +.915353025480499438D+02,-.455893618476430976D+02,      &
     &          +.151506311158459595D+02,-.302284499675992731D+01,      &
     &          +.274265540031599059D+00/
      DATA B13/+.399528278726153023D+01, -.195188099800878715D+02,      &
     &          +.625721892229384891D+02,-.138137021246632326D+03,      &
     &          +.218559022082059346D+03,-.253113924612023136D+03,      &
     &          +.215826629757475677D+03,-.134368881282947193D+03,      &
     &          +.595403908334980073D+02,-.178194315693106098D+02,      &
     &          +.323358285454173557D+01,-.269028846773648774D+00/
      DATA B14/+.425963413562813673D+01, -.226910261604871496D+02,      &
     &          +.800193782151345187D+02,-.196294317887285758D+03,      &
     &          +.349412939523529568D+03,-.462480192518375492D+03,      &
     &          +.460087275648220092D+03,-.343735149189299548D+03,      &
     &          +.190394308274968229D+03,-.759767282099640419D+02,      &
     &          +.206807718467377651D+02,-.344124502717292688D+01,      &
     &          +.264351348366606509D+00/
      DATA B15/+.451977053175573777D+01, -.260727993101459631D+02,      &
     &          +.100310017113087399D+03,-.270693327179779655D+03,      &
     &          +.535410462754764309D+03,-.797275734334598026D+03,      &
     &          +.906481331403183471D+03,-.790129204944262927D+03,      &
     &          +.525189850091190764D+03,-.261974251441198783D+03,      &
     &          +.950797811392316617D+02,-.237318839251258077D+02,      &
     &          +.364612449802541998D+01,-.260136396127601036D+00/
      DATA BS5/+.348611111111111110D+00, +.245833333333333333D+00,      &
     &          -.120833333333333333D+00,+.263888888888888888D-01/
      DATA BS6/+.329861111111111111D+00, +.320833333333333333D+00,      &
     &          -.233333333333333333D+00,+.101388888888888888D+00,      &
     &          -.187499999999999999D-01/
      DATA BS7/+.315591931216931216D+00, +.392179232804232804D+00,      &
     &          -.376025132275132274D+00,+.244080687830687830D+00,      &
     &          -.900958994708994707D-01,+.142691798941798941D-01/
      DATA BS8/+.304224537037037036D+00, +.460383597883597883D+00,      &
     &          -.546536044973544973D+00,+.471428571428571428D+00,      &
     &          -.260606812169312169D+00,+.824735449735449734D-01,      &
     &          -.113673941798941798D-01/
      DATA BS9/+.294868000440917107D+00, +.525879354056437389D+00,      &
     &          -.743023313492063491D+00,+.798907352292768958D+00,      &
     &          -.588085593033509699D+00,+.278960813492063491D+00,      &
     &          -.768631503527336859D-01,+.935653659611992944D-02/
      DATA BS10/+.286975446428571428D+00,+.589019786155202821D+00,      &
     &          -.964014825837742504D+00,+.124089037698412698D+01,      &
     &          -.114056437389770723D+01,+.720943838183421516D+00,      &
     &          -.297854662698412698D+00,+.724969686948853614D-01,      &
     &          -.789255401234567900D-02/
      DATA BS11/+.280189596443936721D+00,+.650092436016915182D+00,      &
     &          -.120830542528459194D+01,+.181090177569344235D+01,      &
     &          -.199558147196168029D+01,+.157596093624739458D+01,      &
     &          -.867866061407728073D+00,+.316787568141734808D+00,      &
     &          -.689652038740580406D-01,+.678584998463470685D-02/
      DATA BS12/+.274265540031599059D+00,+.709333000140291806D+00,      &
     &          -.147488796383978675D+01,+.252178854517396183D+01,      &
     &          -.323963331855258938D+01,+.306882315215648548D+01,      &
     &          -.211191790799863716D+01,+.102767433762225428D+01,      &
     &          -.335547742429252845D+00,+.660264141080113301D-01,      &
     &          -.592405641233766233D-02/
      DATA BS13/+.269028846773648774D+00,+.766936625977744942D+00,      &
     &          -.176290609302705243D+01,+.338584293273575887D+01,      &
     &          -.496774209367618345D+01,+.548817543732951718D+01,      &
     &          -.453127019317166886D+01,+.275578311274584835D+01,      &
     &          -.119960212999104988D+01,+.354044543295277008D+00,      &
     &          -.635276822497907979D-01,+.523669325795028506D-02/
      DATA BS14/+.264351348366606509D+00,+.823066606862252116D+00,      &
     &          -.207162098789184189D+01,+.441489258228505706D+01,      &
     &          -.728310380516210439D+01,+.919275417570699067D+01,      &
     &          -.885327872127872127D+01,+.646036185112332185D+01,      &
     &          -.351496384147697081D+01,+.138309419284457520D+01,      &
     &          -.372242577114580255D+00,+.613666741424574592D-01,      &
     &          -.467749840704226451D-02/
      DATA BS15/+.260136396127601036D+00,+.877860985969323263D+00,      &
     &          -.240038726253426877D+01,+.562036892264062230D+01,      &
     &          -.102967946560510174D+02,+.146173977073070342D+02,      &
     &          -.160861367634121126D+02,+.136932198932567132D+02,      &
     &          -.893960737307701437D+01,+.439678504373348829D+01,      &
     &          -.157771891747014549D+01,+.390132948784884341D+00,      &
     &          -.594718775141134116D-01,+.421495223900547285D-02/
      DATA  A5/+.245833333333333333D+00, -.241666666666666666D+00,      &
     &          +.791666666666666666D-01,+0.0D0/
      DATA  A6/+.320833333333333333D+00, -.466666666666666666D+00,      &
     &          +.304166666666666666D+00,-.749999999999999999D-01,      &
     &          +0.0D0/
      DATA  A7/+.392179232804232804D+00, -.752050264550264549D+00,      &
     &          +.732242063492063491D+00,-.360383597883597883D+00,      &
     &          +.713458994708994708D-01,+0.0D0/
      DATA  A8/+.460383597883597883D+00, -.109307208994708994D+01,      &
     &          +.141428571428571428D+01,-.104242724867724867D+01,      &
     &          +.412367724867724867D+00,-.682043650793650792D-01,      &
     &          +0.0D0/
      DATA  A9/+.525879354056437389D+00, -.148604662698412698D+01,      &
     &          +.239672205687830687D+01,-.235234237213403879D+01,      &
     &          +.139480406746031745D+01,-.461178902116402116D+00,      &
     &          +.654957561728395060D-01,+0.0D0/
      DATA A10/+.589019786155202821D+00, -.192802965167548500D+01,      &
     &          +.372267113095238095D+01,-.456225749559082892D+01,      &
     &          +.360471919091710758D+01,-.178712797619047619D+01,      &
     &          +.507478780864197530D+00,-.631404320987654320D-01,      &
     &          +0.0D0/
      DATA A11/+.650092436016915182D+00, -.241661085056918389D+01,      &
     &          +.543270532708032707D+01,-.798232588784672117D+01,      &
     &          +.787980468123697289D+01,-.520719636844636844D+01,      &
     &          +.221751297699214365D+01,-.551721630992464325D+00,      &
     &          +.610726498617123616D-01,+0.0D0/
      DATA A12/+.709333000140291806D+00, -.294977592767957351D+01,      &
     &          +.756536563552188551D+01,-.129585332742103575D+02,      &
     &          +.153441157607824274D+02,-.126715074479918229D+02,      &
     &          +.719372036335578001D+01,-.268438193943402276D+01,      &
     &          +.594237726972101971D+00,-.592405641233766233D-01,      &
     &          +0.0D0/
      DATA A13/+.766936625977744942D+00, -.352581218605410486D+01,      &
     &          +.101575287982072766D+02,-.198709683747047338D+02,      &
     &          +.274408771866475859D+02,-.271876211590300131D+02,      &
     &          +.192904817892209385D+02,-.959681703992839904D+01,      &
     &          +.318640088965749307D+01,-.635276822497907980D+00,      &
     &          +.576036258374531356D-01,+0.0D0/
      DATA A14/+.823066606862252116D+00, -.414324197578368378D+01,      &
     &          +.132446777468551711D+02,-.291324152206484175D+02,      &
     &          +.459637708785349534D+02,-.531196723276723276D+02,      &
     &          +.452225329578632530D+02,-.281197107318157665D+02,      &
     &          +.124478477356011768D+02,-.372242577114580255D+01,      &
     &          +.675033415567032051D+00,-.561299808845071741D-01,      &
     &          +0.0D0/
      DATA A15/+.877860985969323263D+00, -.480077452506853755D+01,      &
     &          +.168611067679218669D+02,-.411871786242040699D+02,      &
     &          +.730869885365351712D+02,-.965168205804726762D+02,      &
     &          +.958525392527969929D+02,-.715168589846161150D+02,      &
     &          +.395710653936013946D+02,-.157771891747014549D+02,      &
     &          +.429146243663372775D+01,-.713662530169360939D+00,      &
     &          +.547943791070711471D-01,+0.0D0/
      DATA AS5/+.791666666666666666D+01, +.833333333333333332D-02,      &
     &          -.416666666666666666D-02,+0.0D0/
      DATA AS6/+.749999999999999999D-01, +.208333333333333333D-01,      &
     &          -.166666666666666666D-01,+.416666666666666666D-02,      &
     &          +0.0D0/
      DATA AS7/+.713458994708994708D-01, +.354497354497354496D-01,      &
     &          -.385912698412698412D-01,+.187830687830687830D-01,      &
     &          -.365410052910052909D-02,+0.0D0/
      DATA AS8/+.682043650793650792D-01, +.511574074074074073D-01,      &
     &          -.700066137566137565D-01,+.501984126984126983D-01,      &
     &          -.193617724867724867D-01,+.314153439153439153D-02,      &
     &          +0.0D0/
      DATA AS9/+.654957561728395060D-01, +.674090608465608465D-01,      &
     &          -.110635747354497354D+00,+.104370590828924162D+00,      &
     &          -.599909060846560846D-01,+.193931878306878306D-01,      &
     &          -.270860890652557319D-02,+0.0D0/
      DATA AS10/+.631404320987654320D-01,+.838963293650793650D-01,      &
     &          -.160097552910052909D+00,+.186806933421516754D+00,      &
     &          -.142427248677248677D+00,+.688549933862433862D-01,      &
     &          -.191958774250440916D-01,+.235532407407407407D-02,      &
     &          +0.0D0/
      DATA AS11/+.610726498617123616D-01,+.100438587261503928D+00,      &
     &          -.217995455547538880D+00,+.302602738696488696D+00,      &
     &          -.287172005270963604D+00,+.184650798661215327D+00,      &
     &          -.770937800625300624D-01,+.188975819704986371D-01,      &
     &          -.206778223705307038D-02,+0.0D0/
      DATA AS12/+.592405641233766233D-01,+.116927358906525573D+00,      &
     &          -.283950542127625460D+00,+.456497940716690716D+00,      &
     &          -.518014808301266634D+00,+.415493601691518357D+00,      &
     &          -.230988982082732082D+00,+.848526685505852171D-01,      &
     &          -.185565538820747153D-01,+.183208573833573833D-02,      &
     &          +0.0D0/
      DATA AS13/+.576036258374531356D-01,+.133296741765760449D+00,      &
     &          -.357612764994182404D+00,+.652930535027509232D+00,      &
     &          -.861771848345199039D+00,+.828002049744237243D+00,      &
     &          -.574746022126664487D+00,+.281285262861403734D+00,      &
     &          -.922187767486316592D-01,+.182014685975706147D-01,      &
     &          -.163693828592348764D-02,+0.0D0/
      DATA AS14/+.561299808845071741D-01,+.149506836248166026D+00,      &
     &          -.438663237406210289D+00,+.896081952263592888D+00,      &
     &          -.134807468281736634D+01,+.150882601800527147D+01,      &
     &          -.125556999038769872D+01,+.767588097333571043D+00,      &
     &          -.335370193984715313D+00,+.992519410095984996D-01,      &
     &          -.178470327683290646D-01,+.147364495294596154D-02,      &
     &          +0.0D0/
      DATA AS15/+.547943791070711471D-01,+.165534057577398350D+00,      &
     &          -.526812954716988074D+00,+.118991434329951883D+01,      &
     &          -.200919756264819973D+01,+.256662262573460489D+01,      &
     &          -.248966603273858771D+01,+.182538470506290446D+01,      &
     &          -.996493073815548703D+00,+.393084332045524450D+00,      &
     &          -.105996750079106849D+00,+.175008662821782861D-01,      &
     &          -.133560177743602704D-02,+0.0D0/
!
!***********************************************************************
! START OF EXECUTABLE CODE *********************************************
!***********************************************************************
!
      IERR=1
      IF(IORDER.GT.15.OR.IORDER.LT.5) GO TO 9000
      INDEX=((IORDER-5)*(IORDER+2))/2
      IL=IORDER-2
      ILP1=IL+1
      IERR=2
      IF(IPC.EQ.1)GO TO 100
      IF(IPC.NE.0)GO TO 9000
      DO 10 I=1,IL
      POS(I)=ALPHAS(INDEX+I)
      VEL(I)=BETAS(INDEX+I)
   10 END DO
      VEL(ILP1)=BETAS(INDEX+ILP1)
      RETURN
  100 DO 110 I=1,IL
      POS(I)=ALPHA (INDEX+I)
      VEL(I)=BETA (INDEX+I)
  110 END DO
      VEL(ILP1)=BETA (INDEX+ILP1)
      RETURN
 9000 CONTINUE
      JLINE6=ILINE6+4
      IF(JLINE6.LE.MLINE6) GO TO 9050
      IPAGE6=IPAGE6+1
      JLINE6=5
      WRITE(IOUT6,10000) IPAGE6
 9050 CONTINUE
      ILINE6=JLINE6
      WRITE(IOUT6,20000)
      IF(IERR.EQ.2) GO TO 9200
      WRITE(IOUT6,20100) IORDER
      GO TO 9999
 9200 CONTINUE
      WRITE(IOUT6,20200) IPC
 9999 CONTINUE
      STOP 16
10000 FORMAT('1',109X,'UNIT  6 PAGE NO.',I6)
20000 FORMAT(' **COWCOF**  ILLEGAL INPUT.  ***** RUN TERMINATING *****',&
     &   /)
20100 FORMAT(' PERMISSIBLE VALUES OF IORDER ARE 5 THROUGH 15'/          &
     &                    17X,'VALUE PASSED WAS ',I10)
20200 FORMAT(' PERMISSIBLE VALUES OF IPC ARE 0 AND 1'/                  &
     &                 14X,'VALUE PASSED WAS ',I10)
      END