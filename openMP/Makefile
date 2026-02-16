CC=gcc
CCMACS = gcc-15
CFLAGS = -Wall -O2 -fopenmp



totient: TotientRange.c
	$(CC) $(CFLAGS) -o totient TotientRange.c


mac: TotientRange.c
	$(CCMACS) $(CFLAGS) -o totient TotientRange.c


test: totient
	./totient 0 100
	./totient 0 1000	
#	./totient 5 3000
#	./totient 100 10000


mac-test: mac test


.PHONY: clean

clean:
	rm -f totient
#	rm totient

re: clean totient test


re-mac: clean mac test

