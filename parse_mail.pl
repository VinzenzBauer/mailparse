#!/usr/bin/perl -w
use strict;
use warnings;
use MIME::Base64;
use Term::ANSIColor;

### VARS
my $M0 = "named_attribute: sasl_username=";         #named_attribute: sasl_username=m05ad8d7
my $IP = "named_attribute: client_address=";        #client_address=209.85.128.197
my $DATE = "Date:.*[0-9]{2}:[0-9]{2}:[0-9]{2}";     #Date: Wed, 20 Mar 2024 16:31:40 +0000 (UTC)
my $FROM = "From:";                                	#From: TPMS-SAS-Live <tpms-sas-live@auto.prodefis-outbox.de>
my $TO = "To:";                                     #To: "Messing Ragert, Ingrid  10162" <10162@sas.dk>
my $SUBJECT = "Subject:";                           #Subject: Event report Filed
my $REPLYTO = "Reply-To:";
						
my $htmlstart="<[t]?body.*?>";						#<body class="mainBody"> #<tbody>
my $htmlend = "<.*?\/[t]?body>";					#hmtl tag not exist in 3
my @removes = qw/ &nbsp; &copy; \t =09 &quot; = &zwnj; 0A /;			# bsp: 1
my @removes_iso = qw/ =\?iso-8859-1\?B\? =\?= \?= /;		# bsp: 5

my $PIPE = "";
my $base64 = "";
my $content = "";

my $bounce = 0;

### SUBROUTINES
sub remove_strings {
    my ($input, $rem) = @_;
    my @rem = @{ $rem };
    
    foreach my $remove (@rem){
        $input =~ s/$remove//g;
    }
    return $input;
}
sub decode_iso_8859_1_base64 {		# bsp 5: subject from etc waren base64 mit iso-tags zb: =?iso-8859-1?B?Kysg
	my $encoded = shift;
	$encoded = remove_strings($encoded, \@removes_iso);
	my $decoded = MIME::Base64::decode($encoded);
    return $decoded;
}
sub decode_guess{
	my $line = shift;
	if ($line =~ m/=\?iso-8859/) {
		return decode_iso_8859_1_base64("$line");
	};
	return $line;
}
sub printHeaderInfo{
	my $head = shift;
	my @headA = split (/\n/, $head);
	foreach my $line (@headA) {
		if ($line =~ m/^$M0/) {
			$line =~ s/^[^=]*=//;
			printf "%s:\t\t%s ", "sasl", $line;
		};
		if ($line =~ m/$IP/) {
			$line =~ s/^[^=]*=//;
			printf "<%s>\n", $line;
		};
		if ($line =~ m/^$DATE/) {
			$line =~ s/^[^,]*,\s//;
			printf "%s:\t\t%s\n", "date", $line;
		};
		if ($line =~ m/^$FROM/) {
			$line =~ s/^[^:]*:\s//;
			$line = decode_guess("$line");
			printf "%s:\t\t%s\n", "from", $line;
		};
		if ($line =~ m/^$TO/) {
			$line =~ s/^[^:]*:\s//;
			$line = decode_guess("$line");
			printf "%s:\t\t%s\n", "to", $line;
		};
		if ($line =~ m/^$REPLYTO/) {
			$line =~ s/^[^:]*:\s//;
			$line = decode_guess("$line");
			printf "%s:\t%s\n", "replyto", $line;
		};
		if ($line =~ m/^$SUBJECT/) {
			$line =~ s/^[^:]*:\s//;
			$line = decode_guess("$line");
			printf "%s:\t%s\n", "subject", $line;
		};
	}
}

### READ WHOLE FILE
foreach my $line ( <STDIN> ) {
    $PIPE .= $line;
}

### SEPARATE HEAD AND BODY
my ($head, $body) = split /\n\h*\n/, $PIPE, 2;

### MAIL HEAD
printHeaderInfo($head);

### MAIL BODY
## HTML CONTENT (bsp: 1, 3, 7)
$content = $body; 
$content =~ s/\R//g;							# remove linebreaks
$content =~ s/.*?$htmlstart(.*)$htmlend.*/$1/s;	# extract content between html-body-tags
$content =~ s|<.+?>||g;                         # html raus
$content =~ s/{.+}//sg;                         # webkit raus
$content = remove_strings($content, \@removes);	# spezielle tags raus
$content =~ s/^ +//gm ;							# remove whitespaces at start of line
$content =~ s/\n\s*/\n/g;						# remove empty lines
$content =~ s/\h+/ /g;                        	# replace multispaces with single space

if ($body =~ /I'm sorry to have to inform you that your message could not/s) {

	## ERROR EG.: Content-Description: Undelivered Message
	#Reply-To: WinBTC <bitcoin-mining@groupalim.com>
	#From: WinBTC <benjamin@widmann-elektrotechnik.de>
	#Subject: Balance Mining BTC 
	#Date: Fri, 22 Mar 2024 16:29:30 +0000
	print '-' x 80, "\n"; 
	$bounce = 1;
	printHeaderInfo($body);
	
	# bsp: 10 alles nach X-Spamd-Bar: von interesse: Hallo * * * 馃獧 袙袗袦 袟袗效袠小袥袝袧袨 ...
	if ($body =~ /X-Spamd-Bar: \/\n/s) {
		$content = $body;
		$content =~ s/.*?X-Spamd-Bar: \/\n(.*?)--.*/$1/s;
		$content =~ s/\R//g;							# remove linebreaks
		$content =~ s|<.+?>||g;                         # html raus
		
		print color("green"), "$content\n", color("reset");
	}
}

if ( !$bounce ){		# bsp 6 ist ein bounce -> nix valides zum zeigen
	print color("green"), "$content\n", color("reset");
}

### BASE64 TEXT CONTENTS			# (bsp: 6 )
if ($body =~ /Content-Type: (text\/plain|text\/html);(?=.{5,200}Content-Transfer-Encoding: base64)/s) {
	#print color("red"), "Base64 DECODE:\n", color("reset");
	$base64 = $body;
	
	while ($base64 =~ /Content-Type: (text\/plain|text\/html);((.*?\n?.*?){0,3})(Encoding: base64)((.*?\n?.*?)+)=/g){
		my $type = $1;
		my $b64ent = $5;
		#print color("red"), "ausgabe: ", color("reset"), "$5 ", pos $base64, "\n";
		$b64ent = MIME::Base64::decode($b64ent);
		$b64ent =~ s|<.+?>||g;                      # html raus (manche links können von interesse sein)           
		$b64ent =~ s/^ +//gm ;						# remove whitespaces at start of line
		$b64ent =~ s/\n\s*/\n/g;					# remove empty lines
		print color("red"), "Base64(", color("white"), "$type", color("red"), ") DECODE: ", color("yellow"), "$b64ent\n", color("reset");
	}
}

### END
1