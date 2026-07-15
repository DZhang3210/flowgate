## 3.6

#Create tenant
curl \
-X POST \
http://flowgate-staging-2100968138.us-east-1.elb.amazonaws.com/tenants \ 
-H "Content-Type: application/json" \
-d '{"name":"David", "email":"davidzhang3210@gmail.com", "plan":"free"}'

#Create api key
curl \
-X POST \
http://flowgate-staging-2100968138.us-east-1.elb.amazonaws.com/tenants/37eb81652-9d1d-4c72-849d-b02aaa544cdb/keys \ 

#Test if we can get data using api 
curl http://flowgate-staging-2100968138.us-east-1.elb.amazonaws.com/api/data -H "Authorization: Bearer fg_57a8b16f553adf3baf2d14ca9e8067e2"

## 3.7
#Tests if we can create a persistent TCP Connection to RDS (Should fail in database subnet)
nc -zv terraform-20260620024034101200000001.cmbguau82pu3.us-east-1.rds.amazonaws.com 5432
#windows version
Test-NetConnection -ComputerName terraform-20260620024034101200000001.cmbguau82pu3.us-east-1.rds.amazonaws.com -Port 5432

## 3.8
#Tests if we can create a persistent TCP Connection to redis (Should fail in database subnet)
nc -zv flowgate-staging-redis.a5mr2q.ng.0001.use1.cache.amazonaws.com 6379
#windows version
Test-NetConnection -ComputerName flowgate-staging-redis.a5mr2q.ng.0001.use1.cache.amazonaws.com -Port 6379