a = 1
b = 2
c = a + b
result = 0
if (c > 5) goto L1t
goto L1f
L1t:result = 1
L1f:result = (null) - 1
fac = 1
i = 1
L2l:if (i <= 10) goto L2t
goto L2f
L2t: fac = fac * i
i = i + 1
goto L2l
L2f: 