#Test Experiment A. Shut down one ecs api server
aws fis start-experiment --experiment-template-id EXTCt7jhVSTqstVXn

#Test Experiment B. Shut down all ecs api server. Need to implement for prod
aws fis start-experiment --experiment-template-id EXT7ZTtp5WhzHktqW

# Test Experiment C. Initiate Pseudo Redis Failure, via reboot
aws elasticache reboot-cache-cluster --cache-cluster-id flowgate-staging-redis-001 --cache-node-ids-to-reboot 0001

#HIT ALB
curl http://flowgate-staging-2100968138.us-east-1.elb.amazonaws.com/api/data -H "Authorization: Bearer fg_57a8b16f553adf3baf2d14ca9e8067e2"

#HIT ALB CONTINUOUSLY
while true; do 
  code=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer fg_57a8b16f553adf3baf2d14ca9e8067e2" http://flowgate-staging-2100968138.us-east-1.elb.amazonaws.com/api/data)
  echo "$(date +%H:%M:%S) - $code"
  sleep 1
done