

var AWS = require('aws-sdk');
var fxp = require('fast-xml-parser');
var s3 = new AWS.S3();
var parser = new fxp.XMLParser();
// Create DynamoDB service object
//var db = new AWS.DynamoDB();




exports.handler = async (event) => {
    try {
        var params = {Bucket: 'xmlres', Key: 'results-' + event.queryStringParameters.id + '.xml'};
        var results = await s3.getObject(params, function(err, data) {
          if (err) {
            console.log('Error', err);
          }
          else {
            return data;
          }
        }).promise();
        var xml = results.Body.toString('utf-8');
        var jsObj = parser.parse(xml);
        return sendRes(200, JSON.stringify(jsObj.ResultList.ClassResult));
    }
    catch (error) {
        console.log(error);
        return sendRes(404, 'Error');
    }
};

/*
const queryXML = (id) => {
  var params = {
    ExpressionAttributeValues: {
      ':id': {S: id},
    },
    KeyConditionExpression: 'id_gara = :id ',
    TableName: 'risultati_gare'
  };
  
  db.query(params, function(err, data) {
    if (err) {
      console.log("Error", err);
    } else {
      console.log("Success", data.Items);
      return data.Items;
    }
  });
};
*/

const sendRes = (status, body) => {
    var response = {
        statusCode: status,
        headers: {
            "Content-Type" : "application/json",
            "Access-Control-Allow-Headers" : "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
            "Access-Control-Allow-Methods" : "OPTIONS,POST,PUT",
            "Access-Control-Allow-Credentials" : true,
            "Access-Control-Allow-Origin" : "*",
            "X-Requested-With" : "*"
        },
        body: body
    };
    return response;
};



