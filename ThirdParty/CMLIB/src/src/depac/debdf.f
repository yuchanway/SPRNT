      SUBROUTINE DEBDF(F,NEQ,T,Y,TOUT,INFO,RTOL,ATOL,IDID,RWORK,LRW,
     1   IWORK,LIW,RPAR,IPAR,JAC)
C***BEGIN PROLOGUE  DEBDF
C***DATE WRITTEN   800901   (YYMMDD)
C***REVISION DATE  820801   (YYMMDD)
C***REVISION HISTORY  (YYMMDD)
C   000330  Modified array declarations.  (JEC)
C
C***CATEGORY NO.  I1A2
C***KEYWORDS  BACKWARD DIFFERENTIATION FORMULAS,DEPAC,
C             INITIAL VALUE PROBLEMS,ODE,
C             ORDINARY DIFFERENTIAL EQUATIONS,STIFF
C***AUTHOR  SHAMPINE, L. F., (SNLA)
C           WATTS, H. A., (SNLA)
C***PURPOSE  Solves initial value problems in ordinary differential
C            equations using backward differentiation formulae.
C            It is intended primarily for STIFF problems.
C***DESCRIPTION
C
C   This is the backward differentiation code in the package of
C   differential equation solvers DEPAC, consisting of the codes
C   DERKF, DEABM, and DEBDF.  Design of the package was by
C   L. F. Shampine and H. A. Watts.  It is documented in
C        SAND-79-2374 , DEPAC - Design of a User Oriented Package of ODE
C                              Solvers.
C   DEBDF is a driver for a modification of the code LSODE written by
C             A. C. Hindmarsh
C             Lawrence Livermore Laboratory
C             Livermore, California 94550
C
C **********************************************************************
C **             DEPAC PACKAGE OVERVIEW           **
C **************************************************
C
C        You have a choice of three differential equation solvers from
C        DEPAC.  The following brief descriptions are meant to aid you
C        in choosing the most appropriate code for your problem.
C
C        DERKF is a fifth order Runge-Kutta code.  It is the simplest of
C        the three choices, both algorithmically and in the use of the
C        code.  DERKF is primarily designed to solve non-stiff and mild-
C        ly stiff differential equations when derivative evaluations are
C        not expensive.  It should generally not be used to get high
C        accuracy results nor answers at a great many specific points.
C        Because DERKF has very low overhead costs, it will usually
C        result in the least expensive integration when solving
C        problems requiring a modest amount of accuracy and having
C        equations that are not costly to evaluate.  DERKF attempts to
C        discover when it is not suitable for the task posed.
C
C        DEABM is a variable order (one through twelve) Adams code.
C        Its complexity lies somewhere between that of DERKF and DEBDF.
C        DEABM is primarily designed to solve non-stiff and mildly stiff
C        differential equations when derivative evaluations are
C        expensive, high accuracy results are needed or answers at
C        many specific points are required.  DEABM attempts to discover
C        when it is not suitable for the task posed.
C
C        DEBDF is a variable order (one through five) backward
C        differentiation formula code.  It is the most complicated of
C        the three choices.  DEBDF is primarily designed to solve stiff
C        differential equations at crude to moderate tolerances.
C        If the problem is very stIff at all, DERKF and DEABM will be
C        quite inefficient compared to DEBDF.  However, DEBDF will be
C        inefficient compared to DERKF and DEABM on non-stiff problems
C        because it uses much more storage, has a much larger overhead,
C        and the low order formulas will not give high accuracies
C        efficiently.
C
C        The concept of stiffness cannot be described in a few words.
C        If you do not know the problem to be stiff, try either DERKF
C        or DEABM.  Both of these codes will inform you of stiffness
C        when the cost of solving such problems becomes important.
C
C **********************************************************************
C ** ABSTRACT **
C **************
C
C   Subroutine DEBDF uses the backward differentiation formulas of
C   orders one through five to integrate a system of NEQ first order
C   ordinary differential equations of the form
C                         DU/DX = F(X,U)
C   when the vector Y(*) of initial values for U(*) at X=T is given. The
C   subroutine integrates from T to TOUT.  It is easy to continue the
C   integration to get results at additional TOUT.  This is the interval
C   mode of operation.  It is also easy for the routine to return with
C   The solution at each intermediate step on the way to TOUT.  This is
C   the intermediate-output mode of operation.
C
C   DEBDF uses subprograms LSOD, INTYD, STOD, CFOD, PJAC, SLVS, VNWRMS,
C   HSTART, VNORM, SVCO, RSCO, R1MACH, and the LINPACK routines SGEFA,
C   SGESL, SGBFA, SGBSL (which also uses the BLAS routines SAXPY, SSCAL,
C   ISAMAX and SDOT) and the error handling routine XERRWV.
C   The only machine dependent parameters to be assigned appear in
C   R1MACH.
C
C **********************************************************************
C ** DESCRIPTION OF THE ARGUMENTS TO DEBDF (AN OVERVIEW) **
C *********************************************************
C
C   The parameters are:
C
C      F -- This is the name of a subroutine which you provide to
C             define the differential equations.
C
C      NEQ -- This is the number of (first order) differential
C             equations to be integrated.
C
C      T -- This is a value of the independent variable.
C
C      Y(*) -- This array contains the solution components at T.
C
C      TOUT -- This is a point at which a solution is desired.
C
C      INFO(*) -- The basic task of the code is to integrate the
C             differential equations from T to TOUT and return an
C             answer at TOUT.  INFO(*) is an integer array which is used
C             to communicate exactly how you want this task to be
C             carried out.
C
C      RTOL, ATOL -- These quantities represent relative and absolute
C             error tolerances which you provide to indicate how
C             accurately you wish the solution to be computed.  You may
C             choose them to be both scalars or else both vectors.
C
C      IDID -- This scalar quantity is an indicator reporting what
C             the code did.  You must monitor this integer variable to
C             decide what action to take next.
C
C      RWORK(*), LRW -- RWORK(*) is a real work array of length LRW
C             which provides the code with needed storage space.
C
C      IWORK(*), LIW -- IWORK(*) is an integer work array of length LIW
C             which provides the code with needed storage space.
C
C      RPAR, IPAR -- These are real and integer parameter arrays which
C             you can use for communication between your calling
C             program and the F subroutine (and the JAC subroutine).
C
C      JAC -- This is the name of a subroutine which you may choose to
C             provide for defining the Jacobian matrix of partial
C             derivatives DF/DU.
C
C  Quantities which are used as input items are
C             NEQ, T, Y(*), TOUT, INFO(*),
C             RTOL, ATOL, RWORK(1), LRW,
C             IWORK(1), IWORK(2), and LIW.
C
C  Quantities which may be altered by the code are
C             T, Y(*), INFO(1), RTOL, ATOL,
C             IDID, RWORK(*) and IWORK(*).
C
C **********************************************************************
C ** INPUT -- WHAT TO DO ON THE FIRST CALL TO DEBDF **
C ****************************************************
C
C   The first call of the code is defined to be the start of each new
C   problem.  Read through the descriptions of all the following items,
C   provide sufficient storage space for designated arrays, set
C   appropriate variables for the initialization of the problem, and
C   give information about how you want the problem to be solved.
C
C
C      F -- provide a subroutine of the form
C                               F(X,U,UPRIME,RPAR,IPAR)
C             to define the system of first order differential equations
C             which is to be solved. for the given values of X and the
C             vector  U(*)=(U(1),U(2),...,U(NEQ)) , the subroutine must
C             evaluate the NEQ components of the system of differential
C             equations  DU/DX=F(X,U)  and store the derivatives in the
C             array UPRIME(*), that is,  UPRIME(I) = * DU(I)/DX *  for
C             equations I=1,...,NEQ.
C
C             Subroutine F must not alter X or U(*).  You must declare
C             the name F in an external statement in your program that
C             calls DEBDF.  You must dimension U and UPRIME in F.
C
C             RPAR and IPAR are real and integer parameter arrays which
C             you can use for communication between your calling program
C             and subroutine F.  They are not used or altered by DEBDF.
C             If you do not need RPAR or IPAR, ignore these parameters
C             by treating them as dummy arguments.  If you do choose to
C             use them, dimension them in your calling program and in F
C             as arrays of appropriate length.
C
C      NEQ -- Set it to the number of differential equations.
C             (NEQ .GE. 1)
C
C      T -- Set it to the initial point of the integration.
C             You must use a program variable for T because the code
C             changes its value.
C
C      Y(*) -- Set this vector to the initial values of the NEQ solution
C             components at the initial point.  You must dimension Y at
C             least NEQ in your calling program.
C
C      TOUT -- Set it to the first point at which a solution
C             is desired.  You can take TOUT = T, in which case the code
C             will evaluate the derivative of the solution at T and
C             return.  Integration either forward in T  (TOUT .GT. T)
C             or backward in T  (TOUT .LT. T)  is permitted.
C
C             The code advances the solution from T to TOUT using
C             step sizes which are automatically selected so as to
C             achieve the desired accuracy.  If you wish, the code will
C             return with the solution and its derivative following
C             each intermediate step (intermediate-output mode) so that
C             you can monitor them, but you still must provide TOUT in
C             accord with the basic aim of the code.
C
C             The first step taken by the code is a critical one
C             because it must reflect how fast the solution changes near
C             the initial point.  The code automatically selects an
C             initial step size which is practically always suitable for
C             the problem.  By using the fact that the code will not
C             step past TOUT in the first step, you could, if necessary,
C             restrict the length of the initial step size.
C
C             For some problems it may not be permissible to integrate
C             past a point TSTOP because a discontinuity occurs there
C             or the solution or its derivative is not defined beyond
C             TSTOP.  When you have declared a TSTOP point (see INFO(4)
C             and RWORK(1)), you have told the code not to integrate
C             past TSTOP.  In this case any TOUT beyond TSTOP is invalid
C             input.
C
C      INFO(*) -- Use the INFO array to give the code more details about
C             how you want your problem solved.  This array should be
C             dimensioned of length 15 to accomodate other members of
C             DEPAC or possible future extensions, though DEBDF uses
C             only the first six entries.  You must respond to all of
C             the following items which are arranged as questions.  The
C             simplest use of the code corresponds to answering all
C             questions as yes ,i.e. setting all entries of INFO to 0.
C
C        INFO(1) -- This parameter enables the code to initialize
C               itself.  You must set it to indicate the start of every
C               new problem.
C
C            **** Is this the first call for this problem ...
C                  YES -- Set INFO(1) = 0
C                   NO -- Not applicable here.
C                         See below for continuation calls.  ****
C
C        INFO(2) -- How much accuracy you want of your solution
C               is specified by the error tolerances RTOL and ATOL.
C               The simplest use is to take them both to be scalars.
C               To obtain more flexibility, they can both be vectors.
C               The code must be told your choice.
C
C            **** Are both error tolerances RTOL, ATOL scalars ...
C                  YES -- Set INFO(2) = 0
C                         and input scalars for both RTOL and ATOL
C                   NO -- Set INFO(2) = 1
C                         and input arrays for both RTOL and ATOL ****
C
C        INFO(3) -- The code integrates from T in the direction
C               of TOUT by steps.  If you wish, it will return the
C               computed solution and derivative at the next
C               intermediate step (the intermediate-output mode) or
C               TOUT, whichever comes first.  This is a good way to
C               proceed if you want to see the behavior of the solution.
C               If you must have solutions at a great many specific
C               TOUT points, this code will compute them efficiently.
C
C            **** Do you want the solution only at
C                 TOUT (and not at the next intermediate step) ...
C                  YES -- Set INFO(3) = 0
C                   NO -- Set INFO(3) = 1 ****
C
C        INFO(4) -- To handle solutions at a great many specific
C               values TOUT efficiently, this code may integrate past
C               TOUT and interpolate to obtain the result at TOUT.
C               Sometimes it is not possible to integrate beyond some
C               point TSTOP because the equation changes there or it is
C               not defined past TSTOP.  Then you must tell the code
C               not to go past.
C
C            **** Can the integration be carried out without any
C                 restrictions on the independent variable T ...
C                  YES -- Set INFO(4)=0
C                   NO -- Set INFO(4)=1
C                         and define the stopping point TSTOP by
C                         setting RWORK(1)=TSTOP ****
C
C        INFO(5) -- To solve stiff problems it is necessary to use the
C               Jacobian matrix of partial derivatives of the system
C               of differential equations.  If you do not provide a
C               subroutine to evaluate it analytically (see the
C               description of the item JAC in the call list), it will
C               be approximated by numerical differencing in this code.
C               Although it is less trouble for you to have the code
C               compute partial derivatives by numerical differencing,
C               the solution will be more reliable if you provide the
C               derivatives via JAC.  Sometimes numerical differencing
C               is cheaper than evaluating derivatives in JAC and
C               sometimes it is not - this depends on your problem.
C
C               If your problem is linear, i.e. has the form
C               DU/DX = F(X,U) = J(X)*U + G(X)   for some matrix J(X)
C               and vector G(X), the Jacobian matrix  DF/DU = J(X).
C               Since you must provide a subroutine to evaluate F(X,U)
C               analytically, it is little extra trouble to provide
C               subroutine JAC for evaluating J(X) analytically.
C               Furthermore, in such cases, numerical differencing is
C               much more expensive than analytic evaluation.
C
C            **** Do you want the code to evaluate the partial
C                 derivatives automatically by numerical differences ...
C                  YES -- Set INFO(5)=0
C                   NO -- Set INFO(5)=1
C                         and provide subroutine JAC for evaluating the
C                         Jacobian matrix ****
C
C        INFO(6) -- DEBDF will perform much better if the Jacobian
C               matrix is banded and the code is told this.  In this
C               case, the storage needed will be greatly reduced,
C               numerical differencing will be performed more cheaply,
C               and a number of important algorithms will execute much
C               faster.  The differential equation is said to have
C               half-bandwidths ML (lower) and MU (upper) if equation I
C               involves only unknowns Y(J) with
C                              I-ML .LE. J .LE.  I+MU
C               for all I=1,2,...,NEQ.  Thus, ML and MU are the widths
C               of the lower and upper parts of the band, respectively,
C               with the main diagonal being excluded.  If you do not
C               indicate that the equation has a banded Jacobian,
C               the code works with a full matrix of NEQ**2 elements
C               (stored in the conventional way).  Computations with
C               banded matrices cost less time and storage than with
C               full matrices if  2*ML+MU .LT. NEQ.  If you tell the
C               code that the Jacobian matrix has a banded structure and
C               you want to provide subroutine JAC to compute the
C               partial derivatives, then you must be careful to store
C               the elements of the Jacobian matrix in the special form
C               indicated in the description of JAC.
C
C            **** Do you want to solve the problem using a full
C                 (dense) Jacobian matrix (and not a special banded
C                 structure) ...
C                  YES -- Set INFO(6)=0
C                   NO -- Set INFO(6)=1
C                         and provide the lower (ML) and upper (MU)
C                         bandwidths by setting
C                         IWORK(1)=ML
C                         IWORK(2)=MU ****
C
C      RTOL, ATOL -- You must assign relative (RTOL) and absolute (ATOL)
C             error tolerances to tell the code how accurately you want
C             the solution to be computed.  They must be defined as
C             program variables because the code may change them.  You
C             have two choices --
C                  Both RTOL and ATOL are scalars. (INFO(2)=0)
C                  Both RTOL and ATOL are vectors. (INFO(2)=1)
C             In either case all components must be non-negative.
C
C             The tolerances are used by the code in a local error test
C             at each step which requires roughly that
C                     ABS(LOCAL ERROR) .LE. RTOL*ABS(Y)+ATOL
C             for each vector component.
C             (More specifically, a root-mean-square norm is used to
C             measure the size of vectors, and the error test uses the
C             magnitude of the solution at the beginning of the step.)
C
C             The true (global) error is the difference between the true
C             solution of the initial value problem and the computed
C             approximation.  Practically all present day codes,
C             including this one, control the local error at each step
C             and do not even attempt to control the global error
C             directly.  Roughly speaking, they produce a solution Y(T)
C             which satisfies the differential equations with a
C             residual R(T),    DY(T)/DT = F(T,Y(T)) + R(T)   ,
C             and, almost always, R(T) is bounded by the error
C             tolerances.  Usually, but not always, the true accuracy of
C             the computed Y is comparable to the error tolerances. This
C             code will usually, but not always, deliver a more accurate
C             solution if you reduce the tolerances and integrate again.
C             By comparing two such solutions you can get a fairly
C             reliable idea of the true error in the solution at the
C             bigger tolerances.
C
C             Setting ATOL=0.0 results in a pure relative error test on
C             that component.  Setting RTOL=0.0 results in a pure abso-
C             lute error test on that component.  A mixed test with non-
C             zero RTOL and ATOL corresponds roughly to a relative error
C             test when the solution component is much bigger than ATOL
C             and to an absolute error test when the solution component
C             is smaller than the threshold ATOL.
C
C             Proper selection of the absolute error control parameters
C             ATOL  requires you to have some idea of the scale of the
C             solution components.  To acquire this information may mean
C             that you will have to solve the problem more than once. In
C             the absence of scale information, you should ask for some
C             relative accuracy in all the components (by setting  RTOL
C             values non-zero) and perhaps impose extremely small
C             absolute error tolerances to protect against the danger of
C             a solution component becoming zero.
C
C             The code will not attempt to compute a solution at an
C             accuracy unreasonable for the machine being used.  It will
C             advise you if you ask for too much accuracy and inform
C             you as to the maximum accuracy it believes possible.
C
C      RWORK(*) -- Dimension this real work array of length LRW in your
C             calling program.
C
C      RWORK(1) -- If you have set INFO(4)=0, you can ignore this
C             optional input parameter.  Otherwise you must define a
C             stopping point TSTOP by setting   RWORK(1) = TSTOP.
C             (For some problems it may not be permissible to integrate
C             past a point TSTOP because a discontinuity occurs there
C             or the solution or its derivative is not defined beyond
C             TSTOP.)
C
C      LRW -- Set it to the declared length of the RWORK array.
C             You must have
C                  LRW .GE. 250+10*NEQ+NEQ**2
C             for the full (dense) Jacobian case (when INFO(6)=0),  or
C                  LRW .GE. 250+10*NEQ+(2*ML+MU+1)*NEQ
C             for the banded Jacobian case (when INFO(6)=1).
C
C      IWORK(*) -- Dimension this integer work array of length LIW in
C             your calling program.
C
C      IWORK(1), IWORK(2) -- If you have set INFO(6)=0, you can ignore
C             these optional input parameters.  Otherwise you must de-
C             fine the half-bandwidths ML (lower) and MU (upper) of the
C             Jacobian matrix by setting    IWORK(1) = ML   and
C             IWORK(2) = MU.  (The code will work with a full matrix
C             of NEQ**2 elements unless it is told that the problem has
C             a banded Jacobian, in which case the code will work with
C             a matrix containing at most  (2*ML+MU+1)*NEQ  elements.)
C
C      LIW -- Set it to the declared length of the IWORK array.
C             You must have LIW .GE. 55+NEQ.
C
C      RPAR, IPAR -- These are parameter arrays, of real and integer
C             type, respectively.  You can use them for communication
C             between your program that calls DEBDF and the  F
C             subroutine (and the JAC subroutine).  They are not used or
C             altered by DEBDF.  If you do not need RPAR or IPAR, ignore
C             these parameters by treating them as dummy arguments.  If
C             you do choose to use them, dimension them in your calling
C             program and in F (and in JAC) as arrays of appropriate
C             length.
C
C      JAC -- If you have set INFO(5)=0, you can ignore this parameter
C             by treating it as a dummy argument. (For some compilers
C             you may have to write a dummy subroutine named  JAC  in
C             order to avoid problems associated with missing external
C             routine names.)  Otherwise, you must provide a subroutine
C             of the form
C                          JAC(X,U,PD,NROWPD,RPAR,IPAR)
C             to define the Jacobian matrix of partial derivatives DF/DU
C             of the system of differential equations   DU/DX = F(X,U).
C             For the given values of X and the vector
C             U(*)=(U(1),U(2),...,U(NEQ)), the subroutine must evaluate
C             the non-zero partial derivatives  DF(I)/DU(J)  for each
C             differential equation I=1,...,NEQ and each solution
C             component J=1,...,NEQ , and store these values in the
C             matrix PD.  The elements of PD are set to zero before each
C             call to JAC so only non-zero elements need to be defined.
C
C             Subroutine JAC must not alter X, U(*), or NROWPD.  You
C             must declare the name JAC in an EXTERNAL statement in your
C             program that calls DEBDF.  NROWPD is the row dimension of
C             the PD matrix and is assigned by the code.  Therefore you
C             must dimension PD in JAC according to
C                              DIMENSION PD(NROWPD,1)
C             You must also dimension U in JAC.
C
C             The way you must store the elements into the PD matrix
C             depends on the structure of the Jacobian which you
C             indicated by INFO(6).
C             *** INFO(6)=0 -- Full (Dense) Jacobian ***
C                 When you evaluate the (non-zero) partial derivative
C                 of equation I with respect to variable J, you must
C                 store it in PD according to
C                                PD(I,J) = * DF(I)/DU(J) *
C             *** INFO(6)=1 -- Banded Jacobian with ML Lower and MU
C                 Upper Diagonal Bands (refer to INFO(6) description of
C                 ML and MU) ***
C                 When you evaluate the (non-zero) partial derivative
C                 of equation I with respect to variable J, you must
C                 store it in PD according to
C                                IROW = I - J + ML + MU + 1
C                                PD(IROW,J) = * DF(I)/DU(J) *
C
C             RPAR and IPAR are real and integer parameter arrays which
C             you can use for communication between your calling
C             program and your Jacobian subroutine JAC.  They are not
C             altered by DEBDF.  If you do not need RPAR or IPAR, ignore
C             these parameters by treating them as dummy arguments.  If
C             you do choose to use them, dimension them in your calling
C             program and in JAC as arrays of appropriate length.
C
C **********************************************************************
C ** OUTPUT -- AFTER ANY RETURN FROM DEBDF **
C *******************************************
C
C   The principal aim of the code is to return a computed solution at
C   TOUT, although it is also possible to obtain intermediate results
C   along the way.  To find out whether the code achieved its goal
C   or if the integration process was interrupted before the task was
C   completed, you must check the IDID parameter.
C
C
C      T -- The solution was successfully advanced to the
C             output value of T.
C
C      Y(*) -- Contains the computed solution approximation at T.
C             You may also be interested in the approximate derivative
C             of the solution at T.  It is contained in
C             RWORK(21),...,RWORK(20+NEQ).
C
C      IDID -- Reports what the code did
C
C                         *** Task Completed ***
C                   reported by positive values of IDID
C
C             IDID = 1 -- A step was successfully taken in the
C                       intermediate-output mode.  The code has not
C                       yet reached TOUT.
C
C             IDID = 2 -- The integration to TOUT was successfully
C                       completed (T=TOUT) by stepping exactly to TOUT.
C
C             IDID = 3 -- The integration to TOUT was successfully
C                       completed (T=TOUT) by stepping past TOUT.
C                       Y(*) is obtained by interpolation.
C
C                         *** Task Interrupted ***
C                   reported by negative values of IDID
C
C             IDID = -1 -- A large amount of work has been expended.
C                       (500 steps attempted)
C
C             IDID = -2 -- The error tolerances are too stringent.
C
C             IDID = -3 -- The local error test cannot be satisfied
C                       because you specified a zero component in ATOL
C                       and the corresponding computed solution
C                       component is zero.  Thus, a pure relative error
C                       test is impossible for this component.
C
C             IDID = -4,-5  -- Not applicable for this code but used
C                       by other members of DEPAC.
C
C             IDID = -6 -- DEBDF had repeated convergence test failures
C                       on the last attempted step.
C
C             IDID = -7 -- DEBDF had repeated error test failures on the
C                       last attempted step.
C
C             IDID = -8,..,-32  -- Not applicable for this code but
C                       used by other members of DEPAC or possible
C                       future extensions.
C
C                         *** Task Terminated ***
C                   reported by the value of IDID=-33
C
C             IDID = -33 -- The code has encountered trouble from which
C                       it cannot recover.  A message is printed
C                       explaining the trouble and control is returned
C                       to the calling program.  For example, this
C                       occurs when invalid input is detected.
C
C      RTOL, ATOL -- These quantities remain unchanged except when
C             IDID = -2.  In this case, the error tolerances have been
C             increased by the code to values which are estimated to be
C             appropriate for continuing the integration.  However, the
C             reported solution at T was obtained using the input values
C             of RTOL and ATOL.
C
C      RWORK, IWORK -- Contain information which is usually of no
C             interest to the user but necessary for subsequent calls.
C             However, you may find use for
C
C             RWORK(11)--which contains the step size H to be
C                        attempted on the next step.
C
C             RWORK(12)--If the tolerances have been increased by the
C                        code (IDID = -2) , they were multiplied by the
C                        value in RWORK(12).
C
C             RWORK(13)--which contains the current value of the
C                        independent variable, i.e.  the farthest point
C                        integration has reached.  This will be
C                        different from T only when interpolation has
C                        been performed (IDID=3).
C
C             RWORK(20+I)--which contains the approximate derivative
C                        of the solution component Y(I).  In DEBDF, it
C                        is never obtained by calling subroutine F to
C                        evaluate the differential equation using T and
C                        Y(*), except at the initial point of
C                        integration.
C
C **********************************************************************
C ** INPUT -- WHAT TO DO TO CONTINUE THE INTEGRATION **
C **             (CALLS AFTER THE FIRST)             **
C *****************************************************
C
C        This code is organized so that subsequent calls to continue the
C        integration involve little (if any) additional effort on your
C        part.  You must monitor the IDID parameter in order to deter-
C        mine what to do next.
C
C        Recalling that the principal task of the code is to integrate
C        from T to TOUT (the interval mode), usually all you will need
C        to do is specify a new TOUT upon reaching the current TOUT.
C
C        Do not alter any quantity not specifically permitted below,
C        in particular do not alter NEQ, T, Y(*), RWORK(*), IWORK(*) or
C        the differential equation in subroutine F.  Any such alteration
C        constitutes a new problem and must be treated as such, i.e.
C        you must start afresh.
C
C        You cannot change from vector to scalar error control or vice
C        versa (INFO(2)) but you can change the size of the entries of
C        RTOL, ATOL.  Increasing a tolerance makes the equation easier
C        to integrate.  Decreasing a tolerance will make the equation
C        harder to integrate and should generally be avoided.
C
C        You can switch from the intermediate-output mode to the
C        interval mode (INFO(3)) or vice versa at any time.
C
C        If it has been necessary to prevent the integration from going
C        past a point TSTOP (INFO(4), RWORK(1)), keep in mind that the
C        code will not integrate to any TOUT beyond the currently
C        specified TSTOP.  Once TSTOP has been reached you must change
C        the value of TSTOP or set INFO(4)=0.  You may change INFO(4)
C        or TSTOP at any time but you must supply the value of TSTOP in
C        RWORK(1) whenever you set INFO(4)=1.
C
C        Do not change INFO(5), INFO(6), IWORK(1), or IWORK(2)
C        unless you are going to restart the code.
C
C        The parameter INFO(1) is used by the code to indicate the
C        beginning of a new problem and to indicate whether integration
C        is to be continued.  You must input the value  INFO(1) = 0
C        when starting a new problem.  You must input the value
C        INFO(1) = 1  if you wish to continue after an interrupted task.
C        Do not set  INFO(1) = 0  on a continuation call unless you
C        want the code to restart at the current T.
C
C                         *** Following a Completed Task ***
C         If
C             IDID = 1, call the code again to continue the integration
C                     another step in the direction of TOUT.
C
C             IDID = 2 or 3, define a new TOUT and call the code again.
C                     TOUT must be different from T.  You cannot change
C                     the direction of integration without restarting.
C
C                         *** Following an Interrupted Task ***
C                     To show the code that you realize the task was
C                     interrupted and that you want to continue, you
C                     must take appropriate action and reset INFO(1) = 1
C         If
C             IDID = -1, the code has attempted 500 steps.
C                     If you want to continue, set INFO(1) = 1 and
C                     call the code again.  An additional 500 steps
C                     will be allowed.
C
C             IDID = -2, the error tolerances RTOL, ATOL have been
C                     increased to values the code estimates appropriate
C                     for continuing.  You may want to change them
C                     yourself.  If you are sure you want to continue
C                     with relaxed error tolerances, set INFO(1)=1 and
C                     call the code again.
C
C             IDID = -3, a solution component is zero and you set the
C                     corresponding component of ATOL to zero.  If you
C                     are sure you want to continue, you must first
C                     alter the error criterion to use positive values
C                     for those components of ATOL corresponding to zero
C                     solution components, then set INFO(1)=1 and call
C                     the code again.
C
C             IDID = -4,-5  --- cannot occur with this code but used
C                     by other members of DEPAC.
C
C             IDID = -6, repeated convergence test failures occurred
C                     on the last attempted step in DEBDF.  An inaccu-
C                     rate Jacobian may be the problem.  If you are
C                     absolutely certain you want to continue, restart
C                     the integration at the current T by setting
C                     INFO(1)=0 and call the code again.
C
C             IDID = -7, repeated error test failures occurred on the
C                     last attempted step in DEBDF.  A singularity in
C                     the solution may be present.  You should re-
C                     examine the problem being solved.  If you are
C                     absolutely certain you want to continue, restart
C                     the integration at the current T by setting
C                     INFO(1)=0 and call the code again.
C
C             IDID = -8,..,-32  --- cannot occur with this code but
C                     used by other members of DEPAC or possible future
C                     extensions.
C
C                         *** Following a Terminated Task ***
C         If
C             IDID = -33, you cannot continue the solution of this
C                     problem.  An attempt to do so will result in your
C                     run being terminated.
C
C **********************************************************************
C
C         ***** Warning *****
C
C     If DEBDF is to be used in an overlay situation, you must save and
C     restore certain items used internally by DEBDF  (values in the
C     common block DEBDF1).  This can be accomplished as follows.
C
C     To save the necessary values upon return from DEBDF, simply call
C        SVCO(RWORK(22+NEQ),IWORK(21+NEQ)).
C
C     To restore the necessary values before the next call to DEBDF,
C     simply call    RSCO(RWORK(22+NEQ),IWORK(21+NEQ)).
C***REFERENCES  SHAMPINE L.F., WATTS H.A., *DEPAC - DESIGN OF A USER
C                 ORIENTED PACKAGE OF ODE SOLVERS*, SAND79-2374,
C                 SANDIA LABORATORIES, 1979.
C***ROUTINES CALLED  LSOD,XERRWV
C***COMMON BLOCKS    DEBDF1
C***END PROLOGUE  DEBDF
C
C
      LOGICAL INTOUT
