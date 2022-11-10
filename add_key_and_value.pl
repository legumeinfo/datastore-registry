#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;

my ($help, $registry, $stdout, $vowels, $user_key);
my $width=4;
my $count=1; # How many IDs to generate
my $message_value = "";
my $too_many_tries = 10000;

my $usage = <<EOS;
  Synopsis: add_key_and_value.pl -r registry.tsv [options]

  Reads a tab-delimited file with keys and values and adds another key and value.

  Examples:
  Just return a key:
    add_key_and_value.pl -r registry.tsv -stdout

  Add a key and values to the registry file:
    add_key_and_value.pl -r registry.tsv -m "Canis lupus genome Spot.gnm1"
  

  Required: 
    -registry   File with keys and values (values may have one or more column). Key is in first column.

  Options:
    -value      Value to add to the registry, opposite new key. If omitted, only the key will be generated.
    -message    Same as "-value", reminiscent of git commit -m. 
    -key        Use the four-character key provided (if it is not in the registry).
    -stdout     Print to STDOUT rather than to the registry file.
    -help       Boolean. This message. 
EOS

GetOptions (
  "registry=s" =>  \$registry,
  "value:s" =>     \$message_value,
  "message:s" =>   \$message_value,
  "key:s" =>       \$user_key,
  "stdout" =>      \$stdout,
  "help" =>        \$help,
);

die "\n$usage\n" if ( $help );
die "\n$usage\nPlease provide a registry file: -registry FILENAME\n\n" unless ( $registry );
if ($user_key){
  die "\n$usage\nUser-provided key must have four characters\n\n" unless ( length($user_key) == 4 );
}

my @s; # hash with characters to use in random ID strings

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

my $message_tsv = $message_value;
$message_tsv =~ s/\s+/\t/g;

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
  if ( $message_tsv ){ print "$new_ID\t$message_tsv\n" }
  else {print "$new_ID\n" }
} 
else { # print to registry
  if ( $message_tsv ){ 
    print $OUT "$new_ID\t$message_tsv\n";
    print "Printed to registry: $new_ID\t$message_tsv\n";
  }
  else { 
    print $OUT "$new_ID\t\n";
    print "Printed to registry: $new_ID\t... with no corresponding value.\n";
  }
}


