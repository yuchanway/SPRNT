      SUBROUTINE VRFFTB(M,N,R,RT,MDIMR,WSAVE)
C
C     VRFFTPK, VERSION 1, AUGUST 1985
C
      DIMENSION     R(MDIMR,N),RT(MDIMR,N),WSAVE(N+15)
      IF (N .EQ. 1) RETURN
      CALL VRFTB1 (M,N,R,RT,MDIMR,WSAVE(1),WSAVE(N+1))
      RETURN
      END
