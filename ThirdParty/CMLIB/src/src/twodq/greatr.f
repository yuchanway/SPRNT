      LOGICAL FUNCTION GREATR(A,B,NWDS)
      INTEGER NWDS
      REAL A(NWDS), B(NWDS)
      GREATR= A(1) .GT. B(1)
      RETURN
      END
