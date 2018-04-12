      SUBROUTINE PFISH(M, X, K, NSG, SG, NMG, MG, OUNIT)
C
C<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
C
C   PURPOSE
C   -------
C
C      PRINTS RESULTS FROM FISHER ALGORITHM
C
C   DESCRIPTION
C   -----------
C
C   1.  THE ARRAYS SG AND MG STORE THE OPTIMAL PARTITIONS FOR ALL VALUES
C       LESS THAN K AND WILL ALSO BE PRINTED.
C
C   INPUT PARAMETERS
C   ----------------
C
C   M     INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE NUMBER OF CASES.
C
C   X     REAL VECTOR DIMENSIONED AT LEAST M (UNCHANGED ON OUTPUT)
C         VECTOR CONTAINING THE OBSERVATIONS.
C
C   K     INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE NUMBER OF CLUSTER SUBSEQUENCES REQUESTED.
C
C   NSG   INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE LEADING DIMENSION OF THE MATRIX SG.
C
C   SG    REAL MATRIX WHOSE FIRST DIMENSION MUST BE NSG AND SECOND
C            DIMENSION MUST BE AT LEAST K (UNCHANGED ON OUTPUT).
C
C         SG(I,J) IS THE SUM OF THE WITHIN-GROUP SUM OF SQUARES
C           FOR X(1), ..., X(I) SPLIT OPTIMALLY INTO J GROUPS
C
C   NMG   INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         THE LEADING DIMENSION OF THE MATRIX MG.
C
C   MG    REAL MATRIX WHOSE FIRST DIMENSION MUST BE NMG AND SECOND
C            DIMENSION MUST BE AT LEAST K (UNCHANGED ON OUTPUT).
C
C         MG(I,J) IS THE LOWER BOUNDARY OF THE J-TH GROUP IN THE
C          OPTIMAL PARTITION OF X(1), ..., X(I) INTO J GROUPS
C
C   OUNIT INTEGER SCALAR (UNCHANGED ON OUTPUT).
C         UNIT NUMBER FOR OUTPUT.
C
C   REFERENCES
C   ----------
C
C     FISHER, W. D. (1958).  "ON GROUPING FOR MAXIMAL HOMOGENEITY,"
C     JOURNAL OF THE AMERICAN STATISTICAL ASSOCIATION 53, 789-798.
C
C     HARTIGAN, J. A. (1975).  CLUSTERING ALGORITHMS, JOHN WILEY &
C        SONS, INC., NEW YORK.  PAGE 142.
C
C<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
C
      DIMENSION SG(NSG,*), MG(NMG,*), X(*)
      INTEGER OUNIT
C
      WRITE(OUNIT,1) M,K
    1 FORMAT('1 PARTITION OF',I5,'  OBSERVATIONS UP TO ',I5,' CLUSTERS')
C
      DO 30 J=1,K
         JJ=K-J+1
         WRITE(OUNIT,2)JJ,SG(M,JJ)
    2    FORMAT('0THE',I5,'  PARTITION WITH SUM OF SQUARES',F20.6)
         WRITE(OUNIT,3)
    3    FORMAT(' CLUSTER   NUMBER OBS   MEAN      S.D.   ')
         IL=M+1
         DO 20 L=1,JJ
            LL=JJ-L+1
            S=0.
            SS=0.
            IU=IL-1
            IL=MG(IU,LL)
            DO 10 II=IL,IU
               S=S+X(II)
   10          SS=SS+X(II)**2
            SN=IU-IL+1
            S=S/SN
            SS=SS/SN-S**2
            SS=SQRT(ABS(SS))
            WRITE(OUNIT,4) LL,SN,S,SS
    4       FORMAT(I5,5X,3F10.4)
   20    CONTINUE
   30 CONTINUE
      RETURN
      END
