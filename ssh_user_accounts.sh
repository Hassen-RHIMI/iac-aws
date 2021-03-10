#!/bin/bash
users="toolchain jumper"
REMOTE_SSH_KEYS_DIR="/tmp"

create_user_account(){
    useradd -m $1
    mkdir /home/$1/.ssh
    touch /home/$1/.ssh/authorized_keys
    cat $REMOTE_SSH_KEYS_DIR/$1.pub >> /home/$1/.ssh/authorized_keys 
    if [ $? -eq 0 ];then
      echo "user '$1' is successfuly created"
      fix_permissions $user
      disable_password_ask $user
    else
      echo  "creation user '$1' is aborted"
    fi
}
fix_permissions(){
    chown -R $1:$1 /home/$1/.ssh
    chmod 0755 /home/$1/.ssh && sudo chmod 0600  /home/$1/.ssh/authorized_keys
}
disable_password_ask(){
    echo "$1 ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/$user > /dev/null 2>&1
    
}
for user in $users;do 
   getent passwd > /dev/null 2>&1
   [ $? -eq 0 ] && create_user_account "$user" || echo "user '$user' already created"
    
done