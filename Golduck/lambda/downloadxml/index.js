const AWS = require('aws-sdk');
const s3 = new AWS.S3();
const parser = require('xml-js');
exports.handler = async (event) => {

  var params = {
    Bucket: 'xmlres-1',
    Key: 'results-' + event.queryStringParameters.id + '.xml'
  };
  try {
    var results = await s3download(params);
  } catch (error) {
    console.log(error);
    return sendRes(404, error);
  }
  while (true) { // itera finchè s3 non restituisce il file in modo corretto
    try {
      JSON.parse(parser.xml2json(results.Body.toString('utf-8'), {
        compact: true,
        ignoreComment: false,
        spaces: 2
      }));
      break;
    } catch (err) {
      results = await s3download(event);
    }
  }

  return sendRes(200, results.Body.toString('utf-8'));

};


const sendRes = (status, body) => {
  var response = {
    statusCode: status,
    headers: {
      "Content-Type": "application/octet-stream",
      "Content-Disposition": 'attachment; filename="results.xml"',
      "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
      "Access-Control-Allow-Credentials": true,
      "Access-Control-Allow-Origin": "*",
      "X-Requested-With": "*"
    },
    body: body
  };
  return response;
};

async function s3download(params) {
  return await s3.getObject(params, function (err, data) {
    if (err) {
      console.log('Error', err);
    } else {
      return data;
    }
  }).promise();
}