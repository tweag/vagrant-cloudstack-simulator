NAME=cloudstack-simulator
FILE=$(NAME).box

all: provision install

clean:
	rm -f $(FILE)
	vagrant destroy --force

provision: clean
	vagrant up --provision

package: $(FILE)
$(FILE):
	vagrant package --output $(FILE)

install: package
	vagrant box add $(NAME) $(FILE) --clean --force
