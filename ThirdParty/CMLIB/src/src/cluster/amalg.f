      SUBROUTINE AMALG(M, X, Y, N)
C
C<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
C
C   PURPOSE
C   -------
C
C      AMALGAMATES TWO OBJECTS
C
C   DESCRIPTION
C   -----------
C
C   1.  THE PARAMETERS X AND Y ARE ASSUMED TO BE EITHER A VECTOR OR A
C       STARTING LOCATION IN A MATRIX.  IF THEY ARE VECTORS OR THE
C       AMALGAMATION OF TWO COLUMNS OF A MATRIX ARE REQUIRED, SET N=1.
C       IF THE AMALGAMATION OF TWO ROWS OF A MATRIX ARE REQUIRED, SET N
C       EQUAL TO THE LEADING DIMENSION OF THE MATRIX AS DECLARED IN THE
C       MAIN PROGRAM.
C
C   2.  BOTH OBJECTS WILL BE SET TO THE ARITHMETIC MEAN OF THE
C       CORRESPONDING ELEMENTS OF BOTH OBJECTS.
C
C   INPUT PARAMETERS
C   ----------------
C
C   M     INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE NUMBER OF ELEMENTS.
C
C   X     REAL VECTOR DIMENSIONED AT LEAST M*N (CHANGED ON OUTPUT).
C         THE STARTING LOCATION OF THE FIRST VECTOR OF ELEMENTS.
C
C   Y     REAL VECTOR DIMENSIONED AT LEAST M*N (CHANGED ON OUTPUT).
C         THE STARTING LOCATION OF THE SECOND VECTOR OF ELEMENTS.
C
C   N     INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE SKIP FACTOR BETWEEN DESIRED ELEMENTS.
C
C         IF THE DISTANCE BETWEEN COLUMNS OF A MATRIX IS DESIRED,
C            SET N = 1.
C         IF THE DISTANCE BETWEEN ROWS OF A MATRIX IS DESIRED,
C            SET N = DIM, WHERE DIM IS THE LEADING DIMENSION OF THE
C            ARRAY THE ELEMENTS X AND Y COME FROM.
C
C   OUTPUT PARAMETERS
C   -----------------
C
C      X AND Y HOLD THE AMALGAMATED VECTORS.
C
C   REFERENCE
C   ---------
C
C     HARTIGAN, J. A. (1975).  CLUSTERING ALGORITHMS, JOHN WILEY &
C        SONS, INC., NEW YORK.  PAGE 232.
C
C<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
C
      DIMENSION X(*), Y(*)
C
      DO 10 I=1,M
         II = (I-1) * N + 1
         X(II)=(X(II)+Y(II))/2.
   10    Y(II)=X(II)
      RETURN
      END
