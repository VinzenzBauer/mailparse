#!/usr/bin/perl -w
use strict;
use warnings;
use MIME::Base64;
use Term::ANSIColor;
use MIME::QuotedPrint;
use Data::Dumper qw(Dumper);
use HTML::FormatText 2;								#https://docstore.mik.ua/orelly/perl4/cook/ch20_07.htm
use Encode qw(encode decode);
#no warnings 'utf8';

### VARS
my $M0 = "named_attribute: sasl_username=.*";  		#named_attribute: sasl_username=m05ad8d7
my $IP = "named_attribute: client_address=.*";   	#client_address=209....197
my $DATE = "Date:.*[0-9]{2}:[0-9]{2}:[0-9]{2}.*";	#Date: Wed, 20 Mar 2024 16:31:40 +0000 (UTC)
my $FROM = "From:.*";								#From: TPMS-SAS-Live <tpms-sas-outbox.de>
my $TO = "To:.*";                           		#To: "Messing Ragert, Ingrid  10162" <10162@sas.dk>
my $SUBJECT = "Subject:.*";                    		#Subject: Event report Filed
my $XSENDER = "X-SenderIP:.*";						#X-SenderIP: 84.....120 bsp 21
my $REPLYTO = "Reply-To:.*";
my $RECEIVED = "Received:.*";						# Received: from ....ru (unknown [147....106]) bsp 23	
my $XPAMD = "X-Spamd-Bar:.*";						# X-Spamd-Bar: +++ # 40
my $XPAM = "X-Spam:.*";								# X-Spam: Yes # 41
		
#my @removes = qw( &nbsp; &copy; &quot; &zwnj; \x{200c} \x{34f} );		# bsp: 1 43
#my @removes = qw( \x{34f} \x{a9} \x{200c} &zwnj; &nbsp; &nb= &nb=.sp &nbs= nbsp; &zw=.nj; =.47; 47; =20 =0A &zwn= zwnj;);

my $PIPE = "";
my $base64 = "";
my $qp = "";
my $content = "";
my $spaces = '';
#my $index = 0;

my %mail;
my $blocks;

