var fs = require('fs');
const convert = require('xml-js');

const args = process.argv.slice(2);

const maxTime = parseInt(args[0]);

const data = fs.readFileSync('./test-result.xml', 'utf8');

const options = {
    compact: true,
    ignoreComment: false,
    spaces: 2
};
const jsonData = JSON.parse(convert.xml2json(data, options));

jsonData.ResultList.ClassResult.forEach(classRes => {
    if (Array.isArray(classRes.PersonResult)) {
        classRes.PersonResult
            .filter(person => person.Result.Time == null || parseInt(person.Result.Time["_text"]) > maxTime)
            .forEach(toRemove => classRes.PersonResult.splice(classRes.PersonResult.indexOf(toRemove), 1));
    } else {
        if (classRes.PersonResult.Result.Time != null) {
            if (parseInt(classRes.PersonResult.Result.Time["_text"]) > maxTime) {
                delete classRes.PersonResult;
            }
        } else {
            delete classRes.PersonResult;
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