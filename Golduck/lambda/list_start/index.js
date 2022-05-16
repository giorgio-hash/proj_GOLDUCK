const AWS = require('aws-sdk');
const s3 = new AWS.S3();

const parser = require('xml-js');

exports.handler = async (event) => {

  var id = event.queryStringParameters.id;
  var clazz = event.queryStringParameters.class;

  var results;
  try {
    results = await s3download(id);
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

  var starters = new Array();

  for(var classStart of xml.StartList.ClassStart) {
    if (classStart.Class.Name != clazz)
      continue;
    for(var personStart of classStart.PersonStart) {

      starters.push({
        'name': personStart.Person.Name.Family,
        'surname': personStart.Person.Name.Given,
        'org': personStart.Organisation.Name,
        'time': personStart.Start.StartTime != null ? personStart.Start.StartTime : '00.00.00'
    });

    }
  }
  return sendRes(200, JSON.stringify(starters));

};

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
    Bucket: 'xmlres',
    Key: 'start-' + id + '.xml'
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