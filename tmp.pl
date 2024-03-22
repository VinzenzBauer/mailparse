{"payload":{"allShortcutsEnabled":false,"fileTree":{"":{"items":[{"name":"hooks","path":"hooks","contentType":"directory"},{"name":"info","path":"info","contentType":"directory"},{"name":".gitignore","path":".gitignore","contentType":"file"},{"name":"HEAD","path":"HEAD","contentType":"file"},{"name":"README.md","path":"README.md","contentType":"file"},{"name":"config","path":"config","contentType":"file"},{"name":"description","path":"description","contentType":"file"},{"name":"file","path":"file","contentType":"file"},{"name":"format_text.sh","path":"format_text.sh","contentType":"file"},{"name":"parse_mail.pl","path":"parse_mail.pl","contentType":"file"}],"totalCount":10}},"fileTreeProcessingTime":1.981415,"foldersToFetch":[],"repo":{"id":775531061,"defaultBranch":"main","name":"mailparse","ownerLogin":"VinzenzBauer","currentUserCanPush":false,"isFork":false,"isEmpty":false,"createdAt":"2024-03-21T15:05:23.000Z","ownerAvatar":"https://avatars.githubusercontent.com/u/2396757?v=4","public":true,"private":false,"isOrgOwned":false},"codeLineWrapEnabled":false,"symbolsExpanded":false,"treeExpanded":true,"refInfo":{"name":"main","listCacheKey":"v0:1711033524.669795","canEdit":false,"refType":"branch","currentOid":"75bfecb13a5fdcd10c2813c2b3f617c46cf021fc"},"path":"parse_mail.pl","currentUser":null,"blob":{"rawLines":["#!/usr/bin/perl -w","use strict;","use warnings;","use HTML::Strip;","","### VARS","my $M0 = \"named_attribute: sasl_username=\";","my $DATE = \"Date:\";","my $FROM = \"From:\";","my $TO = \"To:\";","my $SUBJECT = \"Subject:\";","","my $bodystart=\"<body\";","my $bodyend = \"\\/body>\";","my $body = \"\";","my @removes = qw(&nbsp; &copy; \\t);","","my $stuff_path = '/home/vinzenz/mailparse/mail_unformated';","my $PIPE = \"\";","my $CTYPE = 0;","","### FUNCTIONS","sub remove_strings {","\tmy ($input, $rem) = @_;","\tmy @rem = @{ $rem };","\t","\tforeach my $remove (@rem){","\t\t$input =~ s/$remove//g;","\t}","\treturn $input;","}","","### MAIN","foreach my $line ( <STDIN> ) {","    chomp( $line );","\t$PIPE .= $line;","","\t### MAIL HEADER","\tif ($line =~ m/^$M0/) {","\t\t#named_attribute: sasl_username=m05ad8d7","\t\t$line =~ s/^[^=]*=//;","  \t\tprintf \"%s:\\t%s\\n\", \"Postfach\", $line;","\t};","\tif ($line =~ m/^$DATE/) {","\t\t#Date: Wed, 20 Mar 2024 16:31:40 +0000 (UTC)","\t\t$line =~ s/^[^,]*\\s,//;","  \t\tprintf \"%s:\\t\\t%s\\n\", \"Am\", $line;","\t};","\tif ($line =~ m/^$FROM/) {","\t\t#From: TPMS-SAS-Live <tpms-sas-live@auto.prodefis-outbox.de>","\t\t$line =~ s/^[^:]*:\\s//;","  \t\tprintf \"%s:\\t\\t%s\\n\", \"Von\", $line;","\t};","\tif ($line =~ m/^$TO/) {","\t\t#To: \"Messing Ragert, Ingrid  10162\" <10162@sas.dk>","\t\t$line =~ s/^[^:]*:\\s//;","  \t\tprintf \"%s:\\t\\t%s\\n\", \"An\", $line;","\t};","\tif ($line =~ m/^$SUBJECT/) {","\t\t#Subject: Event report Filed","\t\t$line =~ s/^[^:]*:\\s//;","  \t\tprintf \"%s:\\t%s\\n\", \"Betreff\", $line;","\t};","\t","\t### MAIL CONTENT","\tif ($line =~ m/^Content-Type: text\\/html;/) {","\t\t$CTYPE = 1","\t}","\tif ($line =~ m/^Content-Type: text\\/plain;/) {","\t\t$CTYPE = 2","\t}","\t","\tif ($line =~ m/^.*$bodyend/) {","\t\t$PIPE =~ s/.*$bodystart/$bodystart.*/;\t\t# alles bis <body raus","\t\t$PIPE =~ s/$bodyend.*/.*$bodyend/;\t\t\t# alles nach /body> raus","\t\t$PIPE = remove_strings($PIPE, \\@removes);\t# spezielle tags raus","\t\t$PIPE =~ s|<.+?>||g;\t\t\t\t\t\t# html raus","\t\t#$PIPE =~ s|{.+?}||g;\t\t\t\t\t\t# webkit raus","\t\t$PIPE =~ s/{.+}//sg;","\t\t$PIPE =~ s/\\h+/ /g;\t\t\t\t\t\t\t# remove multispaces","\t\t","\t\t#my $hs = HTML::Strip->new();","\t\t#my $clean_text = $hs->parse( $PIPE );","\t\t#$hs->eof;","","  \t\tprintf \"%s:\\t%s\\n\", \"Content\", \"$PIPE\";","\t};","}","","#my $hs = HTML::Strip->new();","#my $clean_text = $hs->parse( $PIPE );","#$hs->eof;","#printf \"%s:\\t%s\\n\", \"Content\", \"$clean_text\";","\t\t","","if ($CTYPE == 2){","\t$PIPE =~ s/.*X-Spamd-Bar://;\t\t\t\t# alles bis raus","\t$PIPE =~ s/\\*\\*\\*.*/\\*\\*\\*/;\t\t\t\t# alles nach raus","\t$PIPE = remove_strings($PIPE, \\@removes);\t# spezielle tags raus","\t$PIPE =~ s/\\h+/ /g;\t\t\t\t\t\t\t# replace multispaces with single space","\tprintf \"%s:\\t%s\\n\", \"Content\", \"$PIPE\";","}","","### END","1"],"stylingDirectives":[[{"start":0,"end":18,"cssClass":"pl-c"},{"start":0,"end":1,"cssClass":"pl-c"}],[{"start":0,"end":3,"cssClass":"pl-k"}],[{"start":0,"end":3,"cssClass":"pl-k"}],[{"start":0,"end":3,"cssClass":"pl-k"}],[],[{"start":0,"end":8,"cssClass":"pl-c"},{"start":0,"end":1,"cssClass":"pl-c"}],[{"start":0,"end":2,"cssClass":"pl-k"},{"start":3,"end":6,"cssClass":"pl-smi"},{"start":9,"end":42,"cssClass":"pl-s"},{"start":9,"end":10,"cssClass":"pl-pds"},{"start":41,"end":42,"cssClass":"pl-pds"}],[{"start":0,"end":2,"cssClass":"pl-k"},{"start":3,"end":8,"cssClass":"pl-smi"},{"start":11,"end":18,"cssClass":"pl-s"},{"start":11,"end":12,"cssClass":"pl-pds"},{"start":17,"end":18,"cssClass":"pl-pds"}],[{"start":0,"end":2,"cssClass":"pl-k"},{"start":3,"end":8,"cssClass":"pl-smi"},{"start":11,"end":18,"cssClass":"pl-s"},{"start":11,"end":12,"cssClass":"pl-pds"},{"start":17,"end":18,"cssClass":"pl-pds"}],[{"start":0,"end":2,"cssClass":"pl-k"},{"start":3,"end":6,"cssClass":"pl-smi"},{"start":9,"end":14,"cssClass":"pl-s"},{"start":9,"end":10,"cssClass":"pl-pds"},{"start":13,"end":14,"cssClass":"pl-pds"}],[{"start":0,"end":2,"cssClass":"pl-k"},{"start":3,"end":11,"cssClass":"pl-smi"},{"start":14,"end":24,"cssClass":"pl-s"},{"start":14,"end":15,"cssClass":"pl-pds"},{"start":23,"end":24,"cssClass":"pl-pds"}],[],[{"start":0,"end":2,"cssClass":"pl-k"},{"start":3,"end":13,"cssClass":"pl-smi"},{"start":14,"end":21,"cssClass":"pl-s"},{"start":14,"end":15,"cssClass":"pl-pds"},{"start":20,"end":21,"cssClass":"pl-pds"}],[{"start":0,"end":2,"cssClass":"pl-k"},{"start":3,"end":11,"cssClass":"pl-smi"},{"start":14,"end":23,"cssClass":"pl-s"},{"start":14,"end":15,"cssClass":"pl-pds"},{"start":15,"end":17,"cssClass":"pl-cce"},{"start":22,"end":23,"cssClass":"pl-pds"}],[{"start":0,"end":2,"cssClass":"pl-k"},{"start":3,"end":8,"cssClass":"pl-smi"},{"start":11,"end":13,"cssClass":"pl-s"},{"start":11,"end":12,"cssClass":"pl-pds"},{"start":12,"end":13,"cssClass":"pl-pds"}],[{"start":0,"end":2,"cssClass":"pl-k"},{"start":3,"end":11,"cssClass":"pl-smi"},{"start":14,"end":34,"cssClass":"pl-s"},{"start":14,"end":17,"cssClass":"pl-pds"},{"start":33,"end":34,"cssClass":"pl-pds"}],[],[{"start":0,"end":2,"cssClass":"pl-k"},{"start":3,"end":14,"cssClass":"pl-smi"},{"start":17,"end":58,"cssClass":"pl-s"},{"start":17,"end":18,"cssClass":"pl-pds"},{"start":57,"end":58,"cssClass":"pl-pds"}],[{"start":0,"end":2,"cssClass":"pl-k"},{"start":3,"end":8,"cssClass":"pl-smi"},{"start":11,"end":13,"cssClass":"pl-s"},{"start":11,"end":12,"cssClass":"pl-pds"},{"start":12,"end":13,"cssClass":"pl-pds"}],[{"start":0,"end":2,"cssClass":"pl-k"},{"start":3,"end":9,"cssClass":"pl-smi"}],[],[{"start":0,"end":13,"cssClass":"pl-c"},{"start":0,"end":1,"cssClass":"pl-c"}],[{"start":0,"end":3,"cssClass":"pl-k"},{"start":4,"end":18,"cssClass":"pl-en"}],[{"start":1,"end":3,"cssClass":"pl-k"},{"start":5,"end":11,"cssClass":"pl-smi"},{"start":13,"end":17,"cssClass":"pl-smi"},{"start":21,"end":23,"cssClass":"pl-smi"}],[{"start":1,"end":3,"cssClass":"pl-k"},{"start":4,"end":8,"cssClass":"pl-smi"},{"start":14,"end":18,"cssClass":"pl-smi"}],[],[{"start":1,"end":8,"cssClass":"pl-k"},{"start":9,"end":11,"cssClass":"pl-k"},{"start":12,"end":19,"cssClass":"pl-smi"},{"start":21,"end":25,"cssClass":"pl-smi"}],[{"start":2,"end":8,"cssClass":"pl-smi"},{"start":12,"end":21,"cssClass":"pl-sr"},{"start":12,"end":14,"cssClass":"pl-pds"},{"start":12,"end":13,"cssClass":"pl-c1"},{"start":21,"end":23,"cssClass":"pl-sr"},{"start":21,"end":23,"cssClass":"pl-pds"},{"start":23,"end":24,"cssClass":"pl-sr"},{"start":23,"end":24,"cssClass":"pl-pds"},{"start":23,"end":24,"cssClass":"pl-k"}],[],[{"start":1,"end":7,"cssClass":"pl-k"},{"start":8,"end":14,"cssClass":"pl-smi"}],[],[],[{"start":0,"end":8,"cssClass":"pl-c"},{"start":0,"end":1,"cssClass":"pl-c"}],[{"start":0,"end":7,"cssClass":"pl-k"},{"start":8,"end":10,"cssClass":"pl-k"},{"start":11,"end":16,"cssClass":"pl-smi"},{"start":20,"end":25,"cssClass":"pl-c1"}],[{"start":4,"end":9,"cssClass":"pl-c1"},{"start":11,"end":16,"cssClass":"pl-smi"}],[{"start":1,"end":6,"cssClass":"pl-smi"},{"start":10,"end":15,"cssClass":"pl-smi"}],[],[{"start":1,"end":16,"cssClass":"pl-c"},{"start":1,"end":2,"cssClass":"pl-c"}],[{"start":1,"end":3,"cssClass":"pl-k"},{"start":5,"end":10,"cssClass":"pl-smi"},{"start":14,"end":21,"cssClass":"pl-sr"},{"start":14,"end":16,"cssClass":"pl-pds"},{"start":14,"end":15,"cssClass":"pl-c1"},{"start":17,"end":20,"cssClass":"pl-smi"},{"start":20,"end":21,"cssClass":"pl-pds"}],[{"start":2,"end":42,"cssClass":"pl-c"},{"start":2,"end":3,"cssClass":"pl-c"}],[{"start":2,"end":7,"cssClass":"pl-smi"},{"start":11,"end":20,"cssClass":"pl-sr"},{"start":11,"end":13,"cssClass":"pl-pds"},{"start":11,"end":12,"cssClass":"pl-c1"},{"start":20,"end":22,"cssClass":"pl-sr"},{"start":20,"end":22,"cssClass":"pl-pds"}],[{"start":4,"end":10,"cssClass":"pl-c1"},{"start":11,"end":22,"cssClass":"pl-s"},{"start":11,"end":12,"cssClass":"pl-pds"},{"start":12,"end":14,"cssClass":"pl-smi"},{"start":15,"end":17,"cssClass":"pl-cce"},{"start":17,"end":19,"cssClass":"pl-smi"},{"start":19,"end":21,"cssClass":"pl-cce"},{"start":21,"end":22,"cssClass":"pl-pds"},{"start":24,"end":34,"cssClass":"pl-s"},{"start":24,"end":25,"cssClass":"pl-pds"},{"start":33,"end":34,"cssClass":"pl-pds"},{"start":36,"end":41,"cssClass":"pl-smi"}],[],[{"start":1,"end":3,"cssClass":"pl-k"},{"start":5,"end":10,"cssClass":"pl-smi"},{"start":14,"end":23,"cssClass":"pl-sr"},{"start":14,"end":16,"cssClass":"pl-pds"},{"start":14,"end":15,"cssClass":"pl-c1"},{"start":17,"end":22,"cssClass":"pl-smi"},{"start":22,"end":23,"cssClass":"pl-pds"}],[{"start":2,"end":46,"cssClass":"pl-c"},{"start":2,"end":3,"cssClass":"pl-c"}],[{"start":2,"end":7,"cssClass":"pl-smi"},{"start":11,"end":22,"cssClass":"pl-sr"},{"start":11,"end":13,"cssClass":"pl-pds"},{"start":11,"end":12,"cssClass":"pl-c1"},{"start":19,"end":21,"cssClass":"pl-cce"},{"start":22,"end":24,"cssClass":"pl-sr"},{"start":22,"end":24,"cssClass":"pl-pds"}],[{"start":4,"end":10,"cssClass":"pl-c1"},{"start":11,"end":24,"cssClass":"pl-s"},{"start":11,"end":12,"cssClass":"pl-pds"},{"start":12,"end":14,"cssClass":"pl-smi"},{"start":15,"end":19,"cssClass":"pl-cce"},{"start":19,"end":21,"cssClass":"pl-smi"},{"start":21,"end":23,"cssClass":"pl-cce"},{"start":23,"end":24,"cssClass":"pl-pds"},{"start":26,"end":30,"cssClass":"pl-s"},{"start":26,"end":27,"cssClass":"pl-pds"},{"start":29,"end":30,"cssClass":"pl-pds"},{"start":32,"end":37,"cssClass":"pl-smi"}],[],[{"start":1,"end":3,"cssClass":"pl-k"},{"start":5,"end":10,"cssClass":"pl-smi"},{"start":14,"end":23,"cssClass":"pl-sr"},{"start":14,"end":16,"cssClass":"pl-pds"},{"start":14,"end":15,"cssClass":"pl-c1"},{"start":17,"end":22,"cssClass":"pl-smi"},{"start":22,"end":23,"cssClass":"pl-pds"}],[{"start":2,"end":62,"cssClass":"pl-c"},{"start":2,"end":3,"cssClass":"pl-c"}],[{"start":2,"end":7,"cssClass":"pl-smi"},{"start":11,"end":22,"cssClass":"pl-sr"},{"start":11,"end":13,"cssClass":"pl-pds"},{"start":11,"end":12,"cssClass":"pl-c1"},{"start":20,"end":22,"cssClass":"pl-cce"},{"start":22,"end":24,"cssClass":"pl-sr"},{"start":22,"end":24,"cssClass":"pl-pds"}],[{"start":4,"end":10,"cssClass":"pl-c1"},{"start":11,"end":24,"cssClass":"pl-s"},{"start":11,"end":12,"cssClass":"pl-pds"},{"start":12,"end":14,"cssClass":"pl-smi"},{"start":15,"end":19,"cssClass":"pl-cce"},{"start":19,"end":21,"cssClass":"pl-smi"},{"start":21,"end":23,"cssClass":"pl-cce"},{"start":23,"end":24,"cssClass":"pl-pds"},{"start":26,"end":31,"cssClass":"pl-s"},{"start":26,"end":27,"cssClass":"pl-pds"},{"start":30,"end":31,"cssClass":"pl-pds"},{"start":33,"end":38,"cssClass":"pl-smi"}],[],[{"start":1,"end":3,"cssClass":"pl-k"},{"start":5,"end":10,"cssClass":"pl-smi"},{"start":14,"end":21,"cssClass":"pl-sr"},{"start":14,"end":16,"cssClass":"pl-pds"},{"start":14,"end":15,"cssClass":"pl-c1"},{"start":17,"end":20,"cssClass":"pl-smi"},{"start":20,"end":21,"cssClass":"pl-pds"}],[{"start":2,"end":53,"cssClass":"pl-c"},{"start":2,"end":3,"cssClass":"pl-c"}],[{"start":2,"end":7,"cssClass":"pl-smi"},{"start":11,"end":22,"cssClass":"pl-sr"},{"start":11,"end":13,"cssClass":"pl-pds"},{"start":11,"end":12,"cssClass":"pl-c1"},{"start":20,"end":22,"cssClass":"pl-cce"},{"start":22,"end":24,"cssClass":"pl-sr"},{"start":22,"end":24,"cssClass":"pl-pds"}],[{"start":4,"end":10,"cssClass":"pl-c1"},{"start":11,"end":24,"cssClass":"pl-s"},{"start":11,"end":12,"cssClass":"pl-pds"},{"start":12,"end":14,"cssClass":"pl-smi"},{"start":15,"end":19,"cssClass":"pl-cce"},{"start":19,"end":21,"cssClass":"pl-smi"},{"start":21,"end":23,"cssClass":"pl-cce"},{"start":23,"end":24,"cssClass":"pl-pds"},{"start":26,"end":30,"cssClass":"pl-s"},{"start":26,"end":27,"cssClass":"pl-pds"},{"start":29,"end":30,"cssClass":"pl-pds"},{"start":32,"end":37,"cssClass":"pl-smi"}],[],[{"start":1,"end":3,"cssClass":"pl-k"},{"start":5,"end":10,"cssClass":"pl-smi"},{"start":14,"end":26,"cssClass":"pl-sr"},{"start":14,"end":16,"cssClass":"pl-pds"},{"start":14,"end":15,"cssClass":"pl-c1"},{"start":17,"end":25,"cssClass":"pl-smi"},{"start":25,"end":26,"cssClass":"pl-pds"}],[{"start":2,"end":30,"cssClass":"pl-c"},{"start":2,"end":3,"cssClass":"pl-c"}],[{"start":2,"end":7,"cssClass":"pl-smi"},{"start":11,"end":22,"cssClass":"pl-sr"},{"start":11,"end":13,"cssClass":"pl-pds"},{"start":11,"end":12,"cssClass":"pl-c1"},{"start":20,"end":22,"cssClass":"pl-cce"},{"start":22,"end":24,"cssClass":"pl-sr"},{"start":22,"end":24,"cssClass":"pl-pds"}],[{"start":4,"end":10,"cssClass":"pl-c1"},{"start":11,"end":22,"cssClass":"pl-s"},{"start":11,"end":12,"cssClass":"pl-pds"},{"start":12,"end":14,"cssClass":"pl-smi"},{"start":15,"end":17,"cssClass":"pl-cce"},{"start":17,"end":19,"cssClass":"pl-smi"},{"start":19,"end":21,"cssClass":"pl-cce"},{"start":21,"end":22,"cssClass":"pl-pds"},{"start":24,"end":33,"cssClass":"pl-s"},{"start":24,"end":25,"cssClass":"pl-pds"},{"start":32,"end":33,"cssClass":"pl-pds"},{"start":35,"end":40,"cssClass":"pl-smi"}],[],[],[{"start":1,"end":17,"cssClass":"pl-c"},{"start":1,"end":2,"cssClass":"pl-c"}],[{"start":1,"end":3,"cssClass":"pl-k"},{"start":5,"end":10,"cssClass":"pl-smi"},{"start":14,"end":43,"cssClass":"pl-sr"},{"start":14,"end":16,"cssClass":"pl-pds"},{"start":14,"end":15,"cssClass":"pl-c1"},{"start":35,"end":37,"cssClass":"pl-cce"},{"start":42,"end":43,"cssClass":"pl-pds"}],[{"start":2,"end":8,"cssClass":"pl-smi"}],[],[{"start":1,"end":3,"cssClass":"pl-k"},{"start":5,"end":10,"cssClass":"pl-smi"},{"start":14,"end":44,"cssClass":"pl-sr"},{"start":14,"end":16,"cssClass":"pl-pds"},{"start":14,"end":15,"cssClass":"pl-c1"},{"start":35,"end":37,"cssClass":"pl-cce"},{"start":43,"end":44,"cssClass":"pl-pds"}],[{"start":2,"end":8,"cssClass":"pl-smi"}],[],[],[{"start":1,"end":3,"cssClass":"pl-k"},{"start":5,"end":10,"cssClass":"pl-smi"},{"start":14,"end":28,"cssClass":"pl-sr"},{"start":14,"end":16,"cssClass":"pl-pds"},{"start":14,"end":15,"cssClass":"pl-c1"},{"start":19,"end":27,"cssClass":"pl-smi"},{"start":27,"end":28,"cssClass":"pl-pds"}],[{"start":2,"end":7,"cssClass":"pl-smi"},{"start":11,"end":25,"cssClass":"pl-sr"},{"start":11,"end":13,"cssClass":"pl-pds"},{"start":11,"end":12,"cssClass":"pl-c1"},{"start":25,"end":39,"cssClass":"pl-sr"},{"start":25,"end":26,"cssClass":"pl-pds"},{"start":26,"end":36,"cssClass":"pl-smi"},{"start":38,"end":39,"cssClass":"pl-pds"},{"start":42,"end":64,"cssClass":"pl-c"},{"start":42,"end":43,"cssClass":"pl-c"}],[{"start":2,"end":7,"cssClass":"pl-smi"},{"start":11,"end":23,"cssClass":"pl-sr"},{"start":11,"end":13,"cssClass":"pl-pds"},{"start":11,"end":12,"cssClass":"pl-c1"},{"start":23,"end":35,"cssClass":"pl-sr"},{"start":23,"end":24,"cssClass":"pl-pds"},{"start":26,"end":34,"cssClass":"pl-smi"},{"start":34,"end":35,"cssClass":"pl-pds"},{"start":39,"end":63,"cssClass":"pl-c"},{"start":39,"end":40,"cssClass":"pl-c"}],[{"start":2,"end":7,"cssClass":"pl-smi"},{"start":25,"end":30,"cssClass":"pl-smi"},{"start":33,"end":41,"cssClass":"pl-smi"},{"start":44,"end":65,"cssClass":"pl-c"},{"start":44,"end":45,"cssClass":"pl-c"}],[{"start":2,"end":7,"cssClass":"pl-smi"},{"start":11,"end":18,"cssClass":"pl-sr"},{"start":11,"end":13,"cssClass":"pl-pds"},{"start":11,"end":12,"cssClass":"pl-c1"},{"start":18,"end":20,"cssClass":"pl-sr"},{"start":18,"end":20,"cssClass":"pl-pds"},{"start":20,"end":21,"cssClass":"pl-sr"},{"start":20,"end":21,"cssClass":"pl-pds"},{"start":20,"end":21,"cssClass":"pl-k"},{"start":28,"end":39,"cssClass":"pl-c"},{"start":28,"end":29,"cssClass":"pl-c"}],[{"start":2,"end":42,"cssClass":"pl-c"},{"start":2,"end":3,"cssClass":"pl-c"}],[{"start":2,"end":7,"cssClass":"pl-smi"},{"start":11,"end":17,"cssClass":"pl-sr"},{"start":11,"end":13,"cssClass":"pl-pds"},{"start":11,"end":12,"cssClass":"pl-c1"},{"start":17,"end":19,"cssClass":"pl-sr"},{"start":17,"end":19,"cssClass":"pl-pds"},{"start":19,"end":21,"cssClass":"pl-sr"},{"start":19,"end":21,"cssClass":"pl-pds"},{"start":19,"end":21,"cssClass":"pl-k"}],[{"start":2,"end":7,"cssClass":"pl-smi"},{"start":11,"end":16,"cssClass":"pl-sr"},{"start":11,"end":13,"cssClass":"pl-pds"},{"start":11,"end":12,"cssClass":"pl-c1"},{"start":13,"end":15,"cssClass":"pl-cce"},{"start":16,"end":19,"cssClass":"pl-sr"},{"start":16,"end":17,"cssClass":"pl-pds"},{"start":18,"end":19,"cssClass":"pl-pds"},{"start":19,"end":20,"cssClass":"pl-sr"},{"start":19,"end":20,"cssClass":"pl-pds"},{"start":19,"end":20,"cssClass":"pl-k"},{"start":28,"end":48,"cssClass":"pl-c"},{"start":28,"end":29,"cssClass":"pl-c"}],[],[{"start":2,"end":31,"cssClass":"pl-c"},{"start":2,"end":3,"cssClass":"pl-c"}],[{"start":2,"end":40,"cssClass":"pl-c"},{"start":2,"end":3,"cssClass":"pl-c"}],[{"start":2,"end":12,"cssClass":"pl-c"},{"start":2,"end":3,"cssClass":"pl-c"}],[],[{"start":4,"end":10,"cssClass":"pl-c1"},{"start":11,"end":22,"cssClass":"pl-s"},{"start":11,"end":12,"cssClass":"pl-pds"},{"start":12,"end":14,"cssClass":"pl-smi"},{"start":15,"end":17,"cssClass":"pl-cce"},{"start":17,"end":19,"cssClass":"pl-smi"},{"start":19,"end":21,"cssClass":"pl-cce"},{"start":21,"end":22,"cssClass":"pl-pds"},{"start":24,"end":33,"cssClass":"pl-s"},{"start":24,"end":25,"cssClass":"pl-pds"},{"start":32,"end":33,"cssClass":"pl-pds"},{"start":35,"end":42,"cssClass":"pl-s"},{"start":35,"end":36,"cssClass":"pl-pds"},{"start":36,"end":41,"cssClass":"pl-smi"},{"start":41,"end":42,"cssClass":"pl-pds"}],[],[],[],[{"start":0,"end":29,"cssClass":"pl-c"},{"start":0,"end":1,"cssClass":"pl-c"}],[{"start":0,"end":38,"cssClass":"pl-c"},{"start":0,"end":1,"cssClass":"pl-c"}],[{"start":0,"end":10,"cssClass":"pl-c"},{"start":0,"end":1,"cssClass":"pl-c"}],[{"start":0,"end":46,"cssClass":"pl-c"},{"start":0,"end":1,"cssClass":"pl-c"}],[],[],[{"start":0,"end":2,"cssClass":"pl-k"},{"start":4,"end":10,"cssClass":"pl-smi"}],[{"start":1,"end":6,"cssClass":"pl-smi"},{"start":10,"end":26,"cssClass":"pl-sr"},{"start":10,"end":12,"cssClass":"pl-pds"},{"start":10,"end":11,"cssClass":"pl-c1"},{"start":26,"end":28,"cssClass":"pl-sr"},{"start":26,"end":28,"cssClass":"pl-pds"},{"start":33,"end":49,"cssClass":"pl-c"},{"start":33,"end":34,"cssClass":"pl-c"}],[{"start":1,"end":6,"cssClass":"pl-smi"},{"start":10,"end":20,"cssClass":"pl-sr"},{"start":10,"end":12,"cssClass":"pl-pds"},{"start":10,"end":11,"cssClass":"pl-c1"},{"start":12,"end":18,"cssClass":"pl-cce"},{"start":20,"end":28,"cssClass":"pl-sr"},{"start":20,"end":21,"cssClass":"pl-pds"},{"start":21,"end":27,"cssClass":"pl-cce"},{"start":27,"end":28,"cssClass":"pl-pds"},{"start":33,"end":50,"cssClass":"pl-c"},{"start":33,"end":34,"cssClass":"pl-c"}],[{"start":1,"end":6,"cssClass":"pl-smi"},{"start":24,"end":29,"cssClass":"pl-smi"},{"start":32,"end":40,"cssClass":"pl-smi"},{"start":43,"end":64,"cssClass":"pl-c"},{"start":43,"end":44,"cssClass":"pl-c"}],[{"start":1,"end":6,"cssClass":"pl-smi"},{"start":10,"end":15,"cssClass":"pl-sr"},{"start":10,"end":12,"cssClass":"pl-pds"},{"start":10,"end":11,"cssClass":"pl-c1"},{"start":12,"end":14,"cssClass":"pl-cce"},{"start":15,"end":18,"cssClass":"pl-sr"},{"start":15,"end":16,"cssClass":"pl-pds"},{"start":17,"end":18,"cssClass":"pl-pds"},{"start":18,"end":19,"cssClass":"pl-sr"},{"start":18,"end":19,"cssClass":"pl-pds"},{"start":18,"end":19,"cssClass":"pl-k"},{"start":27,"end":66,"cssClass":"pl-c"},{"start":27,"end":28,"cssClass":"pl-c"}],[{"start":1,"end":7,"cssClass":"pl-c1"},{"start":8,"end":19,"cssClass":"pl-s"},{"start":8,"end":9,"cssClass":"pl-pds"},{"start":9,"end":11,"cssClass":"pl-smi"},{"start":12,"end":14,"cssClass":"pl-cce"},{"start":14,"end":16,"cssClass":"pl-smi"},{"start":16,"end":18,"cssClass":"pl-cce"},{"start":18,"end":19,"cssClass":"pl-pds"},{"start":21,"end":30,"cssClass":"pl-s"},{"start":21,"end":22,"cssClass":"pl-pds"},{"start":29,"end":30,"cssClass":"pl-pds"},{"start":32,"end":39,"cssClass":"pl-s"},{"start":32,"end":33,"cssClass":"pl-pds"},{"start":33,"end":38,"cssClass":"pl-smi"},{"start":38,"end":39,"cssClass":"pl-pds"}],[],[],[{"start":0,"end":7,"cssClass":"pl-c"},{"start":0,"end":1,"cssClass":"pl-c"}],[]],"colorizedLines":null,"csv":null,"csvError":null,"dependabotInfo":{"showConfigurationBanner":false,"configFilePath":null,"networkDependabotPath":"/VinzenzBauer/mailparse/network/updates","dismissConfigurationNoticePath":"/settings/dismiss-notice/dependabot_configuration_notice","configurationNoticeDismissed":null},"displayName":"parse_mail.pl","displayUrl":"https://github.com/VinzenzBauer/mailparse/blob/main/parse_mail.pl?raw=true","headerInfo":{"blobSize":"2.42 KB","deleteTooltip":"You must be signed in to make or propose changes","editTooltip":"You must be signed in to make or propose changes","ghDesktopPath":"https://desktop.github.com","isGitLfs":false,"onBranch":true,"shortPath":"7677c1d","siteNavLoginPath":"/login?return_to=https%3A%2F%2Fgithub.com%2FVinzenzBauer%2Fmailparse%2Fblob%2Fmain%2Fparse_mail.pl","isCSV":false,"isRichtext":false,"toc":null,"lineInfo":{"truncatedLoc":"105","truncatedSloc":"90"},"mode":"executable file"},"image":false,"isCodeownersFile":null,"isPlain":false,"isValidLegacyIssueTemplate":false,"issueTemplate":null,"discussionTemplate":null,"language":"Perl","languageID":282,"large":false,"planSupportInfo":{"repoIsFork":null,"repoOwnedByCurrentUser":null,"requestFullPath":"/VinzenzBauer/mailparse/blob/main/parse_mail.pl","showFreeOrgGatedFeatureMessage":null,"showPlanSupportBanner":null,"upgradeDataAttributes":null,"upgradePath":null},"publishBannersInfo":{"dismissActionNoticePath":"/settings/dismiss-notice/publish_action_from_dockerfile","releasePath":"/VinzenzBauer/mailparse/releases/new?marketplace=true","showPublishActionBanner":false},"rawBlobUrl":"https://github.com/VinzenzBauer/mailparse/raw/main/parse_mail.pl","renderImageOrRaw":false,"richText":null,"renderedFileInfo":null,"shortPath":null,"symbolsEnabled":true,"tabSize":8,"topBannersInfo":{"overridingGlobalFundingFile":false,"globalPreferredFundingPath":null,"showInvalidCitationWarning":false,"citationHelpUrl":"https://docs.github.com/github/creating-cloning-and-archiving-repositories/creating-a-repository-on-github/about-citation-files","actionsOnboardingTip":null},"truncated":false,"viewable":true,"workflowRedirectUrl":null,"symbols":{"timed_out":false,"not_analyzed":true,"symbols":[]}},"copilotInfo":null,"copilotAccessAllowed":false,"csrf_tokens":{"/VinzenzBauer/mailparse/branches":{"post":"wwg70dmHVfGY_VjedhFR1EYayJOUIYbwsH4nynhUS68uAnwZ7aKMW7if1WQIfOQ-eX4ocyoi1gj5nwEcYy60pw"},"/repos/preferences":{"post":"YlMd80_Rt9XrMgLHoJhDcYRJ5etdERnEoO5wft4RPjv_GNuvWHG5kZi3M9kQiwtF5FIHdQsGl6Y0h9aTm7gJMw"}}},"title":"mailparse/parse_mail.pl at main · VinzenzBauer/mailparse"}