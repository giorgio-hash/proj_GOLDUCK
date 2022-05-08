

const AWS = require('aws-sdk');
const s3 = new AWS.S3();

const fxp = require('fast-xml-parser');
const parser = new fxp.XMLParser();

exports.handler = async (event) => {
    try {
        var params = {
          Bucket: 'xmlres', 
          Key: 'results-' + event.queryStringParameters.id + '.xml'
        };
        
        var results = await s3.getObject(params, function(err, data) {
          if (err) {
            console.log('Error', err);
          }
          else {
            return data;
          }
        }).promise();
        
        var xml = parser.parse(results.Body.toString('utf-8'));
        var classList = xml.ResultList.ClassResult.map(classRes => {
          return classRes.Class.Name;
        });
        
        return sendRes(200, JSON.stringify(classList));
    }
    catch (error) {
        console.log(error);
        return sendRes(404, 'Error');
    }
};

/*
ClassResult.Class.Name
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


