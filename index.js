const AWS = require('aws-sdk');
const fs = require('fs');
const path = require('path');
const archiver = require('archiver');

const s3 = new AWS.S3();

exports.handler = async (event) => {
  const binaryDir = path.join(process.env.LAMBDA_TASK_ROOT, 'cputil-linux-x64');
  const zipPath = '/tmp/cputil-linux-x64.zip';
  // Create zip file
  const output = fs.createWriteStream(zipPath);
  const archive = archiver('zip', {
    zlib: { level: 9 }, // Maximum compression
  });

  // Create promise to handle the zip completion
  const zipPromise = new Promise((resolve, reject) => {
    output.on('close', resolve);
    archive.on('error', reject);
  });

  // Pipe archive data to the output file
  archive.pipe(output);

  // Add the entire directory to the zip
  archive.directory(binaryDir, 'cputil-linux-x64');

  // Finalize the archive
  await archive.finalize();

  // Wait for the zip to complete
  await zipPromise;

  // Upload zip to S3
  await s3
    .putObject({
      Bucket: '**your bucket name**',
      Key: 'cputil-linux-x64.zip',
      Body: fs.createReadStream(zipPath),
    })
    .promise();

  return {
    statusCode: 200,
    body: 'Binaries uploaded to S3',
  };
};
