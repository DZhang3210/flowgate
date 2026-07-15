#./wake.ps1 

$wakeArn = terraform output -raw wake_lambda_arn
aws lambda invoke --function-name $wakeArn response.json
Get-Content response.json