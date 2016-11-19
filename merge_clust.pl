#!/usr/bin/perl
@merged = (0, 2, 4, 5, 7, 8, 9, 10, 12, 13, 15, 16, 18, 19);              						# example nodes 
@nel = ('0-7', '0-12', '0-15', '0-18', '2-9', '4-5', '5-7', '5-16', '8-10', '13-19');           # example connections

@cmerged = @merged;
@fset = @cmerged;
@red = ();
$next = $cmerged[0];
$p = 0;
@done = ();
@merclust = ();
$nc = 0;

for $k (0..scalar(@cmerged)-1)
{
@conn = ();
$flagN = 0;
$flagN1 = 0;
$flag = 0;
#========================== CHECK IF ALREADY CHECKED FOR ========================
#print "The Leftover set: ";
        for $rd (@red)
        {
#       print "$rd     ";
                if ($k == $rd)
                {
                $flagN = 1;             # already checked
                }
        }
print "\nNext: $next\n";
        if ($flagN == 0)
        {
        print "PROCEEDING FOR $next\n";
                for $j (0..scalar(@nel)-1)
                {
                @hold1 = split(/-/,$nel[$j]);
                        if ($next == $hold1[0])
                        {
                        $con = $hold1[1];
                        @conn = (@conn,$con);
                        $flag = 1;
                        }
                        elsif ($next == $hold1[1])
                        {
                        $con = $hold1[0];
                        @conn = (@conn,$con);
                        $flag = 1;
                        }
                        else
                        {
                        $flag = 0;
                        }
                 }
        print scalar(@conn),"    ",$flag,"\n";
                if ($flag == 0 || scalar(@conn) >= 1)
                {
                print "I am here\n";
                unshift (@conn,$next);
                @sconn = sort {$a <=> $b} (@conn);
                $mer = '';
                $mer = join('-',@sconn);
                print $mer,"\n";
                @collmer = (@collmer,$mer);
                @red = subtract(\@fset,\@sconn);
                print scalar(@fset),"   ",scalar(@sconn),"   ",scalar(@red),"\n";
                print "==========leftover set =======\n";
                foreach $r (@red){print $r," ";}
                print "\n============================== $p ", scalar(@sconn),"  $next\n";
                @conn = ();
                @fset = @red;
#               $next = $sconn[$p+1];
                @done = (@done,$next);
                @rest = subtract(\@sconn,\@done);
                @srest = sort {$a <=> $b} @rest;
                $next = $srest[0];
                print "Now do for $next\n";
                        if ($next eq "")
                        {
						$nc++;
						print "Last cluster does not grow any further\n";
                        $str1 = join('-',@collmer);
                        @comp = split(/-/,$str1);
                        %hh = ();
                                foreach $cm (@comp)
                                {
                                $hh{$cm}++;
                                }
                        @comp = sort {$a <=> $b} keys %hh;
                        $str1 = join('-',@comp);
                        print "The merged cluster is ($nc) : $str1\n";
                        @merclust = (@merclust,$str1);
                        @collmer = ();
                        @red = subtract(\@fset,\@comp);
                                if (scalar(@red) == 0)
                                {
                                goto SKIP;
                                }
                        print "==========new leftover set =======\n";
                        foreach $r (@red){print $r," ";}
                        $next = $red[0];
                        print "\n============================== $p ", scalar(@sconn),"  $next\n";
                        }
                $p++;
                }
        }
}
 
 
SKIP:

print "\ndone\n";

#=================================================================================

sub subtract
{
my ($r1,$r2) = @_;
my @set = @$r1;
my @subset = @$r2;
my $i = 0;
my $j = 0;
my @diff = ();
        for $i (0..scalar(@set)-1)
        {
        my $flag = 0;
                for $j (0..scalar(@subset)-1)
                {
                        if ($set[$i] == $subset[$j])
                        {
                        $flag = 1;
                        }
                }
                if ($flag == 0)
                {
                @diff = (@diff,$set[$i]);
                }
        }
return @diff;
@diff = ();
}

                        

## Main Output : 

#The merged cluster (1) is : 0-4-5-7-12-15-16-18
#The merged cluster (2) is : 2-9
#The merged cluster (3) is : 8-10
#The merged cluster (4) is : 13-19

 
