for a in $(aws sqs list-queues --profile Dev_sso | grep -v "sys" | grep -v "int" | grep -v "hotfix" | grep -v "dev-###-dev" | sed ':a;N;$!ba;s/,\(\s*\]\s*\)/\1/' | jq -r '.QueueUrls[]');
do
  aws sqs delete-queue --queue-url $a --profile  Dev_sso;
done
