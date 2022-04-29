exports.handler = async (event,context,callback) => {
    // TODO implement
    if(event.headers.authorization != Buffer.from('pippo:ciao123').toString('base64'))
        {
            console.log("\n\n failed");
        
            callback("Unauthorized access",null);
            return sendRes("405", false);
            
        }
        
    console.log("\n\nAuth passed");
    return sendRes("200",true);
    
};

const sendRes = (status, auth) => {
        var response = {
            
            isAuthorized: auth
            
        };
        return response;
};