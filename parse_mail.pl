#!/usr/bin/perl -w
use strict;
use warnings;
use MIME::Base64;
use Term::ANSIColor;
use MIME::QuotedPrint;
use Data::Dumper qw(Dumper);
use HTML::FormatText 2;								# https://docstore.mik.ua/orelly/perl4/cook/ch20_07.htm
use Encode qw(encode decode decode_utf8);			# https://eli.thegreenplace.net/2007/07/20/parsing-of-undecoded-utf-8-will-give-garbage-when-decoding-entities
no warnings 'utf8';

### VARS
my $M0 = "named_attribute: sasl_username=.*";  		# named_attribute: sasl_username=m05ad8d7
my $IP = "named_attribute: client_address=.*";   	# client_address=209....197
my $DATE = "Date:.*[0-9]{2}:[0-9]{2}:[0-9]{2}.*";	# Date: Wed, 20 Mar 2024 16:31:40 +0000 (UTC)
my $FROM = "From:.*";								# From: TPMS-SAS-Live <tpms-sas-outbox.de>
my $TO = "To:.*";                           		# To: "Messing Ragert, Ingrid  10162" <10162@sas.dk>
my $SUBJECT = "Subject:.*";                    		# Subject: Event report Filed
my $XSENDER = "X-SenderIP:.*";						# X-SenderIP: 84.....120 bsp 21
my $SENDER = "sender:.*";							# 93 sender: bounces@jjjjjjjdfddsdsd.com
my $RECIPIENT = "original_recipient:.*";			# 98 original_recipient: ge@kueb.net
my $REPLYTO = "Reply-To:.*";
my $RECEIVED = "Received:.*";						# Received: from ....ru (unknown [147....106]) bsp 23	
my $XSPAMD = "X-Spamd-Bar:.*";						# X-Spamd-Bar: +++ # 40
my $XSPAM = "X-Spam:.*";							# X-Spam: Yes # 41
		
my $PIPE = "";
my $base64 = "";
my $qp = "";
my $content = "";
my $spaces = '';

my %mail;
my $bodysplit = qr/([cC]ontent-[tT].{3,20}: .*?\n)/;# 1	vs 79 (just plain text)
my $debug = 0;
my $maxlines = 20;

#local $SIG{__WARN__} = sub {
#	my $message = shift;
#	print color("yellow"), "warning! : $message", color("reset"), "\n";
#};
#my @removals = qw( &nbsp; &copy; &quot; &zwnj; \x{200c} \x{34f} );		# bsp: 1 43

### SUBROUTINES

sub extractkey{ # turn key "html.none.none" to "html"
	my ($type, $chars, $enc) = @_;
	my $key = "";
	my $before = "";
	
	if ($type && $type ne "none") { 
		$key.=$type; 
	}
	
	if ($chars && $chars ne "none") { 
		if ($key ne $before) { $key.="."; $before=$key; }
		$key.=$chars; 
	}
	
	if ($enc && $enc ne "none") { 
		if ($key ne $before) { $key.="."; $before=$key; }
		$key.=$enc; 
	}
	
	return $key;
}

