#!/bin/bash

handle_optical(){

doc <<EOD

    handle_optical
    --------------

    Executes common actions on cd/dvd images.

    Actually available actions:

    * save_disk: Copies the content of a cd/dvd to an iso image
    * write_iso: Writes an ISO image to a cd/dvd
    * write_dir: Creates an ISO image and writes it into a cd/dvd
    * erase_dev: Cleans a rw cd/dvd.

    :param action: Action to execute
    :param device: Device to execute actions on
    :param file: File/Source/Destiny folder to execute actions on

EOD

eval $endoc

    action=$1; shift
    cd_${action} ${@}
}

cd_erase_disk(){
doc <<EOD

    cd_erase_disk
    -------------

    Erases the content of a rw drive

    :param drive: cd/dvd drive

EOD

eval $endoc

    wodim blank=fast -eject dev=$1; 
}

cd_write_dir(){
doc <<EOD

    cd_write_dir
    ------------

    Creates an ISO image from a directory and then 
    writes it into a cd/dvd

    :param drive: cd/dvd drive
    :param dir: directory to write on the cd/dvd

EOD

eval $endoc

    temp=$(mktemp)
    mkisofs -o ${temp}.iso -J -r -v $2 
    cdtool "write_iso" $1 ${temp}.iso 
    rm ${temp}.iso

}

cd_write_iso(){
doc <<EOD

    cd_write_iso
    ------------

    Writes an ISO image to a cd/dvd drive

    :param drive: cd/dvd drive
    :param file: File to write cd/dvd image from

EOD

eval $endoc

    {
        wodim -eject -tao speed=1 dev=$1 -v -data $2
    } || {
        wodim -eject -tao speed=1 dev=$1 -v -data $2
    }
}

cd_save_disk(){
doc <<EOD

    cd_save_disk
    ------------

    Saves a cd/dvd to disk

    :param drive: cd/dvd drive
    :param file: destination file

EOD

eval $endoc

    dd if=$1 of=$2 bs=2048 conv=sync,notrunc; 
}
