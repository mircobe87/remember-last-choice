#!/bin/bash

CONFIG_FILE=/etc/default/grub
BACKUP_DIR=/tmp

# Make sure only root can run our script
if [ $EUID -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

if [ -f $CONFIG_FILE ]; then
    if [ -w $CONFIG_FILE ]; then
        if [ -w $CONFIG_FILE ]; then
            # make a backup for the GRUB configuration file
            cp $CONFIG_FILE $BACKUP_DIR/$CONFIG_FILE

            # comment already existing configuration entries
            sed -i -r 's/(GRUB_DEFAULT.*)/#\1/g' $CONFIG_FILE
            sed -i -r 's/(GRUB_SAVEDEFAULT.*)/#\1/g' $CONFIG_FILE

            # add the configurations
            echo "" >> $CONFIG_FILE
            echo '# Make GRUB able to remeber last user choise' >> $CONFIG_FILE
            echo "GRUB_DEFAULT=saved" >> $CONFIG_FILE
            echo "GRUB_SAVEDEFAULT=true" >> $CONFIG_FILE

            # show the new configuration
            echo "================================"
            echo "FILE: $CONFIG_FILE"
            echo "--------------------------------"
            cat -n $CONFIG_FILE
            echo "================================"
            echo "Do you want to keep the current new settings?"
            select opt in "OK" "Restore backup"
            do
                case $opt in
                    "OK")
                        update-grub
                        break
                        ;;
                    "Restore backup")
                        cp $BACKUP_DIR/$CONFIG_FILE $CONFIG_FILE
                        break
                        ;;
                    *)
                        echo "Invalid option"
                        ;;
                esac
            done
            rm $BACKUP_DIR/$CONFIG_FILE
        else
            echo "the file '$CONFIG_FILE' has not write permission granted." 1>&2
            exit 3
        fi
    else
        echo "the file '$CONFIG_FILE' has not read permission granted." 1>&2
        exit 4
    fi
else
    echo -e "the file '$CONFIG_FILE' does not exist." 1>&2
    exit 2
fi

exit 0
