#! usr\bin\perl
#! D:\Software\OtherApp\Strawberry\perl\bin\perl

## Copyright (C) 2019 Novelbio
## Running Platform: Windows
## Updator: LI, Yadang          Update time: 2019.07.22
## Author:  LI, Yadang          Create time: 2019.07.21
## Information: The function of this script is to format text as Markdown for task doc

use 5.016;
use strict;
use warnings;
use Encode;

&main;
sub main {
    our ( @file, $ctrl, @md );
    my  ( $txt );
    &GV;
    say "\nPlease type in $file[1]" and system "start $file[1]";
    say 'Ready?';	chomp ( $ctrl = <STDIN> );
    $txt = &read_file_into_string ( $file[1] );
    &txt2md ( $txt );
    &write_file ( $file[2], @md );
    system "start $file[2]";
}

sub GV {  ## set Global Variables
  	our ( @ctrl, @Gdir, @file, @keyword, @replace );
  	my $stop = 0;
  	@ctrl[0..1] = ( 1, 1 );
  	@Gdir = qw ( 1
  		D:\Work\program\TestData\
  	);
  	@file = qw( 2
  		txt2md.txt
      md.txt
  	);
  	$_ = $Gdir[1].$_ for @file[1..2];
  	@keyword = qw( 1_5_9_10_11_14_18
      工具介绍 分析流程 参数设置 结果解读
      功能概述 软件特点 软件官网 结果文件结构
      输入文件参数
      页面显示参数
      上游工具 下游工具 连接示例
      图 表 文件 说明 ：
      ├─
      （
    );
    @replace = ( 4,
      "<div style=\"text-align:center\">\n<img data-src=\"",
      '.png" height="',
      '.png" width="',
      "px\" ></img>\n<\/div>",
      "　  "
    );  #say &utf2gbk(">$_<") for @replace;
  	(-d $Gdir[$_]) ? () : (say "!!! \$Gdir[$_] $Gdir[$_] does not exist" and ++$stop) for 1 .. $#Gdir;
  	(-e $_) ? () : (say "!!! file $_ does not exist" and ++$stop) for $file[1];
  	exit if $stop > 0;
}

sub txt2md {
    our ( @keyword, @replace, @md );
    my ( $txt, $r, $tree ) = $_[0];
    $txt = &para_format ( $txt );
    $txt = &link_format ( $txt );
    $txt = &otpt_format ( $txt );
    $txt = &plot_format ( $txt );
    $txt = &head_format ( $txt );
    $txt = &tree_format ( $txt );
    $txt = &list_format ( $txt );
    @md = split "\n", $txt;    #say $txt;    #say &utf2gbk($_) for @md;
}

##  Func: add  <label id='xxx'> </label> for each parameter
sub para_format {
    our ( @keyword );
    my  ( $txt, @row, $r, $para ) = $_[0];
    @row = split "\n", $txt;
    for $r( 1..$#row ) {
      next unless $row[$r] =~ /$keyword[10] (.+)/;
      $para = $1;
      $para =~ s/\s//g;
      $para =~ s/\(optional\)$//;
      $row[$r] =~ s/$keyword[10]/<label id='$para'> <\/label>\n$keyword[10]/;
    }
    $txt = join "\n", @row;
}

##  Func: add the following text in link section
##  <div style="text-align:center">
##  <img data-src="1.png" height="175px" ></img>
##  </div>
sub link_format {
    our ( @keyword, @replace );
    my  ( $txt ) = $_[0];
    $txt =~ s/($keyword[3])/$replace[1]1$replace[2]175$replace[4]\n$1/;
    $txt;
}

##  Func: format the title in OuTPuT interpretation section
sub otpt_format {
    our ( @keyword );
    my  ( $txt ) = $_[0];
    $txt =~ s/\n(.+)($keyword[14]|$keyword[15]|$keyword[16])(\n\s*\n$keyword[17])/\n\#\#\#\# \*\*$1$2\*\*$3/g;
    $txt;
}

##  Func: add the following text in plot section
##  <div style="text-align:center">
##  <img data-src=".png" height/width="px" ></img>
##  </div>
sub plot_format {
    our ( @keyword, @replace );
    my  ( $txt ) = $_[0];
    $txt =~ s/($keyword[14]\*\*\n)\s*\n($keyword[17])/$1$replace[1]$replace[2]600$replace[4]\n$2/g; ## plot of pic
    $txt =~ s/($keyword[15]\*\*\n)\s*\n($keyword[17])/$1$replace[1]$replace[3]$replace[4]\n$2/g; ## plot of table
    $txt;
}

