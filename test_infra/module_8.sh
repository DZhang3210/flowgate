#Test Experiment A. Shut down one ecs api server
aws fis start-experiment --experiment-template-id EXTCt7jhVSTqstVXn

#Test Experiment B. Shut down all ecs api server. Need to implement for prod
aws fis start-experiment --experiment-template-id EXT7ZTtp5WhzHktqW

# Test Experiment C. Initiate Pseudo Redis Failure, via reboot
aws elasticache reboot-cache-cluster --cache-cluster-id flowgate-staging-redis-001 --cache-node-ids-to-reboot 0001