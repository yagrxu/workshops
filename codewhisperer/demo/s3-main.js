// import s3 client from @aws-sdk
import { S3Client, CreateBucketCommand, DeleteBucketCommand, PutObjectCommand, DeleteObjectCommand } from "@aws-sdk/client-s3";
import fs from "fs";

// create a new S3Client
const s3Client = new S3Client({});

// create a S3 bucket
// parameter: bucketName and region
export const createBucket = async (bucketName, region) => {
  // create a bucket
  const bucket = await s3Client.send(
    new CreateBucketCommand({
      Bucket: bucketName,
      CreateBucketConfiguration: {
        LocationConstraint: region,
      },
    })
  );
  console.log("Bucket Created Successfully", bucket.Location);
};

// function main
// parameter argv, command line input
// if argv[2] is create, then create a bucket with name taking from argv[3]
function main(argv) {
  if (argv[2] === "create") {
    createBucket(argv[3], argv[4]);
  } else if (argv[2] === "delete") {
    deleteBucket(argv[3], argv[4]);
  } else if (argv[2] === "upload") {
    uploadObject(argv[3], argv[4], argv[5]);
  } else if (argv[2] === "deleteObject") {
    deleteObject(argv[3], argv[4]);
  }
}

// upload an object to S3 bucket
// parameter: bucketName, objectName, content
export const uploadObject = async (bucketName, objectName, fileName) => {
  const response = await s3Client.send(
    new PutObjectCommand({
      Bucket: bucketName,
      Key: objectName,
      Body: fs.readFileSync(fileName),
    })
  );
  console.log("Object Uploaded Successfully", response);
};

// delete a S3 bucket
// parameter: bucketName, region
export const deleteBucket = async (bucketName, region) => {
  const response = await s3Client.send(new DeleteBucketCommand({ Bucket: bucketName }));
  console.log("Bucket Deleted Successfully", response);
};

// delete a object from s3 bucket
// parameter: bucketName, objectName
export const deleteObject = async (bucketName, objectName) => {
  const response = await s3Client.send(
    new DeleteObjectCommand({
      Bucket: bucketName,
      Key: objectName,
    })
  );
  console.log("Object Deleted Successfully", response);
};

main(process.argv);
