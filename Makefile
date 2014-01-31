NAME=cloudstack-simulator
FILE=$(NAME).box

all: clean provision install

clean:
	rm -f $(FILE)
	vagrant destroy --force

provision:
	vagrant up --provision

package: $(FILE)
$(FILE):
	vagrant package --output $(FILE)

install: package
	vagrant box add $(NAME) $(FILE) --clean --force