sub decodeGuess{
	my $input = shift || '';
	my $key = shift || '';
	my $key2 = shift || 'enc';
		
	my $sum_raw = '';
	my $sum_dec = '';
	my $dec = $input;
	my $order = "none";
	
	my $inc = 0;
	my @matches;
	
	# HEADER DATA
	my $iso8859b64all 	= qr/(=?\??iso-8859-1\?b\?.*?=?=?\?=)(.*?<.*?>.*?)?/i;		# 5
	my $iso8859b64enc	=  qr/=?\??iso-8859-1\?b\?(.*?)=?=?\?=/i;
	my $utf8b64all 		= qr/(=?\??utf-8\?b\?.*?=?=?\?=)(.*?<.*?>.*?)?/i;			# 14 28
	my $utf8b64enc		=  qr/=?\??utf-8\?b\?(.*?)=?=?\?=/i;						# 84
	my $iso8859qpall 	= qr/(=?\??iso-8859-1\?q\?.*?=?=?\?=)(.*?<.*?>.*?)?/i;		# 20
	my $iso8859qpenc	=  qr/=?\??iso-8859-1\?q\?'?(.*?)'?=?=?\?=/i;
	my $utf8qpall 		= qr/(=?\??utf-8\?q\?.*?=?=?\?=)(.*?<.*?>.*?)?/i;			# 28 3
	my $utf8qpenc		=  qr/=?\??utf-8\?q\?(.*?)=?=?\?=/i;
	my $asciiqpall		= qr/(=?\??us-ascii\?q\?.*?=?=?\?=)(.*?<.*?>.*?)?/i;		# 12 78
	my $asciiqpenc		=  qr/=?\??us-ascii\?q\?(.*?)=?=?\?=/i;
	
	# BODY DATA
	my $ContentType		= qr/[cC]ontent-[tT]ype: (?!multi)/;						# 32
	my $ContentEnc		= qr/[cC]ontent-?[tT]ransfer-?[eE]ncoding: /;

	########## HEADER ########### 
	if ($key2 ne "body"){
		my @inputA = split (/\n/, $input);
		foreach my $line (@inputA) {
			if ($debug eq 1){
				print color("blue"), "line parsed $key->$key2:", color("yellow"), $line, color("reset"), "\n";
			}

			@matches = $line =~ /${$iso8859b64all}/g;	
			foreach my $m (@matches) {
				if (defined($m)){ 
					if ($m =~ /${$iso8859b64enc}/g){
						$mail{"$key"}{"$key2"}{"$inc"}{"iso8859.b64"}{enc} = $1; 
						$mail{"$key"}{"$key2"}{"$inc"}{"iso8859.b64"}{dec} = MIME::Base64::decode($1); 
					}else{
						$mail{"$key"}{"$key2"}{"$inc"}{raw} = $m; 
						$mail{"$key"}{"$key2"}{"$inc"}{cln} = clean_string($m); 
					}
					$inc++;
				}		
			} #next if ($line =~ /${$iso8859b64enc}/g);		
			@matches = $line =~ /${$utf8qpall}/g;	
			foreach my $m (@matches) {
				if (defined($m)){ 
					if ($m =~ /${$utf8qpenc}/g){
						$mail{"$key"}{"$key2"}{"$inc"}{"utf8.qp"}{enc} = $1; 
						$mail{"$key"}{"$key2"}{"$inc"}{"utf8.qp"}{dec} = decode_qp($1); 
					}else{
						$mail{"$key"}{"$key2"}{"$inc"}{raw} = $m; 
						$mail{"$key"}{"$key2"}{"$inc"}{cln} = clean_string($m); 
					}
					$inc++;
				}		
			}
			@matches = $line =~ /${$iso8859qpall}/g;	
			foreach my $m (@matches) {
				if (defined($m)){ 
					if ($m =~ /${$iso8859qpenc}/g){
						$mail{"$key"}{"$key2"}{"$inc"}{"iso8859.qp"}{enc} = $1; 
						$mail{"$key"}{"$key2"}{"$inc"}{"iso8859.qp"}{dec} = decode_qp($1); 
					}else{
						$mail{"$key"}{"$key2"}{"$inc"}{raw} = $m; 
						$mail{"$key"}{"$key2"}{"$inc"}{cln} = clean_string($m); 
					}
					$inc++;
				}		
			}
			@matches = $line =~ /${$asciiqpall}/g;	
			foreach my $m (@matches) {
				if (defined($m)){ 
					if ($m =~ /${$asciiqpenc}/g){
						$mail{"$key"}{"$key2"}{"$inc"}{"ascii.qp"}{enc} = $1; 
						$mail{"$key"}{"$key2"}{"$inc"}{"ascii.qp"}{dec} = decode_qp($1); 
					}else{
						$mail{"$key"}{"$key2"}{"$inc"}{raw} = $m; 
						$mail{"$key"}{"$key2"}{"$inc"}{cln} = clean_string($m); 
					}
					$inc++;
				}		
			}
			@matches = $line =~ /${$utf8b64all}/g;	
			foreach my $m (@matches) {
				if (defined($m)){ 
					#print color("red"),"matched uft 8 b: \'", color("green"), $m, color("reset"), "\'\n";
					if ($m =~ /${$utf8b64enc}/g){
						#print color("red"),"matched enc uft 8 b: \'", color("green"), $m, color("reset"), "\'\n";
						$mail{"$key"}{"$key2"}{"$inc"}{"utf8.b64"}{enc} = $1; 
						$mail{"$key"}{"$key2"}{"$inc"}{"utf8.b64"}{dec} = MIME::Base64::decode($1); 
					}else{
						#print color("red"),"matched non enc uft 8 b: \'", color("green"), $m, color("reset"), "\'\n";
						$mail{"$key"}{"$key2"}{"$inc"}{raw} = $m; 
						$mail{"$key"}{"$key2"}{"$inc"}{cln} = clean_string($m); 
					}
					$inc++;
				}
			}

			# left overs HEADERS # bsp 1, da keine encodings im header
			if ($mail{"$key"}{"$key2"}{raw}){ # multilines bsp: 98 4* received
				#$mail{"$key"}{"$key2"}{raw} .=  "\n\t\t\t\t".$line;	
				$mail{"$key"}{"$key2"}{raw} .=  "\n".$line;
			}else{
				$mail{"$key"}{"$key2"}{raw} .=  $line;
				my $temp = clean_string($mail{"$key"}{"$key2"}{raw});
				if ($temp ne $mail{"$key"}{"$key2"}{raw}){
					$mail{"$key"}{"$key2"}{cln} = $temp;
				}
			}
		} 
	}
	
	########## BODY ########### 
	if ($key2 eq "body"){
		my $type = "";
		my $chars = "";
		my $enc = "";
		my $content = "";
		
		my $typecode = "";
		if ($input =~ /${$ContentType}(.*?\n?.*?){0,3}${$ContentEnc}/g){		# 1 86 88
			if ($debug eq 1){
				print color("red"),"type first!", color("reset"), "\n";
			}
			$order = "TE";
		}elsif ($input =~ /${$ContentEnc}(.*?\n?.*?){0,3}${$ContentType}/g){	# 54
			if ($debug eq 1){
				print color("red"),"enc first!", color("reset"), "\n";
			}
			$order = "ET";
		}elsif ($input =~ /${$ContentType}/g){									# 40 86: 7 zeilen dazwischen
			if ($input =~ /${$ContentEnc}/g){
				if ($debug eq 1){
					print color("red"),"type first & enc later!", color("reset"), "\n";
				}
				$order = "T E";
			}else{
				if ($debug eq 1){
					print color("red"),"type only!", color("reset"), "\n";
				}
				$order = "T";
				$enc = "none";
			}
		}elsif ($input =~ /${$ContentEnc}/g){
			if ($input =~ /${$ContentType}/g){
				if ($debug eq 1){
					print color("red"),"enc first & type later!", color("reset"), "\n";
				}
				$order = "E T";
			}else{
				if ($debug eq 1){
					print color("red"),"enc only!", color("reset"), "\n";
				}
				$order = "E";
				$type = "none";
				$chars = "none";
			}
		}else{
			if ($debug eq 1){
				print color("red"),"raw only!", color("reset"), "\n";
			}
			$order = "R";
		};

		my @sA = split (/${$bodysplit}/, $input);
		if ($debug eq 1){
			foreach my $m (@sA) {
				print color("yellow"),"array: ", color("green"), $m, color("reset"), "\n";
			}
		}

		$inc = 0;
		my $cont = 0;
		foreach my $m (@sA) {
			if ($m =~ /$bodysplit/g){ # Content-Type:
				if ($m =~ /quoted-printable/i){
					if ($order eq "TE" && $type ne ''){ $enc = "qp"; } 
					if ($order eq "ET" && $type eq ''){ $enc = "qp"; }
					if ($order eq "T E" || $order eq "E T"){ $enc = "qp"; }		# 86
				}
				if ($m =~ /base64/i){
					if ($order eq "TE" && $type ne ''){ $enc = "b64"; } 
					if ($order eq "ET" && $type eq ''){ $enc = "b64"; } 
					if ($order eq "T E" || $order eq "E T"){ $enc = "b64"; }	# 86
				}
				if ($m =~ /7bit/i){
					if ($order eq "TE" && $type ne ''){ $enc = "7b"; }			# 29
					if ($order eq "ET" && $type eq ''){ $enc = "7b"; }
					if ($order eq "T E" || $order eq "E T"){ $enc = "7b"; }		# 86
				}
				if ($m =~ /8bit/i){
					if ($order eq "TE" && $type ne ''){ $enc = "8b"; }
					if ($order eq "ET" && $type eq ''){ $enc = "8b"; }
					if ($order eq "T E" || $order eq "E T"){ $enc = "8b"; }		# 86
				}
				if ($m =~ /text\/(.*?)(;|$)/){									# 65 kein ;
					$type = $1; 
					if ($m =~      /text\/(.*?);\s?charset\s?=\s?"?(.*?)"?(;.*)?\n/){	# 11 41 43 54 81
						$chars = $2;
					} elsif ($sA[($inc+1)] =~ /^\s*charset\s?=\s?"?(.*?)"?(;.*)?\n/){ 	# 6 23 90 100
						$chars = $1;
					} else{														# 65
						$chars = "none";
					}
				}
			}

			if (defined($type) && $type ne '' && defined($chars) && $chars ne '' && defined($enc) && $enc ne ''){
				$content = $sA[($inc+1)];
				if (defined($content) && $content ne '' && $content !~ /$bodysplit/g){
					my $temp = $content;
					if ($chars =~ /utf-?8/i){
						$content = decode('utf-8', $content);
					}
					#print color("yellow"),"$cont -> ", color("red"),  "before!: $type.$chars.$enc: \"$content\"", color("reset"), "\n";
					$content = clean_body($content);
					#print color("yellow"),"$cont -> ", color("green"), "after!: $type.$chars.$enc: \"$content\"", color("reset"), "\n";
					if ($enc eq "qp"){
						$content = decode_qp($content);
					}
					if ($enc eq "b64"){
						$content = MIME::Base64::decode($content);
					}
					if ($type eq "html" || $type eq "plain") {		# plain kann auch html enthalten: bsp 37	
						my $temp = $content;
						eval{
							$temp = decode_utf8 $temp;
						};
						if ( $@ ) {
							print color("red"), "warning: body contains non utf8 / foreign symbols !", color("reset"), "\n";
						}
						local $SIG{__WARN__} = sub { }; # eat garbage warnings from FormatText
						$content = HTML::FormatText->format_string($temp);
					}
					
					if ($content ne $temp){
						$mail{"$key"}{"$key2"}{"$cont"}{extractkey($type, $chars, $enc)}{dec} = $content;
					}else{
						$mail{"$key"}{"$key2"}{"$cont"}{extractkey($type, $chars, $enc)}{raw} = $temp;
					}
					$content = clean_string($content);
					if ($content ne $temp){
						$mail{"$key"}{"$key2"}{"$cont"}{extractkey($type, $chars, $enc)}{cln} = $content;
					}
					#print color("red"),"resettet!: $type.$chars.$enc: \"$content\"", color("reset"), "\n";
					$type = ""; $chars = ""; $enc = ""; $content = "";
					$cont++;
				}
			}
			#print color("yellow"), "$inc: $type.$chars.$enc", color("reset"), "\n";
			$inc++;
		}
		
		if (exists($mail{"$key"}{"$key2"}{0})){
			# all good
		}else{
			print color("red"), "===== FAILED PARSING MAIL-BODY, OR BODY EMPTY => debug info below =====", color("reset"), "\n";
			foreach my $m (@sA) {
				print color("yellow"),"array split: ", color("green"), $m, color("reset"), "\n";
			}
		}
	}
}
sub clean_string{
	my $input = shift || '';
	$input =~ s/^\s+|\s+$//g;						# trim
	$input =~ s/\n\s*/\n/g;							# remove empty lines
    return $input;
}
sub clean_body{
	my $input = shift || '';
	$input =~ s/$M0//g;
	$input =~ s/$IP//g;
	$input =~ s/$DATE//g;
	$input =~ s/$FROM//g;
	$input =~ s/$REPLYTO//g;
	$input =~ s/$TO//g;
	$input =~ s/$SUBJECT//g;
	$input =~ s/$XSENDER//g;
	$input =~ s/$SENDER//g;
	$input =~ s/$RECEIVED//g;
	$input =~ s/$XSPAMD//g;
	$input =~ s/$XSPAM//g;
	$input =~ s/$RECIPIENT//g;
	
	$input =~ s/\*\*\*\s?HEADER.*\*\*\*\n//g;		# 40 21
	$input =~ s/\*\*\*\s?MESSAGE.*\*\*\*\n?//g;		# 40 21 102	
	$input =~ s/Message-ID:.*\n//g;					# 18
	$input =~ s/--.*?\.kasserver\.com--.*//g;		# 21
	$input =~ s/--.*?=_.*?--//g;					# 4			# --b1=_5rL5sE1gxdXRyxPfwuXw0g0LmvTlwggj9CiWdPjZk--
	$input =~ s/----_.*?-.*?-.*//g;					# 87		# ----_NmP-e7875a061ce819fc-Part_1
	$input =~ s/--_=_.*?_=_.*\n//g;					# 26		# --_=_swift_v4_1711953407_a6d0eab157ec92d9_=_--
	$input =~ s/--[a-zA-Z0-9=_]*(--)?\n//g;			# 27 33 35	# --a8e4ad06f2361c1e5df79aface0b32c8254c--
	$input =~ s/--Apple-.*(--)?\n//g;				# 29		# --Apple-Mail-EAFC032E-8C51-4A17-82BC-BB3B42F3BD85
	$input =~ s/--{2,20}.*?\..*//g;					# 18 43		# ------=_NextPart_001_0163_01DA7B92.23E43150--		------=_NextPart_001_0163_01DA7B92.23E43150--		
	#$input =~ s/.*\[IMAGE\].*//g;					# 18 52
	$input =~ s/Content-Description:.*//g;
	$input =~ s/X-Priority:.*//g;					# 38		# X-Priority: 3 (Normal)
	$input =~ s/X-Mailer:.*//g;						# 41		# X-Mailer: express
	$input =~ s/X-MSMail-Priority:.*//g;			# 41		# X-MSMail-Priority: High
	$input =~ s/X-Dmarc-Test:.*//g;					# 52
	$input =~ s/X-Auto-Response-Suppress:.*//g;		# 86
	$input =~ s/named_attribute: .*//g;				# 52
	$input =~ s/original_recipient: .*//g;			# 73
	$input =~ s/recipient: .*//g;					# 73
	$input =~ s/Message-Id:.*//g;
	$input =~ s/List-Unsubscribe:.*//g;				# 41		# List-Unsubscribe: <mailto:?subject=Unsubscribe>
	$input =~ s/.*format=flowed.*//g;				# 54
	$input =~ s/Content-Disposition: .*//g;			# 75
	$input =~ s/X-Spf-.{2,10}: .*//g;				# 77
	$input =~ s/X-(Kas)?Loop: .*//g;				# 19
	$input =~ s/Precedence: .*//g;					# 19
	$input =~ s/Auto-Submitted: .*//g;				# 19
	$input =~ s/MIME-Version: .*//gi;				# 86 106
	$input =~ s/X-Original.*//g;					# 103
	$input =~ s/References: .*//gi;					# 106

	
	#$input =~ s/(3D|22|=){3}//g;					# 98 3D=22=22
	$input =~ s/^\s*charset\s?=\s?"?(.*?)"?(;.*)?\n//g;				# 100
	
	return $input;
}
sub remove_strings {
    my ($input, $rem) = @_;
    my @rem = @{ $rem };
    
    foreach my $remove (@rem){
        $input =~ s/$remove//g;
    }
    return $input;
}
my @paths;
my $iter = 0;
$content = "";
sub printMail{
	my $input = shift;
	
	#handle print body always first
	if (exists($input->{"body"})){
		push(@paths, "body");
		printMail($input->{"body"});
		pop(@paths);
	}
	
	#handle print cln and raw always first
	if ( exists($input->{"cln"}) ){
		printMailItem($input, "cln");
	}elsif ( exists($input->{"raw"}) ){
		printMailItem($input, "raw");
	}
	
	while(my($k, $v) = each %{$input}) {
		if (exists($input->{$k}) && ($k ne "body")){
			if ($k =~ /(raw|enc|dec|cln)/){
				if ($k !~ /(cln|raw)/){	# already handled above while beeing print first
					printMailItem($input, "$k");
				}
			}else{
				# handle numbered
				if (exists($input->{"$iter"})){
					push(@paths, $iter);
					printMail($input->{"$iter"});
					$iter++;
					if (!exists($input->{"$iter"})){
						$iter = 0;
					}
					pop(@paths);
				}else{
					push(@paths, $k);
					#printMail($input->{"$iter"});
					printMail(\%{$v});
					pop(@paths);
				}
			}
		}
	}
}
sub printMailItem{
	my($input, $k) = @_;
	my $temp = "";

	if ($k =~ /(raw|enc|dec|cln)/){
		if (exists($input->{"raw"})){
			$temp = "raw";
		}
		if (exists($input->{"enc"})){
			$temp = "enc";
		}
		if (exists($input->{"dec"})){
			$temp = "dec";
		}
		if (exists($input->{"cln"})){
			$temp = "cln";
		}
		#$content = $input->{$temp};
		$content = $input->{$k};
		
		if ($temp eq $k){
			$spaces = "\t\t\t\t";
			if ($temp eq "raw") { 
				$temp = ""; 
			}else{
				$temp = " $temp";
			}
			#123456789012345678901234
			#subject 0 utf8.b64 dec:		Mi
			if (length("@paths$temp: ") > 8) {$spaces = "\t\t\t"}
			if (length("@paths$temp: ") > 15) {$spaces = "\t\t"}
			if (length("@paths$temp: ") > 24) {$spaces = "\t"}		# bsp 28 8
			if (length("@paths$temp: ") > 31) {$spaces = ""}		# bsp 20
			#binmode(STDOUT, ":utf8");		# vs 14: 绿茶网址	-> no warning utf8
			if ($content=~ m/(.*\n){$maxlines,}/){ # more than 10 multilines > shorten
				$content = join "\n", (split "\n", $content)[0 .. $maxlines];
				
				$content = "\n".$content ;
				print color("yellow"), "@paths", color("green"), $temp, color("yellow"), ":", color("reset"), $content . color("reset") ."\n";	# <<========
				print "... ", color("red"), "<content too long - shortened>" , color("reset"), " ... call with 999 for more text\n";
				#$content.= "\n... <content too long - shortened> ... call with 999 for more text";
			}else{
				if ($content=~ m/.*\n.*/) { 
					$content = "\n".$content ;
					print color("yellow"), "@paths", color("green"), $temp, color("yellow"), ":", color("reset"), $content . color("reset") ."\n";	# <<========
				}else{
					print color("yellow"), "@paths", color("green"), $temp, color("yellow"), ":", color("reset"), $spaces.$content . color("reset") ."\n";	# <<========
				}
			}
		}					
		#print color("yellow"), "@paths $temp: ", color("reset"), "$content\n", color("reset");
	}	
}
sub hashHeaderInfo{
	my $input = shift;
	my $key = shift || "unknown";
	
	my @headA = split (/\n(?=\S)/, $input);
	foreach my $line (@headA) {
		#print color("blue"), "content: ", color("green"), $line, color("reset"), "\n";
		if ($line =~ m/^$M0/i) {
			$line =~ s/^[^=]*=//;
			decodeGuess($line, $key, "sasl");
		};
		if ($line =~ m/$IP/i) {
			$line =~ s/^[^=]*=//;
			decodeGuess($line, $key, "ip");
		};
		if ($line =~ m/^$RECEIVED/i) {
			$line =~ s/^[^:]*:\s?//;
			decodeGuess($line, $key, "received");
		};
		if ($line =~ m/^$DATE/i) {
			$line =~ s/^[^,]*,\s?//;
			decodeGuess($line, $key, "date");
		};
		if ($line =~ m/^$XSENDER/i) {
			$line =~ s/^[^:]*:\s?//;
			decodeGuess($line, $key, "xsender");
		};
		if ($line =~ m/^$SENDER/i) {
			$line =~ s/^[^:]*:\s?//;
			decodeGuess($line, $key, "sender");
		};
		if ($line =~ m/^$FROM/i) {
			$line =~ s/^[^:]*:\s?//;				# 65 kein \s nach from:
			decodeGuess($line, $key, "from");
		};
		if ($line =~ m/^$TO/i) {
			$line =~ s/^[^:]*:\s?//;
			decodeGuess($line, $key, "to");
		};
		if ($line =~ m/^$REPLYTO/i) {
			$line =~ s/^[^:]*:\s?//;
			decodeGuess($line, $key, "replyto");
		};
		if ($line =~ m/^$SUBJECT/i) {
			$line =~ s/^[^:]*:\s?//;
			decodeGuess($line, $key, "subject");
		};
		if ($line =~ m/^$XSPAM/i) {
			$line =~ s/^[^:]*:\s?//;
			decodeGuess($line, $key, "xspam");
		};
		if ($line =~ m/^$XSPAMD/i) {
			$line =~ s/^[^:]*:\s?//;
			decodeGuess($line, $key, "xspamd");
		};
		if ($line =~ m/^$RECIPIENT/i) {
			$line =~ s/^[^:]*:\s?//;
			decodeGuess($line, $key, "recipient");
		};
		
	}
}
###### mail = origin + [bounce] ######
sub hashMail{
	my $input = shift;
	my $key = shift || "origin";
	
	my $BOUNCE = "Content-Description: Undelivered Message"; # bsp 6 23
	
	## SEPARATE HEAD AND BODY
	#my ($head, $body) = split /\n\h*\n/, $input, 2;
	my ($head, $body) = split/\R+\s*\R+/, $input, 2; # 76 in live example
	#my ($head, $body) = split /[\n]{2,}/, $input, 2;
	
	## MAIL HEAD
	if ($head)
	{
		hashHeaderInfo($head, $key);
	}
	
	#print color("red"), "======================= :: BODY BELOW :: =======================", color("reset"), "\n";
	#print $body;
	
	## MAIL BODY
	if ($body)
	{
		if ($body =~ m/$BOUNCE/s) {		# 23
			$body =~ s/.*?$BOUNCE.*?(Return-Path)(.*)/$1$2/s;
			hashMail($body, "bounce");
		}else{
			if ("$head.$body" =~ /$bodysplit/g){ 	# some body-encriptions are in the header-info
				$body = $head."\n\n".$body;		
				decodeGuess($body, $key, "body");
			} else { 								# some mails have just plain text bsp 79 > no decoding needed
				$mail{"$key"}{"body"}{raw} = $body;
				my $temp = clean_body($mail{"$key"}{"body"}{raw});		# 80
				$temp = clean_string($temp);
				#my $temp = clean_string($mail{"$key"}{"body"}{raw});
				if ($temp ne $mail{"$key"}{"body"}{raw}){
					$mail{"$key"}{"body"}{cln} = $temp;
				}
			} 
		}
	}else{	# ERROR in body > try to figure out which split could work # only a temporary dirty solution
		print color("red"), "FAILED PARSING MAIL-BODY, debug info below", color("reset"), "\n";
		($head, $body) = split /\n\h*\n/, $input, 2;
		if ($body)
		{
			print color("red"), "|split1 nhn works|", color("reset"), "\n";
		}
		($head, $body) = split/\R+\s*\R+/, $input, 2;
		if ($body)
		{
			print color("red"), "|split2 rsr works|", color("reset"), "\n";
		}
		($head, $body) = split /[\n]{2,}/, $input, 2;
		if ($body)
		{
			print color("red"), "|split3 n2 works|", color("reset"), "\n";
		}
		print color("red"), "==================\nMailcode is:", color("reset"), "\n";
		print $input;
	}
}

