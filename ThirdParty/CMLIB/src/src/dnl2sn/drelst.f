      DOUBLE PRECISION FUNCTION DRELST(P, D, X, X0)
C
C  ***  COMPUTE AND RETURN RELATIVE DIFFERENCE BETWEEN X AND X0  ***
C  ***  NL2SOL VERSION 2.2  ***
C
      INTEGER P
      DOUBLE PRECISION D(P), X(P), X0(P)
C/+
      DOUBLE PRECISION DABS
C/
      INTEGER I
      DOUBLE PRECISION EMAX, T, XMAX, ZERO
C/6
      DATA ZERO/0.D+0/
C/7
C     PARAMETER (ZERO=0.D+0)
C/
C
      EMAX = ZERO
      XMAX = ZERO
      DO 10 I = 1, P
         T = DABS(D(I) * (X(I) - X0(I)))
         IF (EMAX .LT. T) EMAX = T
         T = D(I) * (DABS(X(I)) + DABS(X0(I)))
         IF (XMAX .LT. T) XMAX = T
 10      CONTINUE
      DRELST = ZERO
      IF (XMAX .GT. ZERO) DRELST = EMAX / XMAX
 999  RETURN
C  ***  LAST CARD OF DRELST FOLLOWS  ***
      END
