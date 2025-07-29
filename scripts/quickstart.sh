#!/bin/sh
# /qompassai/neomutt/quickstart.sh
# Qompass AI Neomutt
# Copyright (C) 2025 Qompass AI, All rights reserved
# ----------------------------------------
DB_PATH="$HOME/.config/dovecot/virtual_users.db"
MAIL_PATH="$HOME/.mail"
CONFIG_PATH="$HOME/.config/dovecot"
echo "==> Setting up Dovecot SQLite user DB at $DB_PATH"
mkdir -p "$CONFIG_PATH"
echo "
CREATE TABLE IF NOT EXISTS virtual_users (
    email TEXT PRIMARY KEY,
    password TEXT NOT NULL
);
" | sqlite3 "$DB_PATH"
echo "SQLite database initialized."
printf "Enter email address for new mail user (e.g. me@example.com): "
read -r MAILUSER
printf "Enter password for %s: " "$MAILUSER"
stty -echo
read -r PASSWORD
stty echo
echo
HASH=$(doveadm pw -s SHA512-CRYPT -p "$PASSWORD")
HASH=$(echo "$HASH" | tail -n1)
echo "INSERT OR REPLACE INTO virtual_users (email, password) VALUES ('$MAILUSER', '$HASH');" | sqlite3 "$DB_PATH"
echo "User $MAILUSER added to virtual_users.db"
USERMAIL="$MAIL_PATH/$(echo "$MAILUSER" | cut -d'@' -f2)/$(echo "$MAILUSER" | cut -d'@' -f1)"
mkdir -p "$USERMAIL"
echo "Maildir skeleton (if needed) at: $USERMAIL"
echo "==> Dovecot SQLite DB ready!"
echo "Remember to configure Dovecot with:"
echo "  passdb { driver = sql; args = $DB_PATH }"
echo "  userdb { driver = sql; args = $DB_PATH }"
echo "  mail_location = maildir:$MAIL_PATH/%d/%n"
