C  XOR MULTILAYER PERCEPTION
C  2025, DAMIEN BOUREILLE
C  CODE RELEASED UNDER THE MIT LICENSE
C  ------------------------------------------------------
C  MAIN PROGRAM
C     COMMON BLOCKS AND TYPE DECLARATIONS
      DOUBLE PRECISION INPUTS(4,2), TARGETS(4,1)
      DOUBLE PRECISION W1(2,4), B1(4), W2(4,1), B2(1)
      DOUBLE PRECISION Z1(4), A1(4), Z2(1), A2(1)
      DOUBLE PRECISION DELTA1(4), DELTA2(1)
      DOUBLE PRECISION DW1(2,4), DW2(4,1), DB1(4), DB2(1)
      DOUBLE PRECISION LOSS, ERROR, LEARNR, DW1UPDT
      INTEGER EPOCHS, SAMPLES, I, J, EPOCH, EXPLIM
C
      COMMON /DATA/ INPUTS, TARGETS
      COMMON /WGHTS/ W1, B1, W2, B2
      COMMON /CONSTS/ EXPLIM, LEARNR
      COMMON /LAYER/ Z1, A1, Z2, A2
C
C     CONSTANTS
      EPOCHS = 500
      SAMPLES = 4
      EXPLIM = 10
      LEARNR = 0.5D0
C
C     DATA
      INPUTS(1,1)=0.0D0
      INPUTS(1,2)=0.0D0
      INPUTS(2,1)=0.0D0
      INPUTS(2,2)=1.0D0
      INPUTS(3,1)=1.0D0
      INPUTS(3,2)=0.0D0
      INPUTS(4,1)=1.0D0
      INPUTS(4,2)=1.0D0
      TARGETS(1,1)=0.0D0
      TARGETS(2,1)=1.0D0
      TARGETS(3,1)=1.0D0
      TARGETS(4,1)=0.0D0
C
C     FORMATS
9000  FORMAT(I5, D20.12)
9001  FORMAT(' ')
9002  FORMAT (2I2, 1X, 'GOT:', F8.6, ' EXPECTED:', F2.0)
C
C     INITIALIZE WEIGHTS AND BIASES
      CALL INITWE
C
C     TRAINING LOOP
      DO 100 EPOCH = 1, EPOCHS
          LOSS = 0.0D0
          CALL ZEROGR(DW1, DW2, DB1, DB2)
          DO 200 ISAMPLE = 1, SAMPLES
              CALL FORWRD(ISAMPLE)
              ERROR = TARGETS(ISAMPLE,1) - A2(1)
 70           LOSS = LOSS + ERROR * ERROR
              DELTA2(1) = ERROR * SIGDRV(Z2(1))
              DO 300 I = 1, 4
                  DW2(I,1) = DW2(I,1) + A1(I) * DELTA2(1)
 300          CONTINUE
              DB2(1) = DB2(1) + DELTA2(1)
              DO 400 I = 1, 4
                  DELTA1(I) = DELTA2(1) * W2(I,1) * RELUDRV(Z1(I))
                  DO 500 J = 1, 2
                      DW1UPDT = INPUTS(ISAMPLE,J) * DELTA1(I)       
                      DW1(J,I) = DW1(J,I) + DW1UPDT
 500              CONTINUE
                  DB1(I) = DB1(I) + DELTA1(I)
 400          CONTINUE
 200      CONTINUE
          DO 10 I = 1, 2
            DO 20 J = 1, 4
                DW1(I,J) = DW1(I,J) / 4.0D0
   20       CONTINUE
          CALL UPDATE(DW1, DW2, DB1, DB2, LEARNR)
   10     CONTINUE
          DO 30 I = 1, 4
              DW2(I,1) = DW2(I,1) / 4.0D0
              DB1(I) = DB1(I) / 4.0D0
   30     CONTINUE
          DB2(1) = DB2(1) / 4.0D0
          IF (EPOCH .GT. 350) GOTO 202
          IF (EPOCH .GT. 100) GOTO 201
          LEARNR = 0.5D0
          GOTO 203
 201      LEARNR = 0.1D0
          GOTO 203
 202      LEARNR = 0.01D0
 203      CALL UPDATE(DW1, DW2, DB1, DB2, LEARNR)
          LOSS = LOSS / DBLE(SAMPLES)
          IF (EPOCH .EQ. 1.0) GOTO 204
          IF (AMOD(DBLE(EPOCH), 100.0) .NE. 0.0) GOTO 205
 204        WRITE(7,9000) EPOCH, LOSS
 205      CONTINUE
 100  CONTINUE
      WRITE(7, 9001)
      DO 600 ISAMPLE = 1, SAMPLES
        CALL FORWRD(ISAMPLE)
        WRITE(7, 9002) NINT(INPUTS(ISAMPLE,1)), 
     $  NINT(INPUTS(ISAMPLE,2)), REAL(A2(1)), 
     $  REAL(TARGETS(ISAMPLE,1))
