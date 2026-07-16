import os
import boto3

ecs = boto3.client('ecs')
rds = boto3.client('rds')

def lambda_handler(event, context):
    cluster = os.environ['ECS_CLUSTER']
    api_service = os.environ['ECS_API_SERVICE']
    worker_service = os.environ['ECS_WORKER_SERVICE']
    db_identifier = os.environ['RDS_IDENTIFIER']
    api_desired_count = os.environ["API_DESIRED_COUNT"]
    worker_desired_count = os.environ["WORKER_DESIRED_COUNT"]

    try: 
        response = rds.describe_db_instances(DBInstanceIdentifier=db_identifier)
        status = response['DBInstances'][0]['DBInstanceStatus']
        if status == 'stopped':
            rds.start_db_instance(DBInstanceIdentifier=db_identifier)

        waiter = rds.get_waiter('db_instance_available')
        waiter.wait(DBInstanceIdentifier=db_identifier)
    
        ecs.update_service(cluster=cluster, service=api_service, desiredCount=int(api_desired_count))
        ecs.update_service(cluster=cluster, service=worker_service, desiredCount=int(worker_desired_count))
        return {"status": "awake"}
    except Exception as e:
        return {"status": "internal failure", "error": str(e)}

   