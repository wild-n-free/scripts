for a in $(aws s3api list-buckets --query 'Buckets[*].Name' --output text --profile Dev_sso);
do
  aws s3 rm s3://$a/ --recursive --profile Dev_sso;
done
