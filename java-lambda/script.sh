cd spring-demo
sam build
sam local start-api
curl localhost:3000/health
sam deploy