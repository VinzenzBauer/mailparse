# mailparse
### mailscourcecode filter to only the important info

# execute from git providing the mail mail_unformated10
### cat mail_unformated10 | perl <(wget -qO- https://raw.githubusercontent.com/VinzenzBauer/mailparse/main/parse_mail.pl)
### postcat -q mail_unformated10 | perl <(wget -qO- https://raw.githubusercontent.com/VinzenzBauer/mailparse/main/parse_mail.pl)

### or use the keybind which parses the selected input and chooses the appropriate command itself