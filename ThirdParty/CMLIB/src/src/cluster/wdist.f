      REAL FUNCTION WDIST(MM, N, A, DMWT, WT, CASE1, CASE2)
C
C<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
C
C   PURPOSE
C   -------
C
C      COMPUTES A WEIGHTED EUCLIDEAN DISTANCE BETWEEN TWO CASES
C
C   DESCRIPTION
C   -----------
C
C   1.  THE WEIGHTED DIFFERENCES OF THE NON-MISSING VALUES FOR EACH
C       CASE FOR EVERY PAIR OF VARIABLES ARE ACCUMULATED.  THEN THE
C       SQUARE ROOT OF THE SUM AFTER THE TOTAL WEIGHT HAS BEEN DIVIDED
C       OUT IS RETURNED BY THE FUNCTION.  MISSING VALUES ARE DENOTED BY
C       99999.
C
C   INPUT PARAMETERS
C   ----------------
C
C   MM    INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE FIRST DIMENSION OF THE MATRIX A.
C
C   N     INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE NUMBER OF VARIABLES.
C
C   A     REAL MATRIX WHOSE FIRST DIMENSION MUST BE MM AND WHOSE SECOND
C            DIMENSION MUST BE AT LEAST N. (UNCHANGED ON OUTPUT).
C         THE MATRIX OF DATA VALUES.
C
C         A(I,J) IS THE VALUE FOR THE J-TH VARIABLE FOR THE I-TH CASE.
C
C   DMWT  INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE FIRST DIMENSION OF THE MATRIX WT.  MUST BE AT LEAST N.
C
C   WT    REAL MATRIX WHOSE FIRST DIMENSION MUST BE DMWT AND WHOSE
C            SECOND DIMENSION MUST BE AT LEAST N. (UNCHANGED ON OUTPUT).
C         THE MATRIX OF WEIGHTS TO BE USED IN THE DISTANCE CALCULATIONS.
C
C   CASE1,
C   CASE2 INTEGER SCALARS (UNCHANGED ON OUTPUT).
C         THE NUMBERS OF THE TWO CASES.
C
C   OUTPUT PARAMETERS
C   -----------------
C
C   WDIST  REAL SCALAR.
C          THE MAHALANOBIS DISTANCE BETWEEN CASE1 AND CASE2.
C
C   REFERENCES
C   ----------
C
C     HARTIGAN, J. A. (1975).  CLUSTERING ALGORITHMS, JOHN WILEY &
C        SONS, INC., NEW YORK.  PAGES 69, 71.
C
C     MAHALANOBIS, P. C. (1936). "ON THE GENERALIZED DISTANCE IN
C        STATISTICS."  PROC. OF THE INDIAN NAT. INST. SCI. (CALCUTTA),
C        VOL. 2, PAGES 49-55.
C
C<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
C
      INTEGER DMWT, CASE1, CASE2
      DIMENSION WT(DMWT,*), A(MM,*)
C
      WDIST=0.
      DP=0.
      XM=99999.
      DO 10 I=1,N
         DO 10 J=1,N
            IF(A(CASE1,I) .NE. XM .AND. A(CASE1,J) .NE. XM .AND.
     *         A(CASE2,I) .NE. XM .AND. A(CASE2,J) .NE. XM) THEN
               WDIST=WDIST+(A(CASE1,I)-A(CASE2,I)) *
     *                     (A(CASE1,J)-A(CASE2,J)) * WT(I,J)
               DP=DP+WT(I,J)
            ENDIF
   10 CONTINUE
      IF(DP.NE.0.) WDIST=SQRT(WDIST/DP)
      RETURN
      END
