
var fxp = require('fast-xml-parser');
var fs = require('fs');

var parser = new fxp.XMLParser();
var builder = new fxp.XMLBuilder({format: true});

var maxTime = 2005;

var data = fs.readFileSync( './test-result.xml');
var xmlObj = parser.parse(data.toString('utf-8'));

xmlObj.ResultList.ClassResult.forEach((classRes, index, obj) => {

    if (Array.isArray(classRes.PersonResult)) {
        obj[index].PersonResult
        .filter(person => person.Result.Time == null || person.Result.Time > maxTime)
        .forEach(toRemove => obj[index].PersonResult.splice(obj[index].PersonResult.indexOf(toRemove), 1));
    } else {
        if(classRes.PersonResult.Result.Time != null) {
            if(classRes.PersonResult.Result.Time > maxTime) {
                delete obj[index].PersonResult;
            }
        }else{
            delete obj[index].PersonResult;
        }
    }
});

var xmlStr = builder.build(xmlObj)

fs.writeFile("filtred.xml", xmlStr, 'utf8', function (err) {
    if (err) {
        console.log("An error occured while writing XML String to File.");
        return console.log(err);
    }
 
    console.log("XML file has been saved.");
});

