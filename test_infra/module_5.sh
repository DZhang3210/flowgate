#Test api endpoint
curl http://flowgate-staging-2100968138.us-east-1.elb.amazonaws.com/api/data -H "Authorization: Bearer fg_3658f7064b3b729058ad1f195c679e5e"

#Trigger a cloudwatch alarm to observe SNS
aws cloudwatch set-alarm-state --alarm-name flowgate-dlq-greater-than-zero --state-value ALARM --state-reason "Manual test of SNS wiring"

#Trigger a 500 Error on your server
curl http://flowgate-staging-2100968138.us-east-1.elb.amazonaws.com/tenants/abc/keys

#Spams 500 Triggering Command.
for ($i=0; $i -lt 240; $i++) { curl.exe -s -o NUL http://flowgate-staging-2100968138.us-east-1.elb.amazonaws.com/tenants/abc/keys; Start-Sleep -Seconds 1 }

#trigger DLQ alarm (already uses invalid webhook email)
curl http://flowgate-staging-2100968138.us-east-1.elb.amazonaws.com/api/data -H "Authorization: Bearer fg_3658f7064b3b729058ad1f195c679e5e"

#try to connect from outside