const AWS = require('aws-sdk');
const s3 = new AWS.S3();

const parser = require('xml-js');

exports.handler = async (event) => {
  var i = 0;
  var results;
  try {
    results = await s3download(event.queryStringParameters.id);
  } catch (error) {
    console.log(error);
    return sendRes(404, error);
  }

  while (true) {

    try {
      var xml = JSON.parse(parser.xml2json(results.Body.toString('utf-8'), {
        compact: true,
        ignoreComment: false,
        spaces: 2
      }));
      break;
    } catch (err) {
      results = await s3download(event);
    }

  }

  var classList = xml.ResultList.ClassResult.map(classRes => {
    return classRes.Class.Name['_text'];
  });

  return sendRes(200, JSON.stringify(classList));

};

/*
ClassResult.Class.Name
*/

const sendRes = (status, body) => {
  var response = {
    statusCode: status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
      "Access-Control-Allow-Methods": "OPTIONS,POST,PUT",
      "Access-Control-Allow-Credentials": true,
      "Access-Control-Allow-Origin": "*",
      "X-Requested-With": "*"
    },
    body: body
  };
  return response;
};

async function s3download(id) {
  var params = {
    Bucket: 'xmlres-1',
    Key: 'results-' + id + '.xml'
  };

  var results = await s3.getObject(params, function (err, data) {
    if (err) {
      console.log('Error', err);
    } else {
      return data;
    }
  }).promise();
  return results;
}