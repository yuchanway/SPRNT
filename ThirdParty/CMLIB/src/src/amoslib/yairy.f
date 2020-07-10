      SUBROUTINE YAIRY(X,RX,C,BI,DBI)
C***BEGIN PROLOGUE  YAIRY
C***REFER TO  BESJ,BESY
C
C                  YAIRY computes the Airy function BI(X)
C                   and its derivative DBI(X) for ASYJY
C
C                                     INPUT
C
C         X  - Argument, computed by ASYJY, X unrestricted
C        RX  - RX=SQRT(ABS(X)), computed by ASYJY
C         C  - C=2.*(ABS(X)**1.5)/3., computed by ASYJY
C
C                                    OUTPUT
C        BI  - Value of function BI(X)
C       DBI  - Value of the derivative DBI(X)
C
C                                  Written by
C
C                                  D. E. Amos
C                                 S. L. Daniel
C***ROUTINES CALLED  (NONE)
C***END PROLOGUE  YAIRY
C
      INTEGER I, J, M1, M1D, M2, M2D, M3, M3D, M4D, N1, N1D, N2, N2D,
     1 N3, N3D, N4D
      REAL AA, AX, BB, BI, BJN, BJP, BK1, BK2, BK3, BK4, C, CON1, CON2,
     1 CON3, CV, DAA, DBB, DBI, DBJN, DBJP, DBK1, DBK2, DBK3, DBK4, D1,
     2 D2, EX, E1, E2, FPI12, F1, F2, RTRX, RX, SPI12, S1, S2, T, TC,
     3 TEMP1, TEMP2, TT, X
      DIMENSION BK1(20), BK2(20), BK3(20), BK4(14)
      DIMENSION BJP(19), BJN(19), AA(14), BB(14)
      DIMENSION DBK1(21), DBK2(20), DBK3(20), DBK4(14)
      DIMENSION DBJP(19), DBJN(19), DAA(14), DBB(14)
      SAVE N1, N2, N3, M1, M2, M3, N1D, N2D, N3D, N4D,
     1 M1D, M2D, M3D, M4D, FPI12, SPI12, CON1, CON2, CON3,
     2 BK1, BK2, BK3, BK4, BJP, BJN, AA, BB, DBK1, DBK2, DBK3, DBK4,
     3 DBJP, DBJN, DAA, DBB
      DATA N1,N2,N3/20,19,14/
      DATA M1,M2,M3/18,17,12/
      DATA N1D,N2D,N3D,N4D/21,20,19,14/
      DATA M1D,M2D,M3D,M4D/19,18,17,12/
      DATA FPI12,SPI12,CON1,CON2,CON3/
     1 1.30899693899575E+00, 1.83259571459405E+00, 6.66666666666667E-01,
     2 7.74148278841779E+00, 3.64766105490356E-01/
      DATA BK1(1),  BK1(2),  BK1(3),  BK1(4),  BK1(5),  BK1(6),
     1     BK1(7),  BK1(8),  BK1(9),  BK1(10), BK1(11), BK1(12),
     2     BK1(13), BK1(14), BK1(15), BK1(16), BK1(17), BK1(18),
     3     BK1(19), BK1(20)/ 2.43202846447449E+00, 2.57132009754685E+00,
     4 1.02802341258616E+00, 3.41958178205872E-01, 8.41978629889284E-02,
     5 1.93877282587962E-02, 3.92687837130335E-03, 6.83302689948043E-04,
     6 1.14611403991141E-04, 1.74195138337086E-05, 2.41223620956355E-06,
     7 3.24525591983273E-07, 4.03509798540183E-08, 4.70875059642296E-09,
     8 5.35367432585889E-10, 5.70606721846334E-11, 5.80526363709933E-12,
     9 5.76338988616388E-13, 5.42103834518071E-14, 4.91857330301677E-15/
      DATA BK2(1),  BK2(2),  BK2(3),  BK2(4),  BK2(5),  BK2(6),
     1     BK2(7),  BK2(8),  BK2(9),  BK2(10), BK2(11), BK2(12),
     2     BK2(13), BK2(14), BK2(15), BK2(16), BK2(17), BK2(18),
     3     BK2(19), BK2(20)/ 5.74830555784088E-01,-6.91648648376891E-03,
     4 1.97460263052093E-03,-5.24043043868823E-04, 1.22965147239661E-04,
     5-2.27059514462173E-05, 2.23575555008526E-06, 4.15174955023899E-07,
     6-2.84985752198231E-07, 8.50187174775435E-08,-1.70400826891326E-08,
     7 2.25479746746889E-09,-1.09524166577443E-10,-3.41063845099711E-11,
     8 1.11262893886662E-11,-1.75542944241734E-12, 1.36298600401767E-13,
     9 8.76342105755664E-15,-4.64063099157041E-15, 7.78772758732960E-16/
      DATA BK3(1),  BK3(2),  BK3(3),  BK3(4),  BK3(5),  BK3(6),
     1     BK3(7),  BK3(8),  BK3(9),  BK3(10), BK3(11), BK3(12),
     2     BK3(13), BK3(14), BK3(15), BK3(16), BK3(17), BK3(18),
     3     BK3(19), BK3(20)/ 5.66777053506912E-01, 2.63672828349579E-03,
     4 5.12303351473130E-05, 2.10229231564492E-06, 1.42217095113890E-07,
     5 1.28534295891264E-08, 7.28556219407507E-10,-3.45236157301011E-10,
     6-2.11919115912724E-10,-6.56803892922376E-11,-8.14873160315074E-12,
     7 3.03177845632183E-12, 1.73447220554115E-12, 1.67935548701554E-13,
     8-1.49622868806719E-13,-5.15470458953407E-14, 8.75741841857830E-15,
     9 7.96735553525720E-15,-1.29566137861742E-16,-1.11878794417520E-15/
      DATA BK4(1),  BK4(2),  BK4(3),  BK4(4),  BK4(5),  BK4(6),
     1     BK4(7),  BK4(8),  BK4(9),  BK4(10), BK4(11), BK4(12),
     2     BK4(13), BK4(14)/ 4.85444386705114E-01,-3.08525088408463E-03,
     3 6.98748404837928E-05,-2.82757234179768E-06, 1.59553313064138E-07,
     4-1.12980692144601E-08, 9.47671515498754E-10,-9.08301736026423E-11,
     5 9.70776206450724E-12,-1.13687527254574E-12, 1.43982917533415E-13,
     6-1.95211019558815E-14, 2.81056379909357E-15,-4.26916444775176E-16/
      DATA BJP(1),  BJP(2),  BJP(3),  BJP(4),  BJP(5),  BJP(6),
     1     BJP(7),  BJP(8),  BJP(9),  BJP(10), BJP(11), BJP(12),
     2     BJP(13), BJP(14), BJP(15), BJP(16), BJP(17), BJP(18),
     3     BJP(19)         / 1.34918611457638E-01,-3.19314588205813E-01,
     4 5.22061946276114E-02, 5.28869112170312E-02,-8.58100756077350E-03,
     5-2.99211002025555E-03, 4.21126741969759E-04, 8.73931830369273E-05,
     6-1.06749163477533E-05,-1.56575097259349E-06, 1.68051151983999E-07,
     7 1.89901103638691E-08,-1.81374004961922E-09,-1.66339134593739E-10,
     8 1.42956335780810E-11, 1.10179811626595E-12,-8.60187724192263E-14,
     9-5.71248177285064E-15, 4.08414552853803E-16/
      DATA BJN(1),  BJN(2),  BJN(3),  BJN(4),  BJN(5),  BJN(6),
     1     BJN(7),  BJN(8),  BJN(9),  BJN(10), BJN(11), BJN(12),
     2     BJN(13), BJN(14), BJN(15), BJN(16), BJN(17), BJN(18),
     3     BJN(19)         / 6.59041673525697E-02,-4.24905910566004E-01,
     4 2.87209745195830E-01, 1.29787771099606E-01,-4.56354317590358E-02,
     5-1.02630175982540E-02, 2.50704671521101E-03, 3.78127183743483E-04,
     6-7.11287583284084E-05,-8.08651210688923E-06, 1.23879531273285E-06,
     7 1.13096815867279E-07,-1.46234283176310E-08,-1.11576315688077E-09,
     8 1.24846618243897E-10, 8.18334132555274E-12,-8.07174877048484E-13,
     9-4.63778618766425E-14, 4.09043399081631E-15/
      DATA AA(1),   AA(2),   AA(3),   AA(4),   AA(5),   AA(6),
     1     AA(7),   AA(8),   AA(9),   AA(10),  AA(11),  AA(12),
     2     AA(13),  AA(14) /-2.78593552803079E-01, 3.52915691882584E-03,
     3 2.31149677384994E-05,-4.71317842263560E-06, 1.12415907931333E-07,
     4 2.00100301184339E-08,-2.60948075302193E-09, 3.55098136101216E-11,
     5 3.50849978423875E-11,-5.83007187954202E-12, 2.04644828753326E-13,
     6 1.10529179476742E-13,-2.87724778038775E-14, 2.88205111009939E-15/
      DATA BB(1),   BB(2),   BB(3),   BB(4),   BB(5),   BB(6),
     1     BB(7),   BB(8),   BB(9),   BB(10),  BB(11),  BB(12),
     2     BB(13),  BB(14) /-4.90275424742791E-01,-1.57647277946204E-03,
     3 9.66195963140306E-05,-1.35916080268815E-07,-2.98157342654859E-07,
     4 1.86824767559979E-08, 1.03685737667141E-09,-3.28660818434328E-10,
     5 2.57091410632780E-11, 2.32357655300677E-12,-9.57523279048255E-13,
     6 1.20340828049719E-13, 2.90907716770715E-15,-4.55656454580149E-15/
      DATA DBK1(1), DBK1(2), DBK1(3), DBK1(4), DBK1(5), DBK1(6),
     1     DBK1(7), DBK1(8), DBK1(9), DBK1(10),DBK1(11),DBK1(12),
     2     DBK1(13),DBK1(14),DBK1(15),DBK1(16),DBK1(17),DBK1(18),
     3     DBK1(19),DBK1(20),
     4     DBK1(21)        / 2.95926143981893E+00, 3.86774568440103E+00,
     5 1.80441072356289E+00, 5.78070764125328E-01, 1.63011468174708E-01,
     6 3.92044409961855E-02, 7.90964210433812E-03, 1.50640863167338E-03,
     7 2.56651976920042E-04, 3.93826605867715E-05, 5.81097771463818E-06,
     8 7.86881233754659E-07, 9.93272957325739E-08, 1.21424205575107E-08,
     9 1.38528332697707E-09, 1.50190067586758E-10, 1.58271945457594E-11,
     1 1.57531847699042E-12, 1.50774055398181E-13, 1.40594335806564E-14,
     2 1.24942698777218E-15/
      DATA DBK2(1), DBK2(2), DBK2(3), DBK2(4), DBK2(5), DBK2(6),
     1     DBK2(7), DBK2(8), DBK2(9), DBK2(10),DBK2(11),DBK2(12),
     2     DBK2(13),DBK2(14),DBK2(15),DBK2(16),DBK2(17),DBK2(18),
     3    DBK2(19),DBK2(20)/ 5.49756809432471E-01, 9.13556983276901E-03,
     4-2.53635048605507E-03, 6.60423795342054E-04,-1.55217243135416E-04,
     5 3.00090325448633E-05,-3.76454339467348E-06,-1.33291331611616E-07,
     6 2.42587371049013E-07,-8.07861075240228E-08, 1.71092818861193E-08,
     7-2.41087357570599E-09, 1.53910848162371E-10, 2.56465373190630E-11,
     8-9.88581911653212E-12, 1.60877986412631E-12,-1.20952524741739E-13,
     9-1.06978278410820E-14, 5.02478557067561E-15,-8.68986130935886E-16/
      DATA DBK3(1), DBK3(2), DBK3(3), DBK3(4), DBK3(5), DBK3(6),
     1     DBK3(7), DBK3(8), DBK3(9), DBK3(10),DBK3(11),DBK3(12),
     2     DBK3(13),DBK3(14),DBK3(15),DBK3(16),DBK3(17),DBK3(18),
     3    DBK3(19),DBK3(20)/ 5.60598509354302E-01,-3.64870013248135E-03,
     4-5.98147152307417E-05,-2.33611595253625E-06,-1.64571516521436E-07,
     5-2.06333012920569E-08,-4.27745431573110E-09,-1.08494137799276E-09,
     6-2.37207188872763E-10,-2.22132920864966E-11, 1.07238008032138E-11,
     7 5.71954845245808E-12, 7.51102737777835E-13,-3.81912369483793E-13,
     8-1.75870057119257E-13, 6.69641694419084E-15, 2.26866724792055E-14,
     9 2.69898141356743E-15,-2.67133612397359E-15,-6.54121403165269E-16/
      DATA DBK4(1), DBK4(2), DBK4(3), DBK4(4), DBK4(5), DBK4(6),
     1     DBK4(7), DBK4(8), DBK4(9), DBK4(10),DBK4(11),DBK4(12),
     2    DBK4(13),DBK4(14)/ 4.93072999188036E-01, 4.38335419803815E-03,
     3-8.37413882246205E-05, 3.20268810484632E-06,-1.75661979548270E-07,
     4 1.22269906524508E-08,-1.01381314366052E-09, 9.63639784237475E-11,
     5-1.02344993379648E-11, 1.19264576554355E-12,-1.50443899103287E-13,
     6 2.03299052379349E-14,-2.91890652008292E-15, 4.42322081975475E-16/
      DATA DBJP(1), DBJP(2), DBJP(3), DBJP(4), DBJP(5), DBJP(6),
     1     DBJP(7), DBJP(8), DBJP(9), DBJP(10),DBJP(11),DBJP(12),
     2     DBJP(13),DBJP(14),DBJP(15),DBJP(16),DBJP(17),DBJP(18),
     3     DBJP(19)        / 1.13140872390745E-01,-2.08301511416328E-01,
     4 1.69396341953138E-02, 2.90895212478621E-02,-3.41467131311549E-03,
     5-1.46455339197417E-03, 1.63313272898517E-04, 3.91145328922162E-05,
     6-3.96757190808119E-06,-6.51846913772395E-07, 5.98707495269280E-08,
     7 7.44108654536549E-09,-6.21241056522632E-10,-6.18768017313526E-11,
     8 4.72323484752324E-12, 3.91652459802532E-13,-2.74985937845226E-14,
     9-1.95036497762750E-15, 1.26669643809444E-16/
      DATA DBJN(1), DBJN(2), DBJN(3), DBJN(4), DBJN(5), DBJN(6),
     1     DBJN(7), DBJN(8), DBJN(9), DBJN(10),DBJN(11),DBJN(12),
     2     DBJN(13),DBJN(14),DBJN(15),DBJN(16),DBJN(17),DBJN(18),
     3     DBJN(19)        /-1.88091260068850E-02,-1.47798180826140E-01,
     4 5.46075900433171E-01, 1.52146932663116E-01,-9.58260412266886E-02,
     5-1.63102731696130E-02, 5.75364806680105E-03, 7.12145408252655E-04,
     6-1.75452116846724E-04,-1.71063171685128E-05, 3.24435580631680E-06,
     7 2.61190663932884E-07,-4.03026865912779E-08,-2.76435165853895E-09,
     8 3.59687929062312E-10, 2.14953308456051E-11,-2.41849311903901E-12,
     9-1.28068004920751E-13, 1.26939834401773E-14/
      DATA DAA(1),  DAA(2),  DAA(3),  DAA(4),  DAA(5),  DAA(6),
     1     DAA(7),  DAA(8),  DAA(9),  DAA(10), DAA(11), DAA(12),
     2     DAA(13), DAA(14)/ 2.77571356944231E-01,-4.44212833419920E-03,
     3 8.42328522190089E-05, 2.58040318418710E-06,-3.42389720217621E-07,
     4 6.24286894709776E-09, 2.36377836844577E-09,-3.16991042656673E-10,
     5 4.40995691658191E-12, 5.18674221093575E-12,-9.64874015137022E-13,
     6 4.90190576608710E-14, 1.77253430678112E-14,-5.55950610442662E-15/
      DATA DBB(1),  DBB(2),  DBB(3),  DBB(4),  DBB(5),  DBB(6),
     1     DBB(7),  DBB(8),  DBB(9),  DBB(10), DBB(11), DBB(12),
     2     DBB(13), DBB(14)/ 4.91627321104601E-01, 3.11164930427489E-03,
     3 8.23140762854081E-05,-4.61769776172142E-06,-6.13158880534626E-08,
     4 2.87295804656520E-08,-1.81959715372117E-09,-1.44752826642035E-10,
     5 4.53724043420422E-11,-3.99655065847223E-12,-3.24089119830323E-13,
     6 1.62098952568741E-13,-2.40765247974057E-14, 1.69384811284491E-16/
