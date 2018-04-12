      SUBROUTINE XDPNRM(NU1,NU2,MU1,MU2,PQA,IPQA)
C***BEGIN PROLOGUE  XDPNRM
C***REFER TO  XDLEGF
C***ROUTINES CALLED  XDADJ
C***DATE WRITTEN   820728   (YYMMDD)
C***REVISION DATE  871119   (YYMMDD)
C***CATEGORY NO.  C3a2,C9
C***KEYWORDS  LEGENDRE FUNCTIONS
C***AUTHOR  SMITH, JOHN M. (NBS AND GEORGE MASON UNIVERSITY)
C***PURPOSE  TO COMPUTE THE VALUES OF LEGENDRE FUNCTIONS FOR XDLEGF.
C        SUBROUTINE XDPNRM TRANSFORMS AN ARRAY OF LEGENDRE
C        FUNCTIONS OF THE FIRST KIND OF NEGATIVE ORDER STORED
C        IN ARRAY PQA INTO NORMALIZED LEGENDRE POLYNOMIALS STORED
C        IN ARRAY PQA. THE ORIGINAL ARRAY IS DESTROYED.
C***REFERENCES  OLVER AND SMITH,J.COMPUT.PHYSICS,51(1983),N0.3,502-518.
C***END PROLOGUE  XDPNRM
      DOUBLE PRECISION C1,DMU,NU,NU1,NU2,PQA,PROD
      DIMENSION PQA(*),IPQA(*)
C***FIRST EXECUTABLE STATEMENT   XDPNRM
      L=(MU2-MU1)+(NU2-NU1+1.5D0)
      MU=MU1
      DMU=DBLE(FLOAT(MU1))
      NU=NU1
C
C         IF MU .GT.NU, NORM P =0.
C
      J=1
  500 IF(DMU.LE.NU) GO TO 505
      PQA(J)=0.
      IPQA(J)=0
      J=J+1
      IF(J.GT.L) RETURN
C
C        INCREMENT EITHER MU OR NU AS APPROPRIATE.
C
      IF(MU2.GT.MU1) DMU=DMU+1.D0
      IF(NU2-NU1.GT..5D0) NU=NU+1.D0
      GO TO 500
C
C         TRANSFORM P(-MU,NU,X) INTO NORMALIZED P(MU,NU,X) USING
C              NORM P(MU,NU,X)=
C                 SQRT((NU+.5)*FACTORIAL(NU+MU)/FACTORIAL(NU-MU))
C                              *P(-MU,NU,X)
C
  505 PROD=1.D0
      IPROD=0
      K=2*MU
      IF(K.LE.0) GO TO 520
      DO 510 I=1,K
      PROD=PROD*DSQRT(NU+DMU+1.D0-DBLE(FLOAT(I)))
  510 CALL XDADJ(PROD,IPROD)
  520 DO 540 I=J,L
      C1=PROD*DSQRT(NU+.5D0)
      PQA(I)=PQA(I)*C1
      IPQA(I)=IPQA(I)+IPROD
      CALL XDADJ(PQA(I),IPQA(I))
      IF(NU2-NU1.GT..5D0) GO TO 530
      IF(DMU.GE.NU) GO TO 525
      PROD=DSQRT(NU+DMU+1.D0)*PROD
      IF(NU.GT.DMU) PROD=PROD*DSQRT(NU-DMU)
      CALL XDADJ(PROD,IPROD)
      MU=MU+1
      DMU=DMU+1.D0
      GO TO 540
  525 PROD=0.
      IPROD=0
      MU=MU+1
      DMU=DMU+1.D0
      GO TO 540
  530 PROD=DSQRT(NU+DMU+1.D0)*PROD
      IF(NU.NE.DMU-1.D0) PROD=PROD/DSQRT(NU-DMU+1.D0)
      CALL XDADJ(PROD,IPROD)
      NU=NU+1.D0
  540 CONTINUE
      RETURN
      END
