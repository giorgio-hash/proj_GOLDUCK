exports.handler = async (event,context,callback) => {
    // TODO implement
     console.log("\n\nAuth: \n" + JSON.stringify(event.headers));
    
    if(event.headers.Authorization != Buffer.from('carmine:nduja69').toString('base64'))
        {
            console.log("\n\n failed");
            
            callback("Unauthorized",null);
            return sendRes("405",false);
            
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
