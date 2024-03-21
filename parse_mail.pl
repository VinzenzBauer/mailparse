#!/usr/bin/perl -w
use strict;
use warnings;

#my $input1 = "/yo:/sup:/hello:/yo:/hello:/yup.";
#my @removes = qw(hello sup);
#my $remove;

#foreach $remove (@removes){
#	$input1 =~ s/$remove//g;
#}
#print($input1."\n");

#vars
my $M0 = "named_attribute: sasl_username=";
my $DATE = "Date:";
my $FROM = "From:";
my $TO = "To:";
my $SUBJECT = "Subject:";

#my $bodystart="<body";
my $bodyend = "/body>";
my $body = "";
my $bod = "";
#my $delete = "&nbsp; &copy;";

my $stuff_path = '/home/vinzenz/mailparse/mail_unformated';
my $PIPE = "";


#while(<STDIN>)
#{
#  $PIPE .= $_;
  
#  if ($PIPE =~ m/$M0/) {
#  	print $_;
#  };
#}

foreach my $line ( <STDIN> ) {
    chomp( $line );

	if ($line =~ m/^$M0/) {
		#named_attribute: sasl_username=m05ad8d7
		$line =~ s/^[^=]*=//;
  		printf "%s:\t%s\n", "Postfach", $line;
	};
	if ($line =~ m/^$DATE/) {
		#Date: Wed, 20 Mar 2024 16:31:40 +0000 (UTC)
		$line =~ s/^[^,]*\s,//;
  		printf "%s:\t\t%s\n", "Am", $line;
	};
	if ($line =~ m/^$FROM/) {
		#From: TPMS-SAS-Live <tpms-sas-live@auto.prodefis-outbox.de>
		$line =~ s/^[^:]*:\s//;
  		printf "%s:\t\t%s\n", "Von", $line;
	};
	if ($line =~ m/^$TO/) {
		#To: "Messing Ragert, Ingrid  10162" <10162@sas.dk>
		$line =~ s/^[^:]*:\s//;
  		printf "%s:\t\t%s\n", "An", $line;
	};
	if ($line =~ m/^$SUBJECT/) {
		#Subject: Event report Filed
		$line =~ s/^[^:]*:\s//;
  		printf "%s:\t%s\n", "Betreff", $line;
	};
}





#if [[ $line == "$M0"* ]]; then
#			echo "sasl" $'\t\t' $(echo ${line} | cut -d'=' -f2)
#       fi


#print "This was read from the pipe:\n";
#print "<$PIPE>\n\n";

#print "This was the read from the parameters:\n";
#print "<@{ARGV}>\n";


#open (my $stuff, '<', $stuff_path)
#    or die "Cannot open'$stuff_path' for read : $!\n";

# My preferred method to loop over a file line by line:
# while loop with explicit variable
#while( my $line = <$stuff> ) {
#    print "Line $. is : $line\n";
#}

#open my $fh, "<", $ARGV[0] or die $!;
#while (<$fh>) {
	#print "Line $. is : $_";
#}

1