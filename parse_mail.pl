#!/usr/bin/perl -w
use strict;
use warnings;
use MIME::Base64;

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
my $BASE64 = 0;
my $dup = "";

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
	
	## BASE64 DECODE
	if ($line =~ m/^Content-Transfer-Encoding: base64/) {
		$BASE64 = 1;
	}

	### MAIL CONTENT
	if ($line =~ m/^Content-Type: text\/html;/) {
		$CTYPE = 1;
	}
	if ($line =~ m/^Content-Type: text\/plain;/) {
		$CTYPE = 2;
	}
	
	### HTML CONTENT
	if ($line =~ m/^.*$bodyend/) {
		$dup = $PIPE;
		#$dup =~ s/.*$bodystart/$bodystart.*/;		# alles bis <body raus
		#$dup =~ s/$bodyend.*/.*$bodyend/;			# alles nach /body> raus
		$dup =~ s/.*$bodystart>(.*)$bodyend/$1/;	# zwischen start und end
		$dup = remove_strings($dup, \@removes);		# spezielle tags raus
		$dup =~ s|<.+?>||g;							# html raus
		#$dup =~ s|{.+?}||g;						# webkit raus
		$dup =~ s/{.+}//sg;							# webkit raus
		$dup =~ s/\h+/ /g;							# remove multispaces

  		printf "%s:\t%s\n", "Content", "$dup";
	};
}

### PLAIN TEXT CONTENT
if ($CTYPE == 2){
	$dup = $PIPE;
	$dup =~ s/.*X-Spamd-Bar: \/(.*)/$1/;			# alles bis raus
	$dup =~ s/\*\*\*.*\*\*\*//;						# alles nach raus
	$dup = remove_strings($dup, \@removes);			# spezielle tags raus
	$dup =~ s/\h+/ /g;								# replace multispaces with single space
	printf "%s:\t%s\n", "Content", "$dup";
}


### BASE64 TEXT CONTENTS
if ($BASE64 == 1){
	$dup = $PIPE;
	$dup =~ s/.*Content-Type: text\/plain.*?Content-Transfer-Encoding: base64(.*?)=.*/$1/;
	#printf "%s:\t%s\n", "Base64", "$dup";
	
	my $decoded = MIME::Base64::decode($dup);
	printf "%s:\t\t%s\n", "Base64", "$decoded";

	#Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
	#Content-Transfer-Encoding: base64

	#PT09IE5ld3MgLSAxIG5ldWVzIEVyZ2VibmlzIGbDvHIgW2VpZ2VuZXIgbmV3c2xldHRlcl0gPT09
	#DQoNCkV4LVJBRi1UZXJyb3Jpc3RpbiBLbGV0dGUgc29sbCAxNDAuMDAwIEV1cm8gaW4gZWlnZW5l
	#ciBXb2hudW5nIHZlcnN0ZWNrdA0KaGFiZW4gLSBSTkQNClJORA0KTWl0IG1laW5lciBBbm1lbGR1
	#bmcgenVtIE5ld3NsZXR0ZXIgc3RpbW1lIGljaCBkZXIgLi4uDQo8aHR0cHM6Ly93d3cuZ29vZ2xl
	#LmNvbS91cmw/cmN0PWomc2E9dCZ1cmw9aHR0cHM6Ly93d3cucm5kLmRlL3BvbGl0aWsvcmFmLWts
	#ZXR0ZS1zb2xsLTE0MC0wMDAtZXVyby1pbi1laWdlbmVyLXdvaG51bmctdmVyc3RlY2t0LWhhYmVu
	#LU9PWUNRWlhYNFZFUTNLS0xGSlM0NlpQNE1ZLmh0bWwmY3Q9Z2EmY2Q9Q0FFWUFDb1VNVFkzTkRJ
	#NE16RTNOek0xTWpZM05EUXlORGd5R2preFpqazVPRFkzWXpJd01UQTJPV0k2WTI5dE9tUmxPbFZU
	#JnVzZz1BT3ZWYXcxOWZVSkZpOWROOG1BTFliUWZORDlCPg0KDQoNCi0gLSAtIC0gLSAtIC0gLSAt
	#IC0gLSAtIC0gLSAtIC0gLSAtIC0gLSAtIC0gLSAtIC0gLSAtIC0gLSAtIC0gLSAtIC0NCkRpZXNl
	#biBHb29nbGUgQWxlcnQgbmljaHQgbWVociBlcmhhbHRlbjoNCjxodHRwczovL3d3dy5nb29nbGUu
	#Y29tL2FsZXJ0cy9yZW1vdmU/c291cmNlPWFsZXJ0c21haWwmaGw9ZGUmZ2w9VVMmbXNnaWQ9TVRZ
	#M05ESTRNekUzTnpNMU1qWTNORFF5TkRnJnM9QUIyWHE0Z05KekpmZlJ4bFZwNHR3OVpIRkVSUzhZ
	#M3N3QjlnSF9jPg0KDQpXZWl0ZXJlbiBHb29nbGUgQWxlcnQgZXJzdGVsbGVuOg0KPGh0dHBzOi8v
	#d3d3Lmdvb2dsZS5jb20vYWxlcnRzP3NvdXJjZT1hbGVydHNtYWlsJmhsPWRlJmdsPVVTJm1zZ2lk
	#PU1UWTNOREk0TXpFM056TTFNalkzTkRReU5EZz4NCg0KTWVsZGUgZGljaCBhbiwgdW0gZGVpbmUg
	#QWxlcnRzIHp1IHZlcndhbHRlbjoNCjxodHRwczovL3d3dy5nb29nbGUuY29tL2FsZXJ0cz9zb3Vy
	#Y2U9YWxlcnRzbWFpbCZobD1kZSZnbD1VUyZtc2dpZD1NVFkzTkRJNE16RTNOek0xTWpZM05EUXlO
	#RGc+DQo=
	#--000000000000ab91de0614407291
}

### END
1