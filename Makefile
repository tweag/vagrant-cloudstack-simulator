all: clean provision package

clean:
	rm -f cloudstack-simulator.box
	vagrant destroy --force

provision:
	vagrant up --provision

package:
	vagrant package --output cloudstack-simulator.box
