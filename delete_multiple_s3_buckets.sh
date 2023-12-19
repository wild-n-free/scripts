for a in $(aws s3api list-buckets --query 'Buckets[*].Name' --output text --profile Dev_sso);
do
  aws s3api delete-bucket --bucket $a --profile Dev_sso;
done
