      SUBROUTINE SUMSL(N, D, X, CALCF, CALCG, IV, LIV, LV, V,
     1                  UIPARM, URPARM, UFPARM)
C
C  ***  MINIMIZE GENERAL UNCONSTRAINED OBJECTIVE FUNCTION USING   ***
C  ***  ANALYTIC GRADIENT AND HESSIAN APPROX. FROM SECANT UPDATE  ***
C
      INTEGER N, LIV, LV
      INTEGER IV(LIV), UIPARM(*)
      REAL D(N), X(N), V(LV), URPARM(*)
C     DIMENSION V(71 + N*(N+15)/2), UIPARM(*), URPARM(*)
      EXTERNAL CALCF, CALCG, UFPARM
C
C  ***  PURPOSE  ***
C
C        THIS ROUTINE INTERACTS WITH SUBROUTINE  SUMIT  IN AN ATTEMPT
C     TO FIND AN N-VECTOR  X*  THAT MINIMIZES THE (UNCONSTRAINED)
C     OBJECTIVE FUNCTION COMPUTED BY  CALCF.  (OFTEN THE  X*  FOUND IS
C     A LOCAL MINIMIZER RATHER THAN A GLOBAL ONE.)
C
C--------------------------  PARAMETER USAGE  --------------------------
C
C N........ (INPUT) THE NUMBER OF VARIABLES ON WHICH  F  DEPENDS, I.E.,
C                  THE NUMBER OF COMPONENTS IN  X.
C D........ (INPUT/OUTPUT) A SCALE VECTOR SUCH THAT  D(I)*X(I),
C                  I = 1,2,...,N,  ARE ALL IN COMPARABLE UNITS.
C                  D CAN STRONGLY AFFECT THE BEHAVIOR OF SUMSL.
C                  FINDING THE BEST CHOICE OF D IS GENERALLY A TRIAL-
C                  AND-ERROR PROCESS.  CHOOSING D SO THAT D(I)*X(I)
C                  HAS ABOUT THE SAME VALUE FOR ALL I OFTEN WORKS WELL.
C                  THE DEFAULTS PROVIDED BY SUBROUTINE DEFLT (SEE IV
C                  BELOW) REQUIRE THE CALLER TO SUPPLY D.
C X........ (INPUT/OUTPUT) BEFORE (INITIALLY) CALLING SUMSL, THE CALL-
C                  ER SHOULD SET  X  TO AN INITIAL GUESS AT  X*.  WHEN
C                  SUMSL RETURNS,  X  CONTAINS THE BEST POINT SO FAR
C                  FOUND, I.E., THE ONE THAT GIVES THE LEAST VALUE SO
C                  FAR SEEN FOR  F(X).
C CALCF.... (INPUT) A SUBROUTINE THAT, GIVEN X, COMPUTES F(X).  CALCF
C                  MUST BE DECLARED EXTERNAL IN THE CALLING PROGRAM.
C                  IT IS INVOKED BY
C                       CALL CALCF(N, X, NF, F, UIPARM, URPARM, UFPARM)
C                  NF IS THE INVOCATION COUNT FOR CALCF.  IT IS INCLUD-
C                  ED FOR POSSIBLE USE WITH CALCG.  IF X IS OUT OF
C                  BOUNDS (E.G., IF IT WOULD CAUSE OVERFLOW IN COMPUT-
C                  ING F(X)), THEN CALCF SHOULD SET NF TO 0.  THIS WILL
C                  CAUSE A SHORTER STEP TO BE ATTEMPTED.  THE OTHER
C                  PARAMETERS ARE AS DESCRIBED ABOVE AND BELOW.  CALCF
C                  SHOULD NOT CHANGE N, P, OR X.
C CALCG.... (INPUT) A SUBROUTINE THAT, GIVEN X, COMPUTES G(X), THE GRA-
C                  DIENT OF F AT X.  CALCG MUST BE DECLARED EXTERNAL IN
C                  THE CALLING PROGRAM.  IT IS INVOKED BY
C                       CALL CALCG(N, X, NF, G, UIPARM, URPARM, UFAPRM)
C                  NF IS THE INVOCATION COUNT FOR CALCF AT THE TIME
C                  F(X) WAS EVALUATED.  THE X PASSED TO CALCG IS
C                  USUALLY THE ONE PASSED TO CALCF ON EITHER ITS MOST
C                  RECENT INVOCATION OR THE ONE PRIOR TO IT.  IF CALCF
C                  SAVES INTERMEDIATE RESULTS FOR USE BY CALCG, THEN IT
C                  IS POSSIBLE TO TELL FROM NF WHETHER THEY ARE VALID
C                  FOR THE CURRENT X (OR WHICH COPY IS VALID IF TWO
C                  COPIES ARE KEPT).  IF G CANNOT BE COMPUTED AT X,
C                  THEN CALCG SHOULD SET NF TO 0.  IN THIS CASE, SUMSL
C                  WILL RETURN WITH IV(1) = 65.  THE OTHER PARAMETERS
C                  TO CALCG ARE AS DESCRIBED ABOVE AND BELOW.  CALCG
C                  SHOULD NOT CHANGE N OR X.
C IV....... (INPUT/OUTPUT) AN INTEGER VALUE ARRAY OF LENGTH LIV (SEE
C                  BELOW) THAT HELPS CONTROL THE SUMSL ALGORITHM AND
C                  THAT IS USED TO STORE VARIOUS INTERMEDIATE QUANTI-
C                  TIES.  OF PARTICULAR INTEREST ARE THE INITIALIZATION/
C                  RETURN CODE IV(1) AND THE ENTRIES IN IV THAT CONTROL
C                  PRINTING AND LIMIT THE NUMBER OF ITERATIONS AND FUNC-
C                  TION EVALUATIONS.  SEE THE SECTION ON IV INPUT
C                  VALUES BELOW.
C V........ (INPUT/OUTPUT) A FLOATING-POINT VALUE ARRAY OF LENGTH LV
C                  (SEE BELOW) THAT HELPS CONTROL THE SUMSL ALGORITHM
C                  AND THAT IS USED TO STORE VARIOUS INTERMEDIATE
C                  QUANTITIES.  OF PARTICULAR INTEREST ARE THE ENTRIES
C                  IN V THAT LIMIT THE LENGTH OF THE FIRST STEP
C                  ATTEMPTED (LMAX0) AND SPECIFY CONVERGENCE TOLERANCES
C                  (AFCTOL, LMAXS, RFCTOL, SCTOL, XCTOL, XFTOL).
C LIV...... (INPUT) LENGTH OF IV ARRAY.  MUST BE AT LEAST 60.  IF LIV
C                  IS TOO SMALL, THEN SUMSL RETURNS WITH IV(1) = 15.
C                  IF LIV IS AT LEAST LASTIV (= 44), THEN THE MINIMUM
C                  ACCEPTABLE VALUE OF LIV IS STORED IN IV(LASTIV)
C                  WHEN SUMSL RETURNS.  (THIS IS INTENDED FOR USE
C                  WITH EXTENSIONS OF SUMSL THAT HANDLES CONSTRAINTS.)
C LV....... (INPUT) LENGTH OF V ARRAY.  MUST BE AT LEAST 71+N*(N+15)/2.
C                  (AT LEAST 77+N*(N+17)/2 FOR SMSNO, AT LEAST
C                  78+N*(N+12) FOR HUMSL).  IF LV IS TOO SMALL, THEN
C                  SUMSL RETURNS WITH IV(1) = 16.  IF LIV IS AT LEAST
C                  LASTV (= 45), THEN THE MINIMUM ACCEPTABLE VALUE OF
C                  LV IS STORED IN IV(LASTV) WHEN SUMSL RETURNS.
C UIPARM... (INPUT) USER INTEGER PARAMETER ARRAY PASSED WITHOUT CHANGE
C                  TO CALCF AND CALCG.
C URPARM... (INPUT) USER FLOATING-POINT PARAMETER ARRAY PASSED WITHOUT
C                  CHANGE TO CALCF AND CALCG.
C UFPARM... (INPUT) USER EXTERNAL SUBROUTINE OR FUNCTION PASSED WITHOUT
C                  CHANGE TO CALCF AND CALCG.
C
C  ***  IV INPUT VALUES (FROM SUBROUTINE DEFLT)  ***
C
C IV(1)...  ON INPUT, IV(1) SHOULD HAVE A VALUE BETWEEN 0 AND 14......
C             0 AND 12 MEAN THIS IS A FRESH START.  0 MEANS THAT
C                  DEFLT(2, IV, LIV, LV, V)
C             IS TO BE CALLED TO PROVIDE ALL DEFAULT VALUES TO IV AND
C             V.  12 (THE VALUE THAT DEFLT ASSIGNS TO IV(1)) MEANS THE
C             CALLER HAS ALREADY CALLED DEFLT AND HAS POSSIBLY CHANGED
C             SOME IV AND/OR V ENTRIES TO NON-DEFAULT VALUES.
C             13 MEANS DEFLT HAS BEEN CALLED AND THAT SUMSL (AND
C             SUMIT) SHOULD ONLY ALLOCATE STORAGE IN IV AND V.
C             14 MEANS THAT A STORAGE HAS BEEN ALLOCATED (E.G. BY A
C             CALL WITH IV(1) = 13) AND THAT THE ALGORITHM SHOULD BE
C             STARTED.  WHEN CALLED WITH IV(1) = 13, SUMSL RETURNS
C             IV(1) = 14 UNLESS LIV OR LV IS TOO SMALL (OR N IS NOT
C             POSITIVE).  DEFAULT = 12.
C IV(INITH).... IV(25) TELLS WHETHER THE HESSIAN APPROXIMATION H SHOULD
C             BE INITIALIZED.  1 (THE DEFAULT) MEANS SUMIT SHOULD
C             INITIALIZE H TO THE DIAGONAL MATRIX WHOSE I-TH DIAGONAL
C             ELEMENT IS D(I)**2.  0 MEANS THE CALLER HAS SUPPLIED A
C             CHOLESKY FACTOR  L  OF THE INITIAL HESSIAN APPROXIMATION
C             H = L*(L**T)  IN V, STARTING AT V(IV(LMAT)) = V(IV(42))
C             (AND STORED COMPACTLY BY ROWS).  NOTE THAT IV(LMAT) MAY
C             BE INITIALIZED BY CALLING SUMSL WITH IV(1) = 13 (SEE
C             THE IV(1) DISCUSSION ABOVE).  DEFAULT = 1.
C IV(MXFCAL)... IV(17) GIVES THE MAXIMUM NUMBER OF FUNCTION EVALUATIONS
C             (CALLS ON CALCF) ALLOWED.  IF THIS NUMBER DOES NOT SUF-
C             FICE, THEN SUMSL RETURNS WITH IV(1) = 9.  DEFAULT = 200.
C IV(MXITER)... IV(18) GIVES THE MAXIMUM NUMBER OF ITERATIONS ALLOWED.
C             IT ALSO INDIRECTLY LIMITS THE NUMBER OF GRADIENT EVALUA-
C             TIONS (CALLS ON CALCG) TO IV(MXITER) + 1.  IF IV(MXITER)
C             ITERATIONS DO NOT SUFFICE, THEN SUMSL RETURNS WITH
C             IV(1) = 10.  DEFAULT = 150.
C IV(OUTLEV)... IV(19) CONTROLS THE NUMBER AND LENGTH OF ITERATION SUM-
C             MARY LINES PRINTED (BY ITSUM).  IV(OUTLEV) = 0 MEANS DO
C             NOT PRINT ANY SUMMARY LINES.  OTHERWISE, PRINT A SUMMARY
C             LINE AFTER EACH ABS(IV(OUTLEV)) ITERATIONS.  IF IV(OUTLEV)
C             IS POSITIVE, THEN SUMMARY LINES OF LENGTH 78 (PLUS CARRI-
C             AGE CONTROL) ARE PRINTED, INCLUDING THE FOLLOWING...  THE
C             ITERATION AND FUNCTION EVALUATION COUNTS, F = THE CURRENT
C             FUNCTION VALUE, RELATIVE DIFFERENCE IN FUNCTION VALUES
C             ACHIEVED BY THE LATEST STEP (I.E., RELDF = (F0-V(F))/F01,
C             WHERE F01 IS THE MAXIMUM OF ABS(V(F)) AND ABS(V(F0)) AND
C             V(F0) IS THE FUNCTION VALUE FROM THE PREVIOUS ITERA-
C             TION), THE RELATIVE FUNCTION REDUCTION PREDICTED FOR THE
C             STEP JUST TAKEN (I.E., PRELDF = V(PREDUC) / F01, WHERE
C             V(PREDUC) IS DESCRIBED BELOW), THE SCALED RELATIVE CHANGE
C             IN X (SEE V(RELDX) BELOW), THE STEP PARAMETER FOR THE
C             STEP JUST TAKEN (STPPAR = 0 MEANS A FULL NEWTON STEP,
C             BETWEEN 0 AND 1 MEANS A RELAXED NEWTON STEP, BETWEEN 1
C             AND 2 MEANS A DOUBLE DOGLEG STEP, GREATER THAN 2 MEANS
C             A SCALED DOWN CAUCHY STEP -- SEE SUBROUTINE DBLDOG), THE
C             2-NORM OF THE SCALE VECTOR D TIMES THE STEP JUST TAKEN
C             (SEE V(DSTNRM) BELOW), AND NPRELDF, I.E.,
C             V(NREDUC)/F01, WHERE V(NREDUC) IS DESCRIBED BELOW -- IF
C             NPRELDF IS POSITIVE, THEN IT IS THE RELATIVE FUNCTION
C             REDUCTION PREDICTED FOR A NEWTON STEP (ONE WITH
C             STPPAR = 0).  IF NPRELDF IS NEGATIVE, THEN IT IS THE
C             NEGATIVE OF THE RELATIVE FUNCTION REDUCTION PREDICTED
C             FOR A STEP COMPUTED WITH STEP BOUND V(LMAXS) FOR USE IN
C             TESTING FOR SINGULAR CONVERGENCE.
C                  IF IV(OUTLEV) IS NEGATIVE, THEN LINES OF LENGTH 50
C             ARE PRINTED, INCLUDING ONLY THE FIRST 6 ITEMS LISTED
C             ABOVE (THROUGH RELDX).
C             DEFAULT = 1.
C IV(PARPRT)... IV(20) = 1 MEANS PRINT ANY NONDEFAULT V VALUES ON A
C             FRESH START OR ANY CHANGED V VALUES ON A RESTART.
C             IV(PARPRT) = 0 MEANS SKIP THIS PRINTING.  DEFAULT = 1.
C IV(PRUNIT)... IV(21) IS THE OUTPUT UNIT NUMBER ON WHICH ALL PRINTING
C             IS DONE.  IV(PRUNIT) = 0 MEANS SUPPRESS ALL PRINTING.
C             DEFAULT = STANDARD OUTPUT UNIT (UNIT 6 ON MOST SYSTEMS).
C IV(SOLPRT)... IV(22) = 1 MEANS PRINT OUT THE VALUE OF X RETURNED (AS
C             WELL AS THE GRADIENT AND THE SCALE VECTOR D).
C             IV(SOLPRT) = 0 MEANS SKIP THIS PRINTING.  DEFAULT = 1.
C IV(STATPR)... IV(23) = 1 MEANS PRINT SUMMARY STATISTICS UPON RETURN-
C             ING.  THESE CONSIST OF THE FUNCTION VALUE, THE SCALED
C             RELATIVE CHANGE IN X CAUSED BY THE MOST RECENT STEP (SEE
C             V(RELDX) BELOW), THE NUMBER OF FUNCTION AND GRADIENT
C             EVALUATIONS (CALLS ON CALCF AND CALCG), AND THE RELATIVE
C             FUNCTION REDUCTIONS PREDICTED FOR THE LAST STEP TAKEN AND
C             FOR A NEWTON STEP (OR PERHAPS A STEP BOUNDED BY V(LMAX0)
C             -- SEE THE DESCRIPTIONS OF PRELDF AND NPRELDF UNDER
C             IV(OUTLEV) ABOVE).
C             IV(STATPR) = 0 MEANS SKIP THIS PRINTING.
C             IV(STATPR) = -1 MEANS SKIP THIS PRINTING AS WELL AS THAT
C             OF THE ONE-LINE TERMINATION REASON MESSAGE.  DEFAULT = 1.
C IV(X0PRT).... IV(24) = 1 MEANS PRINT THE INITIAL X AND SCALE VECTOR D
C             (ON A FRESH START ONLY).  IV(X0PRT) = 0 MEANS SKIP THIS
C             PRINTING.  DEFAULT = 1.
C
C  ***  (SELECTED) IV OUTPUT VALUES  ***
C
C IV(1)........ ON OUTPUT, IV(1) IS A RETURN CODE....
C             3 = X-CONVERGENCE.  THE SCALED RELATIVE DIFFERENCE (SEE
C                  V(RELDX)) BETWEEN THE CURRENT PARAMETER VECTOR X AND
C                  A LOCALLY OPTIMAL PARAMETER VECTOR IS VERY LIKELY AT
C                  MOST V(XCTOL).
C             4 = RELATIVE FUNCTION CONVERGENCE.  THE RELATIVE DIFFER-
C                  ENCE BETWEEN THE CURRENT FUNCTION VALUE AND ITS LO-
C                  CALLY OPTIMAL VALUE IS VERY LIKELY AT MOST V(RFCTOL).
C             5 = BOTH X- AND RELATIVE FUNCTION CONVERGENCE (I.E., THE
C                  CONDITIONS FOR IV(1) = 3 AND IV(1) = 4 BOTH HOLD).
C             6 = ABSOLUTE FUNCTION CONVERGENCE.  THE CURRENT FUNCTION
C                  VALUE IS AT MOST V(AFCTOL) IN ABSOLUTE VALUE.
C             7 = SINGULAR CONVERGENCE.  THE HESSIAN NEAR THE CURRENT
C                  ITERATE APPEARS TO BE SINGULAR OR NEARLY SO, AND A
C                  STEP OF LENGTH AT MOST V(LMAX0) IS UNLIKELY TO YIELD
C                  A RELATIVE FUNCTION DECREASE OF MORE THAN V(SCTOL).
C             8 = FALSE CONVERGENCE.  THE ITERATES APPEAR TO BE CONVERG-
C                  ING TO A NONCRITICAL POINT.  THIS MAY MEAN THAT THE
C                  CONVERGENCE TOLERANCES (V(AFCTOL), V(RFCTOL),
C                  V(XCTOL)) ARE TOO SMALL FOR THE ACCURACY TO WHICH
C                  THE FUNCTION AND GRADIENT ARE BEING COMPUTED, THAT
C                  THERE IS AN ERROR IN COMPUTING THE GRADIENT, OR THAT
C                  THE FUNCTION OR GRADIENT IS DISCONTINUOUS NEAR X.
C             9 = FUNCTION EVALUATION LIMIT REACHED WITHOUT OTHER CON-
C                  VERGENCE (SEE IV(MXFCAL)).
C            10 = ITERATION LIMIT REACHED WITHOUT OTHER CONVERGENCE
C                  (SEE IV(MXITER)).
C            11 = STOPX RETURNED .TRUE. (EXTERNAL INTERRUPT).  SEE THE
C                  USAGE NOTES BELOW.
C            14 = STORAGE HAS BEEN ALLOCATED (AFTER A CALL WITH
C                  IV(1) = 13).
C            17 = RESTART ATTEMPTED WITH N CHANGED.
C            18 = D HAS A NEGATIVE COMPONENT AND IV(DTYPE) .LE. 0.
C            19...43 = V(IV(1)) IS OUT OF RANGE.
C            63 = F(X) CANNOT BE COMPUTED AT THE INITIAL X.
C            64 = BAD PARAMETERS PASSED TO ASSESS (WHICH SHOULD NOT
C                  OCCUR).
C            65 = THE GRADIENT COULD NOT BE COMPUTED AT X (SEE CALCG
C                  ABOVE).
C            67 = BAD FIRST PARAMETER TO DEFLT.
C            80 = IV(1) WAS OUT OF RANGE.
C            81 = N IS NOT POSITIVE.
C IV(G)........ IV(28) IS THE STARTING SUBSCRIPT IN V OF THE CURRENT
C             GRADIENT VECTOR (THE ONE CORRESPONDING TO X).
C IV(NFCALL)... IV(6) IS THE NUMBER OF CALLS SO FAR MADE ON CALCF (I.E.,
C             FUNCTION EVALUATIONS).
C IV(NGCALL)... IV(30) IS THE NUMBER OF GRADIENT EVALUATIONS (CALLS ON
C             CALCG).
C IV(NITER).... IV(31) IS THE NUMBER OF ITERATIONS PERFORMED.
C
C  ***  (SELECTED) V INPUT VALUES (FROM SUBROUTINE DEFLT)  ***
C
C V(BIAS)..... V(43) IS THE BIAS PARAMETER USED IN SUBROUTINE DBLDOG --
C             SEE THAT SUBROUTINE FOR DETAILS.  DEFAULT = 0.8.
C V(AFCTOL)... V(31) IS THE ABSOLUTE FUNCTION CONVERGENCE TOLERANCE.
C             IF SUMSL FINDS A POINT WHERE THE FUNCTION VALUE IS LESS
C             THAN V(AFCTOL) IN ABSOLUTE VALUE, AND IF SUMSL DOES NOT
C             RETURN WITH IV(1) = 3, 4, OR 5, THEN IT RETURNS WITH
C             IV(1) = 6.  DEFAULT = MAX(10**-20, MACHEP**2), WHERE
C             MACHEP IS THE UNIT ROUNDOFF.
C V(DINIT).... V(38), IF NONNEGATIVE, IS THE VALUE TO WHICH THE SCALE
C             VECTOR D IS INITIALIZED.  DEFAULT = -1.
C V(LMAX0).... V(35) GIVES THE MAXIMUM 2-NORM ALLOWED FOR D TIMES THE
C             VERY FIRST STEP THAT SUMSL ATTEMPTS.  THIS PARAMETER CAN
C             MARKEDLY AFFECT THE PERFORMANCE OF SUMSL.
C V(LMAXS).... V(36) IS USED IN TESTING FOR SINGULAR CONVERGENCE -- IF
C             THE FUNCTION REDUCTION PREDICTED FOR A STEP OF LENGTH
C             BOUNDED BY V(LMAXS) IS AT MOST V(SCTOL) * ABS(F0), WHERE
C             F0  IS THE FUNCTION VALUE AT THE START OF THE CURRENT
C             ITERATION, AND IF SUMSL DOES NOT RETURN WITH IV(1) = 3,
C             4, 5, OR 6, THEN IT RETURNS WITH IV(1) = 7.  DEFAULT = 1.
C V(RFCTOL)... V(32) IS THE RELATIVE FUNCTION CONVERGENCE TOLERANCE.
C             IF THE CURRENT MODEL PREDICTS A MAXIMUM POSSIBLE FUNCTION
C             REDUCTION (SEE V(NREDUC)) OF AT MOST V(RFCTOL)*ABS(F0)
C             AT THE START OF THE CURRENT ITERATION, WHERE  F0  IS THE
C             THEN CURRENT FUNCTION VALUE, AND IF THE LAST STEP ATTEMPT-
C             ED ACHIEVED NO MORE THAN TWICE THE PREDICTED FUNCTION
C             DECREASE, THEN SUMSL RETURNS WITH IV(1) = 4 (OR 5).
C             DEFAULT = MAX(10**-10, MACHEP**(2/3)), WHERE MACHEP IS
C             THE UNIT ROUNDOFF.
C V(SCTOL).... V(37) IS THE SINGULAR CONVERGENCE TOLERANCE -- SEE THE
C             DESCRIPTION OF V(LMAXS) ABOVE.
C V(TUNER1)... V(26) HELPS DECIDE WHEN TO CHECK FOR FALSE CONVERGENCE.
C             THIS IS DONE IF THE ACTUAL FUNCTION DECREASE FROM THE
C             CURRENT STEP IS NO MORE THAN V(TUNER1) TIMES ITS PREDICT-
C             ED VALUE.  DEFAULT = 0.1.
C V(XCTOL).... V(33) IS THE X-CONVERGENCE TOLERANCE.  IF A NEWTON STEP
C             (SEE V(NREDUC)) IS TRIED THAT HAS V(RELDX) .LE. V(XCTOL)
C             AND IF THIS STEP YIELDS AT MOST TWICE THE PREDICTED FUNC-
C             TION DECREASE, THEN SUMSL RETURNS WITH IV(1) = 3 (OR 5).
C             (SEE THE DESCRIPTION OF V(RELDX) BELOW.)
C             DEFAULT = MACHEP**0.5, WHERE MACHEP IS THE UNIT ROUNDOFF.
C V(XFTOL).... V(34) IS THE FALSE CONVERGENCE TOLERANCE.  IF A STEP IS
C             TRIED THAT GIVES NO MORE THAN V(TUNER1) TIMES THE PREDICT-
C             ED FUNCTION DECREASE AND THAT HAS V(RELDX) .LE. V(XFTOL),
C             AND IF SUMSL DOES NOT RETURN WITH IV(1) = 3, 4, 5, 6, OR
C             7, THEN IT RETURNS WITH IV(1) = 8.  (SEE THE DESCRIPTION
C             OF V(RELDX) BELOW.)  DEFAULT = 100*MACHEP, WHERE
C             MACHEP IS THE UNIT ROUNDOFF.
C V(*)........ DEFLT SUPPLIES TO V A NUMBER OF TUNING CONSTANTS, WITH
C             WHICH IT SHOULD ORDINARILY BE UNNECESSARY TO TINKER.  SEE
C             SECTION 17 OF VERSION 2.2 OF THE NL2SOL USAGE SUMMARY
C             (I.E., THE APPENDIX TO REF. 1) FOR DETAILS ON V(I),
C             I = DECFAC, INCFAC, PHMNFC, PHMXFC, RDFCMN, RDFCMX,
C             TUNER2, TUNER3, TUNER4, TUNER5.
C
C  ***  (SELECTED) V OUTPUT VALUES  ***
C
C V(DGNORM)... V(1) IS THE 2-NORM OF (DIAG(D)**-1)*G, WHERE G IS THE
C             MOST RECENTLY COMPUTED GRADIENT.
C V(DSTNRM)... V(2) IS THE 2-NORM OF DIAG(D)*STEP, WHERE STEP IS THE
C             CURRENT STEP.
C V(F)........ V(10) IS THE CURRENT FUNCTION VALUE.
C V(F0)....... V(13) IS THE FUNCTION VALUE AT THE START OF THE CURRENT
C             ITERATION.
C V(NREDUC)... V(6), IF POSITIVE, IS THE MAXIMUM FUNCTION REDUCTION
C             POSSIBLE ACCORDING TO THE CURRENT MODEL, I.E., THE FUNC-
C             TION REDUCTION PREDICTED FOR A NEWTON STEP (I.E.,
C             STEP = -H**-1 * G,  WHERE  G  IS THE CURRENT GRADIENT AND
C             H IS THE CURRENT HESSIAN APPROXIMATION).
C                  IF V(NREDUC) IS NEGATIVE, THEN IT IS THE NEGATIVE OF
C             THE FUNCTION REDUCTION PREDICTED FOR A STEP COMPUTED WITH
C             A STEP BOUND OF V(LMAXS) FOR USE IN TESTING FOR SINGULAR
C             CONVERGENCE.
C V(PREDUC)... V(7) IS THE FUNCTION REDUCTION PREDICTED (BY THE CURRENT
C             QUADRATIC MODEL) FOR THE CURRENT STEP.  THIS (DIVIDED BY
C             V(F0)) IS USED IN TESTING FOR RELATIVE FUNCTION
C             CONVERGENCE.
C V(RELDX).... V(17) IS THE SCALED RELATIVE CHANGE IN X CAUSED BY THE
C             CURRENT STEP, COMPUTED AS
C                  MAX(ABS(D(I)*(X(I)-X0(I)), 1 .LE. I .LE. P) /
C                     MAX(D(I)*(ABS(X(I))+ABS(X0(I))), 1 .LE. I .LE. P),
C             WHERE X = X0 + STEP.
C
C-------------------------------  NOTES  -------------------------------
C
C  ***  ALGORITHM NOTES  ***
C
C        THIS ROUTINE USES A HESSIAN APPROXIMATION COMPUTED FROM THE
C     BFGS UPDATE (SEE REF 3).  ONLY A CHOLESKY FACTOR OF THE HESSIAN
C     APPROXIMATION IS STORED, AND THIS IS UPDATED USING IDEAS FROM
C     REF. 4.  STEPS ARE COMPUTED BY THE DOUBLE DOGLEG SCHEME DESCRIBED
C     IN REF. 2.  THE STEPS ARE ASSESSED AS IN REF. 1.
C
C  ***  USAGE NOTES  ***
C
C        AFTER A RETURN WITH IV(1) .LE. 11, IT IS POSSIBLE TO RESTART,
C     I.E., TO CHANGE SOME OF THE IV AND V INPUT VALUES DESCRIBED ABOVE
C     AND CONTINUE THE ALGORITHM FROM THE POINT WHERE IT WAS INTERRUPT-
C     ED.  IV(1) SHOULD NOT BE CHANGED, NOR SHOULD ANY ENTRIES OF IV
C     AND V OTHER THAN THE INPUT VALUES (THOSE SUPPLIED BY DEFLT).
C        THOSE WHO DO NOT WISH TO WRITE A CALCG WHICH COMPUTES THE
C     GRADIENT ANALYTICALLY SHOULD CALL SMSNO RATHER THAN SUMSL.
C     SMSNO USES FINITE DIFFERENCES TO COMPUTE AN APPROXIMATE GRADIENT.
C        THOSE WHO WOULD PREFER TO PROVIDE F AND G (THE FUNCTION AND
C     GRADIENT) BY REVERSE COMMUNICATION RATHER THAN BY WRITING SUBROU-
C     TINES CALCF AND CALCG MAY CALL ON SUMIT DIRECTLY.  SEE THE COM-
C     MENTS AT THE BEGINNING OF SUMIT.
C        THOSE WHO USE SUMSL INTERACTIVELY MAY WISH TO SUPPLY THEIR
C     OWN STOPX FUNCTION, WHICH SHOULD RETURN .TRUE. IF THE BREAK KEY
C     HAS BEEN PRESSED SINCE STOPX WAS LAST INVOKED.  THIS MAKES IT
C     POSSIBLE TO EXTERNALLY INTERRUPT SUMSL (WHICH WILL RETURN WITH
C     IV(1) = 11 IF STOPX RETURNS .TRUE.).
C        STORAGE FOR G IS ALLOCATED AT THE END OF V.  THUS THE CALLER
C     MAY MAKE V LONGER THAN SPECIFIED ABOVE AND MAY ALLOW CALCG TO USE
C     ELEMENTS OF G BEYOND THE FIRST N AS SCRATCH STORAGE.
C
C  ***  PORTABILITY NOTES  ***
C
C        THE SUMSL DISTRIBUTION TAPE CONTAINS BOTH SINGLE- AND DOUBLE-
C     PRECISION VERSIONS OF THE SUMSL SOURCE CODE, SO IT SHOULD BE UN-
C     NECESSARY TO CHANGE PRECISIONS.
C        INTRINSIC FUNCTIONS ARE EXPLICITLY DECLARED.  ON CERTAIN COM-
C     PUTERS (E.G. UNIVAC), IT MAY BE NECESSARY TO COMMENT OUT THESE
C     DECLARATIONS.  SO THAT THIS MAY BE DONE AUTOMATICALLY BY A SIMPLE
C     PROGRAM, SUCH DECLARATIONS ARE PRECEDED BY A COMMENT HAVING C/+
C     IN COLUMNS 1-3 AND BLANKS IN COLUMNS 4-72 AND ARE FOLLOWED BY
C     A COMMENT HAVING C/ IN COLUMNS 1 AND 2 AND BLANKS IN COLUMNS 3-72.
C        THE SUMSL SOURCE CODE IS EXPRESSED IN 1966 ANSI STANDARD
C     FORTRAN.  IT MAY BE CONVERTED TO FORTRAN 77 BY COMMENTING OUT ALL
C     LINES THAT FALL BETWEEN A LINE HAVING C/6 IN COLUMNS 1-3 AND A
C     LINE HAVING C/7 IN COLUMNS 1-3 AND BY REMOVING (I.E., REPLACING
C     BY A BLANK) THE C IN COLUMN 1 OF THE LINES THAT FOLLOW THE C/7
C     LINE AND PRECEDE A LINE HAVING C/ IN COLUMNS 1-2 AND BLANKS IN
C     COLUMNS 3-72.  THESE CHANGES CONVERT SOME DATA STATEMENTS INTO
C     PARAMETER STATEMENTS, CONVERT SOME VARIABLES FROM REAL TO
C     CHARACTER*4, AND MAKE THE DATA STATEMENTS THAT INITIALIZE THESE
C     VARIABLES USE CHARACTER STRINGS DELIMITED BY PRIMES INSTEAD
C     OF HOLLERITH CONSTANTS.  (SUCH VARIABLES AND DATA STATEMENTS
C     APPEAR ONLY IN MODULES ITSUM AND PARCK.  PARAMETER STATEMENTS
C     APPEAR NEARLY EVERYWHERE.)
C
C  ***  REFERENCES  ***
C
C 1.  DENNIS, J.E., GAY, D.M., AND WELSCH, R.E. (1981), ALGORITHM 573 --
C             AN ADAPTIVE NONLINEAR LEAST-SQUARES ALGORITHM, ACM TRANS.
C             MATH. SOFTWARE 7, PP. 369-383.
C
C 2.  DENNIS, J.E., AND MEI, H.H.W. (1979), TWO NEW UNCONSTRAINED OPTI-
C             MIZATION ALGORITHMS WHICH USE FUNCTION AND GRADIENT
C             VALUES, J. OPTIM. THEORY APPLIC. 28, PP. 453-482.
C
C 3.  DENNIS, J.E., AND MORE, J.J. (1977), QUASI-NEWTON METHODS, MOTIVA-
C             TION AND THEORY, SIAM REV. 19, PP. 46-89.
C
C 4.  GOLDFARB, D. (1976), FACTORIZED VARIABLE METRIC METHODS FOR UNCON-
C             STRAINED OPTIMIZATION, MATH. COMPUT. 30, PP. 796-811.
C
C***REVISION HISTORY  (YYMMDD)
C   000330  Modified array declarations.  (JEC)
C
C  ***  GENERAL  ***
C
C     CODED BY DAVID M. GAY (WINTER 1980).  REVISED SUMMER 1982.
C     THIS SUBROUTINE WAS WRITTEN IN CONNECTION WITH RESEARCH
C     SUPPORTED IN PART BY THE NATIONAL SCIENCE FOUNDATION UNDER
C     GRANTS MCS-7600324, DCR75-10143, 76-14311DSS, MCS76-11989,
C     AND MCS-7906671.
C
C.
C----------------------------  DECLARATIONS  ---------------------------
C
      EXTERNAL DEFLT, SUMIT
C
C DEFLT.... SUPPLIES DEFAULT IV AND V INPUT COMPONENTS.
C SUMIT... REVERSE-COMMUNICATION ROUTINE THAT CARRIES OUT SUMSL ALGO-
C             RITHM.
C
      INTEGER G1, IV1, NF
      REAL F
C
C  ***  SUBSCRIPTS FOR IV   ***
C
      INTEGER NEXTV, NFCALL, NFGCAL, G, TOOBIG, VNEED
C
C/6
      DATA NEXTV/47/, NFCALL/6/, NFGCAL/7/, G/28/, TOOBIG/2/, VNEED/4/
C/7
C     PARAMETER (NEXTV=47, NFCALL=6, NFGCAL=7, G=28, TOOBIG=2, VNEED=4)
C/
C
C+++++++++++++++++++++++++++++++  BODY  ++++++++++++++++++++++++++++++++
C
      IF (IV(1) .EQ. 0) CALL DEFLT(2, IV, LIV, LV, V)
      IV(VNEED) = IV(VNEED) + N
      IV1 = IV(1)
      IF (IV1 .EQ. 14) GO TO 10
      IF (IV1 .GT. 2 .AND. IV1 .LT. 12) GO TO 10
      G1 = 1
      IF (IV1 .EQ. 12) IV(1) = 13
      GO TO 20
C
 10   G1 = IV(G)
C
 20   CALL SUMIT(D, F, V(G1), IV, LIV, LV, N, V, X)
      IF (IV(1) - 2) 30, 40, 50
C
 30   NF = IV(NFCALL)
      CALL CALCF(N, X, NF, F, UIPARM, URPARM, UFPARM)
      IF (NF .LE. 0) IV(TOOBIG) = 1
      GO TO 20
C
 40   CALL CALCG(N, X, IV(NFGCAL), V(G1), UIPARM, URPARM, UFPARM)
      GO TO 20
C
 50   IF (IV(1) .NE. 14) GO TO 999
C
C  ***  STORAGE ALLOCATION
C
      IV(G) = IV(NEXTV)
      IV(NEXTV) = IV(G) + N
      IF (IV1 .NE. 13) GO TO 10
C
 999  RETURN
C  ***  LAST CARD OF SUMSL FOLLOWS  ***
      END
