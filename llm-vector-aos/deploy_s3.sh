cd ./src

rm chatglm2-6b-model.tar.gz
tar zcvf chatglm2-6b-model.tar.gz *

aws s3 cp chatglm2-6b-model.tar.gz \
  s3://cloudbeer-llm-models/llm/chatglm2-6b-model.tar.gz