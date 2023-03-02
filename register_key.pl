#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;

my ($help, $stdout, $vowels, $user_key);
my $registry = "ds_registry.tsv";
my $width=4;
my $count=1; # How many IDs to generate
my $value = "";
my $message = "";
my $too_many_tries = 10000;

my $usage = <<EOS;
  Synopsis: register_key.pl -r ds_registry.tsv [options]

  Reads a tab-delimited file with keys and values and adds another key and value.

  Examples:
  Just return a key:
    register_key.pl -stdout

  Add a key and values to the registry file:
    register_key.pl -v "Canis lupus genomes Spot.gnm1"
    register_key.pl -v "Vigna GENUS pangenes mixed.pan1"

  Add a user-provided key and values to the registry file:
    register_key.pl -k XXXX -v "Canis lupus genomes Spot.gnm1"
  
  Options:
    -registry   String. File with keys and values (values may have one or more column). Key is in first column.
                Default: ds_registry.tsv
    -value      String. The value (-v) should have four components, space-separated: 
                   "Genus species type accession.type"   -- for example
                    Cicer arietinum genomes CDCFrontier.gnm3
                  The third field should be one of the following types:
                    annotations genefamilies genomes maps markers methylation pangenes pangenomes 
                    repeats supplements synteny traits transcriptomes
    -key        String. Use the four-character key provided (if it is not in the registry).
    -message    String. Optional comment; reminiscent of the github -m commit message.
    -stdout     Boolean. Print to STDOUT rather than to the registry file.
    -help       Boolean. This message. 
EOS

GetOptions (
  "registry:s" =>  \$registry,
  "key:s" =>       \$user_key,
  "value:s" =>     \$value,
  "message:s" =>   \$message,
  "stdout" =>      \$stdout,
  "help" =>        \$help,
);

print "message: $message\n";

die "\n$usage\n" if ( $help || (!$value && !$user_key && !$stdout) );
die "\n$usage\nPlease provide a registry file: -registry FILENAME\n\n" unless ( -f $registry );
if ($user_key){
  die "\n$usage\nUser-provided key must have four characters\n\n" unless ( length($user_key) == 4 );
}

my @s; # array of characters to use in random ID strings

my @cons =   qw(B C D F G H J K L M N P Q R S T V W X Y Z);
my @vowels = qw(A E I O U); # Not used unless global $vowels is set to 1
my @nums =   qw(0 1 2 3 4 5 6 7 8 9);

push(@s, @cons, @nums);
if ($vowels){ push(@s, @vowels) }

my $characters = scalar(@s); # number of characters in alphabet to use for IDs

my %id_hsh;
my $new_ID;
my @IDs;
my $number_of_tries = 0;

open (my $IN, '<', $registry) or die "can't open $registry for reading: $!\n";
my %seen_key;
while (<$IN>){
  chomp;
  my ($key, @rest) = split(/\s+/, $_);
  $id_hsh{$key} = join("\t", @rest);
  $seen_key{$key}++;
}
close $IN;

my $value_tsv = $value;
$value_tsv =~ s/,*\s+/\t/g; # Replace spaces or comma+spaces with tabs
my @parts = split(/\t/, $value_tsv);
unless (scalar(@parts) == 4){
  warn "\nNOTE: The value (-v) should have four components, space-separated: \n" .
       "  Genus species type accession.type# -- for example,\n" .
       "  Cicer arietinum genomes CDCFrontier.gnm3\n" .
       "Please check if the value string is as you intend.\n\n";
}
unless ($parts[2] =~ m/annotations|genefamilies|genomes|maps|markers|methylation|pangenes|pangenomes|repeats|supplements|synteny|traits|transcriptomes/){
  warn "\nNOTE: The third component of the value (-v) should be one of the following: \n" .
       "  annotations genefamilies genomes maps markers methylation pangenes \n" .
       "  pangenomes repeats supplements synteny traits transcriptomes\n" .
       "(Note plurals in e.g. \"annotations\" and \"genomes\")\n" .
       "Please check if the value string is as you intend.\n\n";
}

my $OUT;
unless ($stdout){
  open ($OUT, '>>', $registry) or die "can't open $registry for writing: $!\n"; 
}

my $count_OK_IDs = 0;
if ($user_key){
  # User has proided a key. Check if it is in the registry.
  if ($seen_key{$user_key}){
    if ($id_hsh{$user_key}){
      die "Provided key $user_key is already in the $registry:\n$user_key\t$id_hsh{$user_key}\n";
    }
    else {
      die "Provided key $user_key is already in the $registry:\n$user_key\t[no associated value]\n";
    }
  }
  else {
    $new_ID = $user_key
  }
}
else { # Make a new key
  do {
    $new_ID="";
    for (1..$width) { $new_ID .= $s[int(rand()*$characters)] }
    if ($id_hsh{$new_ID}) {
      $number_of_tries++;
      if ($number_of_tries > $too_many_tries) {
        die "Bailing out after $number_of_tries tries. Number of IDs generated: $count_OK_IDs\n"; 
      }
    } 
    else {
      $id_hsh{$new_ID}++;
      $count_OK_IDs++;
    }
  } until $count_OK_IDs >= $count;
}

if ( $stdout ) { # print to STDOUT
  if ( $value_tsv ){ 
    if ($message){
      print "$new_ID\t$value_tsv\t$message\n";
    }
    else {
      print "$new_ID\t$value_tsv\n"; 
    }
  }
  else {print "$new_ID\n" }
} 
else { # print to registry
  if ( $value_tsv ){ 
    if ($message){
      print $OUT "$new_ID\t$value_tsv\t$message\n";
      print "Printed to registry: $new_ID\t$value_tsv\t$message\n";
    }
    else {
      print "$new_ID\t$value_tsv\n";
    }
  }
  else { 
    print $OUT "$new_ID\t\n";
    print "Printed to registry: $new_ID\t... with no corresponding value.\n";
  }
}


