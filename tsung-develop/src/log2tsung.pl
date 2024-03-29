#!/usr/bin/env perl
# -*- Mode: CPerl -*-
#
#  Copyright (C) 2004 Nicolas Niclausse
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.

# Auteur: Nicolas Niclausse (nicolas@niclux.org)
# Version: $Id$

# purpose: create a config file for tsung from a Combined Log file

use strict;
use Getopt::Long;
use Time::Local;

use vars qw ($help *verbose $version $thinktime_threshold $visit_timeout
            $session_threshold $max_pages $max_duration);
my %Months=('Jan','0', 'Feb','1', 'Mar','2', 'Apr','3', 'May','4', 'Jun','5',
            'Jul','6', 'Aug','7', 'Sep','8', 'Oct','9', 'Nov','10', 'Dec','11');

my $tagvsn = '1.7.1_dev';

GetOptions( "help",\$help,
            "verbose",\$verbose,
            "tt=i",\$thinktime_threshold,
            "st=i",\$session_threshold,
            "visit_timeout=i",\$visit_timeout,
            "max_pages=i",\$max_pages,
            "max_duration=i",\$max_duration,
            "version",\$version
          );

my $prefix ="/usr";
my $dtd ="${prefix}/share/tsung-1.0.dtd";

# remove thinktime less than 1 sec
$thinktime_threshold ="1" unless $thinktime_threshold;
# remove session with less than 2 requests
$session_threshold ="2"unless $session_threshold;

my $ims = "Fri, 14 Nov 2003 02:43:31 GMT"; # if modified since ... for 304

# if thinktime is more than $visit_timeout, it's a new session
$visit_timeout=600 unless $visit_timeout;

$max_pages    =  100 unless $max_pages ;   # 100 pages max per session
$max_duration = 3600 unless $max_duration; # 1hour max session duration

my %hit;
my %http;
my $visite;
my ($time,$sec,$min,$hour,$mday,$mon,$year);
my $total;
my $bad = 0;
my $user;
my $id;
my $visit_tot=0;

&usage if $help or $Getopt::Long::error;
&version if $version;

while (<>) {
    if (m@.*([\w\.]+) \S+ \S+ \[(\w+/\w+/\w+:\d+:\d+:\d+)([^\]]+)\] \"(\w+) ([^\"]+)\" (\d+) (\S+) \"([^\"]*)\" \"([^\"]*)\".*$@) {
        my $ip      = $1;
        my $date    = $2;
        my $code    = $6;
        my $referer = $8;
        my $method  = $4;
        my $user_agent = $9;
        my $req     = $5;
        my ($url, $protocole) = split(/\s+/,$req);
        $url = &replace_entities($url);
        my $version;
        if ($protocole =~ /HTTP\/(\d\.\d)/) {
            $version=$1;
        } else {
            $version="1.0";
        }
        $date =~ m'(\d+)/(\w+)/(\d+):(\d+):(\d+):(\d+)';
        $mday =  $1;
        $mon = $Months{$2};
        $year = $3 - 1900;
        $hour = $4;
        $min = $5;
        $sec = $6;
        $time = timelocal($sec,$min,$hour,$mday,$mon,$year);
        $user = "$ip-$user_agent";
        if ($visite->{$user}) {
            if ($time - $visite->{$user}->{'last_visit'} > $visit_timeout) {
                # new visit
                $visit_tot ++;
                $visite->{$user}->{'id'}++;
                $id = $visite->{$user}->{'id'};
                $visite->{$user}->{'last_visit'}=$time;
                $visite->{$user}->{'last_referer'}=$referer;
                $visite->{$user}->{$id}->{'started'}=$time;
                $visite->{$user}->{$id}->{'last_request'}=$time;
                $visite->{$user}->{$id}->{'page'}=1;
                $visite->{$user}->{$id}->{'hit'}=1;
                $visite->{$user}->{$id}->{'duration'}=0;
                $visite->{$user}->{$id}->{'tsung'} = '<session name="'.$ip."-".$id.'" type="ts_http">'."\n";
                $visite->{$user}->{$id}->{'tsung'} .= "\t".'<request><http url="'.$url.'" version="'.$version.'" method="'.$method.'"';
                if ($code  == 304) {
                    $visite->{$user}->{$id}->{'tsung'} .= ' if_modified_since="'.$ims.'">';
                } else {
                    $visite->{$user}->{$id}->{'tsung'} .= '>';
                }
                $visite->{$user}->{$id}->{'tsung'} .= "</http></request>\n";
            } else {
                # same visit
                $id = $visite->{$user}->{'id'};
                $visite->{$user}->{$id}->{'hit'}++;
                my $thinktime = $time - $visite->{$user}->{$id}->{'last_request'};
                $visite->{$user}->{'last_visit'}=$time;
                $visite->{$user}->{$id}->{'last_request'}=$time;
                $visite->{$user}->{$id}->{'tsung'} .= "\t".'<thinktime value="'.$thinktime.'"/>'."\n\n" if $thinktime > $thinktime_threshold;
                $visite->{$user}->{$id}->{'tsung'} .= "\t".'<request><http url="'.$url.'" version="'.$version.'" method="'.$method.'"></http></request>'."\n";
                # update duration
                $visite->{$user}->{$id}->{'duration'} = $time - $visite->{$user}->{$id}->{'started'} ;
                if ($visite->{$user}->{'last_referer'} eq $referer) {
                    # same page/frame
                } else {
                    # new frame/page
                    $visite->{$user}->{$id}->{'page'}++;
                    $visite->{$user}->{'last_referer'}=$referer;
                }
            }
        } else {# new visitor
            $visit_tot ++;
            $visite->{$user}->{'id'}=1;
            $id = 1;
            $visite->{$user}->{'last_visit'}=$time;
            $visite->{$user}->{'last_referer'}=$referer;
            $visite->{$user}->{$id}->{'started'}=$time;
            $visite->{$user}->{$id}->{'last_request'}=$time;
            $visite->{$user}->{$id}->{'hit'}=1;
            $visite->{$user}->{$id}->{'page'}=1;
            $visite->{$user}->{$id}->{'duration'}=0;
            $visite->{$user}->{$id}->{'tsung'} = '<session name="'.$ip."-".$id.'" type="ts_http">'."\n";
            $visite->{$user}->{$id}->{'tsung'} .= "\t".'<request><http url="'.$url.'" version="'.$version.'" method="'.$method.'"></http></request>'."\n";
        }
        $total ++;
    } else {
#       print STDERR "$_\n";
        $bad ++;
    }
}
my $users_tot=scalar %{$visite};
my $page_tot=0;
my $hit_tot=0;
my $bad_visit =0;
my $bad_pages =0;
print STDERR "number of unique users is $users_tot\n" if $verbose;
print '<?xml version="1.0"?>
<!DOCTYPE tsung SYSTEM "'.$dtd.'" [] >
';
print '<tsung loglevel="notice" dumptraffic="false" version="1.0">
<clients>
    <client host="localhost" maxusers="950" />
