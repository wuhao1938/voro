#!/usr/bin/perl
$hr=4;
$r=$hr*2;
$ls=63;
$d=8;
use Math::Trig;

open W,">worklist.hh";
print W "static const int hgrid=$hr;\n";
print W "static const int fgrid=$r;\n";
printf W "static const int hgridsq=%d;\n",$hr*$hr*$hr;
printf W "static const int seq_length=%d;\n",$ls+1;
printf W "static const unsigned int wl[%d];\n",($ls+1)*$hr*$hr*$hr;
close W;

open W,">worklist.cc";
printf W "template<class r_option>\n";
printf W "const unsigned int container_base<r_option>::wl[%d]={\n",($ls+1)*$hr*$hr*$hr;

for($kk=0;$kk<$hr;$kk++) {
	for($jj=0;$jj<$hr;$jj++) {
		for($ii=0;$ii<$hr;$ii++) {
			worklist($ii,$jj,$kk);
		}
	}
}

print W "};\n";
close W;

sub worklist {
	print "@_[0] @_[1] @_[2]\n";
	$ind=@_[0]+$hr*(@_[1]+$hr*@_[2]);
	$ac=0;$v++;
	$xp=$yp=$zp=0;
	$x=(@_[0]+0.5)/$r;
	$y=(@_[1]+0.5)/$r;
	$z=(@_[2]+0.5)/$r;
	$m[$d][$d][$d]=$v;
	add(1,0,0);add(0,1,0);add(0,0,1);
	add(-1,0,0);add(0,-1,0);add(0,0,-1);
	foreach $l (1..$ls) {
		$minwei=1e9;
		foreach (0..$ac-1) {
			$xt=@a[3*$_];$yt=@a[3*$_+1];$zt=@a[3*$_+2];
#			$wei=dis($x,$y,$z,$xt,$yt,$zt)+1*acos(($xt*$xp+$yt*$yp+$zt*$zp)/($xt*$xt+$yt*$yt+$zt*$zt)*($xp*$xp+$yp*$yp+$zp*$zp));
			$wei=adis($x,$y,$z,$xt,$yt,$zt)+0.02*sqrt(($xt-$xp)**2+($yt-$yp)**2+($zt-$zp)**2);
			$nx=$_,$minwei=$wei if $wei<$minwei;
		}
		$xp=@a[3*$nx];$yp=@a[3*$nx+1];$zp=@a[3*$nx+2];
		add($xp+1,$yp,$zp);add($xp,$yp+1,$zp);add($xp,$yp,$zp+1);
		add($xp-1,$yp,$zp);add($xp,$yp-1,$zp);add($xp,$yp,$zp-1);
		print "=> $l $xp $yp $zp\n" if $l<4; 
		push @b,(splice @a,3*$nx,3);$ac--;
	}
	$v++;
	for($i=0;$i<$#b;$i+=3) {
		$xt=@b[$i];$yt=@b[$i+1];$zt=@b[$i+2];
		$m[$d+$xt][$d+$yt][$d+$zt]=$v;
	}
	$m[$d][$d][$d]=$v;
	for($i=0;$i<$#b;$i+=3) {
		$xt=@b[$i];$yt=@b[$i+1];$zt=@b[$i+2];
		last if $m[$d+$xt+1][$d+$yt][$d+$zt]!=$v;
		last if $m[$d+$xt][$d+$yt+1][$d+$zt]!=$v;
		last if $m[$d+$xt][$d+$yt][$d+$zt+1]!=$v;
		last if $m[$d+$xt-1][$d+$yt][$d+$zt]!=$v;
		last if $m[$d+$xt][$d+$yt-1][$d+$zt]!=$v;
		last if $m[$d+$xt][$d+$yt][$d+$zt-1]!=$v;	
	}
	$j=$i/3;
	print W "\t$j";
	while ($#b>0) {
		$i-=3;
		$xt=shift @b;$yt=shift @b;$zt=shift @b;
		$o=0;
		$o|=1 if $m[$d+$xt+1][$d+$yt][$d+$zt]!=$v;
		$o^=3 if $m[$d+$xt-1][$d+$yt][$d+$zt]!=$v;
		$o|=8 if $m[$d+$xt][$d+$yt+1][$d+$zt]!=$v;
		$o^=24 if $m[$d+$xt][$d+$yt-1][$d+$zt]!=$v;
		$o|=64 if $m[$d+$xt][$d+$yt][$d+$zt+1]!=$v;
		$o^=192 if $m[$d+$xt][$d+$yt][$d+$zt-1]!=$v;
		$pack=($xt+64)|($yt+64)<<7|($zt+64)<<14|$o<<21;
		printf W ",%#x",$pack;
	}
	print W "," unless $ind==$hr*$hr*$hr-1;
	print W "\n";
	undef @a;
	undef @b;
}

sub add {
	if ($m[$d+@_[0]][$d+@_[1]][$d+@_[2]]!=$v) {
		$ac++;
		push @a,@_[0],@_[1],@_[2];
		$m[$d+@_[0]][$d+@_[1]][$d+@_[2]]=$v;
	}
}

sub dis {
	$xl=@_[3]+0.3-@_[0];$xh=@_[3]+0.7-@_[0];
	$yl=@_[4]+0.3-@_[1];$yh=@_[4]+0.7-@_[1];
	$zl=@_[5]+0.3-@_[2];$zh=@_[5]+0.7-@_[2];
	$dis=(abs($xl)<abs($xh)?$xl:$xh)**2
		+(abs($yl)<abs($yh)?$yl:$yh)**2
		+(abs($zl)<abs($zh)?$zl:$zh)**2;
	return sqrt $dis;
}

sub adis {
	$xco=$yco=$zco=0;
	$xco=@_[0]-@_[3] if @_[3]>0;
	$xco=@_[0]-@_[3]-1 if @_[3]<0;
	$yco=@_[1]-@_[4] if @_[4]>0;
	$yco=@_[1]-@_[4]-1 if @_[4]<0;
	$zco=@_[2]-@_[5] if @_[5]>0;
	$zco=@_[2]-@_[5]-1 if @_[5]<0;
	return sqrt $xco*$xco+$yco*$yco+$zco*$zco;
}
