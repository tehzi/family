all: less coffee

less:
	bin/less &> /dev/null &

coffee:
	bin/coffee &> /dev/null &
	# coffee  -o ./js/ -cw ./coffee/