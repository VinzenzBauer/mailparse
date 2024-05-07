# mailparse
### parse and shorten mail to raw decoded text

# example mail called mail_unformated10
### cat mail_unformated10 | perl <(wget -qO- https://raw.githubusercontent.com/VinzenzBauer/mailparse/main/parse_mail.pl)
### postcat -q mail_unformated10 | perl <(wget -qO- https://raw.githubusercontent.com/VinzenzBauer/mailparse/main/parse_mail.pl)

#### or use the keybind which parses the selected input and chooses the appropriate command itself
#### parameters 1 for debug and greater 1 for maximum lines per item (eg. mail-body or receivers-lists)
