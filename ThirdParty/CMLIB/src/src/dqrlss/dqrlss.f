      SUBROUTINE DQRLSS(A,LDA,M,N,KR,B,X,RSD,JPVT,QRAUX)
C***BEGIN PROLOGUE  DQRLSS
C***REVISION NOVEMBER 15, 1980
C***REVISION HISTORY  (YYMMDD)
C   000330  Modified array declarations.  (JEC)
C
C***CATEGORY NO.  D9
C***KEYWORD(S)  OVERDETERMINED,LEAST SQUARES,LINEAR EQUATIONS
C***AUTHOR  D. KAHANER (NBS)
C***DATE WRITTEN
C***PURPOSE
C      SOLVES AN OVERDETERMINED, UNDERDETERMINED, OR SINGULAR SYSTEM OF
C      LINEAR EQUATIONS IN LEAST SQUARE SENSE.
C***DESCRIPTION
C
C     DQRLSS USES THE LINPACK SUBROUTINE DQRSL TO SOLVE AN OVERDETERMINE
C     UNDERDETERMINED, OR SINGULAR LINEAR SYSTEM IN A LEAST SQUARES
C     SENSE.  IT MUST BE PRECEEDED BY DQRANK .
C     THE SYSTEM IS  A*X  APPROXIMATES  B  WHERE  A  IS  M  BY  N  WITH
C     RANK  KR  (DETERMINED BY DQRANK),  B  IS A GIVEN  M-VECTOR,
C     AND  X  IS THE  N-VECTOR TO BE COMPUTED.  A SOLUTION  X  WITH
C     AT MOST  KR  NONZERO COMPONENTS IS FOUND WHICH MINIMIMZES
C     THE 2-NORM OF THE RESIDUAL,  A*X - B .
C
C     ON ENTRY
C
C        A,LDA,M,N,KR,JPVT,QRAUX
C              THE OUTPUT FROM DQRANK .
C
C        B     DOUBLE PRECISION(M) .
C              THE RIGHT HAND SIDE OF THE LINEAR SYSTEM.
C
C     ON RETURN
C
C        X     DOUBLE PRECISION(N) .
C              A LEAST SQUARES SOLUTION TO THE LINEAR SYSTEM.
C
C        RSD   DOUBLE PRECISION(M) .
C              THE RESIDUAL, B - A*X .  RSD MAY OVERWITE  B .
C
C      USAGE....
C        ONCE THE MATRIX A HAS BEEN FORMED, DQRANK SHOULD BE
C      CALLED ONCE TO DECOMPOSE IT.  THEN FOR EACH RIGHT HAND
C      SIDE, B, DQRLSS SHOULD BE CALLED ONCE TO OBTAIN THE
C      SOLUTION AND RESIDUAL.
C
C
C***REFERENCE(S)
C      DONGARRA, ET AL, LINPACK USERS GUIDE, SIAM, 1979
C***ROUTINES CALLED  DQRSL
C***END PROLOGUE
      INTEGER LDA,M,N,KR,JPVT(*)
      INTEGER J,K,INFO
      DOUBLE PRECISION T
      DOUBLE PRECISION A(LDA,*),B(*),X(*),RSD(*),QRAUX(*)
C***FIRST EXECUTABLE STATEMENT
      IF (KR .NE. 0)
     1   CALL DQRSL(A,LDA,M,KR,QRAUX,B,RSD,RSD,X,RSD,RSD,110,INFO)
      DO 40 J = 1, N
         JPVT(J) = -JPVT(J)
         IF (J .GT. KR) X(J) = 0.0
   40 CONTINUE
      DO 70 J = 1, N
         IF (JPVT(J) .GT. 0) GO TO 70
         K = -JPVT(J)
         JPVT(J) = K
   50    CONTINUE
            IF (K .EQ. J) GO TO 60
            T = X(J)
            X(J) = X(K)
            X(K) = T
            JPVT(K) = -JPVT(K)
            K = JPVT(K)
         GO TO 50
   60    CONTINUE
   70 CONTINUE
      RETURN
      END
