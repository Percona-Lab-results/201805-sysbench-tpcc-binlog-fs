HOST="--mysql-socket=/tmp/mysql.sock"
#HOST="--mysql-host=127.0.0.1"
MYSQLDIR=/opt/vadim/Percona-Server-5.7.21-20-Linux.x86_64.ssl100
DATADIR=/mnt/nvmi/sysbench
CONFIG=cnf/my-rocks.cnf
TEST=oltp_point_select

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

startmysql(){
  sync
  sysctl -q -w vm.drop_caches=3
  echo 3 > /proc/sys/vm/drop_caches
  ulimit -n 1000000
#  numactl --interleave=all /opt/vadim/Percona-Server-5.7.21-20-Linux.x86_64.ssl100/bin/mysqld --defaults-file=$CONFIG --basedir=/opt/vadim/Percona-Server-5.7.21-20-Linux.x86_64.ssl100 --user=root --rocksdb_block_cache_size=${BP}G &
  numactl --interleave=all /opt/vadim/Percona-Server-5.7.21-20-Linux.x86_64.ssl100/bin/mysqld --defaults-file=$CONFIG --basedir=/opt/vadim/Percona-Server-5.7.21-20-Linux.x86_64.ssl100 --user=root --rocksdb_block_cache_size=${BP}G &
}

shutdownmysql(){
  echo "Shutting mysqld down..."
  $MYSQLDIR/bin/mysqladmin shutdown -S /tmp/mysql.sock
}

waitmysql(){
        set +e

        while true;
        do
                $MYSQLDIR/bin/mysql -Bse "SELECT 1" mysql

                if [ "$?" -eq 0 ]
                then
                        break
                fi

                sleep 30

                echo -n "."
        done
        set -e
}

initialstat(){
  cp $CONFIG $OUTDIR
  cp $0 $OUTDIR
}

collect_mysql_stats(){
  $MYSQLDIR/bin/mysqladmin ext -i10 > $OUTDIR/mysqladminext.txt &
  PIDMYSQLSTAT=$!
}
collect_dstat_stats(){
  vmstat 1 > $OUTDIR/vmstat.out &
  PIDDSTATSTAT=$!
}


# cycle by buffer pool size
RUNDIR=res-tpcc-LZ4-cgroup-halfmem-minbinlog-sync10000-`date +%F-%H-%M`

for BP in 100 
#for BP in  5
#for BP in 100
do

for i in 56
#for i in 1 2 4 8 16 32 64 128 256 512
do

#echo "Restoring backup"
#rm -fr /data/sam/vadim/mysql
#cp -r /data/sam/vadim/mysql.LZ4 /data/sam/vadim/mysql

#startmysql &
#sleep 10
waitmysql

#echo $(( $BP + 10 ))G > /sys/fs/cgroup/memory/DBLimitedGroup/memory.limit_in_bytes
#sync; echo 3 > /proc/sys/vm/drop_caches
#cgclassify -g memory:DBLimitedGroup `pidof mysqld`

runid="mysql57.BP$BP"

# perform warmup
#for i in  56

        OUTDIR=$RUNDIR/$runid/thr$i
        mkdir -p $OUTDIR

./start_du.sh /data/sam/mysql $OUTDIR/du.txt &
PIDDU=$!

        # start stats collection
        initialstat
        collect_dstat_stats 


        time=3600
  	$MYSQLDIR/bin/mysql -e "SHOW ENGINE ROCKSDB STATUS\G" > $OUTDIR/show_stat_start.txt 
	./tpcc.lua --mysql-socket=/tmp/mysql.sock --mysql-user=root --mysql-db=sbrocks --time=360000 --threads=$i --report-interval=1 --tables=10 --scale=100 --use_fk=0 --mysql_storage_engine=rocksdb --mysql_table_options="COLLATE latin1_bin" --trx_level=RC --db-driver=mysql run |  tee -a $OUTDIR/res.txt
#--enable-purge=yes
  	$MYSQLDIR/bin/mysql -e "SHOW ENGINE ROCKSDB STATUS\G" > $OUTDIR/show_stat_end.txt 

        # kill stats
        set +e
        kill $PIDDSTATSTAT
#        kill $PIDDU
        set -e

        sleep 30
#	shutdownmysql
done


done
