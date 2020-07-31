      DOUBLE PRECISION FUNCTION DCOSDG(X)
C***BEGIN PROLOGUE  DCOSDG
C***DATE WRITTEN   770601   (YYMMDD)
C***REVISION DATE  820801   (YYMMDD)
C***CATEGORY NO.  C4A
C***KEYWORDS  COSINE,DEGREE,DOUBLE PRECISION,ELEMENTARY FUNCTION,
C             TRIGONOMETRIC COSINE
C***AUTHOR  FULLERTON, W., (LANL)
C***PURPOSE  Computes the d.p. Cosine for degree arguments.
C***DESCRIPTION
C
C DCOSDG(X) calculates the double precision trigonometric cosine
C for double precision argument X in units of degrees.
C***REFERENCES  (NONE)
C***ROUTINES CALLED  (NONE)
C***END PROLOGUE  DCOSDG
      DOUBLE PRECISION X, RADDEG
      DATA RADDEG / 0.0174532925 1994329576 9236907684 886 D0 /
C***FIRST EXECUTABLE STATEMENT  DCOSDG
      DCOSDG = DCOS (RADDEG*X)
C
      IF (DMOD(X,90.D0).NE.0.D0) RETURN
      N = DABS(X)/90.D0 + 0.5D0
      N = MOD (N, 2)
      IF (N.EQ.0) DCOSDG = DSIGN (1.0D0, DCOSDG)
      IF (N.EQ.1) DCOSDG = 0.0D0
C
      RETURN
      END
