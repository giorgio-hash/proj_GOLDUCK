const AWS = require('aws-sdk');
const db = new AWS.DynamoDB();

const crypto = require('crypto');

exports.handler = async (event, context, callback) => {
    var uuid = crypto.randomUUID();
    var token = crypto.randomBytes(8).toString('hex');

    var jsonResp = {
        "uuid": uuid,
        "token": token
    };

    try {
        await storeInfo(uuid, token, event.queryStringParameters);
        return sendRes(200, JSON.stringify(jsonResp));
    } catch (error) {
        return sendRes(404, error);
    }
};
const storeInfo = async (uuid, token, queryString) => {
    var params = {
        TableName: 'risultati_gare',
        Item: {
            'race_id': {
                S: uuid
            },
            'authToken': {
                S: token
            },
            'race_name': {
                S: queryString.race_name
            },
            'race_date': {
                S: queryString.race_date
            },
            'email': {
                S: queryString.email
            }
        }
    };

    // Call DynamoDB to add the item to the table
    return db.putItem(params, function (err, data) {
        if (err) {
            console.log("Error", err);
        } else {
            console.log("Success", data);
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