</clients>
<servers>
 <server host="myservername" port="80" type="tcp"></server>
</servers>

<arrivalphase phase="1" duration="10" unit="minute">
   <users interarrival="0.1" unit="second"></users>
</arrivalphase>

<sessions>
';
my $real_visit = 0;
foreach my $key (keys %$visite) {
    foreach my $id (1..$visite->{$key}->{'id'}) {
        my $page = $visite->{$key}->{$id}->{'page'};
        my $hit = $visite->{$key}->{$id}->{'hit'};
        $real_visit ++ if $hit > $session_threshold;
    }
}
my $first = 1;
foreach my $key (sort {$visite->{$a}->{'id'} cmp $visite->{$b}->{'id'}} keys %$visite) {
    my $tot_id = $visite->{$key}->{'id'};
    print STDERR "number of visit for $key is $tot_id\n" if $verbose;
    foreach my $id (1..$tot_id) {
        my $page = $visite->{$key}->{$id}->{'page'};
        my $hit = $visite->{$key}->{$id}->{'hit'};
        my $duration = $visite->{$key}->{$id}->{'duration'};
        if ($page < $max_pages and $duration < $max_duration) {
            $page_tot += $page;
            $hit_tot += $hit;
            print STDERR " page=$page hit=$hit duration=$duration\n" if $verbose;
        } else {
            $bad_visit++;
            $bad_pages +=$page;

            print STDERR "# page=$page hit=$hit duration=$duration\n" if $verbose;

        }
        next unless $hit > $session_threshold;
        my $pop=sprintf "%.3f",($first ? 100-(($real_visit-1) * int(100000/$real_visit)/1000) : int(100000/$real_visit)/1000 );
        $first = undef;
        my $tsung = $visite->{$key}->{$id}->{'tsung'};
        $tsung =~ s/\<session/<session probability=\"$pop\"/;
        print "$tsung</session>\n";
    }
}
print '</sessions></tsung>';
if ($verbose) {
    select STDERR;
    print "real_visit = $real_visit\n";
    print  "total_visit = $visit_tot  , bad visit = $bad_visit  ";
    printf  "page/visit = %.2f\n",($page_tot/($visit_tot-$bad_visit));
    print  "good_pages = $page_tot , bad pages = $bad_pages  ";
    printf  "hit/page = %.2f\n",($hit_tot/$page_tot);
    print  "bad   = $bad\n";
}

sub replace_entities {
    my $str = shift;
    $str =~ s/\&/\&amp;/g;
    $str =~ s/\'/\&apos;/g;
    $str =~ s/\"/\&quot;/g;
    $str =~ s/>/\&gt;/g;
    $str =~ s/</\&lt;/g;
    return $str;
}
sub usage {
    print "log2tsung.pl:  create a config file for tsung from a Combined Log file\n\n";
    print "This script is part of tsung version $tagvsn,
Copyright (C) 2004 Nicolas Niclausse\n\n";
    print "tsung comes with ABSOLUTELY NO WARRANTY; This is free software, and
ou are welcome to redistribute it under certain conditions
type `log2tsung.pl --version` for details.\n\n";

    print "Usage: $0 [<options>]  <log file>\n","Available options:\n\t",
    "[--help] (this help text)\n\t",
    "[--version] (print version)\n\t",
    "[--tt <integer>] (thinktime threshold: min thinktime (def=2))\n\t",
    "[--st <integer>] (session threshold : min number of requests (def=2))\n\t",
    "[--max_duration <integer>] (maximum session duration in sec. (3600))\n\t",
    "[--max_pages <integer>] (maximum number of pages winthin a session. (100))\n\t";
    exit;
    }

sub version {
print "this script is part of tsung version $tagvsn

Written by Nicolas Niclausse

Copyright (C) 2004-2006 Nicolas Niclausse

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program (see COPYING); if not, write to the 
Free Software Foundation, Inc., 59 Temple Place - Suite 330, 
Boston, MA 02111-1307, USA.";
exit;
}
