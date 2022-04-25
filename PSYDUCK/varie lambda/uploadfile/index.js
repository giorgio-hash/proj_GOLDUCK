const AWS = require('aws-sdk');
//const db = new AWS.DynamoDB();

const s3 = new AWS.S3();
const crypto = require('crypto');


exports.handler = async (event, context, callback) => {
    

    
    var uuid = crypto.randomUUID();
    const s3Bucket = "secchiellobello";
    const objectName = "results-" + uuid + ".xml";
    const objectData = event;
    const objectType = "textxml";
    try {
            const params = {
                Bucket: s3Bucket,
                Key: objectName,
                Body: objectData.body,
                ContentType: objectType
            };
        await storeId('1', uuid);
        await s3.putObject(params).promise(); 
        
        console.log("upload: success\n\n" + event);
        return sendRes(200, 'File uploaded successfully',true);
    } catch (error) {
        
        console.log("upload: fail\n\n" + error + "\n\n" + event);
        return sendRes(404, error,true);
    } 
    
    
};


const storeId = (id, uuid) => {
    var params = {
      TableName: 'risultati_gare',
      Item: {
        'id_gara' : {
            S: id
        },
        'uuid' : {
            S: uuid
        }
      }
    };
    
    // Call DynamoDB to add the item to the table
    /*db.putItem(params, function(err, data) {
      if (err) {
        console.log("Error", err);
      } else {
        console.log("Success", data);
      }
    });*/
}

const sendRes = (status, body) => {
        var response = {
            statusCode: status,
            headers: {
                "Content-Type" : "text/json",
                "Access-Control-Allow-Headers" : "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
                "Access-Control-Allow-Methods" : "OPTIONS,POST,PUT",
                "Access-Control-Allow-Credentials" : false,
                "Access-Control-Allow-Origin" : "*",
                "X-Requested-With" : "*"
            },
            body: body
        };
        return response;
};