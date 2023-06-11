// import DynamoDBClient
const { DynamoDBClient, CreateTableCommand, DeleteTableCommand, ListTablesCommand } = require("@aws-sdk/client-dynamodb");

// create DynamoDB client
let client = new DynamoDBClient({
  region: "ap-southeast-1",
});

// create DynamoDB table with tableName, hashKey and rangeKey as arguments
async function createTable(tableName, hashKey, rangeKey) {
  var params = {
    TableName: tableName,
    KeySchema: [
      { AttributeName: hashKey, KeyType: "HASH" },
      { AttributeName: rangeKey, KeyType: "RANGE" },
    ],
    AttributeDefinitions: [
      { AttributeName: hashKey, AttributeType: "S" },
      { AttributeName: rangeKey, AttributeType: "S" },
    ],
    ProvisionedThroughput: {
      ReadCapacityUnits: 10,
      WriteCapacityUnits: 10,
    },
  };
  let response = await client.send(new CreateTableCommand(params));
  console.log(response);
}

// delete DynamoDB Table
// parameters: tableName
async function deleteTable(tableName) {
  var params = {
    TableName: tableName,
  };
  let response = await client.send(new DeleteTableCommand(params));
  console.log(response);
}

// function listTable - 列出所有DynamoDB 的表
async function listTable() {
  var params = {};
  let response = await client.send(new ListTablesCommand(params));
  console.log(response);
}

// function main
// parmameter from command line argv
// 如果输入参数是create, 就调用createTable，如果参数是delete 就调用deleteTable
async function main(argv) {
  if (argv[2] == "create") {
    await createTable(argv[3], argv[4], argv[5]);
  } else if (argv[2] == "delete") {
    await deleteTable(argv[3]);
  } else if (argv[2] == "list") {
    await listTable();
  } else {
    console.log("Invalid command");
  }
}

// call main function
main(process.argv);
