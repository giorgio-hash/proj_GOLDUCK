
var fxp = require('fast-xml-parser');
var fs = require('fs');

var parser = new fxp.XMLParser();

var maxTime = 10;

var res = fs.readFileSync( './test-result.xml', function(err, data) {
    xmlObj = parser.parse(data.toString('utf-8'));
    xmlObj.ResultList.ClassResult.forEach(res => {
        if (Array.isArray(res.PersonResult)){
            res.PersonResult.forEach(pers => {
                if(pers.Result.Time != null){
                    if(pers.Result.Time > maxTime) {
                        delete res.PersonResult;
                    }
                }
            })
        }else{
            if(res.PersonResult.Result.Time != null){
                if(res.PersonResult.Result.Time > maxTime) {
                    delete res.PersonResult;
                }
            }
        }
        
    });
    return xmlObj;
 });

 fs.writeFileSync("filtred.xml", res.toString('utf-8'), 'utf8', function (err) {
    if (err) {
        console.log("An error occured while writing XML String to File.");
        return console.log(err);
    }
 
    console.log("XML file has been saved.");
});

