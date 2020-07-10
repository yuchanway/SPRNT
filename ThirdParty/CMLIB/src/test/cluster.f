C
C   DRIVER FOR TESTING CMLIB ROUTINES
C     CLUSTER SUBLIBRARY
C
C    ONE INPUT DATA CARD IS REQUIRED
C         READ(LIN,1) KPRINT,TIMES
C    1    FORMAT(I1,E10.0)
C
C     KPRINT = 0   NO PRINTING
C              1   NO PRINTING FOR PASSED TESTS, SHORT MESSAGE
C                  FOR FAILED TESTS
C              2   PRINT SHORT MESSAGE FOR PASSED TESTS, FULLER
C                  INFORMATION FOR FAILED TESTS
C              3   PRINT COMPLETE QUICK-CHECK RESULTS
C
C                ***IMPORTANT NOTE***
C         ALL QUICK CHECKS USE ROUTINES R2MACH AND D2MACH
C         TO SET THE ERROR TOLERANCES.
C     TIMES IS A CONSTANT MULTIPLIER THAT CAN BE USED TO SCALE THE
C     VALUES OF R1MACH AND D1MACH SO THAT
C               R2MACH(I) = R1MACH(I) * TIMES   FOR I=3,4,5
C               D2MACH(I) = D1MACH(I) * TIMES   FOR I=3,4,5
C     THIS MAKES IT EASILY POSSIBLE TO CHANGE THE ERROR TOLERANCES
C     USED IN THE QUICK CHECKS.
C     IF TIMES .LE. 0.0 THEN TIMES IS DEFAULTED TO 1.0
C
C              ***END NOTE***
C
      COMMON/UNIT/LUN
      COMMON/MSG/ICNT,JTEST(38)
      COMMON/XXMULT/TIMES
      LUN=I1MACH(2)
      LIN=I1MACH(1)
      ITEST=1
C
C     READ KPRINT,TIMES PARAMETERS FROM DATA CARD..
C
      READ(LIN,1) KPRINT,TIMES
1     FORMAT(I1,E10.0)
      IF(TIMES.LE.0.) TIMES=1.
      CALL XSETUN(LUN)
      CALL XSETF(1)
      CALL XERMAX(1000)
C   TEST CLUSTER
      CALL CLUSQX(KPRINT,IPASS)
      ITEST=ITEST*IPASS
C
      IF(KPRINT.GE.1.AND.ITEST.NE.1) WRITE(LUN,2)
