var fs = require('fs');
const convert = require('xml-js');

const args = process.argv.slice(2);

var maxTime = parseInt(args[0]);

const data = fs.readFileSync('./test-result.xml', 'utf8');

const options = {
    compact: true,
    ignoreComment: false,
    spaces: 2
};
const jsonData = JSON.parse(convert.xml2json(data, options));

jsonData.ResultList.ClassResult.forEach((classRes, index, obj) => {

    if (Array.isArray(classRes.PersonResult)) {
        obj[index].PersonResult
            .filter(person => person.Result.Time == null || parseInt(person.Result.Time["_text"]) > maxTime)
            .forEach(toRemove => obj[index].PersonResult.splice(obj[index].PersonResult.indexOf(toRemove), 1));
    } else {
        if (classRes.PersonResult.Result.Time != null) {
            if (parseInt(classRes.PersonResult.Result.Time["_text"]) > maxTime) {
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