all: less coffee

less:
	bin/less &> /dev/null &

coffee:
	bin/coffee &> /dev/null &
	# coffee  -o ./js/ -cw ./coffee/

png:
	convert -size 50x50 -alpha set -channel A -evaluate set 60% xc:black images/alpha60.png