C
 600  CONTINUE
      STOP
      END
C
C NINT
      INTEGER FUNCTION NINT(X)
      REAL X
      IF (X .GE. 0.0) GOTO 10
      NINT = -INT(0.5 - X)
      GOTO 20
10    NINT = INT(X + 0.5)
20    RETURN
      END
C
C SIGMOI
      DOUBLE PRECISION FUNCTION SIGMOI(X)
      DOUBLE PRECISION X
      IF (X .GT. 20.0) GOTO 30
      IF (X .LT. -20.0) GOTO 40
      SIGMOI = 1.0 / (1.0 + EXP(-X))
      GOTO 50
  30  SIGMOI = 1.0
      GOTO 50
  40  SIGMOI = 0.0
  50  CONTINUE
      RETURN
      END
C
C SIGDRV
      DOUBLE PRECISION FUNCTION SIGDRV(X)
      DOUBLE PRECISION X, S, SIGMOI
      S = SIGMOI(X)
      SIGDRV = S * (1.0 - S)
      RETURN
      END
C
C TANHAC
      DOUBLE PRECISION FUNCTION TANHAC(X)
      DOUBLE PRECISION X
      TANHAC = TANH(X) 
      RETURN
      END
C
C TANHDR
      DOUBLE PRECISION FUNCTION TANHDR(X)
      DOUBLE PRECISION X, T, TANH
      T = TANH(X)
      TANHDR = 1.0D0 - T * T
      RETURN
      END
C
C RANDN (GAUSSIAN)
      DOUBLE PRECISION FUNCTION RANDN(SEED)
      INTEGER SEED
      INTEGER I
      DOUBLE PRECISION SUM
      SUM = 0.0D0
      DO 10 i = 1, 12
          SUM = SUM + RAN(1, SEED + I)
10    CONTINUE
      RANDN = SUM - 6.0D0
      RETURN
      END
C
C RELU
      DOUBLE PRECISION FUNCTION RELU(X)
      DOUBLE PRECISION X, ALPHA
      DOUBLE PRECISION ALPHA = 0.01D0
      IF (X .GT. 0.0D0) GOTO 10
      RELU = ALPHA * X
      GOTO 20
10    RELU = X
20    RETURN
      END
C      
C RELUDRV
      DOUBLE PRECISION FUNCTION RELUDRV(X)
      DOUBLE PRECISION X, ALPHA
      DOUBLE PRECISION ALPHA = 0.01D0
      IF (X .GT. 0.0D0) GOTO 10
      RELUDRV = ALPHA
      GOTO 20
10    RELUDRV = 1.0D0
20    RETURN
      END
