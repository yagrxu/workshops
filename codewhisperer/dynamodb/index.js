import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { CreateTableCommand } from "@aws-sdk/client-dynamodb";
import { DeleteTableCommand } from "@aws-sdk/client-dynamodb";
import { ListTablesCommand } from "@aws-sdk/client-dynamodb";

let client = new DynamoDBClient({ region: "us-east-1" });

// create a new DynamoDB table named ClientInfo with clientId and time as hash key and range key perspectively
async function createTable() {
  const params = {
    AttributeDefinitions: [
      {
        AttributeName: "clientId",
        AttributeType: "S",
      },
      {
        AttributeName: "time",
        AttributeType: "S",
      },
    ],
    KeySchema: [
      {
        AttributeName: "clientId",
        KeyType: "HASH",
      },
      {
        AttributeName: "time",
        KeyType: "RANGE",
      },
    ],
    ProvisionedThroughput: {
      ReadCapacityUnits: 1,
      WriteCapacityUnits: 1,
    },
    TableName: "ClientInfo",
    StreamSpecification: {
      StreamEnabled: false,
    },
  };

  let resp = await client.send(new CreateTableCommand(params));
  console.log(resp);
  console.log("created");
}

// delete DynamoDB table ClientInfo
async function deleteTableClientInfo() {
  const params = {
    TableName: "ClientInfo",
  };

  let resp = await client.send(new DeleteTableCommand(params));
  console.log(resp);
  console.log("deleted");
}

// list dynamodb tables
async function listTables() {
  const params = {};
  let resp = await client.send(new ListTablesCommand(params));
  console.log(resp);
  console.log("listed");
}

// accept a parameter from command line and if the value is "create" then create the table, if it is "delete" then delete the table or if it is "list" then list the tables.
async function main(argv) {
  console.log(argv);
  if (argv[2] == "create") {
    await createTable();
  } else if (argv[2] == "delete") {
    await deleteTableClientInfo();
  } else if (argv[2] == "list") {
    await listTables();
  }
}

main(process.argv);
