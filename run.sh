# make ARCH=um mrproper

#./tools/testing/kunit/kunit.py run --kunitconfig drivers/gpu/drm/xe/.kunitconfig xe_wa --raw_output --kernel_args="loglevel=8 console=tty" 
#tools/testing/kunit/kunit.py run --kunitconfig drivers/gpu/drm/xe/.kunitconfig xe_wa*

#!/bin/bash
# distributed-kernel-build.sh
#HOSTST=("intel-habana@10.190.216.202" )
HOSTST=("intel-habana@10.190.216.202" "dbhadane@10.190.239.58")
BUILD_DIR="/tmp/kernel-build"
SOURCE_DIR="/home/dbhadane/dnyaneshwar/upstream/codebase/drm-tip"

# Sync source to all machines
for host in "${HOSTST[@]}"; do
	rsync -av --delete "$SOURCE_DIR/" "$host:$BUILD_DIR/" --exclude ".git" --info=progress2 &
done
wait

# Distribute subdirectory builds

#for server in "${HOSTST[@]}"; do
#	  echo "Current fruit: $server"
#	  ssh $server "pwd"
#	  wait
#done
#echo ${HOSTST[0]}

ssh ${HOSTST[1]} "cd $BUILD_DIR && make -j$(nproc) M=drivers" &
ssh ${HOSTST[0]} "cd $BUILD_DIR && make -j$(nproc) M=fs" &
ssh ${HOSTST[1]} "cd $BUILD_DIR && make -j$(nproc) M=net" &
wait

# Collect results and final link on main machine
for host in "${HOSTS[@]}"; do
#	rsync -av  "$SOURCE_DIR/" "$host:$BUILD_DIR/" --exclude ".git" --info=progress2 &
	rsync -av "$host:$BUILD_DIR/" "$SOURCE_DIR/" &
done
wait

# Final linking
#make vmlinux
