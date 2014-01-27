NAME=cloudstack-simulator
FILE=$(NAME).box

all: clean provision package install

clean:
	rm -f $(FILE)
	vagrant destroy --force

provision:
	vagrant up --provision

package:
	vagrant package --output $(FILE)

install:
	vagrant box add $(NAME) $(FILE) --clean --force
