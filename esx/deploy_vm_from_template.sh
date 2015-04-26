### finalduty@github.com [rev: 8fe9263]
## Clone and Deploy VMWare Machine

## Set Source Template and Destination Name
dstvm='nfs-a01.finalduty.me'
srcvm='_template-centos'
srcpath='/vmfs/volumes/datastore0'
dstpath='/vmfs/volumes/datastore0'

src="$srcpath/$srcvm"
dst="$dstpath/$dstvm"

## Copy Files and Rename for New Guest
mkdir -p $dst
for i in `find $src/ -type f | egrep -v 'log|vmdk'`; do cp -p $i $dst/; done
for i in `ls $dst | grep $srcvm`; do mv $dst/$i $dst/`echo $i | sed "s|$srcvm|$dstvm|"`; done
vmkfstools -i $src/$srcvm.vmdk $dst/$dstvm.vmdk -d thin -a lsisas
sed -i "s|$srcvm|$dstvm|"g $dst/$dstvm.vmx
vmid=$(vim-cmd solo/registervm $dst/$dstvm.vmx)
vim-cmd vmsvc/power.on $vmid &
sleep 1; vim-cmd vmsvc/message $vmid _vmx1 2
vim-cmd vmsvc/getallvms | grep $vmid | grep $dstvm
vim-cmd vmsvc/power.getstate $vmid | grep Powered

