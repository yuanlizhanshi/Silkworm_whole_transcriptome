#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: exclude_rfam.pl
#
#        USAGE: ./exclude_rfam.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: QinSheng, embracethesky.blog.chinaunix.net, qinsheng.cn@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 2016/9/2 19:22:25
#     REVISION: ---
#===============================================================================

use 5.010;
use strict;
use warnings;
use utf8;

my %hash;

my @files = <*.tab>;

foreach my $in_file_1 ( @files ) {
    my ( $header ) = $in_file_1 =~ /(\S+?)\./;   # modify this regex by your need;
    my $in_file_2 = $header.'.collapse.fa';
    my $in_file_3 = $header.'.genome.arf';

    my $out_file_2 = $header.'.collapse.-rfam.fa';
    my $out_file_3 = $header.'.genome.-rfam.arf';

    my $IN1_file_name = $in_file_1;		# input file name
    
    open  my $IN1, '<', $IN1_file_name
        or die  "$0 : failed to open  input file '$IN1_file_name' : $!\n";
    
    while ( my $in = <$IN1> ) {
        if ( $in !~ /^#/ ) {
            my ( $type, $id ) = ( split /\s+/, $in )[0, 2];      
            if ( $type !~ /^mir-|^let-|^lin-|^bantam/ ) {
                $hash{$id} = '';
            }
        }
    }
    close  $IN1
        or warn "$0 : failed to close input file '$IN1_file_name' : $!\n";
    
    my $IN2_file_name = $in_file_2;		# input file name
    
    my $TO2_file_name = $out_file_2;		# output file name

    open  my $TO2, '>', $TO2_file_name
        or die  "$0 : failed to open  output file '$TO2_file_name' : $!\n";
    open  my $IN2, '<', $IN2_file_name
        or die  "$0 : failed to open  input file '$IN2_file_name' : $!\n";
    
    while ( my $in = <$IN2> ) {
        if ( $in =~ />(?<id>\w+)/ ) {
            unless ( exists $hash{$+{'id'}} ) {
                my $seq = <$IN2>;
                print $TO2 $in;
                print $TO2 $seq;
            }
        }
    }
    close  $IN2
        or warn "$0 : failed to close input file '$IN2_file_name' : $!\n";
    close  $TO2
        or warn "$0 : failed to close output file '$TO2_file_name' : $!\n";
    print "$in_file_2 has done...\n";
    
    my $IN3_file_name = $in_file_3;		# input file name
    
    my $TO3_file_name = $out_file_3;		# output file name

    open  my $TO3, '>', $TO3_file_name
        or die  "$0 : failed to open  output file '$TO3_file_name' : $!\n";

    
   
    open  my $IN3, '<', $IN3_file_name
        or die  "$0 : failed to open  input file '$IN3_file_name' : $!\n";
    
    while ( my $in = <$IN3> ) {
        $in =~ /^(?<id>\w+)/;
        unless ( exists $hash{$+{'id'}} ) {
            print $TO3 $in;
        }
    }
    close  $IN3
        or warn "$0 : failed to close input file '$IN3_file_name' : $!\n";
    close  $TO3
        or warn "$0 : failed to close output file '$TO3_file_name' : $!\n";
    print "$in_file_3 has done...\n";
} 
