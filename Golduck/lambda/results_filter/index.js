const AWS = require('aws-sdk');
const parser = require('xml-js');
const s3 = new AWS.S3();


exports.handler = async (event, context, callback) => {
    var id = event.queryStringParameters.id;
    var clazz = event.queryStringParameters.class;
    var org = event.queryStringParameters.organisation;

    var results = await getXml(id);

    if (results.Count != 0) {
        while (true) {
            try {
                var xml = JSON.parse(parser.xml2json(results.Body.toString('utf-8'), {
                    compact: true,
                    ignoreComment: false,
                    spaces: 2
                }));
                break;
            } catch (err) {
                results = await getXml(id);
            }
        }
        if (org != null) {
            var clubs = new Array();
            xml.ResultList.ClassResult.forEach(elem => {
                if (elem.PersonResult != null) {
                    if (Array.isArray(elem.PersonResult)) {
                        for (var pRes of elem.PersonResult) {
                            if (pRes.Organisation != null && pRes.Organisation.Name['_text'] == org)
                                clubs.push(pRes.Person.Name.Family['_text'] + ' ' + pRes.Person.Name.Given['_text']);
                        }

                    } else {
                        if (elem.PersonResult.Organisation != null && elem.PersonResult.Organisation.Name['_text'] == org)
                            clubs.push(elem.PersonResult.Person.Name.Family['_text'] + ' ' + elem.PersonResult.Person.Name.Given['_text']);
                    }
                }
            });
            return sendRes(200, JSON.stringify(clubs));
        } else if (clazz != null) {
            var classifica = new Array();

            for (var clazzRes of xml.ResultList.ClassResult) {
                if (clazzRes.Class.Name['_text'] != clazz)
                    continue;
                for (var pRes of clazzRes.PersonResult) {
                    classifica.push({
                        "name": pRes.Person.Name.Given['_text'],
                        "surname": pRes.Person.Name.Family['_text'],
                        "org": pRes.Organisation == null ? 'No Organisation' : pRes.Organisation.Name['_text'],
                        "position": pRes.Result.Position == null ? 'N/A' : pRes.Result.Position['_text'],
                        "time": pRes.Result.Time == null ? 'N/A' : pRes.Result.Time['_text']

                    });
                }
            }

            return sendRes(200, JSON.stringify(classifica));

        } else {
            return sendRes(404, "Invalid Request");
        }
    } else {
        return sendRes(404, "Invalid ID");
    }
};



function getXml(id) {

    var params = {
        Bucket: 'xmlres-1',
        Key: 'results-' + id + '.xml'
    };

    return s3.getObject(params, function (err, data) {
        if (err)
            console.log('Error', err);
        else
            return data;
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