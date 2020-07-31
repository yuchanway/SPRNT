      SUBROUTINE SGRAD2 (ALPHA, D, ETA0, FX, G, IRC, N, W, X)
C
C  ***  COMPUTE FINITE DIFFERENCE GRADIENT BY STWEART*S SCHEME  ***
C
C     ***  PARAMETERS  ***
C
      INTEGER IRC, N
      REAL ALPHA(N), D(N), ETA0, FX, G(N), W(6), X(N)
C
C.......................................................................
C
C     ***  PURPOSE  ***
C
C        THIS SUBROUTINE USES AN EMBELLISHED FORM OF THE FINITE-DIFFER-
C     ENCE SCHEME PROPOSED BY STEWART (REF. 1) TO APPROXIMATE THE
C     GRADIENT OF THE FUNCTION F(X), WHOSE VALUES ARE SUPPLIED BY
C     REVERSE COMMUNICATION.
C
C     ***  PARAMETER DESCRIPTION  ***
C
C  ALPHA IN  (APPROXIMATE) DIAGONAL ELEMENTS OF THE HESSIAN OF F(X).
C      D IN  SCALE VECTOR SUCH THAT D(I)*X(I), I = 1,...,N, ARE IN
C             COMPARABLE UNITS.
C   ETA0 IN  ESTIMATED BOUND ON RELATIVE ERROR IN THE FUNCTION VALUE...
C             (TRUE VALUE) = (COMPUTED VALUE)*(1+E),   WHERE
C             ABS(E) .LE. ETA0.
C     FX I/O ON INPUT,  FX  MUST BE THE COMPUTED VALUE OF F(X).  ON
C             OUTPUT WITH IRC = 0, FX HAS BEEN RESTORED TO ITS ORIGINAL
C             VALUE, THE ONE IT HAD WHEN SGRAD2 WAS LAST CALLED WITH
C             IRC = 0.
C      G I/O ON INPUT WITH IRC = 0, G SHOULD CONTAIN AN APPROXIMATION
C             TO THE GRADIENT OF F NEAR X, E.G., THE GRADIENT AT THE
C             PREVIOUS ITERATE.  WHEN SGRAD2 RETURNS WITH IRC = 0, G IS
C             THE DESIRED FINITE-DIFFERENCE APPROXIMATION TO THE
C             GRADIENT AT X.
C    IRC I/O INPUT/RETURN CODE... BEFORE THE VERY FIRST CALL ON SGRAD2,
C             THE CALLER MUST SET IRC TO 0.  WHENEVER SGRAD2 RETURNS A
C             NONZERO VALUE FOR IRC, IT HAS PERTURBED SOME COMPONENT OF
C             X... THE CALLER SHOULD EVALUATE F(X) AND CALL SGRAD2
C             AGAIN WITH FX = F(X).
C      N IN  THE NUMBER OF VARIABLES (COMPONENTS OF X) ON WHICH F
C             DEPENDS.
C      X I/O ON INPUT WITH IRC = 0, X IS THE POINT AT WHICH THE
C             GRADIENT OF F IS DESIRED.  ON OUTPUT WITH IRC NONZERO, X
C             IS THE POINT AT WHICH F SHOULD BE EVALUATED.  ON OUTPUT
C             WITH IRC = 0, X HAS BEEN RESTORED TO ITS ORIGINAL VALUE
C             (THE ONE IT HAD WHEN SGRAD2 WAS LAST CALLED WITH IRC = 0)
C             AND G CONTAINS THE DESIRED GRADIENT APPROXIMATION.
C      W I/O WORK VECTOR OF LENGTH 6 IN WHICH SGRAD2 SAVES CERTAIN
C             QUANTITIES WHILE THE CALLER IS EVALUATING F(X) AT A
C             PERTURBED X.
C
C     ***  APPLICATION AND USAGE RESTRICTIONS  ***
C
C        THIS ROUTINE IS INTENDED FOR USE WITH QUASI-NEWTON ROUTINES
C     FOR UNCONSTRAINED MINIMIZATION (IN WHICH CASE  ALPHA  COMES FROM
C     THE DIAGONAL OF THE QUASI-NEWTON HESSIAN APPROXIMATION).
C
C     ***  ALGORITHM NOTES  ***
C
C        THIS CODE DEPARTS FROM THE SCHEME PROPOSED BY STEWART (REF. 1)
C     IN ITS GUARDING AGAINST OVERLY LARGE OR SMALL STEP SIZES AND ITS
C     HANDLING OF SPECIAL CASES (SUCH AS ZERO COMPONENTS OF ALPHA OR G).
C
C     ***  REFERENCES  ***
C
C 1. STEWART, G.W. (1967), A MODIFICATION OF DAVIDON*S MINIMIZATION
C        METHOD TO ACCEPT DIFFERENCE APPROXIMATIONS OF DERIVATIVES,
C        J. ASSOC. COMPUT. MACH. 14, PP. 72-83.
C
C     ***  HISTORY  ***
C
C     DESIGNED AND CODED BY DAVID M. GAY (SUMMER 1977/SUMMER 1980).
C
C     ***  GENERAL  ***
C
C        THIS ROUTINE WAS PREPARED IN CONNECTION WITH WORK SUPPORTED BY
C     THE NATIONAL SCIENCE FOUNDATION UNDER GRANTS MCS76-00324 AND
C     MCS-7906671.
C
C.......................................................................
C
C     *****  EXTERNAL FUNCTION  *****
C
C
C     ***** INTRINSIC FUNCTIONS *****
C/+
      INTEGER IABS
      REAL  ABS, AMAX1,  SQRT
