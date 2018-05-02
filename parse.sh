dbs=rfs1.db
for bp in  80 70 60  ; do perl ./parse-tpcc.pl $dbs res-tpcc-inno-EXT4-full-binlog-sync0-2018-04-17-15-46/mysql57.BP${bp}/thr56/res.txt bp=${bp},filesystem=EXT4,binlog=full,syncbinlog=0 ; done
for bp in  80 70 60  ; do perl ./parse-tpcc.pl $dbs res-tpcc-inno-EXT4-full-binlog-sync1-2018-04-17-11-53/mysql57.BP${bp}/thr56/res.txt bp=${bp},filesystem=EXT4,binlog=full,syncbinlog=1 ; done
for bp in  80 70 60  ; do perl ./parse-tpcc.pl $dbs res-tpcc-inno-EXT4-full-binlog-sync1000-2018-04-18-00-15/mysql57.BP${bp}/thr56/res.txt bp=${bp},filesystem=EXT4,binlog=full,syncbinlog=1000 ; done
for bp in  80 70 60  ; do perl ./parse-tpcc.pl $dbs res-tpcc-inno-EXT4-full-binlog-sync10000-2018-04-18-10-30/mysql57.BP${bp}/thr56/res.txt bp=${bp},filesystem=EXT4,binlog=full,syncbinlog=10000 ; done
for bp in  80 70 60  ; do perl ./parse-tpcc.pl $dbs res-tpcc-inno-EXT4-no-binlog-sync0-2018-04-17-20-24/mysql57.BP${bp}/thr56/res.txt bp=${bp},filesystem=EXT4,binlog=no,syncbinlog=0 ; done
for bp in  80 70 60  ; do perl ./parse-tpcc.pl $dbs res-tpcc-inno-XFS-full-binlog-sync0-*/mysql57.BP${bp}/thr56/res.txt bp=${bp},filesystem=XFS,binlog=full,syncbinlog=0 ; done
for bp in  80 70 60  ; do perl ./parse-tpcc.pl $dbs res-tpcc-inno-XFS-full-binlog-sync1-*/mysql57.BP${bp}/thr56/res.txt bp=${bp},filesystem=XFS,binlog=full,syncbinlog=1 ; done
for bp in  80 70 60  ; do perl ./parse-tpcc.pl $dbs res-tpcc-inno-XFS-full-binlog-sync1000-*/mysql57.BP${bp}/thr56/res.txt bp=${bp},filesystem=XFS,binlog=full,syncbinlog=1000 ; done
for bp in  80 70 60  ; do perl ./parse-tpcc.pl $dbs res-tpcc-inno-XFS-full-binlog-sync10000-*/mysql57.BP${bp}/thr56/res.txt bp=${bp},filesystem=XFS,binlog=full,syncbinlog=10000 ; done
for bp in  80 70 60  ; do perl ./parse-tpcc.pl $dbs res-tpcc-inno-XFS-no-binlog-sync0-*/mysql57.BP${bp}/thr56/res.txt bp=${bp},filesystem=XFS,binlog=no,syncbinlog=0 ; done
