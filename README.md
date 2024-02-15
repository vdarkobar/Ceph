# Ceph
highly reliable, easy to manage, and free.

---

Ceph RBD Snapshots & backups on Proxmox VE
```
ceph osd lspools
```
```
rbd ls {pool-name}
```
```
rbd snap create {pool-name}/{image-name}@$(date +%Y%m%d-%Hh%M)
```
```
rbd snap ls {pool-name}/{image-name}
```
```
rbd export {pool-name}/{snapshot-name} /tmp/{snapshot-name}
```
```
rbd export {pool-name}/{snapshot-name} - | nice xz -z8 -T4 > /tmp/{snapshot-name}_FULL-RBD-EXPORT.xz
```
```
rbd snap rollback {pool-name}/{image-name}@{snap-name}
```
```
rbd snap rm {pool-name}/{image-name}@{snap-name}
```
```
rbd snap purge {pool-name}/{image-name}
```
```
rbd snap protect {pool-name}/{image-name}@{snapshot-name}
rbd snap unprotect {pool-name}/{image-name}@{snapshot-name}
```
```
rbd clone {pool-name}/{parent-image}@{snap-name} {pool-name}/{child-image-name}
```
```
rbd children {pool-name}/{image-name}@{snapshot-name}
```
```
rbd flatten {pool-name}/{image-name}
```
```
rbd rm {pool-name}/{image-name}
```  
  
Attach disk to a new VM (reate VM without disk):
```
qm set {vmid} --scsi0 {pool-name}:{image-name}
```  
  
Show the disk usage of RBD images and their snapshots within a pool
```
rbd du --pool {pool-name}
rbd du --pool {pool-name} {image-name}
```
  
Monitoring the storage capacity of a Ceph cluster, Detailed Storage Utilization
```
ceph df
ceph df detail
```  
  
Benchmark the performance of these RBD images (read/write) disk will be destroyed
```
rbd bench --pool <pool_name> <image_name> --io-type write --io-size 4M --io-threads 16 --io-total 1G
rbd bench --pool <pool_name> <image_name> --io-type read --io-size 4M --io-threads 16 --io-total 1G
```

crontab addition for rbs-snaps.sh
```
crontab -e
```
```
# Every 15 minutes
*/15 * * * * /root/script.sh {pool-name}:{image-name} 15min
*/15 * * * * /root/script.sh {pool-name}:{image-name} 15min

# Every hour
0 * * * * /root/script.sh {pool-name}:{image-name} hourly

# Every day
0 0 * * * /root/script.sh {pool-name}:{image-name} daily

# Every week
0 0 * * 0 /root/script.sh {pool-name}:{image-name} weekly

# Every month
0 0 1 * * /root/script.sh {pool-name}:{image-name} monthly
```
