var fs = require('fs');
const convert = require('xml-js');

const maxTime = 2005;

var data = fs.readFileSync('./test-result.xml', 'utf8');

const options = {
    compact: true,
    ignoreComment: false,
    spaces: 2
};
const jsonData = JSON.parse(convert.xml2json(data, options));

jsonData.ResultList.ClassResult.forEach((classRes, index, obj) => {

    if (Array.isArray(classRes.PersonResult)) {
        obj[index].PersonResult
            .filter(person => person.Result.Time == null || person.Result.Time > maxTime)
            .forEach(toRemove => obj[index].PersonResult.splice(obj[index].PersonResult.indexOf(toRemove), 1));
    } else {
        if (classRes.PersonResult.Result.Time != null) {
            if (classRes.PersonResult.Result.Time > maxTime) {
                delete obj[index].PersonResult;
            }
        } else {
            delete obj[index].PersonResult;
        }
    }
});


var result = convert.json2xml(jsonData, options);

fs.writeFile("filtred.xml", result, 'utf8', function (err) {
    if (err) {
        console.log("An error occured while writing XML String to File.");
        return console.log(err);
    }
    console.log("XML file has been saved.");
});