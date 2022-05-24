const AWS = require('aws-sdk');
const db = new AWS.DynamoDB();


exports.handler = async (event, context, callback) => {
    var results = await getRaceList();
    var unmarshalled = results.Items.map(function(elem) {
    
        return AWS.DynamoDB.Converter.unmarshall(elem);
    });
    
    if (results.Count == 0) {
        return sendRes(404, "No events found!"); 
    } else {
        return sendRes(200, JSON.stringify(unmarshalled));
    }
};

function getRaceList() {
    var params = {
        TableName: 'risultati_gare',
        ProjectionExpression: "race_id, race_name, race_date",
    };

    return db.scan(params, function(err, data) {
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