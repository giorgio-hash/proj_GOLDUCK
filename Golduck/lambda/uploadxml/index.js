const AWS = require('aws-sdk');
const parser = require('xml-js');
const db = new AWS.DynamoDB();
const s3 = new AWS.S3();



exports.handler = async (event, context, callback) => {
    var token = event.queryStringParameters.token;
    var results = await getRaceId(token);

    if (results.Count != 1) {
        return sendRes(404, "Invalid Token");
    } else {
        //Validate XML
        try {
            parser.xml2json(event.body, {
                compact: true,
                ignoreComment: false,
                spaces: 2
            })
        } catch (error) {
            return sendRes(404, "Invalid XML");
        }
        //Upload XML
        try {
            const params = {
                Bucket: "xmlres",
                Key: "results-" + results.Items[0]['race_id']['S'] + ".xml",
                Body: event.body,
                ContentType: "application/xml"
            };

            await s3.putObject(params).promise();

            return sendRes(200, 'File uploaded successfully');
        } catch (error) {
            return sendRes(404, error);
        }
    }
};

function getRaceId(token) {
    var params = {
        TableName: 'risultati_gare',
        ProjectionExpression: "race_id",
        FilterExpression: "authToken = :tok",
        ExpressionAttributeValues: {
            ':tok': {
                'S': token
            },
        },
    };

    return db.scan(params, function (err, data) {
        if (err) {
            console.log("Error", err);
        } else {
            return data;
        }
    }).promise();

}



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