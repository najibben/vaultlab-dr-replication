
#!/usr/bin/env bash



#Begin dc2-b promote process
vault operator generate-root -dr-token -init -format=json > optoken.json
NONCE=$(jq -r .nonce optoken.json)
OTP=$(jq -r .otp optoken.json)


ENCODED_TOKEN=$(vault operator generate-root -dr-token -format=json -nonce=${NONCE} `cat /vagrant/SomeKey.txt` | jq -r '.encoded_token')

DR_OPERATION_TOKEN=$(vault operator generate-root -dr-token -decode=${ENCODED_TOKEN} -otp=${OTP})


sleep 1

vault write /sys/replication/dr/secondary/promote dr_operation_token=${DR_OPERATION_TOKEN}
