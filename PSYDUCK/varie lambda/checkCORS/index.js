exports.handler = async (event) => {
    // TODO implement
    
   
        return sendRes("200","preflight passata");
   
};


const sendRes = (status, body) => {
        var response = {
            statusCode: status,
            headers: {
                "Content-Type" : "application/json",
                "Access-Control-Allow-Headers" : "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,",
                "Access-Control-Allow-Methods" : "OPTIONS,POST,PUT",
                "Access-Control-Allow-Credentials" : true,
                "Access-Control-Allow-Origin" : "*",
                "X-Requested-With" : "*"
            },
            body: body
        };
        return response;
};