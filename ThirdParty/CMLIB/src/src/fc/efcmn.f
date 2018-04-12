      SUBROUTINE EFCMN(NDATA,XDATA,YDATA,SDDATA,NORD,NBKPT,BKPTIN,
     1   MDEIN,MDEOUT,COEFF,BF,XTEMP,PTEMP,BKPT,G,MDG,W,MDW,LW)
C***BEGIN PROLOGUE  EFCMN
C***REFER TO  EFC
C
C     This is a companion subprogram to EFC( ).
C     This subprogram does weighted least squares fitting
C     of data by B-spline curves.
C     The documentation for EFC( ) has more complete
C     usage instructions.
C
C     Revised 800905-1300
C     Revised YYMMDD-HHMM
C     R. Hanson, SNLA 87185 September, 1980.
C
C***REVISION HISTORY  (YYMMDD)
C   000330  Modified array declarations.  (JEC)
C
C***ROUTINES CALLED  BNDACC,BNDSOL,BSPLVN,SCOPY,SSCAL,SSORT,XERROR,
C                    XERRWV
C***END PROLOGUE  EFCMN
      DIMENSION XDATA(NDATA), YDATA(NDATA), SDDATA(NDATA), BKPTIN(NBKPT)
      DIMENSION COEFF(*), BF(NORD,NORD)
      DIMENSION XTEMP(*), PTEMP(*), BKPT(NBKPT)
      DIMENSION G(MDG,*), W(MDW,*)
C***FIRST EXECUTABLE STATEMENT  EFCMN
      ASSIGN 10 TO NPR001
      GO TO 40
   10 ASSIGN 20 TO NPR002
      GO TO 100
   20 ASSIGN 30 TO NPR003
      GO TO 360
   30 RETURN
C     PROCEDURE (INITIALIZE-VARIABLES-AND-ANALYZE-INPUT)
C
C     PROCEDURE (INITIALIZE-VARIABLES-AND-ANALYZE-INPUT)
   40 ZERO = 0.E0
      ONE = 1.E0
      L = NBKPT - NORD + 1
C
C     COMPUTE THE NUMBER OF VARIABLES.
      N = NBKPT - NORD