##  Func: format different kinds of title as markdown by the following rules
##     # **Head**
##   ### **Title 1**
##  #### **Title 2**
##       **bold text**
sub head_format {
    our ( @keyword );
    my  ( $txt, $format ) = $_[0];
    $txt =~ s/^(.+)\n/\# \*\*$1\*\*\n/;   ## Head
    $txt =~ s/\n($_)\n/\n　 \n\#\#\# \*\*$1\*\*\n/ for @keyword[1..4]; ## Title 1 after blank line
    $txt =~ s/\n($_(.+)?)\n/\n　  \n\#\#\#\# \*\*$1\*\*\n/g for @keyword[5,8,9]; ## Title 2 after blank line
    $txt =~ s/\n($_(.+)?)\n/\n\#\#\#\# \*\*$1\*\*\n/g for @keyword[6,7,10];  ## Title 2
    $txt =~ s/\n($_)/\n　  \n\*\*$1\*\*/ for @keyword[11..11]; ## bold text after blank line
    $txt =~ s/\n($_)/\n\*\*$1\*\*/ for @keyword[12..13];  ## bold text
    $txt;
}

##  Func: format list as Markdown
##  e.g.
##  |GeneSet Name|Gene Name|  (the head of a list)
##  |:----------:|:-------:|  (add this line after list head)
sub list_format {
    our ( @keyword );
    my  ( $txt, @row, $r, $line ) = $_[0];
    @row = split "\n", $txt;
    for $r( 0..$#row ) { #say &utf2gbk($md[$r]);
      if ( $row[$r] =~ /^\|.+\|.+\|.*/ and $row[$r-1] !~ /\|/ ) {
        $line = $row[$r];  #say $head;
        $line =~ s/[^\|]/-/g;
        $line =~ s/\|-/\|:/g;
        $line =~ s/-\|/:\|/g;
        $row[$r] .= "\n".$line;
      }
    }
    $txt = join "\n", @row;
    $txt;
}

##  Func: format tree structure as Markdown by the following rules
##  <font color=#00BFFF>**name of folder**</font>
##                      **name of a file**
sub tree_format {
    our ( @keyword );
    my  ( $txt, $tree, @row, $r, $loc1, $loc2 ) = $_[0];
    ($txt =~ /[^├](├.+─[^\n]+\n)/s) ? () : (return $txt);
    $tree = $1; #say &utf2gbk(&tree_format($1));
    say &utf2gbk($tree);
    @row = split "\n", $tree;
    for $r( 1..$#row ) {  #say &utf2gbk($row[$r-1]);
      $loc1 = index ( $row[$r-1], "─" );
      $loc2 = index ( $row[$r], "─" );
      ($loc1 < $loc2)
       ? ($row[$r-1] =~ s/(─ )([^（\(]+)( ?[（\(]?)/$1<font color=\#00BFFF>\*\*$2\*\*<\/font>$3/)
       : ($row[$r-1] =~ s/(─ )([^（\(]+)( ?[（\(]?)/$1\*\*$2\*\*$3/); #say &utf2gbk($row[$r-1]);
    }
    $tree = join "\n", @row;
    $tree =~ s/\*\*(\.\.\.)\*\*/$1/g; #say &utf2gbk($tree);
    $tree =~ s/┊/│/g;
    $txt =~ s/[^├](├.+─[^\n]+\n)/$tree/s;
    $txt;
}

sub read_file_into_string {
  	my ( $file, $read ) = $_[0];
  	open FH, $file or die "Couldn't open $file for reading: $!";
  		{ local $/ = undef;	$read = <FH> }	#test say $read;
  	close FH;
  	$read; ## Output: $read is the content of the file
}

sub write_file {
  	my ( $file, @write ) = @_;
  	open FH, '>', $file or die "Couldn't open $file for writing: $!";
  		say FH for @write;
  	close FH;  say "Finsh writing $file";
}

sub utf2gbk{
	my $string = encode ( 'gbk', decode ('utf8', $_[0] ) )
}

sub gbk2utf{ #say $_[0];
	my $string = encode ( 'utf8', decode ('gbk', $_[0] ) )
}

#  ---END---------------------------------------------------------------------------------------------------------END---
