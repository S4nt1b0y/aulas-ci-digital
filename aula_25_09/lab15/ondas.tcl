database -open waves -into waves.shm -default
probe -create tb_top -all -depth 2 -database waves
run 100us
exit