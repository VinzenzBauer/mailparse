#!/usr/bin/perl -w
use strict;
use warnings;

### VARS
my $M0 = "named_attribute: sasl_username=";
my $DATE = "Date:";
my $FROM = "From:";
my $TO = "To:";
my $SUBJECT = "Subject:";

my $bodystart="<body";
my $bodyend = "\/body>";
my $body = "";
my @removes = qw(&nbsp; &copy; \t);

my $stuff_path = '/home/vinzenz/mailparse/mail_unformated';
my $PIPE = "";
my $CTYPE = 0;

### FUNCTIONS
sub remove_strings {
	my ($input, $rem) = @_;
	my @rem = @{ $rem };
	
	foreach my $remove (@rem){
		$input =~ s/$remove//g;
	}
	return $input;
}

### MAIN
foreach my $line ( <STDIN> ) {
    chomp( $line );
	$PIPE .= $line;

	### MAIL HEADER
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
	
	### MAIL CONTENT
	if ($line =~ m/^Content-Type: text\/html;/) {
		$CTYPE = 1
	}
	if ($line =~ m/^Content-Type: text\/plain;/) {
		$CTYPE = 2
	}
	
	if ($line =~ m/^.*$bodyend/) {
		$PIPE =~ s/.*$bodystart/$bodystart.*/;		# alles bis <body raus
		$PIPE =~ s/$bodyend.*/.*$bodyend/;			# alles nach /body> raus
		$PIPE = remove_strings($PIPE, \@removes);	# spezielle tags raus
		$PIPE =~ s|<.+?>||g;						# html raus
		$PIPE =~ s/\h+/ /g;							# remove multispaces
  		printf "%s:\t%s\n", "Content", "$PIPE";
	};
}

if ($CTYPE == 2){
	$PIPE =~ s/.*X-Spamd-Bar://;				# alles bis raus
	$PIPE =~ s/\*\*\*.*/\*\*\*/;				# alles nach raus
	$PIPE = remove_strings($PIPE, \@removes);	# spezielle tags raus
	$PIPE =~ s/\h+/ /g;							# replace multispaces with single space
	printf "%s:\t%s\n", "Content", "$PIPE";
}

### END
1