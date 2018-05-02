HOST="--mysql-socket=/tmp/mysql.sock"
#HOST="--mysql-host=127.0.0.1"
MYSQLDIR=/opt/vadim/Percona-Server-5.7.21-20-Linux.x86_64.ssl100
DATADIR=/data/sam/mysql
CONFIG=cnf/my.cnf
TEST=oltp_point_select

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

startmysql(){
  sync
  sysctl -q -w vm.drop_caches=3
  echo 3 > /proc/sys/vm/drop_caches
  ulimit -n 1000000
  numactl --interleave=all /opt/vadim/Percona-Server-5.7.21-20-Linux.x86_64.ssl100/bin/mysqld --defaults-file=$CONFIG --basedir=/opt/vadim/Percona-Server-5.7.21-20-Linux.x86_64.ssl100 --user=root --innodb_buffer_pool_size=${BP}G --datadir=$DATADIR &
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

RUNDIR=res-tpcc-inno-EXT4-full-binlog-sync1000-`date +%F-%H-%M`
#for BP in 100 90 80 70 60 50 40 30 20 10 5
#for BP in  90 80 70 60 50 40
for BP in 80 70 60 
#for BP in  50 40
#for BP in 100 
do

echo "Restoring backup"
rm -fr /data/sam/mysql
fstrim /data/sam
cp -r /opt/vadim/back/vadim/mysql.inno /data/sam/mysql

startmysql &
sleep 10
waitmysql

runid="mysql57.BP$BP"

# perform warmup

for i in  56
#for i in 1 2 4 8 16 64 128 256
do

        OUTDIR=$RUNDIR/$runid/thr$i
        mkdir -p $OUTDIR

        # start stats collection
        initialstat
        collect_dstat_stats 

        time=3600
	./tpcc.lua --mysql-socket=/tmp/mysql.sock --mysql-user=root --mysql-db=sbinno --time=3600 --threads=$i --report-interval=1 --tables=10 --scale=100  --trx_level=RR  --db-driver=mysql --report_csv=yes run |  tee -a $OUTDIR/res.txt

        # kill stats
        set +e
        kill $PIDDSTATSTAT
        set -e

        sleep 30
done

shutdownmysql

done
