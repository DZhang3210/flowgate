import os
import boto3
import json

ecs = boto3.client('ecs')
rds = boto3.client('rds')

def lambda_handler(event, context):

    message = json.loads(event['Records'][0]['Sns']['Message'])
    if message.get('AlarmName') != 'flowgate-alb-no-requests-for-1-hour':
        return {"status": "ignored"}
    
    cluster = os.environ['ECS_CLUSTER']
    api_service = os.environ['ECS_API_SERVICE']
    worker_service = os.environ['ECS_WORKER_SERVICE']
    db_identifier = os.environ['RDS_IDENTIFIER']

    ecs.update_service(cluster=cluster, service=api_service, desiredCount=0)
    ecs.update_service(cluster=cluster, service=worker_service, desiredCount=0)

    waiter = ecs.get_waiter('services_stable')
    waiter.wait(cluster = cluster, services = [api_service, worker_service])
    

    response = rds.describe_db_instances(DBInstanceIdentifier=db_identifier)
    status = response['DBInstances'][0]['DBInstanceStatus']
    if status == 'available':
        rds.stop_db_instance(DBInstanceIdentifier=db_identifier)

    return {"status": "sleeping"}