C/
C     ***** LOCAL VARIABLES *****
C
      INTEGER FH, FX0, HSAVE, I, XISAVE
      REAL AAI, AFX, AFXETA, AGI, ALPHAI, AXI, AXIBAR,
     1                 DISCON, ETA, GI, H, HMIN
      REAL C2000, FOUR, HMAX0, HMIN0, H0, MACHEP, ONE, P002,
     1                 THREE, TWO, ZERO
C
C/6
      DATA C2000/2.0E+3/, FOUR/4.0E+0/, HMAX0/0.02E+0/, HMIN0/5.0E+1/,
     1     ONE/1.0E+0/, P002/0.002E+0/, THREE/3.0E+0/,
     2     TWO/2.0E+0/, ZERO/0.0E+0/
C/7
C     PARAMETER (C2000=2.0E+3, FOUR=4.0E+0, HMAX0=0.02E+0, HMIN0=5.0E+1,
C    1     ONE=1.0E+0, P002=0.002E+0, THREE=3.0E+0,
C    2     TWO=2.0E+0, ZERO=0.0E+0)
C/
C/6
      DATA FH/3/, FX0/4/, HSAVE/5/, XISAVE/6/
C/7
C     PARAMETER (FH=3, FX0=4, HSAVE=5, XISAVE=6)
C/
C
C---------------------------------  BODY  ------------------------------
C
      IF (IRC) 140, 100, 210
C
C     ***  FRESH START -- GET MACHINE-DEPENDENT CONSTANTS  ***
C
C     STORE MACHEP IN W(1) AND H0 IN W(2), WHERE MACHEP IS THE UNIT
C     ROUNDOFF (THE SMALLEST POSITIVE NUMBER SUCH THAT
C     1 + MACHEP .GT. 1  AND  1 - MACHEP .LT. 1),  AND  H0 IS THE
C     SQUARE-ROOT OF MACHEP.
C
 100  W(1) = R1MACH(4)
      W(2) =  SQRT(W(1))
C
      W(FX0) = FX
C
C     ***  INCREMENT  I  AND START COMPUTING  G(I)  ***
C
 110  I = IABS(IRC) + 1
      IF (I .GT. N) GO TO 300
         IRC = I
         AFX =  ABS(W(FX0))
         MACHEP = W(1)
         H0 = W(2)
         HMIN = HMIN0 * MACHEP
         W(XISAVE) = X(I)
         AXI =  ABS(X(I))
         AXIBAR = AMAX1(AXI, ONE/D(I))
         GI = G(I)
         AGI =  ABS(GI)
         ETA =  ABS(ETA0)
         IF (AFX .GT. ZERO) ETA = AMAX1(ETA, AGI*AXI*MACHEP/AFX)
         ALPHAI = ALPHA(I)
         IF (ALPHAI .EQ. ZERO) GO TO 170
         IF (GI .EQ. ZERO .OR. FX .EQ. ZERO) GO TO 180
         AFXETA = AFX*ETA
         AAI =  ABS(ALPHAI)
C
C        *** COMPUTE H = STEWART*S FORWARD-DIFFERENCE STEP SIZE.
C
         IF (GI**2 .LE. AFXETA*AAI) GO TO 120
              H = TWO* SQRT(AFXETA/AAI)
              H = H*(ONE - AAI*H/(THREE*AAI*H + FOUR*AGI))
              GO TO 130
 120     H = TWO*(AFXETA*AGI/(AAI**2))**(ONE/THREE)
         H = H*(ONE - TWO*AGI/(THREE*AAI*H + FOUR*AGI))
C
C        ***  ENSURE THAT  H  IS NOT INSIGNIFICANTLY SMALL  ***
C
 130     H = AMAX1(H, HMIN*AXIBAR)
C
C        *** USE FORWARD DIFFERENCE IF BOUND ON TRUNCATION ERROR IS AT
C        *** MOST 10**-3.
C
         IF (AAI*H .LE. P002*AGI) GO TO 160
C
C        *** COMPUTE H = STEWART*S STEP FOR CENTRAL DIFFERENCE.
C
         DISCON = C2000*AFXETA
         H = DISCON/(AGI +  SQRT(GI**2 + AAI*DISCON))
C
C        ***  ENSURE THAT  H  IS NEITHER TOO SMALL NOR TOO BIG  ***
C
         H = AMAX1(H, HMIN*AXIBAR)
         IF (H .GE. HMAX0*AXIBAR) H = AXIBAR * H0**(TWO/THREE)
C
C        ***  COMPUTE CENTRAL DIFFERENCE  ***
C
         IRC = -I
         GO TO 200
C
 140     H = -W(HSAVE)
         I = IABS(IRC)
         IF (H .GT. ZERO) GO TO 150
         W(FH) = FX
         GO TO 200
C
 150     G(I) = (W(FH) - FX) / (TWO * H)
         X(I) = W(XISAVE)
         GO TO 110
C
C     ***  COMPUTE FORWARD DIFFERENCES IN VARIOUS CASES  ***
C
 160     IF (H .GE. HMAX0*AXIBAR) H = H0 * AXIBAR
         IF (ALPHAI*GI .LT. ZERO) H = -H
         GO TO 200
 170     H = AXIBAR
         GO TO 200
 180     H = H0 * AXIBAR
C
 200     X(I) = W(XISAVE) + H
         W(HSAVE) = H
         GO TO 999
C
C     ***  COMPUTE ACTUAL FORWARD DIFFERENCE  ***
C
 210     G(IRC) = (FX - W(FX0)) / W(HSAVE)
         X(IRC) = W(XISAVE)
         GO TO 110
C
C  ***  RESTORE FX AND INDICATE THAT G HAS BEEN COMPUTED  ***
C
 300  FX = W(FX0)
      IRC = 0
C
 999  RETURN
C  ***  LAST CARD OF SGRAD2 FOLLOWS  ***
      END
