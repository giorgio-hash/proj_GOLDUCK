const AWS = require('aws-sdk');
const s3 = new AWS.S3();

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
        
        return sendRes(200, results.Body.toString('utf-8'));
    }
    catch (error) {
        console.log(error);
        return sendRes(404, 'Invalid Id');
    }
};


const sendRes = (status, body) => {
    var response = {
        statusCode: status,
        headers: {
            "Content-Type" : "application/octet-stream",
            "Content-Disposition" : 'attachment; filename="results.xml"',
            "Access-Control-Allow-Headers" : "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
            "Access-Control-Allow-Credentials" : true,
            "Access-Control-Allow-Origin" : "*",
            "X-Requested-With" : "*"
        },
        body: body
    };
    return response;
};