C***FIRST EXECUTABLE STATEMENT  YAIRY
      AX = ABS(X)
      RX = SQRT(AX)
      C = CON1*AX*RX
      IF (X.LT.0.0E0) GO TO 120
      IF (C.GT.8.0E0) GO TO 60
      IF (X.GT.2.5E0) GO TO 30
      T = (X+X-2.5E0)*0.4E0
      TT = T + T
      J = N1
      F1 = BK1(J)
      F2 = 0.0E0
      DO 10 I=1,M1
        J = J - 1
        TEMP1 = F1
        F1 = TT*F1 - F2 + BK1(J)
        F2 = TEMP1
   10 CONTINUE
      BI = T*F1 - F2 + BK1(1)
      J = N1D
      F1 = DBK1(J)
      F2 = 0.0E0
      DO 20 I=1,M1D
        J = J - 1
        TEMP1 = F1
        F1 = TT*F1 - F2 + DBK1(J)
        F2 = TEMP1
   20 CONTINUE
      DBI = T*F1 - F2 + DBK1(1)
      RETURN
   30 CONTINUE
      RTRX = SQRT(RX)
      T = (X+X-CON2)*CON3
      TT = T + T
      J = N1
      F1 = BK2(J)
      F2 = 0.0E0
      DO 40 I=1,M1
        J = J - 1
        TEMP1 = F1
        F1 = TT*F1 - F2 + BK2(J)
        F2 = TEMP1
   40 CONTINUE
      BI = (T*F1-F2+BK2(1))/RTRX
      EX = EXP(C)
      BI = BI*EX
      J = N2D
      F1 = DBK2(J)
      F2 = 0.0E0
      DO 50 I=1,M2D
        J = J - 1
        TEMP1 = F1
        F1 = TT*F1 - F2 + DBK2(J)
        F2 = TEMP1
   50 CONTINUE
      DBI = (T*F1-F2+DBK2(1))*RTRX
      DBI = DBI*EX
      RETURN