2     FORMAT(/' ***** WARNING -- AT LEAST ONE TEST FOR SUBLIBRARY CLUSTE
     1R  HAS FAILED ***** ')
      IF(KPRINT.GE.1.AND.ITEST.EQ.1) WRITE(LUN,3)
3     FORMAT(/' ----- SUBLIBRARY CLUSTER PASSED ALL TESTS ----- ')
      END
      DOUBLE PRECISION FUNCTION D2MACH(I)
      DOUBLE PRECISION D1MACH
      COMMON/XXMULT/TIMES
      D2MACH=D1MACH(I)
      IF(I.EQ.1.OR. I.EQ.2) RETURN
      D2MACH = D2MACH * DBLE(TIMES)
      END
      REAL FUNCTION R2MACH(I)
      COMMON/XXMULT/TIMES
      R2MACH=R1MACH(I)
      IF(I.EQ.1.OR. I.EQ.2) RETURN
      R2MACH = R2MACH * TIMES
      RETURN
      END
      SUBROUTINE CLUSQX(KPRINT,IPASS)
C
      COMMON/UNIT/LUN
      INTEGER KPRINT,IPASS
      INTEGER OUNIT, DMWRK1, DMIWRK, DMSUM1, DMSUM2
      REAL A(10,4), WORK1(10,20), WORK2(30), SUM(7,4,4)
      INTEGER IWORK1(4,40), IWORK2(30)
      DIMENSION COVTST(3), STDTST(3), SUMTST(3), NBTST(4)
      CHARACTER*4 CLAB(4), RLAB(10), COVLAB(4), AVECLB(10), AVERLB
      CHARACTER*10 TITLE, COVTIT, AVETIT
C
      DATA TITLE /'THUG      ' /
      DATA N, M  / 4, 10 /
      DATA (CLAB(I),I=1,4) /'MURD', 'RAPE', 'BURG', 'AUTO' /
      DATA (RLAB(I),I=1,10)/'ATLA', 'BOST', 'CHIC', 'DALL', 'DENV',
     *                      'DETR', 'HART', 'HONO', 'HOUS', 'KANS' /
      DATA (A(1,I),I=1,4) / 16.50, 24.80, 1112.0, 494.0 /
      DATA (A(2,I),I=1,4) /  4.20, 13.30,  982.0, 954.0 /
      DATA (A(3,I),I=1,4) / 11.60, 24.70,  808.0, 645.0 /
      DATA (A(4,I),I=1,4) / 18.10, 34.20, 1668.0, 602.0 /
      DATA (A(5,I),I=1,4) /  6.90, 41.50, 1534.0, 780.0 /
      DATA (A(6,I),I=1,4) / 13.00, 35.70, 1566.0, 788.0 /
      DATA (A(7,I),I=1,4) /  2.50,  8.80, 1017.0, 468.0 /
      DATA (A(8,I),I=1,4) /  3.60, 12.70, 1457.0, 637.0 /
      DATA (A(9,I),I=1,4) / 16.80, 26.60, 1509.0, 697.0 /
      DATA (A(10,I),I=1,4)/ 10.80, 43.20, 1494.0, 765.0 /
C
      DATA (COVTST(I),I=1,3) / -143.52, 2028.945, 19286.2 /
      DATA (STDTST(I),I=1,3) / .8757840924311, .1008102525208,
     *                         .07240960664049 /
      DATA (SUMTST(I),I=1,3) / 1.95139845951, .1689654801238,
     *                         -.2707856107517 /
      DATA (NBTST(I),I=1, 4) / 2, 9, 2, 5 /
C
C      ERR = R2MACH(4) * 1000.
      ERR = MAX(1000*R2MACH(4),1.0E-11)
      MM = 10
      NN = 4
      IPASS = 1
      DMWRK1 = 10
      DMIWRK = 4
      DMSUM1 = 7
      DMSUM2 = 4
      OUNIT = 0
C
C     COMPUTE AND PRINT OUT OVERALL MEANS AND COVARIANCES
C
      CALL TWO(MM, M, N, A, CLAB, RLAB, TITLE, DMWRK1, WORK1, COVLAB,
     1         COVTIT, WORK2, AVECLB, AVERLB, AVETIT)
C
      IF (ABS((WORK1(1,4)-COVTST(1)) / COVTST(1)) .GT. ERR .OR.
     *    ABS((WORK1(2,3)-COVTST(2)) / COVTST(2)) .GT. ERR .OR.
     *    ABS((WORK1(4,4)-COVTST(3)) / COVTST(3)) .GT. ERR) THEN
         IF(KPRINT.GE.1) WRITE(LUN,*)'ERROR IN CLUSTER SUBROUTINE TWO'
         IPASS = 2
         IF (KPRINT.GE.2) THEN
           WRITE(LUN,*) 'CALCUALATED   EXPECTED'
           WRITE(LUN,*) '  ', WORK1(1,4), '     ', COVTST(1)
           WRITE(LUN,*) '  ', WORK1(2,3), '     ', COVTST(2)
           WRITE(LUN,*) '  ', WORK1(4,4), '     ', COVTST(3)
         ENDIF
         RETURN
      ENDIF
C
      CALL STAND(MM, M, N, A)
C
      IF (ABS((A(6,3)-STDTST(1)) / STDTST(1)) .GT. ERR .OR.
     *    ABS((A(9,4)-STDTST(2)) / STDTST(2)) .GT. ERR .OR.
     *    ABS((A(10,1)-STDTST(3))/ STDTST(3)) .GT. ERR) THEN
         IF(KPRINT.GE.1) WRITE(LUN,*)'ERROR IN CLUSTER SUBROUTINE STAND'
         IPASS = 2
         IF (KPRINT.GE.2) THEN
           WRITE(LUN,*) '    CALCULATED           EXPECTED'
           WRITE(LUN,*) '  ', A(6,3), '     ', STDTST(1)
           WRITE(LUN,*) '  ', A(9,4), '     ', STDTST(2)
           WRITE(LUN,*) '  ', A(10,1),'     ', STDTST(3)
         ENDIF
         RETURN
      ENDIF
C
      K = 3
      XMISS = 99999.
      ITER = 20
C
      CALL BUILD(MM, M, N, A, CLAB, RLAB, TITLE, K, ITER, XMISS,
     1           DMSUM1, DMSUM2, SUM, IWORK2, WORK2, COVLAB, OUNIT)
C
      IF (ABS((SUM(6,4,3)-SUMTST(1)) / SUMTST(1)) .GT. ERR .OR.
     *    ABS((SUM(4,2,1)-SUMTST(2)) / SUMTST(2)) .GT. ERR .OR.
     *    ABS((SUM(1,3,1)-SUMTST(3)) / SUMTST(3)) .GT. ERR) THEN
         IF(KPRINT.GE.1) WRITE(LUN,*)'ERROR IN CLUSTER SUBROUTINE BUILD'
         IPASS = 2
         IF (KPRINT.GE.2) THEN
           WRITE(LUN,*) '   CALCULATED         EXPECTED'
           WRITE(LUN,*) '  ', SUM(6,4,3), '     ', SUMTST(1)
           WRITE(LUN,*) '  ', SUM(4,2,1), '     ', SUMTST(2)
           WRITE(LUN,*) '  ', SUM(1,3,1), '     ', SUMTST(3)
         ENDIF
         RETURN
      ENDIF
C
      TH = 1.5
      KC = 64
C
      CALL JOIN2(MM, M, N, A, CLAB, RLAB, TITLE, KC, TH, DMWRK1, WORK1,
     *           WORK2, IWORK2, DMIWRK, IWORK1, AVECLB, IERR, OUNIT)
C
      IF (IWORK1(1,7)- NBTST(1) .NE. 0 .OR.
     *    IWORK1(2,4)- NBTST(2) .NE. 0 .OR.
     *    IWORK1(3,12)-NBTST(3) .NE. 0 .OR.
     *    IWORK1(4,6)- NBTST(4) .NE. 0) THEN
         IF(KPRINT.GE.1) WRITE(LUN,*)'ERROR IN CLUSTER SUBROUTINE JOIN2'
         IPASS = 2
         IF (KPRINT.GE.2) THEN
           WRITE(LUN,*) 'CALCULATED  EXPECTED   '
           WRITE(LUN,*) '    ', IWORK1(1,7), '           ', NBTST(1)
           WRITE(LUN,*) '    ', IWORK1(2,4), '           ', NBTST(2)
           WRITE(LUN,*) '    ', IWORK1(3,12),'           ', NBTST(3)
           WRITE(LUN,*) '    ', IWORK1(4,6), '           ', NBTST(4)
         ENDIF
      ENDIF
C
      RETURN
      END