C
      DIMENSION Y(NEQ),INFO(15),RTOL(*),ATOL(*),RWORK(LRW),IWORK(LIW),
     1          RPAR(*),IPAR(*)
C
      COMMON /DEBDF1/ TOLD, ROWNS(210),
     1   EL0, H, HMIN, HMXI, HU, TN, UROUND,
     2   IQUIT, INIT, IYH, IEWT, IACOR, ISAVF, IWM, KSTEPS,
     3   IBEGIN, ITOL, IINTEG, ITSTOP, IJAC, IBAND, IOWNS(6),
     4   IER, JSTART, KFLAG, L, METH, MITER, MAXORD, N, NQ, NST, NFE,
     5   NJE, NQU
C
      EXTERNAL F , JAC
C
C.......................................................................
C
C  INITIALIZE A COUNTER FOR MONITORING AN INFINITE LOOP PITFALL
C
      DATA INFLOP/0/
C
C.......................................................................
C
C     CHECK FOR AN APPARENT INFINITE LOOP
C
C***FIRST EXECUTABLE STATEMENT  DEBDF
      IF (INFLOP .LT. 5) GO TO 10
      IF (T .NE. RWORK(21 + NEQ)) GO TO 10
      CALL XERRWV( 'DEBDF -- AN APPARENT INFINITE LOOP HAS BEEN DETECTED
     1.  YOU HAVE MADE           REPEATED CALLS AT  T = (R1) AND INTEGRA
     2TION HAS NOT ADVANCED.         CHECK THE WAY YOU HAVE SET PARAMETE
     3RS FOR THE CALL TO THE             CODE, PARTICULARLY INFO(1).', 2
     446,13,2,0,0,0,1,T,0.)
      RETURN
