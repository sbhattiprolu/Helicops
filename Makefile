# Makefile

topdir=.
subdirs= arduino pc

all: subdirs

subdirs:
	@for dir in $(subdirs); do \
		(cd $$dir && make) || exit 1; \
	done