### super bsp: 39 für spam
### SUBROUTINES
sub decodeGuess{
	my $input = shift || '';
	my $key = shift || '';
	my $key2 = shift || 'enc';
		
	my $sum_raw = '';
	my $sum_dec = '';
	my $dec = $input;
	
	my $inc = 0;
	my @matches;
	
	# HEADER DATA
	my $iso8859b64all 	= qr/(=?\??iso-8859-1\?B\?.*?=?=?\?=)(.*?<.*?>.*?)?/;		# 5
	my $iso8859b64enc	= qr/=?\??iso-8859-1\?B\?(.*?)=?=?\?=/;
	my $utf8b64all 		= qr/(=?\??[uUtTfF]{3}-8\?B\?.*?=?=?\?=)(.*?<.*?>.*?)?/;	# 14 28
	my $utf8b64enc		= qr/=?\??[uUtTfF]{3}-8\?B\?(.*?)=?=?\?=/;
	my $iso8859qpall 	= qr/(=?\??iso-8859-1\?Q\?.*?=?=?\?=)(.*?<.*?>.*?)?/;		# 20
	my $iso8859qpenc	= qr/=?\??iso-8859-1\?Q\?'?(.*?)'?=?=?\?=/;
	my $utf8qpall 		= qr/(=?\??[uUtTfF]{3}-8\?Q\?.*?=?=?\?=)(.*?<.*?>.*?)?/;	# 28 3
	my $utf8qpenc		= qr/=?\??[uUtTfF]{3}-8\?Q\?(.*?)=?=?\?=/;
	
	# BODY DATA
	my $bodysplit		= qr/([cC]ontent-[tT].{3,20}: .*?\n)/;						# 1	
	my $ContentType		= qr/[cC]ontent-[tT]ype: (?!multi)/;						# 32
	my $ContentEnc		= qr/[cC]ontent-?[tT]ransfer-?[eE]ncoding: /;
	my $order			= "none";

	########## HEADER ########### 
	if ($key2 ne "body"){
		my @inputA = split (/\n/, $input);
		foreach my $line (@inputA) {
			#print color("blue"), "line parsed $key->$key2:", color("yellow"), $line, color("reset"), "\n";

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
			@matches = $line =~ /${$utf8b64all}/g;	
			foreach my $m (@matches) {
				if (defined($m)){ 
					if ($m =~ /${$utf8b64enc}/g){
						$mail{"$key"}{"$key2"}{"$inc"}{"utf8.b64"}{enc} = $1; 
						$mail{"$key"}{"$key2"}{"$inc"}{"utf8.b64"}{dec} = MIME::Base64::decode($1); 
					}else{
						$mail{"$key"}{"$key2"}{"$inc"}{raw} = $m; 
						$mail{"$key"}{"$key2"}{"$inc"}{cln} = clean_string($m); 
					}
					$inc++;
				}		
			}

			# left overs
			if ($key2 eq "body"){
				#$mail{"$key"}{"$key2"}{raw} .=  clean_string($line);		
			}else{
				$mail{"$key"}{"$key2"}{raw} .=  $line;	# bsp 1, da keine encodings im header
				if (clean_string($mail{"$key"}{"$key2"}{raw}) ne $mail{"$key"}{"$key2"}{raw}){
					$mail{"$key"}{"$key2"}{cln} = clean_string($mail{"$key"}{"$key2"}{raw});
				}
			}
		} 
	}
	
	########## BODY ########### 
	if ($key2 eq "body"){
		
		#my $plain_text = $dec;
		my $type = "";
		my $chars = "";
		my $enc = "";
		my $content = "";
		
		my $typecode = "";
		if ($input =~ /${$ContentType}((.*?\n?.*?){0,3})${$ContentEnc}/g){		# 1
			#print color("red"),"type first!", color("reset"), "\n";
			$order = "TE";
		}elsif ($input =~ /${$ContentEnc}((.*?\n?.*?){0,3})${$ContentType}/g){	# 54
			#print color("red"),"enc first!", color("reset"), "\n";
			$order = "ET";
		}elsif ($input =~ /${$ContentType}/g){									# 40
			#print color("red"),"type only!", color("reset"), "\n";
			$order = "T";
			$enc = "none";
		}elsif ($input =~ /${$ContentEnc}/g){
			#print color("red"),"enc only!", color("reset"), "\n";
			$order = "E";
			$type = "none";
			$chars = "none";
		}else{
			#print color("red"),"raw only!", color("reset"), "\n";
		};

		my @sA = split (/$bodysplit/, $input);
		#foreach my $m (@sA) {
		#	print color("yellow"),"array: ", color("green"), $m, color("reset"), "\n";
		#}

		$inc = 0;
		my $cont = 0;
		foreach my $m (@sA) {
			if ($m =~ /$bodysplit/g){ # Content-Type:
			
				if ($m =~ /[qQ]uoted-[pP]rintable/){
					if ($order eq "TE" && $type ne ''){ $enc = "qp"; } 
					if ($order eq "ET" && $type eq ''){ $enc = "qp"; }
				}
				if ($m =~ /[bB]ase64/){
					if ($order eq "TE" && $type ne ''){ $enc = "b64"; } 
					if ($order eq "ET" && $type eq ''){ $enc = "b64"; } 
				}
				if ($m =~ /7[bB]it/){
					if ($order eq "TE" && $type ne ''){ $enc = "7b"; }	# 29
					if ($order eq "ET" && $type eq ''){ $enc = "7b"; }
				}
				if ($m =~ /8[bB]it/){
					if ($order eq "TE" && $type ne ''){ $enc = "8b"; }
					if ($order eq "ET" && $type eq ''){ $enc = "8b"; }
				}
				if ($m =~ /text\/(.*?)(;|$)/){									# 65 kein ;
					$type = $1; 
					if ($m =~    /text\/(.*?);\s?charset=?"?(.*?)"?(;.*)?\n/){	# 11 41 43 54
						$chars = $2;
					} elsif ($sA[($inc+1)] =~ /charset=?"?(.*?)"?(;.*)?\n/){ 	# 6 23
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
					if ($chars =~ /[uUtTfF]{3}-?8/){
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
						$content = HTML::FormatText->format_string($content);
					}
					if ($content ne $temp){
						$mail{"$key"}{"$key2"}{"$cont"}{"$type.$chars.$enc"}{dec} = $content;
					}else{
						$mail{"$key"}{"$key2"}{"$cont"}{"$type.$chars.$enc"}{raw} = $temp;
					}
					$content = clean_string($content);
					if ($content ne $temp){
						$mail{"$key"}{"$key2"}{"$cont"}{"$type.$chars.$enc"}{cln} = $content;
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
			print color("red"), "not parsable, pls forward mail-code to miau\@miaut.de", color("reset"), "\n";
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
	$input =~ s/$RECEIVED//g;
	$input =~ s/$XPAMD//g;
	$input =~ s/$XPAM//g;
	
	$input =~ s/\*\*\*\s?HEADER.*\*\*\*\n//g;		# 40 21
	$input =~ s/\*\*\*\s?MESSAGE.*\*\*\*\n//g;		# 40 21
	$input =~ s/Message-ID:.*\n//g;					# 18
	$input =~ s/--.*?\.kasserver\.com--.*//g;		# 21
	$input =~ s/--.*?=_.*?--//g;					# 4			--b1=_5rL5sE1gxdXRyxPfwuXw0g0LmvTlwggj9CiWdPjZk--
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
	$input =~ s/named_attribute: .*//g;				# 52
	$input =~ s/Message-Id:.*//g;
	$input =~ s/List-Unsubscribe:.*//g;				# 41		# List-Unsubscribe: <mailto:?subject=Unsubscribe>

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
		printLine($input, "cln");
	}elsif ( exists($input->{"raw"}) ){
		printLine($input, "raw");
	}
	
	while(my($k, $v) = each %{$input}) {
		if (exists($input->{$k}) && ($k ne "body")){
			if ($k =~ /(raw|enc|dec|cln)/){
				if ($k !~ /(cln|raw)/){	# already handled above while beeing print first
					printLine($input, "$k");
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
sub printLine{
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
			#if ($temp eq "raw") { $temp = ""; }
			if (length("@paths $temp: ") > 7) {$spaces = "\t\t\t"}
			if (length("@paths $temp: ") > 15) {$spaces = "\t\t"}
			if (length("@paths $temp: ") > 23) {$spaces = "\t"}		# bsp 28
			if (length("@paths $temp: ") > 31) {$spaces = ""}		# bsp 20
			#binmode(STDOUT, ":utf8");		# vs 14: 绿茶网址	-> no warning utf8
			print color("yellow"), "@paths $temp: ", color("reset"), $spaces.$content . color("reset") ."\n";	# <<========
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
		if ($line =~ m/^$M0/) {
			$line =~ s/^[^=]*=//;
			decodeGuess($line, $key, "sasl");
		};
		if ($line =~ m/$IP/) {
			$line =~ s/^[^=]*=//;
			decodeGuess($line, $key, "ip");
		};
		if ($line =~ m/^$RECEIVED/) {
			$line =~ s/^[^:]*:\s//;
			decodeGuess($line, $key, "received");
		};
		if ($line =~ m/^$DATE/) {
			$line =~ s/^[^,]*,\s//;
			decodeGuess($line, $key, "date");
		};
		if ($line =~ m/^$XSENDER/) {
			$line =~ s/^[^:]*:\s//;
			decodeGuess($line, $key, "sender");
		};
		if ($line =~ m/^$FROM/) {
			$line =~ s/^[^:]*:\s//;
			decodeGuess($line, $key, "from");
		};
		if ($line =~ m/^$TO/) {
			$line =~ s/^[^:]*:\s//;
			decodeGuess($line, $key, "to");
		};
		if ($line =~ m/^$REPLYTO/) {
			$line =~ s/^[^:]*:\s//;
			decodeGuess($line, $key, "replyto");
		};
		if ($line =~ m/^$SUBJECT/) {
			$line =~ s/^[^:]*:\s//;
			decodeGuess($line, $key, "subject");
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
	my ($head, $body) = split/\R+\s*\R+/, $input, 2;
	
	print color("red"), "some debugging because of errors:", color("reset"), "\n";
	print Dumper($head);
	print Dumper($body);
	
	## MAIL HEAD
	if ($head)
	{
		hashHeaderInfo($head, $key);
	}
	## MAIL BODY
	if ($body)
	{
		if ($body =~ m/$BOUNCE/s) {		# 23
			$body =~ s/.*?$BOUNCE.*?(Return-Path)(.*)/$1$2/s;
			hashMail($body, "bounce");
		}else{
			$body = $head."\n\n".$body;
			#hashBodyInfo($body, $key);
			decodeGuess($body, $key, "body");
		}
	}else{
		print color("red"), "body empty, pls forward mail-code to ______", color("reset"), "\n";
	}
}

### READ WHOLE FILE
foreach my $line ( <STDIN> ) {
    $PIPE .= $line;
}
### HASH WHOLE CONVERSATION
hashMail($PIPE);
### OUTPUT PARSED INFO
print color("red"), "======================= :: DEBUG HASH :: =======================", color("reset"), "\n";
print Dumper(\%mail);
print color("green"), "======================= :: MAIL PARSE ATTEMPT BELOW :: =======================", color("reset"), "\n";
if (exists $mail{origin}){
	printMail($mail{"origin"});
}
if (exists $mail{bounce}){
	## HEADER INFO
	print color("red"), "======================= :: THIS IS A BOUNCE :: Orig Message BELOW :: =======================", color("reset"), "\n";
	#push(@paths, "bounce");
	printMail($mail{"bounce"});
}


### END
1