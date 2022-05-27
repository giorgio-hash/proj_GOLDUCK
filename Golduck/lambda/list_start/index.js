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
      results = await s3download(id);
    }

  }

  var starters = new Array();
  
  
  if (clazz == '*') {
    
  for(var classStart of xml.StartList.ClassStart) {
    if (classStart.PersonStart != null)
      if (!Array.isArray(classStart.PersonStart)) {
        starters.push({
          'name': classStart.PersonStart.Person.Name.Family['_text'],
          'surname': classStart.PersonStart.Person.Name.Given['_text'],
          'org': classStart.PersonStart.Organisation.Name['_text'],
          'time': classStart.PersonStart.Start.StartTime['_text'] != null ? classStart.PersonStart.Start.StartTime['_text'] : '00.00.00',
          'class': classStart.Class.Name['_text'],
          "numero" : classStart.PersonStart.Person.Id['_text']
      });
    } else {
      for(var personStart of classStart.PersonStart) {
        starters.push({
          'name': personStart.Person.Name.Family['_text'],
          'surname': personStart.Person.Name.Given['_text'],
          'org': personStart.Organisation.Name['_text'],
          'time': personStart.Start.StartTime['_text'] != null ? personStart.Start.StartTime['_text'] : '00.00.00',
          'class': classStart.Class.Name['_text'],
          "numero" : personStart.Person.Id['_text']
      });
     }
    }
    }
    return sendRes(200, JSON.stringify(starters));
  }
  

  for(var classStart of xml.StartList.ClassStart) {
    if (classStart.Class.Name['_text'] != clazz)
      continue;
    for(var personStart of classStart.PersonStart) {

      starters.push({
        'name': personStart.Person.Name.Family['_text'],
        'surname': personStart.Person.Name.Given['_text'],
        'org': personStart.Organisation.Name['_text'],
        'time': personStart.Start.StartTime['_text'] != null ? personStart.Start.StartTime['_text'] : '00.00.00',
        'class': classStart.Class.Name['_text'],
        "numero" : personStart.Person.Id['_text']
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
    Bucket: 'secchiellobello',
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