C
   10 IDID=0
C
C     CHECK VALIDITY OF INFO PARAMETERS
C
      IF (INFO(1) .EQ. 0  .OR.  INFO(1) .EQ. 1) GO TO 20
      CALL XERRWV( 'DEBDF -- INFO(1) MUST BE SET TO 0 FOR THE START OF A
     1 NEW PROBLEM, AND          MUST BE SET TO 1 FOLLOWING AN INTERRUPT
     2ED TASK.  YOU ARE              ATTEMPTING TO CONTINUE THE INTEGRAT
     3ION ILLEGALLY BY CALLING           THE CODE WITH  INFO(1) = (I1).'
     4,249,3,1,1,INFO(1),0,0,0.,0.)
      IDID=-33
C
   20 IF (INFO(2) .EQ. 0  .OR.  INFO(2) .EQ. 1) GO TO 30
      CALL XERRWV( 'DEBDF -- INFO(2) MUST BE 0 OR 1 INDICATING SCALAR AN
     1D VECTOR ERROR             TOLERANCES, RESPECTIVELY.   YOU HAVE CA
     2LLED THE CODE WITH             INFO(2) = (I1).',                16
     34,4,1,1,INFO(2),0,0,0.,0.)
      IDID=-33
C
   30 IF (INFO(3) .EQ. 0  .OR.  INFO(3) .EQ. 1) GO TO 40
      CALL XERRWV( 'DEBDF -- INFO(3) MUST BE 0 OR 1 INDICATING THE INTER
     1VAL OR                     INTERMEDIATE-OUTPUT MODE OF INTEGRATION
     2, RESPECTIVELY.                YOU HAVE CALLED THE CODE WITH  INFO
     3(3) = (I1).',195,5,1,1,INFO(3),0,0,0.,0.)
      IDID=-33
C
   40 IF (INFO(4) .EQ. 0  .OR.  INFO(4) .EQ. 1) GO TO 50
      CALL XERRWV( 'DEBDF -- INFO(4) MUST BE 0 OR 1 INDICATING WHETHER O
     1R NOT THE                  INTEGRATION INTERVAL IS TO BE RESTRICTE
     2D BY A POINT TSTOP.            YOU HAVE CALLED THE CODE WITH  INFO
     3(4) = (I1).',195,14,1,1,INFO(4),0,0,0.,0.)
      IDID=-33
C
   50 IF (INFO(5) .EQ. 0  .OR.  INFO(5) .EQ. 1) GO TO 60
      CALL XERRWV( 'DEBDF -- INFO(5) MUST BE 0 OR 1 INDICATING WHETHER T
     1HE CODE IS TOLD TO         FORM THE JACOBIAN MATRIX BY NUMERICAL D
     2IFFERENCING  OR  YOU            PROVIDE A SUBROUTINE TO EVALUATE I
     3T ANALYTICALLY.  YOU HAVE           CALLED THE CODE WITH  INFO(5)=
     4 (I1).',256,15,1,1,INFO(5),0,0,0.,0.)
      IDID=-33
C
   60 IF (INFO(6) .EQ. 0  .OR.  INFO(6) .EQ. 1) GO TO 70
      CALL XERRWV( 'DEBDF -- INFO(6) MUST BE 0 OR 1 INDICATING WHETHER T
     1HE CODE IS TOLD TO          TREAT THE JACOBIAN AS A FULL (DENSE) M
     2ATRIX OR AS HAVING A            SPECIAL BANDED STRUCTURE.  YOU HAV
     3E CALLED THE CODE WITH             INFO(6) = (I1).',234,16,1,1,  I
     4NFO(6),0,0,0.,0.)
      IDID=-33
C
   70 ILRW=NEQ
      IF (INFO(6) .EQ. 0) GO TO 80
C
C     CHECK BANDWIDTH PARAMETERS
C
      ML=IWORK(1)
      MU=IWORK(2)
      ILRW=2*ML+MU+1
      IF (ML .GE. 0  .AND.  ML .LT. NEQ      .AND.
     1    MU .GE. 0  .AND.  MU .LT. NEQ)    GO TO 80
      CALL XERRWV(   'DEBDF -- YOU HAVE TOLD THE CODE (INFO(6) = 1) THAT
     1 THE JACOBIAN MATRIX         HAS A SPECIAL BANDED STRUCTURE.  HOWE
     2VER, THE LOWER (UPPER)           BANDWIDTHS  ML (MU) VIOLATE THE C
     3ONSTRAINTS   ML,MU .GE. 0            AND  ML,MU .LT. NEQ.  YOU HAV
     4E CALLED THE CODE WITH                   ML = (I1)  AND  MU = (I2)
     5.',315,17,1,2,ML,MU,0,0.,0.)
      IDID=-33
C
C     CHECK LRW AND LIW FOR SUFFICIENT STORAGE ALLOCATION
C
   80 IF (LRW .GE. 250+(10+ILRW)*NEQ) GO TO 100
C
      IF (INFO(6) .EQ. 1) GO TO 90
      CALL XERRWV(   'DEBDF -- LENGTH OF RWORK ARRAY MUST BE AT LEAST 25
     10 + 10*NEQ + NEQ*NEQ          YOU HAVE CALLED THE CODE WITH  LRW =
     2 (I1).',122,1,1,1,LRW,0,0,0.,0.)
      IDID=-33
      GO TO 100
C
   90 CALL XERRWV(      'DEBDF -- LENGTH OF RWORK ARRAY MUST BE AT LEAST
     1                             250 + 10*NEQ + (2*ML+MU+1)*NEQ      .
     2                                 YOU HAVE CALLED THE CODE WITH  LR
     3W = (I1).   ',191,18,1,1,LRW,0,0,0.,0.)
      IDID=-33
C
  100 IF (LIW .GE. 55+NEQ) GO TO 200
      CALL XERRWV(   'DEBDF -- LENGTH OF IWORK ARRAY MUST BE AT LEAST  5
     15 + NEQ.                      YOU HAVE CALLED THE CODE WITH  LIW =
     2 (I1).',122,2,1,1,LIW,0,0,0.,0.)
      IDID=-33
C
C     COMPUTE THE INDICES FOR THE ARRAYS TO BE STORED IN THE WORK ARRAY
C     AND RESTORE COMMON BLOCK DATA
C
  200 ICOMI = 21 + NEQ
      IINOUT = ICOMI + 33
C
      IYPOUT = 21
      ITSTAR = 21 + NEQ
      ICOMR = 22 + NEQ
C
      IF (INFO(1) .EQ. 0) GO TO 250
      INTOUT = IWORK(IINOUT) .NE. (-1)
C     CALL RSCO(RWORK(ICOMR),IWORK(ICOMI))
C
  250 IYH = ICOMR + 218
      IEWT = IYH + 6*NEQ
      ISAVF = IEWT + NEQ
      IACOR = ISAVF + NEQ
      IWM = IACOR + NEQ
      IDELSN = IWM + 2+ILRW*NEQ
C
      IBEGIN = INFO(1)
      ITOL = INFO(2)
      IINTEG = INFO(3)
      ITSTOP = INFO(4)
      IJAC = INFO(5)
      IBAND = INFO(6)
      RWORK(ITSTAR) = T
C
      CALL LSOD(F,NEQ,T,Y,TOUT,RTOL,ATOL,IDID,RWORK(IYPOUT),
     1          RWORK(IYH),RWORK(IYH),RWORK(IEWT),RWORK(ISAVF),
     2          RWORK(IACOR),RWORK(IWM),IWORK(1),JAC,INTOUT,
     3          RWORK(1),RWORK(12),RWORK(IDELSN),RPAR,IPAR)
C
      IWORK(IINOUT) = -1
      IF (INTOUT) IWORK(IINOUT) = 1
C
      IF (IDID .NE. (-2)) INFLOP = INFLOP + 1
      IF (T .NE. RWORK(ITSTAR)) INFLOP = 0
C     CALL SVCO(RWORK(ICOMR),IWORK(ICOMI))
      RWORK(11)=H
      RWORK(13)=TN
      INFO(1) = IBEGIN
C
      RETURN
      END
