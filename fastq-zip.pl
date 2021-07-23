#!/usr/bin/env perl 

use warnings;
use strict;
use Data::Dumper;
use Getopt::Long;
use File::Basename qw/basename/;

local $0 = basename $0;
sub logmsg{local $0=basename $0; print STDERR "$0: @_\n";}
exit(main());

sub main{
  my $settings={};
  GetOptions($settings,qw(help decompress)) or die $!;
  die usage() if($$settings{help} || -t STDIN);

  if($$settings{decompress}){
    my $str = decompressFastq($settings);
    print $str;
  }
  else {
    my $str = compressFastq($settings);
    print $str;
  }

  return 0;
}

sub decompressFastq{
  my($settings) = @_;

  my $idx = "";
  my $block = "";
  while(my $idIdx = <STDIN>){
    my $seqIdx = <STDIN>;
    my $qualIdx= <STDIN>;
    scalar(<STDIN>);

    my(undef, $idLength)  = split(/:/, $idIdx);
    my(undef, $seqLength) = split(/:/, $seqIdx);
    my(undef, $qualLength)= split(/:/, $qualIdx);

    read(STDIN, my $idBlock, $idLength);
    read(STDIN, my $seqBlock, $seqLength);
    read(STDIN, my $qualBlock, $qualLength);

    my @id   = split(/\n/, $idBlock);
    my @seq  = split(/\n/, $seqBlock);
    my @qual = split(/\n/, $qualBlock);
    my $numSeqs = @id;

    for(my $i=0;$i<$numSeqs;$i++){
      print "$id[$i]\n$seq[$i]\n+\n$qual[$i]\n";
    }
  }
}

sub compressFastq{
  my($settings) = @_;

  # Get all ID/SEQ/QUAL into strings
  my $id   = "";
  my $seq  = "";
  my $qual = "";
  while(<STDIN>){
    $id    .= $_;
    $seq  .= <STDIN>;
    scalar(<STDIN>); # burn the plus line
    $qual .= <STDIN>;
  }
  close STDIN;
  
  # Build the index
  my $idLength   = length($id);
  my $seqLength  = length($seq);
  my $qualLength = length($qual);
  if($seqLength != $qualLength){
    logmsg " Warning: Sequence length does not equal to qual length!";
  }

  #my $seqIdx  = $idLength;
  #my $qualIdx = $seqIdx + $seqLength;

  # The index has key:value pairs separated by newlines.
  # The index ends at double newlines.
  my $idx = "ID:$idLength\nSEQ:$seqLength\nQUAL:$qualLength\n\n";

  # Make the content.
  return $idx.$id.$seq.$qual;
}

sub usage{
  "$0: compresses fastq
  Usage: cat fastq | $0 > fastq.kz
  --help   This useful help menu
  --decompress
  "
}
