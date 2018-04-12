      SUBROUTINE FSTOFD(NR,M,N,XPLS,FCN,FPLS,A,SX,RNOISE,FHAT,ICASE)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C PURPOSE
C -------
C FIND FIRST ORDER FORWARD FINITE DIFFERENCE APPROXIMATION "A" TO THE
C FIRST DERIVATIVE OF THE FUNCTION DEFINED BY THE SUBPROGRAM "FNAME"
C EVALUATED AT THE NEW ITERATE "XPLS".
C
C
C FOR OPTIMIZATION USE THIS ROUTINE TO ESTIMATE:
C 1) THE FIRST DERIVATIVE (GRADIENT) OF THE OPTIMIZATION FUNCTION "FCN
C    ANALYTIC USER ROUTINE HAS BEEN SUPPLIED;
C 2) THE SECOND DERIVATIVE (HESSIAN) OF THE OPTIMIZATION FUNCTION
C    IF NO ANALYTIC USER ROUTINE HAS BEEN SUPPLIED FOR THE HESSIAN BUT
C    ONE HAS BEEN SUPPLIED FOR THE GRADIENT ("FCN") AND IF THE
C    OPTIMIZATION FUNCTION IS INEXPENSIVE TO EVALUATE
C
C NOTE
C ----
C _M=1 (OPTIMIZATION) ALGORITHM ESTIMATES THE GRADIENT OF THE FUNCTION
C      (FCN).   FCN(X) # F: R(N)-->R(1)
C _M=N (SYSTEMS) ALGORITHM ESTIMATES THE JACOBIAN OF THE FUNCTION
C      FCN(X) # F: R(N)-->R(N).
C _M=N (OPTIMIZATION) ALGORITHM ESTIMATES THE HESSIAN OF THE OPTIMIZATIO
C      FUNCTION, WHERE THE HESSIAN IS THE FIRST DERIVATIVE OF "FCN"
C
C PARAMETERS
C ----------
C NR           --> ROW DIMENSION OF MATRIX
C M            --> NUMBER OF ROWS IN A
C N            --> NUMBER OF COLUMNS IN A; DIMENSION OF PROBLEM
C XPLS(N)      --> NEW ITERATE:  X[K]
C FCN          --> NAME OF SUBROUTINE TO EVALUATE FUNCTION
C FPLS(M)      --> _M=1 (OPTIMIZATION) FUNCTION VALUE AT NEW ITERATE:
C                       FCN(XPLS)
C                  _M=N (OPTIMIZATION) VALUE OF FIRST DERIVATIVE
C                       (GRADIENT) GIVEN BY USER FUNCTION FCN
C                  _M=N (SYSTEMS)  FUNCTION VALUE OF ASSOCIATED
C                       MINIMIZATION FUNCTION
C A(NR,N)     <--  FINITE DIFFERENCE APPROXIMATION (SEE NOTE).  ONLY
C                  LOWER TRIANGULAR MATRIX AND DIAGONAL ARE RETURNED
C SX(N)        --> DIAGONAL SCALING MATRIX FOR X
C RNOISE       --> RELATIVE NOISE IN FCN [F(X)]
C FHAT(M)      --> WORKSPACE
C ICASE        --> =1 OPTIMIZATION (GRADIENT)
C                  =2 SYSTEMS
C                  =3 OPTIMIZATION (HESSIAN)
C
C***REVISION HISTORY  (YYMMDD)
C   000330  Modified array declarations.  (JEC)
C
C INTERNAL VARIABLES
C ------------------
C STEPSZ - STEPSIZE IN THE J-TH VARIABLE DIRECTION
C
      DIMENSION XPLS(N),FPLS(M)
      DIMENSION FHAT(M)
      DIMENSION SX(N)
      DIMENSION A(NR,*)
C
C FIND J-TH COLUMN OF A
C EACH COLUMN IS DERIVATIVE OF F(FCN) WITH RESPECT TO XPLS(J)
C
      DO 30 J=1,N
        STEPSZ=SQRT(RNOISE)*MAX(ABS(XPLS(J)),1./SX(J))
        XTMPJ=XPLS(J)
        XPLS(J)=XTMPJ+STEPSZ
        CALL FCN(N,XPLS,FHAT)
        XPLS(J)=XTMPJ
        DO 20 I=1,M
          A(I,J)=(FHAT(I)-FPLS(I))/STEPSZ
   20   CONTINUE
   30 CONTINUE
      IF(ICASE.NE.3) RETURN
C
C IF COMPUTING HESSIAN, A MUST BE SYMMETRIC
C
      IF(N.EQ.1) RETURN
      NM1=N-1
      DO 50 J=1,NM1
        JP1=J+1
        DO 40 I=JP1,M
          A(I,J)=(A(I,J)+A(J,I))/2.0
   40   CONTINUE
   50 CONTINUE
      RETURN
      END
