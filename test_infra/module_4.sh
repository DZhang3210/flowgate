#Create a tenant w/ webhook_url
curl \
-X POST \
http://flowgate-staging-2100968138.us-east-1.elb.amazonaws.com/tenants \ 
-H "Content-Type: application/json" \
-d '{"name":"David", "email":"davidzhang43210@gmail.com", "plan":"free", "webhookUrl":"https://webhook.site/2500a8bf-68fc-4ce2-b91c-b2cac6d48b56"}'
Invoke-RestMethod -Method POST `
  -Uri "http://flowgate-staging-2100968138.us-east-1.elb.amazonaws.com/tenants" `
  -ContentType "application/json" `
  -Body '{"name":"David","email":"davidzhang43210@gmail.com","plan":"free","webhookUrl":"https://webhook.site/2500a8bf-68fc-4ce2-b91c-b2cac6d48b56"}'

#Create Api key
curl \
-X POST \
http://flowgate-staging-2100968138.us-east-1.elb.amazonaws.com/tenants/a2e7b811-8e57-42b5-8859-4242043dc4f2/keys \ 
curl -X POST http://flowgate-staging-2100968138.us-east-1.elb.amazonaws.com/tenants/a2e7b811-8e57-42b5-8859-4242043dc4f2/keys -H "Content-Type: application/json" 

#Test if we can get data using api
curl http://flowgate-staging-2100968138.us-east-1.elb.amazonaws.com/api/data -H "Authorization: Bearer fg_dc52a99e4bc6f11b404828ef3d41fc40"


#Test webhook failure (creating user w/ invalid webhook url)
curl -X POST http://flowgate-staging-2100968138.us-east-1.elb.amazonaws.com/tenants -H "Content-Type: application/json" -d '{"name":"David", "email":"davidzhang4321@gmail.com", "plan":"free", "webhookUrl":"https://httpstat.us/500"}'

curl -X POST http://flowgate-staging-2100968138.us-east-1.elb.amazonaws.com/tenants/346a12a8-d8d7-4e91-b90b-463f6ad9cf57/keys -H "Content-Type: application/json" 

curl http://flowgate-staging-2100968138.us-east-1.elb.amazonaws.com/api/data -H "Authorization: Bearer fg_3658f7064b3b729058ad1f195c679e5e"