      DOUBLE PRECISION FUNCTION DQWGTF(X,OMEGA,P2,P3,P4,INTEGR)
C***BEGIN PROLOGUE  DQWGTF
C***REFER TO  DQK15W
C***ROUTINES CALLED  (NONE)
C***REVISION DATE  830518   (YYMMDD)
C***REVISION HISTORY (YYMMDD)
C   000601   Changed DSIN/DCOS to generic SIN/COS
C***KEYWORDS  COS OR SIN IN WEIGHT FUNCTION
C***AUTHOR  PIESSENS, ROBERT, APPLIED MATH. AND PROGR. DIV. -
C             K. U. LEUVEN
C           DE DONCKER, ELISE, APPLIED MATH. AND PROGR. DIV. -
C             K. U. LEUVEN
C***PURPOSE  This function subprogram is used together with the
C            routine DQAWF and defines the WEIGHT function.
C***END PROLOGUE  DQWGTF
C
      DOUBLE PRECISION OMEGA,OMX,P2,P3,P4,X
      INTEGER INTEGR
C***FIRST EXECUTABLE STATEMENT  DQWGTF
      OMX = OMEGA*X
      GO TO(10,20),INTEGR
   10 DQWGTF = COS(OMX)
      GO TO 30
   20 DQWGTF = SIN(OMX)
   30 RETURN
      END
