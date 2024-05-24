FROM alpine:3.14
RUN apk update && apk upgrade && apk add openssh-server

# Use the ssh-demo image's legacy keys. To generate new ones, can do something
# like:
#   RUN ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -P ""
COPY ssh_host_ed25519_key /etc/ssh/ssh_host_ed25519_key
COPY ssh_host_ed25519_key.pub /etc/ssh/ssh_host_ed25519_key.pub

# A password needs to be set for login to work. An empty password is
# unproblematic as password-based login to root is not allowed.
RUN passwd -d root

# Use the ssh-demo user/client's legacy keys. To generate new ones, can do
# something like:
#   $ ssh-keygen -t ed25519 -f ccv0-ssh -P "" -C ""`
COPY ccv0-ssh.pub /root/.ssh/authorized_keys
ENTRYPOINT /usr/sbin/sshd -D

# Can connect to the running container with something like:
#   $ ssh -i ccv0-ssh root@<container-ip-addr>
