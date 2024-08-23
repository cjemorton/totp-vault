# totp-vault

- Clone repository.
- Run `run.sh http://example.com/url`
- The url is a json string, that is base64 encoded, and then gpg encrypted.


## Run the script directly...
`curl -sSL https://raw.githubusercontent.com/cjemorton/totp-vault/main/run.sh | bash -s -- http://example.com/url`

## NOTES.
- The Provided URL required as the first argument $1 of `run.sh $1`, is..
- totp.txt.gpg.b64.json
- The TOTP file is stored as plain text and encrypted with gpg, which is then base64 encoded and then encoded as a JSON file.

# To create JSON data.
`echo "YOUR_TOTP" | gpg -c | base64 | jq -R . | jq .`


`$JSON_STRING | jq -r . | base64 -D | gpg -d`
