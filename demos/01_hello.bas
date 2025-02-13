10 REM Hello World and Counter Demo
20 PRINT "Hello from PBasic Z80!"
30 LET C = 1
40 PRINT "Count: "; C
50 LET C = C + 1
60 IF C <= 5 THEN GOTO 40
70 PRINT "Done counting!"
80 END
RUN
