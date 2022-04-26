const AWS = require('aws-sdk');
const db = new AWS.DynamoDB();
const s3 = new AWS.S3();

var fxp = require('fast-xml-parser');
var parser = new fxp.XMLParser();

const crypto = require('crypto');

exports.handler = async (event, context, callback) => {
    var uuid = crypto.randomUUID();
    const s3Bucket = "xmlres";
    const objectName = "results-" + uuid + ".xml";
    const objectData = event;
    const objectType = "application/xml";
try {
        const params = {
            Bucket: s3Bucket,
            Key: objectName,
            Body: objectData.body,
            ContentType: objectType
        };
        await storeInfo(uuid, objectData.body);
        await s3.putObject(params).promise(); 
        return sendRes(200, 'File uploaded successfully');
    } catch (error) {
        return sendRes(404, error);
    } 
};
const storeInfo = (uuid, xml) => {
    var jsObj = parser.parse(xml);
    var params = {
      TableName: 'risultati_gare',
      Item: {
        'id_gara' : {
            S: uuid
        },
        'event_name' : {
            S: jsObj.ResultList.Event.Name
        },
        'start' : {
            S: '' + jsObj.ResultList.Event.StartTime.Date + jsObj.ResultList.Event.StartTime.Time
        },
        'end' : {
            S: '' + jsObj.ResultList.Event.EndTime.Date + jsObj.ResultList.Event.EndTime.Time
        }
      }
    };
    
    // Call DynamoDB to add the item to the table
    db.putItem(params, function(err, data) {
      if (err) {
        console.log("Error", err);
      } else {
        console.log("Success", data);
      }
    });
}

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