# mailparse
mailscourcecode filter to only the important info

# at one time required modules and installations ** skip this **
cpan
cpan HTML::Strip module
perl -MCPAN -e shell
cpan[1]>  o conf prerequisites_policy follow
cpan[2]>  o conf commit
exit

# execute from git providing the mail mail_unformated10
cat mail_unformated10 | perl <(wget -qO- https://raw.githubusercontent.com/VinzenzBauer/mailparse/main/parse_mail.pl)
