NAME=cloudstack-simulator
FILE=$(NAME).box

all: clean install

clean:
	rm -f $(FILE)
	vagrant destroy --force

provision:
	vagrant up --provision

package: provision
	vagrant package --output $(FILE)

install: package
	vagrant box add $(NAME) $(FILE) --clean --force
