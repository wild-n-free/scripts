for domain_name in $(aws apigateway get-domain-names --region eu-west-2 --query 'items[*].domainName' --output text --profile Dev_sso);
do
  aws apigateway delete-domain-name --region eu-west-2 --domain-name $domain_name --profile Dev_sso;
  sleep 30;
done
