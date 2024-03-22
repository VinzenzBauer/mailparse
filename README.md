# mailparse
mailscourcecode filter to only the important info

# required modules and installations
cpan
cpan HTML::Strip module
perl -MCPAN -e shell
cpan[1]>  o conf prerequisites_policy follow
cpan[2]>  o conf commit
exit

# execute from git providing the mail mail_unformated10
wget -O - https://raw.githubusercontent.com/VinzenzBauer/mailparse/main/parse_mail.pl $1 2>&1 | cat mail_unformated10 | perl ./parse_mail.p
