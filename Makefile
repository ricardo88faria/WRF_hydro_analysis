.PHONY: run tail kill

run:
	./WRF_hydro_analysis.R > log.out

tail:
	tail -f log.out

kill:
	killall R