C
   60 CONTINUE
      RTRX = SQRT(RX)
      T = 16.0E0/C - 1.0E0
      TT = T + T
      J = N1
      F1 = BK3(J)
      F2 = 0.0E0
      DO 70 I=1,M1
        J = J - 1
        TEMP1 = F1
        F1 = TT*F1 - F2 + BK3(J)
        F2 = TEMP1
   70 CONTINUE
      S1 = T*F1 - F2 + BK3(1)
      J = N2D
      F1 = DBK3(J)
      F2 = 0.0E0
      DO 80 I=1,M2D
        J = J - 1
        TEMP1 = F1
        F1 = TT*F1 - F2 + DBK3(J)
        F2 = TEMP1
   80 CONTINUE
      D1 = T*F1 - F2 + DBK3(1)
      TC = C + C
      EX = EXP(C)
      IF (TC.GT.35.0E0) GO TO 110
      T = 10.0E0/C - 1.0E0
      TT = T + T
      J = N3
      F1 = BK4(J)
      F2 = 0.0E0
      DO 90 I=1,M3
        J = J - 1
        TEMP1 = F1
        F1 = TT*F1 - F2 + BK4(J)
        F2 = TEMP1
   90 CONTINUE
      S2 = T*F1 - F2 + BK4(1)
      BI = (S1+EXP(-TC)*S2)/RTRX
      BI = BI*EX
      J = N4D
      F1 = DBK4(J)
      F2 = 0.0E0
      DO 100 I=1,M4D
        J = J - 1
        TEMP1 = F1
        F1 = TT*F1 - F2 + DBK4(J)
        F2 = TEMP1
  100 CONTINUE
      D2 = T*F1 - F2 + DBK4(1)
      DBI = RTRX*(D1+EXP(-TC)*D2)
      DBI = DBI*EX
      RETURN
  110 BI = EX*S1/RTRX
      DBI = EX*RTRX*D1
      RETURN
