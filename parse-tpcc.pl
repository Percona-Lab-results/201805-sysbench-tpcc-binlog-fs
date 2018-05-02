#!/usr/bin/perl

#for bp in 100 50 25                                                                                                                 
#do                                                                                                                                  
#for i in 1 2 4 8 16 64 128 256 ; do ./parse.pl respara.db res-OLTP-RW-meltdown-network-4.4.0-112-oltp_read_only/mysql57-pareto.BP${bp}/thr$i/res.txt bp=${bp},filesystem=EXT4,binlog=minimal,syncbinlog=1000 ; done                                                           
#done

use DBI;

sub parse_query {
   my ( $query, $params ) = @_;
   $params ||= {};
   foreach $var ( split( /,/, $query ) ){
     my ( $k, $v ) = split( /=/, $var );
     $params->{$k} = $v;
   }
   return $params;
}

#print join(",",keys %$hh);

my $db = DBI->connect("dbi:SQLite:$ARGV[0]", "", "", {RaiseError => 1, AutoCommit => 0});

$db->do("CREATE TABLE IF NOT EXISTS results (sec INTEGER, threads INTEGER, tps REAL, reads REAL, writes REAL, rt REAL, runid TEXT,bp TEXT, filesystem TEXT, binlog TEXT, syncbinlog TEXT)");

my $hh=parse_query($ARGV[2]);
my $keysarg=join(",",keys %$hh);
my $valarg=join(",", map qq('$_'), values %$hh);

open FILE, $ARGV[1];
print "handing ",$ARGV[1],"\n";
my $line;
while ($line=<FILE>){
	my @ar = split(/,/, $line);
	if ($ar[0] =~ /^\d+$/) {
        #print $ar[0],",",$ar[1],",",$ar[2],",",$ar[7],"\n";
        #print $ar[1];
        $db->do("INSERT INTO results (sec,threads,tps,rt,runid,$keysarg) VALUES ($ar[0],$ar[1], $ar[2], $ar[7],'$ARGV[2]',$valarg)");
        #$db->do("INSERT INTO results (sec,threads,tps,reads,writes,rt,runid,$keysarg) VALUES ($1, $2, $3,$5,$6,$8,'$ARGV[2]',$valarg)");
	}
}
$db->do("COMMIT");
$db->disconnect();
