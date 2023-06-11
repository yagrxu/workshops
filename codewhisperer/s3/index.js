import { S3Client } from "@aws-sdk/client-s3";
import { CreateBucketCommand } from "@aws-sdk/client-s3";
import { PutObjectCommand } from "@aws-sdk/client-s3";
import { DeleteBucketCommand } from "@aws-sdk/client-s3";
import fs from "fs";
import { DeleteObjectCommand } from "@aws-sdk/client-s3";

let client = new S3Client({ region: "us-east-1" });

// create a S3 bucket with bucketName as parameter
export const createBucket = async (bucketName) => {
  let params = {
    Bucket: bucketName,
  };

  let response = await client.send(new CreateBucketCommand(params));
  console.log(response);
};

// delete a bucket with bucketName as parameter
export const deleteBucket = async (bucketName) => {
  let params = {
    Bucket: bucketName,
  };

  let response = await client.send(new DeleteBucketCommand(params));
  console.log(response);
};

// upload a local file to S3 bucket with bucketName, fileName as arguments
export const uploadFile = async (bucketName, fileName) => {
  let params = {
    Bucket: bucketName,
    Key: fileName,
    Body: fs.readFileSync(fileName),
  };

  let response = await client.send(new PutObjectCommand(params));
  console.log(response);
};

// delete object from S3 bucket with bucketName and fileName as arguments
export const deleteObject = async (bucketName, fileName) => {
  let params = {
    Bucket: bucketName,
    Key: fileName,
  };

  let response = await client.send(new DeleteObjectCommand(params));
  console.log(response);
};

// accept a parameter from command line and if the value is "create" then create the S3 bucket, if it is "delete" then delete the S3 bucket, if it is "delete-object" then delete an object from the S3 bucket or if it is "upload" then upload a file to the S3 bucket

export const main = async (args) => {
  if (args[2] === "create") {
    await createBucket(args[3]);
  } else if (args[2] === "delete") {
    await deleteBucket(args[3]);
  } else if (args[2] === "upload") {
    await uploadFile(args[3], args[4]);
  } else if (args[2] === "delete-object") {
    await deleteObject(args[3], args[4]);
  }
};

main(process.argv);