### READ WHOLE FILE
foreach my $line ( <STDIN> ) {
    $PIPE .= $line;
}
my $param = shift || 0;
$debug = ($param == 1)? 1: 0;
$maxlines = ($param < 2)? 25: $param;

if ($debug eq 1){
	print color("red"), "======================= :: RAW MAIL BELOW :: =======================", color("reset"), "\n";
	print $PIPE;
	print color("red"), "======================= :: HEADER LINES BELOW :: =======================", color("reset"), "\n";
}

hashMail($PIPE);

### OUTPUT PARSED INFO
if ($debug eq 1){
	print color("red"), "======================= :: DEBUG HASH BELOW :: =======================", color("reset"), "\n";
	print Dumper(\%mail);
	print color("red"), "==================== THE ABOVE IS DEBUGGING - IGNORE THAT ====================", color("reset"), "\n";
}
print color("green"), "======================= :: MAIL PARSE ATTEMPT BELOW :: =======================", color("reset"), "\n";
if (exists $mail{origin}){
	printMail($mail{"origin"});
}
if (exists $mail{bounce}){
	## HEADER INFO
	print color("red"), "================ :: THIS IS A BOUNCE :: Orig Message BELOW :: ================", color("reset"), "\n";
	#push(@paths, "bounce");
	printMail($mail{"bounce"});
}


### END
1