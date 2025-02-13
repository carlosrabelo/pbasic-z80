10 REM Number Guessing Game Demo
20 PRINT "Welcome to Guess the Number!"
30 LET T = RND(100)
40 PRINT "I have chosen a number between 1 and 100."
50 INPUT "Enter your guess: "; G
60 IF G < T THEN PRINT "Too low! Try again."
70 IF G > T THEN PRINT "Too high! Try again."
80 IF G = T THEN GOTO 110
90 GOTO 50
110 PRINT "Congratulations! You guessed correctly!"
120 END
RUN
