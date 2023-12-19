for rest_api_id in $(aws apigateway get-rest-apis --region eu-west-2 --query 'items[*].id' --output text --profile Dev_sso);
do
  aws apigateway delete-rest-api --region eu-west-2 --rest-api-id $rest_api_id --profile Dev_sso;
  sleep 30;
done