C
C     INITIALLY SET ALL OUTPUT COEFFICIENTS TO ZERO.
      CALL SCOPY(N, ZERO, 0, COEFF, 1)
      NP1 = L
      IF (.NOT.(.NOT.(1.LE.NORD .AND. NORD.LE.20))) GO TO 50
      CALL XERROR( 'EFC( ), THE ORDER OF THE B-SPLINE MUST BE 1 THRU 20.
     1', 52, 3,   1)
      MDEOUT = -1
      RETURN
C
   50 IF (.NOT.(NBKPT.LT.2*NORD)) GO TO 60
      CALL XERROR( 'EFC( ), NUMBER OF KNOTS MUST BE AT LEAST TWICE THE B
     1-SPLINE ORDER.', 66, 4, 1)
      MDEOUT = -1
      RETURN
   60 IF (.NOT.(NDATA.LT.0)) GO TO 70
      CALL XERROR( 'EFC( ), THE NUMBER OF DATA POINTS MUST BE NONNEGATIV
     1E.', 54,    5, 1)
      MDEOUT = -1
      RETURN
   70 NB = (NBKPT-NORD+3)*(NORD+1) + (NBKPT+1)*(NORD+1) +
     1 2*MAX0(NBKPT,NDATA) + NBKPT + NORD**2
      IF (.NOT.(LW.LT.NB)) GO TO 80
      CALL XERRWV( 'EFC( ). INSUFF. STORAGE FOR W(*). CHECK FORMULA THAT
     1 READS LW.GE. ... . (I1)=NEEDED, (I2)=GIVEN.', 96, 6, 1, 2, NB,
     2 LW, 0, DUMMY, DUMMY)
      MDEOUT = -1
      RETURN
   80 IF (.NOT.(.NOT.(MDEIN.EQ.1 .OR. MDEIN.EQ.2))) GO TO 90
      CALL XERROR( 'EFC( ), INPUT VALUE OF MDEIN MUST BE 1-2.', 41, 7,
     1 1)
      MDEOUT = -1
      RETURN
C
C     SORT THE BREAKPOINTS.
   90 CALL SCOPY(NBKPT, BKPTIN, 1, BKPT, 1)
      CALL SSORT(BKPT, DUMMY, NBKPT, 1)
      XMIN = BKPT(NORD)
C
C     DEFINE THE INDEX OF RIGHT-MOST INTERVAL-DEFINING KNOT.
      LAST = L
      XMAX = BKPT(LAST)
      NORDM1 = NORD - 1
      NORDP1 = NORD + 1
      GO TO NPR001, (10)
C     PROCEDURE (PROCESS-LEAST-SQUARES-EQUATIONS)
C
C     SORT DATA AND AN ARRAY OF POINTERS.
  100 CALL SCOPY(NDATA, XDATA, 1, XTEMP, 1)
      I = 1
      N20019 = NDATA
      GO TO 120
  110 I = I + 1
  120 IF ((N20019-I).LT.0) GO TO 130
      PTEMP(I) = I
      GO TO 110
  130 IF (.NOT.(NDATA.GT.0)) GO TO 140
      CALL SSORT(XTEMP, PTEMP, NDATA, 2)
      XMIN = AMIN1(XMIN,XTEMP(1))
      XMAX = AMAX1(XMAX,XTEMP(NDATA))
C
C     FIX BREAKPOINT ARRAY IF NEEDED. THIS SHOULD ONLY INVOLVE VERY
C     MINOR DIFFERENCES WITH THE INPUT ARRAY OF BREAKPOINTS.
  140 I = 1
      N20026 = NORD
      GO TO 160
  150 I = I + 1
  160 IF ((N20026-I).LT.0) GO TO 170
      BKPT(I) = AMIN1(BKPT(I),XMIN)
      GO TO 150
  170 I = LAST
      N20030 = NBKPT
      GO TO 190
  180 I = I + 1
  190 IF ((N20030-I).LT.0) GO TO 200
      BKPT(I) = AMAX1(BKPT(I),XMAX)
      GO TO 180
C
C     INITIALIZE PARAMETERS OF BANDED MATRIX PROCESSOR, BNDACC( ).
  200 MT = 0
      IP = 1
      IR = 1
      IDATA = 1
      ILEFT = NORD
      INTSEQ = 1
  210 IF (.NOT.(IDATA.LE.NDATA)) GO TO 280
C
C     SORTED INDICES ARE IN PTEMP(*).
      L = PTEMP(IDATA)
      XVAL = XDATA(L)
C
C     WHEN INTERVAL CHANGES, PROCESS EQUATIONS IN THE LAST BLOCK.
      IF (.NOT.(XVAL.GE.BKPT(ILEFT+1))) GO TO 250
      INTRVL = ILEFT - NORDM1
      CALL BNDACC(G, MDG, NORD, IP, IR, MT, INTRVL)
      MT = 0
C
C     MOVE POINTER UP TO HAVE BKPT(ILEFT).LE.XVAL, ILEFT.LT.LAST.
  220 IF (.NOT.(XVAL.GE.BKPT(ILEFT+1) .AND. ILEFT.LT.LAST-1)) GO TO 240
      IF (.NOT.(MDEIN.EQ.2)) GO TO 230
C
C     DATA IS BEING SEQUENTIALLY ACCUMULATED. TRANSFER
C     PREVIOUSLY ACCUMULATED ROWS FROM W(*,*) TO G(*,*)
C     AND PROCESS THEM.
      CALL SCOPY(NORDP1, W(INTSEQ,1), MDW, G(IR,1), MDG)
      CALL BNDACC(G, MDG, NORD, IP, IR, 1, INTSEQ)
      INTSEQ = INTSEQ + 1
  230 ILEFT = ILEFT + 1
      GO TO 220
  240 CONTINUE
C
C     OBTAIN B-SPLINE FUNCTION VALUE.
  250 CALL BSPLVN(BKPT, NORD, 1, XVAL, ILEFT, BF)
C
C     MOVE ROW INTO PLACE.
      IROW = IR + MT
      MT = MT + 1
      CALL SCOPY(NORD, BF, 1, G(IROW,1), MDG)
      G(IROW,NORDP1) = YDATA(L)
C
C     SCALE DATA IF UNCERTAINTY IS NONZERO.
      IF (.NOT.(SDDATA(L).NE.ZERO)) GO TO 260
      CALL SSCAL(NORDP1, ONE/SDDATA(L), G(IROW,1), MDG)
C
C     WHEN STAGING WORK AREA IS EXHAUSTED, PROCESS ROWS.
  260 IF (.NOT.(IROW.EQ.MDG-1)) GO TO 270
      INTRVL = ILEFT - NORDM1
      CALL BNDACC(G, MDG, NORD, IP, IR, MT, INTRVL)
      MT = 0
  270 IDATA = IDATA + 1
      GO TO 210
C
C     PROCESS LAST BLOCK OF EQUATIONS.
  280 INTRVL = ILEFT - NORDM1
      CALL BNDACC(G, MDG, NORD, IP, IR, MT, INTRVL)
C
C     FINISH PROCESSING ANY PREVIOUSLY ACCUMULATED
C     ROWS FROM W(*,*) TO G(*,*).
      IF (.NOT.(MDEIN.EQ.2)) GO TO 320
  290 CALL SCOPY(NORDP1, W(INTSEQ,1), MDW, G(IR,1), MDG)
      CALL BNDACC(G, MDG, NORD, IP, IR, 1, MIN0(N,INTSEQ))
      IF (.NOT.(INTSEQ.EQ.NP1)) GO TO 300
      GO TO 310
  300 INTSEQ = INTSEQ + 1
      GO TO 290
  310 CONTINUE
C
C     LAST CALL TO ADJUST BLOCK POSITIONING.
  320 G(IR,1) = ZERO
      CALL SCOPY(NORDP1, G(IR,1), 0, G(IR,1), MDG)
      CALL BNDACC(G, MDG, NORD, IP, IR, 1, NP1)
C
C     TRANSFER ACCUMULATED ROWS FROM G(*,*) TO W(*,*) FOR
C     POSSIBLE LATER SEQUENTIAL ACCUMULATION.
      I = 1
      N20058 = NP1
      GO TO 340
  330 I = I + 1
  340 IF ((N20058-I).LT.0) GO TO 350
      CALL SCOPY(NORDP1, G(I,1), MDG, W(I,1), MDW)
      GO TO 330
  350 GO TO NPR002, (20)
C     PROCEDURE (SOLVE-FOR-COEFFICIENTS-WHEN-POSSIBLE)
  360 I = 1
      N20062 = N
      GO TO 380
  370 I = I + 1
  380 IF ((N20062-I).LT.0) GO TO 400
      IF (.NOT.(G(I,1).EQ.ZERO)) GO TO 390
      MDEOUT = 2
      GO TO 410
  390 CONTINUE
      GO TO 370
C
C     ALL THE DIAGONAL TERMS IN THE ACCUMULATED TRIANGULAR
C     MATRIX ARE NONZERO.  THE SOLN. CAN BE COMPUTED BUT
C     IT MAY BE UNSUITABLE FOR FURTHER USE DUE TO POOR
C     CONDITIONING OR THE LACK OF CONSTRAINTS.  NO CHECKING
C     FOR EITHER OF THESE IS DONE HERE.
  400 MODE = 1
      CALL BNDSOL(MODE, G, MDG, NORD, IP, IR, COEFF, N, RNORM)
      MDEOUT = 1
  410 GO TO NPR003, (30)
      END