C
  120 CONTINUE
      IF (C.GT.5.0E0) GO TO 150
      T = 0.4E0*C - 1.0E0
      TT = T + T
      J = N2
      F1 = BJP(J)
      E1 = BJN(J)
      F2 = 0.0E0
      E2 = 0.0E0
      DO 130 I=1,M2
        J = J - 1
        TEMP1 = F1
        TEMP2 = E1
        F1 = TT*F1 - F2 + BJP(J)
        E1 = TT*E1 - E2 + BJN(J)
        F2 = TEMP1
        E2 = TEMP2
  130 CONTINUE
      BI = (T*E1-E2+BJN(1)) - AX*(T*F1-F2+BJP(1))
      J = N3D
      F1 = DBJP(J)
      E1 = DBJN(J)
      F2 = 0.0E0
      E2 = 0.0E0
      DO 140 I=1,M3D
        J = J - 1
        TEMP1 = F1
        TEMP2 = E1
        F1 = TT*F1 - F2 + DBJP(J)
        E1 = TT*E1 - E2 + DBJN(J)
        F2 = TEMP1
        E2 = TEMP2
  140 CONTINUE
      DBI = X*X*(T*F1-F2+DBJP(1)) + (T*E1-E2+DBJN(1))
      RETURN
C
  150 CONTINUE
      RTRX = SQRT(RX)
      T = 10.0E0/C - 1.0E0
      TT = T + T
      J = N3
      F1 = AA(J)
      E1 = BB(J)
      F2 = 0.0E0
      E2 = 0.0E0
      DO 160 I=1,M3
        J = J - 1
        TEMP1 = F1
        TEMP2 = E1
        F1 = TT*F1 - F2 + AA(J)
        E1 = TT*E1 - E2 + BB(J)
        F2 = TEMP1
        E2 = TEMP2
  160 CONTINUE
      TEMP1 = T*F1 - F2 + AA(1)
      TEMP2 = T*E1 - E2 + BB(1)
      CV = C - FPI12
      BI = (TEMP1*COS(CV)+TEMP2*SIN(CV))/RTRX
      J = N4D
      F1 = DAA(J)
      E1 = DBB(J)
      F2 = 0.0E0
      E2 = 0.0E0
      DO 170 I=1,M4D
        J = J - 1
        TEMP1 = F1
        TEMP2 = E1
        F1 = TT*F1 - F2 + DAA(J)
        E1 = TT*E1 - E2 + DBB(J)
        F2 = TEMP1
        E2 = TEMP2
  170 CONTINUE
      TEMP1 = T*F1 - F2 + DAA(1)
      TEMP2 = T*E1 - E2 + DBB(1)
      CV = C - SPI12
      DBI = (TEMP1*COS(CV)-TEMP2*SIN(CV))*RTRX
      RETURN
      END