C      
C INITWE
      SUBROUTINE INITWE
      DOUBLE PRECISION W1(2,4), B1(4), W2(4,1), B2(1)
      COMMON /WGHTS/ W1, B1, W2, B2
      INTEGER I, J
      HESCAL1 = SQRT(2.0D0 / DBLE(2 + 4))
      HESCAL2 = SQRT(2.0D0 / DBLE(4 + 1))
      DO 10 I = 1, 2
          DO 20 J = 1, 4
              W1(I,J) = RANDN(1234 + I + J) * HESCAL1
C              WRITE(7, 9003) (W1(I,J))
C9003          FORMAT(D20.12)
 20       CONTINUE
 10   CONTINUE
      DO 30 I = 1, 4
C           B2(1) = RAN(1, 4000) * 0.01D0
           B1(I) = 0
 30   CONTINUE
      DO 40 I = 1, 4
           W2(I,1) = RANDN(4321 + I ) * HESCAL2
 40   CONTINUE
 9000 FORMAT(A, D20.12)
C      B2(1) = RAN(1, 4000) * 0.01D0
      B2(1) = 0
      RETURN
      END
C
C FORWRD
      SUBROUTINE FORWRD(ISAMPLE)
      COMMON /WGHTS/ W1(2,4), B1(4), W2(4,1), B2(1)
      COMMON /LAYER/ Z1(4), A1(4), Z2(1), A2(1)
      COMMON /DATA/ INPUTS(4,2), TARGETS(4,1)
      INTEGER I, J, ISAMPLE
      DOUBLE PRECISION W1, B1, W2, B2
      DOUBLE PRECISION Z1, A1, Z2, A2, INPUTS, TARGETS
      DOUBLE PRECISION TEMP
C
C     LAYER 1
      DO 1000 I = 1, 4
          Z1(I) = 0.0D0
          DO 2000 J = 1, 2
              TEMP = INPUTS(ISAMPLE,J) * W1(J,I)
              Z1(I) = Z1(I) + TEMP
2000      CONTINUE
C      BIAS
          Z1(I) = Z1(I) + B1(I)
C      RELU ACTIVATION
          A1(I) = RELU(Z1(I))
1000  CONTINUE
C
C     LAYER 2
      Z2(1) = 0.0D0
      DO 3000 J = 1, 4
          Z2(1) = Z2(1) + A1(J) * W2(J,1)
3000  CONTINUE
C     BIAS
      Z2(1) = Z2(1) + B2(1)
C     ACTIVATION
      A2(1) = TANHAC(Z2(1))
      RETURN
      END
C
C UPDATE
      SUBROUTINE UPDATE(DW1, DW2, DB1, DB2, LR)
      DOUBLE PRECISION DW1(2,4), DW2(4,1), DB1(4), DB2(1), LR
      COMMON /WGHTS/ W1(2,4), B1(4), W2(4,1), B2(1)
      DOUBLE PRECISION W1, B1, W2, B2
      INTEGER I, J
      DO 10 I = 1, 4
          W2(I,1) = W2(I,1) + LR * DW2(I,1)
 10   CONTINUE
      B2(1) = B2(1) + LR * DB2(1)
      DO 20 I = 1, 2
          DO 30 J = 1, 4
              W1(I,J) = W1(I,J) + LR * DW1(J,I)
 30       CONTINUE
 20   CONTINUE
      DO 40 I = 1, 4
          B1(I) = B1(I) + LR * DB1(I)
 40   CONTINUE
      RETURN
      END
C
C ZEROGR
      SUBROUTINE ZEROGR(DW1, DW2, DB1, DB2)
      DOUBLE PRECISION DW1(2,4), DW2(4,1), DB1(4), DB2(1)
      INTEGER I, J
      DO 10 I = 1, 2
          DO 20 J = 1, 4
              DW1(I,J) = 0.0
 20       CONTINUE
 10   CONTINUE
      DO 30 I = 1, 4
          DW2(I,1) = 0.0
 30   CONTINUE
      DO 40 I = 1, 4
          DB1(I) = 0.0
 40   CONTINUE
      DB2(1) = 0.0
      RETURN
      END
