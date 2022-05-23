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

  while (true) { // itera finchè s3 non restituisce il file in modo corretto
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
       "Content-Type" : "application/json", 
            "Access-Control-Allow-Origin" : "*",
            "X-Requested-With" : "*"
    },
    body: body
  };
  return response;
};

async function s3download(id) {
  var params = {
    Bucket: 'secchiellobello',
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