#!/usr/bin/perl

$filetag = 'topidNld_scf-';
$Nfiles = 100;
open (OUT,">scalefree.ldstat");

$Nset = 0;

for $i (1..$Nfiles)
{
    $file = $filetag.$i.'.out';
#    $pr=`ls -lart $file`;
#    chomp $pr;
#    print $pr,"\n";
    open (INP,"<$file");
    $arr = 'dat'.$i;
    @$arr = <INP>;
    close INP;
    for $j (0..scalar(@$arr)-1)
    {
	chomp $$arr[$j];
	$nsz[$i][$j] = int(substr($$arr[$j],0,5));
	$deg[$i][$j] = int(substr($$arr[$j],6,5));
	$ld[$i][$j] = substr($$arr[$j],12,8);
	$ld[$i][$j] =~ s/\s//g;
	$pmot[$i][$j] = substr($$arr[$j],23, );
	$pmot[$i][$j] =~ s/\s//g;
#	print "$nsz[$i][$j]  $deg[$i][$j]  $ld[$i][$j]\n";
    }
    $Nset = scalar(@$arr);
}

#print $Nset,"\n";

#goto SKIP;
#==================== Link Density: Expected, Mean, Std ================

for $j (0..$Nset-1)
{
    my $nC2=fact($nsz[1][$j])/(fact(2) * fact($nsz[1][$j]-2));
    $ld_exp[$j]=($nsz[1][$j]*$deg[1][$j]/2)/$nC2;
    $lden=0;
    $ldensq=0;
    $N=0;
    for $i (2..$Nfiles)
    {
#	print ">>$nsz[$i][$j] $deg[$i][$j]\n";
	if ($nsz[1][$j]==$nsz[$i][$j] && $deg[1][$j]==$deg[$i][$j])
	{
#	    print "It is a match: $nsz[1][$j] $deg[1][$j]\n";
	    $lden=$lden+$ld[$i][$j];
	    $ldensq=$ldensq+($ld[$i][$j])**2;
	    $N++;
	}
    }
    $ld_mean[$j]=$lden/$N;
    $ld_std[$j]=sqrt(abs(($ldensq/$N)-($ld_mean[$j]**2)));
    printf OUT "%10.5f  %10.5f  %10.5f\n",$ld_exp[$j],$ld_mean[$j],$ld_std[$j];
}

SKIP:

    $i=1;
    $arr = 'dat'.$i;

#$k=0;
for $k (0..scalar(@$arr)-1)
{
$nn=$nsz[1][$k];
$dd=$deg[1][$k];
$Nun=0;
#print "Network parameters: $nn :: $dd\n";
$umot = 0;
@matching_pairs = ();
	for $i (1..$Nfiles)
	{
    	$n1=$nsz[$i][$k];
    	$d1=$deg[$i][$k];
    	$nom=0;
    	$flag=0;
    		for $j (1..$Nfiles)
    		{
			if ($i != $j)
			{
			$n2=$nsz[$j][$k];
			$d2=$deg[$j][$k];
				if (($n1==$n2 && $d1==$d2) && ($n1==$nn && $d1==$dd))
				{
#	    			print ">>1>> $pmot[$i][$k]\n";
#	    			print ">>2>> $pmot[$j][$k]\n";
	    			@pm1=split(/\=/,$pmot[$i][$k]);
	    			@pm2=split(/\=/,$pmot[$j][$k]);
	    			%h1 = ();
	    			%h2 = ();
	    				foreach $aa (@pm1)
	   				{
#					print $aa,"\n";
					$h1{$aa}++;
	    				}
	    				foreach $bb (@pm2)
	    				{
#					print $bb,"\n";
					$h2{$bb}++;
	    				}
	    			@k1 = keys %h1;
	    			@v1 = values %h1;
	    			@k2 = keys %h2;
	    			@v2 = values %h2;
	    			$nmot1=scalar(@k1);
	    			$nmot2=scalar(@k2);
	    
					if ($nmot1 == $nmot2)
	    			    	{
#					print "Match found in the number of nodal motifs: $nmot1 <-> $nmot2\n";
			    	    	$nmatch = 0;
					    for $l1 (0..$nmot1-1)
					    {
						for $l2 (0..$nmot2-1)
						{
							if ($k1[$l1] eq $k2[$l2] && $v1[$l1] == $v2[$l2])
							{
#						    	print "Identical combo: $k1[$l1] -> $v1[$l1] :: $k2[$l2] -> $v2[$l2]\n";
							$nmatch++;
							}
						}
					    }
#				    print "NMATCH:  $nmatch\n";
					    if ($nmatch == $nmot1)
					    {
						$flag=1;
						if ($i<$j)
						{
#						print "Identical newtork motifs: $pmot[$i][$k] & $pmot[$j][$k]\n";
#						print "$i-$j\n";
						@matching_pairs = (@matching_pairs,($i.'-'.$j));
						}
					    }
					    else
					    {
						$nom++;
					    }
				    	}
				    	else
	    				{
					$nom++;
#					print "MISSMATCH in the number of nodal motifs:: $nmot1  $nmot2 :: $nn $dd  $n1 $d1  $n2 $d2\n";
#					print "$pmot[$i][$k]\n";
#					print "$pmot[$j][$k]\n";
	    				}
				}
			}
    		}
    	$mf = ($Nfiles-1)-$nom;
#    	print "$i ($nn, $dd) :: $nom  $mf\n";
    		if ($nom == ($Nfiles-1))
    		{
#		print "This motif never encountered twice: $pmot[$i][$k]\n";
		$Nun++;
    		}
	}
#print "$nn  $dd  :: $Nun\n";
	if (scalar(@matching_pairs) > 0)
	{
	open (OUT,">pairs.inp");
		foreach $a (@matching_pairs)
		{
    		print OUT $a,"\n";
		}	
	$hmmu = `./merge_clust.pl | grep "The merged cluster" | wc`;      # How many more unique
	}
	else
	{
	$hmmu=0;
	}
$totmot = $hmmu + $Nun;
printf "%5d %5d %5d : %5d %5d %5d\n",$nn,$dd,$Nfiles,$Nun,$hmmu,$totmot;
}


sub fact 
{
    my ($num) = @_;
#    print $num,"\n";
    my $factnum = 1;
    for ($i=$num;$i>=1;$i--)
    {
	$factnum = $factnum*$i;
    }
    return $factnum;
}




