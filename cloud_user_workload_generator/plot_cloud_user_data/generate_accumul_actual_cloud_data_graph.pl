#!/usr/bin/perl

use strict;

my $this_dir = ".";

my $gnuplot_scripts_dir = $this_dir ."/gnuplot_scripts";
my $graphs_dir = $this_dir . "/graphs";

if( @ARGV < 1 ){
        print "Need 1 Input: <directory_of_cloud_user_logs>\n";
        exit(1);
};

my $data_dir = shift @ARGV;

system("./create_accumul_actual_cloud_user_data.pl $data_dir");

my $scr_name = "gnuplot_script_accumul_actual_cloud_display.script";
my $data_name = "accumul_actual_cloud_display.log";
my $png_name = "accumul_actual_cloud_display.png";

my $scr_loc = $gnuplot_scripts_dir . "/" . $scr_name;
my $png_loc = $graphs_dir . "/" . $png_name;
my $data_loc = $data_dir . "/" . $data_name;

if( !(-e "$data_loc" ) ){
	print "[ERROR] Cannot locate data file $data_loc\n";
	exit(1);
};

my $y_max = 6;
my $tempbuf = `tail -n 3 $data_loc`;
my @array1 = split(" ", $tempbuf);
foreach my $item (@array1){
        if( $item =~ /^(\d+)$/ ){
                my $num = $1;
                if(  $num > $y_max ){
                        $y_max = $num;
                };
        };
};
$y_max = $y_max + 4;

print "MAX Y RANGE: $y_max\n";

my $ytics = 10;

if( int($y_max / 10) > $ytics ){
	$ytics = int($y_max/10);
};

print "\n";
print "================= PLOT ACCUMUL. ACTUAL RESOURCES  =====================\n";
print "\n";

system("mkdir -p $gnuplot_scripts_dir");
system("mkdir -p $graphs_dir");

open( SCR, "> $scr_loc" ) or die $!;

print SCR "set title \"EUCA MONKEY: ACCUMUL. ACTUAL RESOURCES\"\n";
print SCR "set key outside top\n";
print SCR "set border linewidth 2\n";
print SCR "set xdata time\n";
print SCR "set timefmt \"%Y-%m-%d:%H:%M:%S\"\n";
print SCR "set xlabel \"MINUTE\"\n";
print SCR "set format x \"%M\"\n";
print SCR "set ylabel \"COUNT\"\n";
print SCR "set ytics 0, " . $ytics . "\n";
print SCR "set yrange [-2:" . $y_max . "]\n";
print SCR "set terminal png size 1200, 800\n";
print SCR "set output \"" . $png_loc ."\"\n";
print SCR "plot \"" . $data_loc . "\" using 1:5 title \"Running Instances\" with lines,";
print SCR "\"" . $data_loc . "\" using 1:6 title \"Volumes\" with lines,";
print SCR "\"" . $data_loc . "\" using 1:7 title \"Snapshots\" with lines,";
print SCR "\"" . $data_loc . "\" using 1:8 title \"Security Groups\"with lines,";
print SCR "\"" . $data_loc . "\" using 1:9 title \"Keypairs\"with lines,";
print SCR "\"" . $data_loc . "\" using 1:10 title \"IP Addresses\"with lines\n";
print SCR "exit\n";

close( SCR );

system("gnuplot $scr_loc");

print "\n";
print "===================== DONE =====================\n";
print "\n";

exit(0);

1;

